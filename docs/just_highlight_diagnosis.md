# Just 文件高亮排查

日期：2026-09-22（东八区）。目标：`/Users/lihao/.config/dotfiles/justfile`。

## 方案与执行结果

1. 检查实际文件的类型、高亮状态和语法树。正常配置启动的 Neovim 识别为 `just`，Tree-sitter 高亮已启用，但语法树几乎整体落入 `ERROR`，注释和 recipe 等缺少正常捕获。
2. 缩小输入：`[unix]\nimport 'justfiles/justfile'\n` 可复现解析错误；单独的 import、recipe 上的 `[unix]` 均正常解析。
3. 对比三种假设：parser 不支持属性修饰 import、文件本身语法错误、后续内容还有不支持的语法。
4. 执行 `just --justfile /Users/lihao/.config/dotfiles/justfile --summary`，退出码为 0，正常列出任务。当前 Just CLI 接受该文件。
5. 仅在内存中移除第一行 `[unix]`，将其余完整内容交给同一 parser：`root:has_error()` 为 false，根节点有 47 个具名子节点。未修改目标文件。

## 结论

当前安装的 Just Tree-sitter parser 不支持此文件开头的 `[unix]` 修饰 import。解析错误影响后续内容的高亮；不是文件类型未识别，也不是 parser 未安装。

不能直接删除 `[unix]` 作为修复，因为它限定 import 的平台，会改变 Windows 上的行为。

## 修复与验证

1. 用户要求尝试修复。通过 `git ls-remote` 检查上游 HEAD 为 `5685543a6e64f66335e25518c9ae8ffa1dae3d01`，与本地 nvim-treesitter 指定版本相同；上游 `grammar.js` 的 import 规则仍不接受属性前缀，更新不能解决。
2. 添加 `tests/just_highlight_spec.lua`，覆盖带 `[unix]` 的 import 及后续注释、recipe。修复前失败：`1:2 expected Type, got`。
3. 在 `lua/plugins/theme.lua` 的高亮入口对 Just 停用 Tree-sitter，并设置 `syntax=just`，使用 Neovim 自带语法。其余文件类型沿用原逻辑，目标 justfile 未修改。
4. 测试中 import 的最终高亮组按当前主题链接结果修正为 `PreProc`。Just 高亮回归与现有 JavaScript 回归均通过。
5. 打开用户实际文件，确认 Tree-sitter 高亮未启用、syntax 为 just；第 1、2、4、7 行分别得到 `justRecipeAttr`、`justImportStatement`、`justComment`、`justFunction`。
6. `git diff --check` 通过。重启 Neovim 后生效。
7. 根据后续讨论，将传统语法高亮作为 Just 的长期配置，不以等待上游修复为前提。若将来需要依赖语法树的功能，再评估替代 parser 并用本次语法样例验证。
