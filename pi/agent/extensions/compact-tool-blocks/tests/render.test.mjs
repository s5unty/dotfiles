import assert from "node:assert/strict";
import { test } from "node:test";
import { stripVTControlCharacters } from "node:util";
import { installCompactToolBlocks } from "../patch.mjs";
import { agent, tui } from "./runtime.mjs";

const { ToolExecutionComponent, VERSION, initTheme, createEditToolDefinition } = agent;
const { Box, Text, Container, Spacer } = tui;
initTheme("dark");
const ui = { requestRender() {} };
const deps = { ToolExecutionComponent, Box, Text, version: VERSION };
const plain = (lines) => lines.map((line) => stripVTControlCharacters(line).trimEnd());
const definition = {
  name: "custom", label: "Custom", description: "test", parameters: {},
  renderCall: () => new Text("Tool title 中文", 0, 0),
  renderResult: (_result, options) => new Text(options.expanded ? "first\n\nlast" : "summary", 0, 0),
};
function tool(def = definition, name = "custom") {
  return new ToolExecutionComponent(name, "id", {}, { showImages: false }, def, ui, "/tmp");
}
function done(c, isError = false) {
  c.updateResult({ content: [{ type: "text", text: "output" }], details: {}, isError });
}
function install(t) {
  const patch = installCompactToolBlocks(deps);
  t.after(() => patch.dispose());
  return patch;
}

