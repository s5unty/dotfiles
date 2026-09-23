// Deliberately uses private presentation fields. Do not widen this list without tests.
export const TESTED_VERSIONS = Object.freeze(["0.87.1"]);
const PATCH = Symbol.for("compact-tool-blocks.patch.v1");

/** Change only tool-shell padding; never trim rendered lines or patch all Boxes. */
export function installCompactToolBlocks({ ToolExecutionComponent, Box, Text, version, enabled = true }) {
  if (!TESTED_VERSIONS.includes(version)) {
    throw new Error(`Pi ${version ?? "unknown"} is not supported; tested: ${TESTED_VERSIONS.join(", ")}`);
  }
  const proto = ToolExecutionComponent?.prototype;
  const descriptor = proto && Object.getOwnPropertyDescriptor(proto, "render");
  if (!descriptor?.writable || typeof descriptor.value !== "function" ||
      typeof proto.getRenderShell !== "function" || typeof proto.updateDisplay !== "function") {
    throw new Error("ToolExecutionComponent no longer has the expected rendering API");
  }
  // These fields are private in TypeScript, but ordinary writable properties in 0.87.1.
  for (const node of [new Box(1, 1), new Text("probe", 1, 1)]) {
    if (!Object.getOwnPropertyDescriptor(node, "paddingY")?.writable || node.paddingY !== 1 ||
        typeof node.invalidate !== "function" ||
        (node instanceof Box && typeof node.invalidateCache !== "function")) {
      throw new Error("Tool padding/cache internals have changed; leaving rendering untouched");
    }
  }

  let shared = Object.hasOwn(proto, PATCH) ? proto[PATCH] : undefined;
  // A dormant patch may be buried in another wrapper, or bypassed by a replacement.
  // Wrap the current method afresh rather than trusting an old marker on reload.
  if (!shared || shared.owners.size === 0) {
    const originalRender = descriptor.value;
    const owners = new Set();
    const snapshots = new Set();
    let byNode = new WeakMap();
    // Do not retain every tool component from a long-running or switched session.
    const collected = new FinalizationRegistry((record) => snapshots.delete(record));
    const invalidate = (node) => {
      // Box.invalidate() recursively invalidates children: avoid restarting custom renderers.
      if (node instanceof Box) node.invalidateCache();
      else node.invalidate();
    };
    function compact(node) {
      if (!(node instanceof Box || node instanceof Text) || node.paddingY !== 1) return;
      if (!byNode.has(node)) {
        const record = { ref: new WeakRef(node), paddingY: node.paddingY };
        byNode.set(node, record);
        snapshots.add(record);
        collected.register(node, record, record);
      }
      node.paddingY = 0;
      invalidate(node);
    }
    function restore() {
      const errors = [];
      for (const record of snapshots) {
        try {
          const node = record.ref.deref();
          // Do not overwrite a later extension's intentional change to a different value.
          if (node?.paddingY === 0) {
            node.paddingY = record.paddingY;
            invalidate(node);
          }
        } catch (error) {
          errors.push(error);
        } finally {
          collected.unregister(record);
        }
      }
      snapshots.clear();
      byNode = new WeakMap();
      if (errors.length) throw new AggregateError(errors, "Some tool caches could not be invalidated during restoration");
    }
    shared = { owners, enabled: Boolean(enabled), restore, patchedRender: undefined };
    shared.patchedRender = function (...args) {
      if (shared.enabled && owners.size > 0) {
        // Check instance shape too, so an unrelated subclass is not modified accidentally.
        if (this.contentBox instanceof Box && this.contentText instanceof Text) {
          if (!this.toolDefinition) {
            compact(this.contentText);
          } else if (this.getRenderShell() === "default") {
            compact(this.contentBox);
          } else if (this.toolName === "edit") {
            // Built-in edit owns its shell. Leave arbitrary third-party self shells alone.
            const call = this.callRendererComponent;
            if (call instanceof Box && this.rendererState?.callComponent === call &&
                ["preview", "previewArgsKey", "previewPending", "settledError"].every(
                  (key) => Object.hasOwn(call, key),
                )) compact(call);
          }
        }
      }
      // Original code still owns spacers, colors, images, expansion, and mouse layout.
      return originalRender.apply(this, args);
    };
    shared.originalDescriptor = descriptor;
    Object.defineProperty(proto, PATCH, { value: shared, configurable: true });
    Object.defineProperty(proto, "render", { ...descriptor, value: shared.patchedRender });
  }

  const owner = Symbol("compact-tool-blocks owner");
  shared.owners.add(owner);
  let disposed = false;
  return {
    get enabled() { return !disposed && shared.enabled; },
    setEnabled(enabled) {
      if (disposed) return;
      shared.enabled = Boolean(enabled);
      if (!shared.enabled) shared.restore();
    },
    dispose() {
      if (disposed) return;
      disposed = true;
      shared.owners.delete(owner);
      if (shared.owners.size !== 0) return;
      shared.enabled = false;
      try {
        shared.restore();
      } finally {
        // Preserve wrappers installed by another extension after this one.
        if (proto.render === shared.patchedRender) {
          Object.defineProperty(proto, "render", shared.originalDescriptor);
          delete proto[PATCH];
        }
      }
      // Otherwise leave the wrapper dormant; the next load wraps the current method.
    },
  };
}
