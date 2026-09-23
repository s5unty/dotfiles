# 验证记录

## 环境与运行

使用 Node 24.20.0、隔离安装的真实 `@earendil-works/pi-coding-agent@0.87.1`。安装目录、npm 缓存、测试 agent 目录均在 `/tmp`，未修改宿主安装或 `~/.pi/agent`。

```bash
npm install --prefix /tmp/compact-tool-blocks-test-runtime \
  --cache /tmp/compact-tool-blocks-npm-cache \
  --ignore-scripts --no-audit --no-fund \
  @earendil-works/pi-coding-agent@0.87.1

PI_CODING_AGENT_DIR=/tmp/compact-tool-blocks-test-agent \
PI_TEST_PACKAGE_DIR=/tmp/compact-tool-blocks-test-runtime/node_modules/@earendil-works/pi-coding-agent \
node --test /tmp/compact-tool-blocks/tests/*.test.mjs
```

`PI_TEST_PACKAGE_DIR` 必须是有依赖链接、可运行的 Pi 包目录；仅有内容文件的 pnpm store 包目录不足以运行测试。

## 结果

**16 项通过，0 失败，0 跳过。** `index.ts` 和 `patch.mjs` 也通过 Node 语法检查。

1. 默认色块精确减少两行；原 ANSI 色彩、左右边距与外部 spacer 不变；覆盖窄屏、中文和不同宽度。
2. pending / streaming / success / error 状态保持原背景。
3. 无工具定义 fallback、重复缓存渲染、开关和卸载恢复。
4. 展开正文保留内部空行，鼠标点击能正常展开。
5. 内置 `edit` 自绘色块及 diff 分隔空行、点击行为。
6. 第三方 self renderer 和非工具 Box / Text 不变。
7. 工具之间间距、图片组件与图片 spacer 不变。
8. 空 self renderer 保持隐藏；重复安装、卸载不叠加包装。
9. 不覆盖其他扩展后加的 render 包装和不同值的 padding 修改。
10. 未支持版本、缺失 API 时拒绝安装，不修改 render。
11. 真实 bundled jiti 加载 `index.ts`；确认补丁作用于宿主同一个类；验证 session 生命周期、命令与重载。
12. print / JSON / RPC 模式不安装补丁。
13. 第三方完全替换 render、绕过旧包装后，重新加载可以正常安装新补丁。
14. 重复调用安装函数不会将已关闭的共享补丁重新开启。
15. 单个缓存失效函数抛错时，仍恢复其他组件并移除补丁，再上报错误。
16. 通过真实加载器加载第二份扩展工厂时，也尊重现有的关闭状态。

## 范围限制

- 使用真实 Pi 组件和真实扩展加载器；生命周期上下文中的通知函数为测试替身。
- 图片测试采用占位组件验证布局，不测试实际 Kitty/iTerm2 图像传输。
- 没有执行 LLM 请求，也没有执行真实 read/edit 等工具操作。
- 未在用户当前终端里手动进行截图对比，也未覆盖所有第三方 UI 扩展的组合。
- 这不代表其他 Pi 版本兼容；版本白名单保持 `0.87.1`。
