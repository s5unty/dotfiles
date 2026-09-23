import { readdir } from "node:fs/promises";
import { join, resolve } from "node:path";
import { pathToFileURL } from "node:url";

// Test with a real installed Pi bundle, not a reimplementation of its components.
// It must have resolvable dependencies (the isolated pnpm content-store directory alone does not).
const root = process.env.PI_TEST_PACKAGE_DIR;
if (!root) throw new Error("Set PI_TEST_PACKAGE_DIR to a runnable Pi 0.87.1 package directory; see TESTING.md");
export const packageRoot = resolve(root);
export const agent = await import(pathToFileURL(join(packageRoot, "dist/bundle/index.js")).href);
const chunks = join(packageRoot, "dist/bundle/chunks");
const virtualFile = (await readdir(chunks)).find((file) => /^virtual-modules-.*\.js$/.test(file));
if (!virtualFile) throw new Error("Pi bundle virtual modules were not found");
const { VIRTUAL_MODULES } = await import(pathToFileURL(join(chunks, virtualFile)).href);
export const tui = VIRTUAL_MODULES["@earendil-works/pi-tui"];
