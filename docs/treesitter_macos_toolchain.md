# macOS Tree-sitter 编译错误排查

日期：2026-09-22（东八区）。

## 方案

先以最小动态库复现链接错误，再比较 SDK 和工具链选择，最后用真实 regex parser 编译、加载和解析验证。用户确认仅修改 nvim 配置。

## 执行记录

1. 用 `cc -dynamiclib` 编译仅含 `int main(void) { return 0; }` 的 C 文件，复现 `libSystem.B.tbd` 的 `unknown architecture arm64e.x1-macos`。
2. `xcode-select -p` 指向 `/Applications/Xcode.app/Contents/Developer`；clang 版本为 `2100.1.1.101`。`cc -###` 显示使用 Xcode 的 clang/ld，但 SDK 为 `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk`（27.0）。
3. 清除 `SDKROOT` 后仍失败，排除仅由该环境变量引起的问题。
4. 显式指定 Xcode 自带 SDK，最小编译成功。
5. 设置 `DEVELOPER_DIR=/Library/Developer/CommandLineTools`，最小编译成功。该工具链 clang 版本为 `2100.3.34.2`。
6. 使用已安装的 Mason tree-sitter CLI 和缓存的 regex 源码：默认环境复现原错误；仅切换 `DEVELOPER_DIR` 后成功生成 `/tmp/nvim-regex-after.so`。两次均设置 `XDG_CACHE_HOME=/tmp/nvim-treesitter-check`，避开沙箱外缓存写入。
7. Neovim 使用编译出的 regex parser 解析 `[a-z]+`，加载和解析成功。
8. 尝试 `tests/treesitter_bootstrap_spec.lua`，因 Mason registry refresh 失败而中止，未完成全新依赖安装与高亮回归；该结果不能作为编译修复失败的证据。
9. 在 `lua/init.lua` 的平台识别之后、插件加载之前设置 `vim.env.DEVELOPER_DIR`。仅在 macOS 且 Command Line Tools 目录存在时启用，作用于 nvim 及其子进程。
10. 使用正常配置启动 headless nvim，断言环境变量已设置并等待 parser 安装结束：javascript、jsdoc、regex 均下载、编译、安装成功；随后执行 `tests/treesitter_spec.lua`，输出 `treesitter spec passed`，进程退出码为 0。
11. `git diff --check` 通过。系统的 `xcode-select` 设置未修改。

## 结论

根因是 Xcode 工具链与较新的 Command Line Tools SDK 混用。已在 nvim 启动入口固定使用 Command Line Tools，正常配置下三种 parser 的安装和 JavaScript 高亮回归通过。该设置也会被 nvim 启动的终端及其他构建子进程继承。全新 Mason 安装测试仍保留第 8 步的限制；它使用 `-u NONE`，不加载本次修改的启动入口。

重启 nvim 即可生效，无需额外启动参数。若需手动重装 parser：

```vim
:TSInstall javascript jsdoc regex
```
