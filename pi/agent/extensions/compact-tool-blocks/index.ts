import * as Pi from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Box, Text } from "@earendil-works/pi-tui";
import { installCompactToolBlocks } from "./patch.mjs";

export default function compactToolBlocks(pi: ExtensionAPI) {
  let patch: ReturnType<typeof installCompactToolBlocks> | undefined;
  let wanted = true;
  let failure: string | undefined;

  function start(ctx: ExtensionContext) {
    if (ctx.mode !== "tui" || patch) return;
    try {
      patch = installCompactToolBlocks({
        ToolExecutionComponent: Pi.ToolExecutionComponent,
        Box,
        Text,
        version: Pi.VERSION,
        enabled: wanted,
      });
      // Duplicate loads adopt the shared state instead of silently re-enabling it.
      wanted = patch.enabled;
      failure = undefined;
    } catch (error) {
      failure = error instanceof Error ? error.message : String(error);
      ctx.ui.notify(`compact-tool-blocks 未启用：${failure}`, "warning");
    }
  }

  pi.on("session_start", (_event, ctx) => start(ctx));
  pi.on("session_shutdown", () => {
    const active = patch;
    patch = undefined;
    active?.dispose();
  });

  pi.registerCommand("compact-tools", {
    description: "工具色块紧凑模式：/compact-tools [on|off|status]（无参数切换）",
    handler: async (args, ctx) => {
      if (ctx.mode !== "tui") {
        if (ctx.hasUI) ctx.ui.notify("compact-tools 仅适用于终端交互模式", "info");
        return;
      }
      const action = args.trim().toLowerCase();
      if (!["", "on", "off", "status"].includes(action)) {
        ctx.ui.notify("用法：/compact-tools [on|off|status]", "warning");
        return;
      }
      start(ctx);
      if (!patch) {
        if (failure) ctx.ui.notify(`紧凑模式不可用：${failure}`, "warning");
        return;
      }
      if (action !== "status") {
        wanted = action === "" ? !patch.enabled : action === "on";
        patch.setEnabled(wanted);
      }
      // notify() also schedules a render; no persistent widget or timer is required.
      ctx.ui.notify(`工具色块紧凑模式：${patch.enabled ? "开启" : "关闭"}`, "info");
    },
  });
}
