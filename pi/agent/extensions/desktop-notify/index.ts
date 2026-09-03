import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import { StringEnum } from "@earendil-works/pi-ai";
import { Type } from "typebox";
import { join } from "node:path";

const TOOL_NAME = "desktop_notify";
const ICON_PATH = join(getAgentDir(), "extensions", "desktop-notify", "pi.svg");

const parameters = Type.Object({
  title: Type.Optional(Type.String({ minLength: 1, maxLength: 120 })),
  message: Type.String({ minLength: 1, maxLength: 2000 }),
  urgency: Type.Optional(StringEnum(["low", "normal", "critical"] as const)),
  timeout_ms: Type.Optional(Type.Integer({ minimum: 1000, maximum: 600000 })),
});

export default function desktopNotifyExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: TOOL_NAME,
    label: "Desktop Notify",
    description:
      "Send a local desktop notification with Pi's fixed icon. Accepts only a title, message, urgency, and timeout; it never invokes a shell or accepts executable/icon paths.",
    promptSnippet: "Send a local desktop notification with a fixed Pi icon",
    promptGuidelines: [
      "Use desktop_notify when the user explicitly asks for a local desktop notification or when a requested reminder becomes due.",
      "Do not use desktop_notify for ordinary chat replies or without clear user intent.",
    ],
    parameters,
    async execute(_toolCallId, params, signal) {
      const title = params.title ?? "Pi";
      const urgency = params.urgency ?? "normal";
      const timeoutMs = params.timeout_ms ?? 10000;

      const result = await pi.exec(
        "/usr/bin/notify-send",
        [
          "--app-name=Pi",
          `--icon=${ICON_PATH}`,
          `--urgency=${urgency}`,
          `--expire-time=${timeoutMs}`,
          "--",
          title,
          params.message,
        ],
        { signal, timeout: 5000 },
      );

      if (result.code !== 0) {
        const detail = (result.stderr || result.stdout || "unknown error").trim();
        throw new Error(`Desktop notification failed: ${detail}`);
      }

      return {
        content: [{ type: "text", text: `Desktop notification sent: ${title}` }],
        details: { title, urgency, timeoutMs },
      };
    },
  });
}