test("default shell removes exactly its two padded rows, retains spacer and ANSI content", (t) => {
  for (const width of [12, 40, 100]) {
    const c = tool();
    done(c);
    const before = c.render(width);
    const patch = install(t);
    const after = c.render(width);
    assert.deepEqual(after, [before[0], ...before.slice(2, -1)]);
    assert.equal(after[0], "");
    assert.match(after[1], /\x1b\[/);
    assert.equal(c.contentBox.paddingX, 1);
    patch.dispose();
    assert.deepEqual(c.render(width), before);
  }
});

test("pending, streaming, success and error backgrounds survive unchanged", (t) => {
  const patch = install(t);
  for (const state of ["pending", "streaming", "success", "error"]) {
    const c = tool();
    if (state !== "pending") c.updateResult({ content: [{ type: "text", text: "output" }], isError: state === "error" }, state === "streaming");
    patch.setEnabled(false);
    const before = c.render(50);
    patch.setEnabled(true);
    assert.deepEqual(c.render(50), [before[0], ...before.slice(2, -1)]);
  }
});

test("fallback, cached renders, on/off and disposal restore exactly", (t) => {
  // tool(undefined) would use the JS default argument, so construct explicitly.
  const c = new ToolExecutionComponent("unknown", "id", { x: 1 }, {}, undefined, ui, "/tmp");
  done(c);
  const before = c.render(50);
  const patch = install(t);
  const after = c.render(50);
  assert.deepEqual(after, [before[0], ...before.slice(2, -1)]);
  assert.deepEqual(c.render(50), after);
  patch.setEnabled(false);
  assert.equal(c.contentText.paddingY, 1);
  assert.deepEqual(c.render(50), before);
  patch.setEnabled(true);
  assert.deepEqual(c.render(50), after);
  patch.dispose();
  assert.deepEqual(c.render(50), before);
  patch.dispose();
});

test("expanded body blank lines and click-to-expand mouse coordinates are preserved", (t) => {
  install(t);
  const c = tool();
  done(c);
  const lines = c.render(50);
  assert.equal(plain(lines)[2], " summary");
  const event = { type: "click", button: "left", x: 1, y: 2, width: 50, height: lines.length };
  assert.equal(c.handleMouse(event)?.handled, true);
  assert.deepEqual(plain(c.render(50)), ["", " Tool title 中文", " first", "", " last"]);
});

test("built-in edit self shell loses only outside padding and keeps title/diff separator", (t) => {
  const c = tool(createEditToolDefinition("/tmp"), "edit");
  c.updateArgs({ path: "/tmp/nonexecuted.txt", edits: [{ oldText: "old", newText: "new" }] });
  c.updateResult({ content: [{ type: "text", text: "ok" }], details: { diff: "-1 old\n+1 new", firstChangedLine: 1 }, isError: false });
  const before = c.render(60);
  const patch = install(t);
  const after = c.render(60);
  assert.deepEqual(after, [before[0], ...before.slice(2, -1)]);
  assert.equal(plain(after)[2], "");
  assert.equal(c.callRendererComponent.paddingY, 0);
  assert.equal(c.selfRenderHeight, after.length - 1);
  assert.equal(c.handleMouse({ type: "click", button: "left", x: 2, y: 1, width: 60, height: after.length })?.handled, true);
  patch.dispose();
  assert.deepEqual(c.render(60), before);
});

test("third-party self shell and unrelated boxes/text are untouched", (t) => {
  const self = { ...definition, renderShell: "self", renderCall: () => {
    const box = new Box(1, 1); box.addChild(new Text("private shell", 0, 0)); return box;
  } };
  const c = tool(self);
  const editOverride = tool(self, "edit");
  const box = new Box(1, 1); box.addChild(new Text("ordinary", 0, 0));
  const text = new Text("user message", 1, 1);
  const objects = [c, editOverride, box, text];
  const before = objects.map((v) => v.render(40));
  install(t);
  assert.deepEqual(objects.map((v) => v.render(40)), before);
});

test("tool spacing and image spacer/components remain intact", (t) => {
  const c = tool(); done(c);
  // Inject a deterministic image component: no terminal image protocol or real image needed.
  const image = { render: () => ["IMAGE-PROTOCOL-PLACEHOLDER"], invalidate() {} };
  const spacer = new Spacer(1);
  c.imageComponents = [image]; c.imageSpacers = [spacer];
  c.addChild(spacer); c.addChild(image);
  const before = c.render(40);
  install(t);
  const after = c.render(40);
  assert.deepEqual(after, [before[0], ...before.slice(2, -3), ...before.slice(-2)]);
  assert.deepEqual(after.slice(-2), ["", "IMAGE-PROTOCOL-PLACEHOLDER"]);
  const a = tool(), b = tool(); done(a); done(b);
  const group = new Container(); group.addChild(a); group.addChild(b);
  assert.deepEqual(plain(group.render(50)), ["", " Tool title 中文", " summary", "", " Tool title 中文", " summary"]);
});

test("hidden renderer stays hidden, repeated install/reload does not stack wrappers", (t) => {
  const hidden = tool({ ...definition, renderShell: "self", renderCall: () => new Container(), renderResult: () => new Container() });
  assert.deepEqual(hidden.render(40), []);
  const original = ToolExecutionComponent.prototype.render;
  const first = install(t);
  const wrapped = ToolExecutionComponent.prototype.render;
  const second = install(t);
  assert.equal(ToolExecutionComponent.prototype.render, wrapped);
  assert.deepEqual(hidden.render(40), []);
  first.dispose();
  assert.equal(ToolExecutionComponent.prototype.render, wrapped);
  second.dispose();
  assert.equal(ToolExecutionComponent.prototype.render, original);
  const third = install(t);
  const c = tool(); c.render(40);
  assert.equal(c.contentBox.paddingY, 0);
  third.dispose();
  assert.equal(c.contentBox.paddingY, 1);
});

test("later third-party render wrappers and deliberate padding changes are not overwritten", (t) => {
  const original = ToolExecutionComponent.prototype.render;
  t.after(() => { ToolExecutionComponent.prototype.render = original; });
  const patch = install(t);
  const own = ToolExecutionComponent.prototype.render;
  const outer = function (...args) { return own.apply(this, args); };
  ToolExecutionComponent.prototype.render = outer;
  const c = tool(); c.render(40);
  c.contentBox.paddingY = 2;
  patch.dispose();
  assert.equal(ToolExecutionComponent.prototype.render, outer);
  assert.equal(c.contentBox.paddingY, 2);
  const again = install(t);
  const fresh = tool(); fresh.render(40);
  assert.equal(fresh.contentBox.paddingY, 0);
  again.dispose();
  assert.equal(fresh.contentBox.paddingY, 1);
  assert.equal(ToolExecutionComponent.prototype.render, outer);
});

test("reload wraps a later replacement even when it bypasses the old chain", (t) => {
  const original = ToolExecutionComponent.prototype.render;
  t.after(() => { ToolExecutionComponent.prototype.render = original; });
  const first = install(t);
  const replacement = function (...args) { return original.apply(this, args); };
  ToolExecutionComponent.prototype.render = replacement;
  first.dispose();
  assert.equal(ToolExecutionComponent.prototype.render, replacement);
  const second = install(t);
  const c = tool(); c.render(40);
  assert.equal(c.contentBox.paddingY, 0);
  second.dispose();
  assert.equal(c.contentBox.paddingY, 1);
  assert.equal(ToolExecutionComponent.prototype.render, replacement);
});

test("duplicate installer adopts disabled state rather than resetting it", (t) => {
  const first = install(t);
  first.setEnabled(false);
  const second = install(t);
  assert.equal(second.enabled, false);
  const c = tool(); c.render(40);
  assert.equal(c.contentBox.paddingY, 1);
  second.setEnabled(true);
  assert.equal(first.enabled, true);
});

test("one throwing cache invalidator cannot prevent remaining restoration or unpatching", (t) => {
  const original = ToolExecutionComponent.prototype.render;
  const patch = install(t);
  const a = tool(), b = tool(); a.render(40); b.render(40);
  a.contentBox.invalidateCache = () => { throw new Error("third-party invalidator failed"); };
  assert.throws(() => patch.dispose(), /Some tool caches/);
  assert.equal(a.contentBox.paddingY, 1);
  assert.equal(b.contentBox.paddingY, 1);
  assert.equal(ToolExecutionComponent.prototype.render, original);
});

test("unknown versions and incompatible prototype fail without modifying render", () => {
  const original = ToolExecutionComponent.prototype.render;
  assert.throws(() => installCompactToolBlocks({ ...deps, version: "0.88.0" }), /not supported/);
  assert.equal(ToolExecutionComponent.prototype.render, original);
  assert.throws(() => installCompactToolBlocks({ ...deps, ToolExecutionComponent: class {} }), /expected rendering API/);
});
