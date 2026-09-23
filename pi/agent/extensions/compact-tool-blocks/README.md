# compact-tool-blocks

为 Pi 工具色块移除上下各一行内边距；保留色块之间的空行、左右边距、颜色、正文空行和图片间距。

## 试用

```bash
pi -e /tmp/compact-tool-blocks/index.ts
```

`/tmp` 是临时目录，重启或清理后可能消失。永久使用时，在你自己的终端中复制整个目录（不要只复制 `index.ts`）：

```bash
mkdir -p ~/.pi/agent/extensions
cp -R /tmp/compact-tool-blocks ~/.pi/agent/extensions/compact-tool-blocks
```

若目标目录已存在，请先检查、备份，不要直接重复执行复制。然后在 Pi 中运行 `/reload`，或重启 Pi。不要同时以 `-e` 和自动发现两种方式加载两份副本。

当前开发沙箱对 `~/.pi/agent` 只读，开发过程没有在该目录安装，也没有修改 Pi 安装文件。

## 开关

默认开启。

- `/compact-tools`：切换。
- `/compact-tools on` / `/compact-tools off`：开启 / 关闭。
- `/compact-tools status`：显示状态。

开关只保存在本次扩展运行期间，重新加载扩展或重启后恢复默认开启。仅在终端交互模式生效；不改工具执行、模型上下文、RPC、JSON、打印输出或 HTML 导出。

## 实现与边界

- 使用宿主导出的 `ToolExecutionComponent`，只包装该组件的 `render()`；不深层导入另一份 Pi，也不全局修改 `Box` / `Text`。
- 将默认工具包装（包含第三方工具使用的默认包装）及无工具定义的 fallback 包装的 `paddingY` 从 `1` 改为 `0`。
- 单独识别内置 `edit` 的自绘 Box，保留标题和 diff 之间的分隔行。
- 不裁剪最终行数组：正文中的有意空行、图片序列与鼠标坐标继续由原组件计算。
- 不处理其他第三方 `renderShell: "self"` 自绘色块，也不处理其自定义内容内部的 padding。
- 不修改用户消息、助手消息、输入框或用户手动执行 `!command` 的组件。
- 缓存按需失效；关闭、卸载和扩展生命周期结束时恢复仍存活的组件。弱引用不会保留整段历史会话。
- 重复加载不会叠加渲染包装，关闭时不会覆盖其他扩展之后安装的渲染包装。

这不是官方 padding 配置，而是一个局部运行时补丁。依赖的内部字段目前仅允许 **Pi 0.87.1**。其他版本自动拒绝启用并显示提示，不应未经验证直接扩大版本白名单。即使版本相同，与其他 UI 补丁组合使用也需要检查。

## 卸载

先 `/compact-tools off`，再移走 `~/.pi/agent/extensions/compact-tool-blocks` 并 `/reload`，或退出 Pi 后移走该目录再重启。已滚入终端历史、脱离 Pi 当前可重绘区域的旧输出，不保证能重新排版。

## 测试

测试代码位于 `tests/`；运行方式和实际验证结果见 `TESTING.md`。
