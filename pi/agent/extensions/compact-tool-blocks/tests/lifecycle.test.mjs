import assert from "node:assert/strict";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";
import { agent, tui } from "./runtime.mjs";

const entry = fileURLToPath(new URL("../index.ts", import.meta.url));
agent.initTheme("dark");
const original = agent.ToolExecutionComponent.prototype.render;
async function load(t) {
  const cwd = await mkdtemp(join(tmpdir(), "compact-tools-loader-"));
  t.after(() => rm(cwd, { recursive: true, force: true }));
  const loaded = await agent.discoverAndLoadExtensions([entry], cwd, join(cwd, "agent"));
  assert.deepEqual(loaded.errors, []);
  assert.equal(loaded.extensions.length, 1);
  return loaded.extensions[0];
}
const notices = [];
const ctx = { mode: "tui", hasUI: true, ui: { notify: (text, level) => notices.push({ text, level }) } };
async function emit(ext, name, context = ctx, reason = "startup") {
  for (const handler of ext.handlers.get(name) ?? []) await handler({ type: name, reason }, context);
}
function component() {
  return new agent.ToolExecutionComponent("probe", "id", {}, {}, {
    name: "probe", label: "Probe", parameters: {}, description: "test",
    renderCall: () => new tui.Text("title", 0, 0),
  }, { requestRender() {} }, "/tmp");
}

test("real bundled jiti loader shares host component; lifecycle/command/reload work", async (t) => {
  notices.length = 0;
  const ext = await load(t);
  t.after(() => emit(ext, "session_shutdown", ctx, "quit"));
  assert.equal(agent.ToolExecutionComponent.prototype.render, original, "factory must not patch before a TUI session");
  const existing = component();
  const before = existing.render(40);
  await emit(ext, "session_start");
  const wrapped = agent.ToolExecutionComponent.prototype.render;
  assert.notEqual(wrapped, original, "loader must patch the live host class, not a second import");
  const after = existing.render(40);
  assert.equal(after.length, before.length - 2);
  assert.equal(existing.contentBox.paddingY, 0);
  assert.equal(notices.length, 0, "normal startup should remain quiet");
  await emit(ext, "session_start");
  assert.equal(agent.ToolExecutionComponent.prototype.render, wrapped);
  const command = ext.commands.get("compact-tools");
  await command.handler("off", ctx);
  assert.deepEqual(existing.render(40), before);
  await command.handler("status", ctx);
  assert.match(notices.at(-1).text, /关闭/);
  await command.handler("", ctx);
  assert.deepEqual(existing.render(40), after);
  await command.handler("nonsense", ctx);
  assert.match(notices.at(-1).text, /用法/);
  await emit(ext, "session_shutdown", ctx, "reload");
  assert.equal(agent.ToolExecutionComponent.prototype.render, original);
  assert.deepEqual(existing.render(40), before);
  const reloaded = await load(t);
  t.after(() => emit(reloaded, "session_shutdown", ctx, "quit"));
  await emit(reloaded, "session_start", ctx, "reload");
  assert.deepEqual(existing.render(40), after);
  await emit(reloaded, "session_shutdown", ctx, "quit");
  assert.equal(agent.ToolExecutionComponent.prototype.render, original);
});

test("a second extension factory respects an already disabled shared patch", async (t) => {
  const a = await load(t);
  const b = await load(t);
  t.after(() => emit(a, "session_shutdown", ctx, "quit"));
  t.after(() => emit(b, "session_shutdown", ctx, "quit"));
  await emit(a, "session_start");
  await a.commands.get("compact-tools").handler("off", ctx);
  await emit(b, "session_start");
  const c = component(); c.render(40);
  assert.equal(c.contentBox.paddingY, 1);
  await emit(a, "session_shutdown", ctx, "quit");
  await emit(b, "session_shutdown", ctx, "quit");
  assert.equal(agent.ToolExecutionComponent.prototype.render, original);
});

test("print, JSON and RPC lifecycle/commands never patch host rendering", async (t) => {
  const ext = await load(t);
  for (const mode of ["print", "json", "rpc"]) {
    const other = { ...ctx, mode, hasUI: mode === "rpc" };
    await emit(ext, "session_start", other);
    await ext.commands.get("compact-tools").handler("on", other);
    assert.equal(agent.ToolExecutionComponent.prototype.render, original);
    await emit(ext, "session_shutdown", other, "quit");
  }
});
