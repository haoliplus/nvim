
Relative path of script file:
`let s:path = expand('<sfile>')`

Absolute path of script file:
`let s:path = expand('<sfile>:p')`

Absolute path of script file with symbolic links resolved:
`let s:path = resolve(expand('<sfile>:p'))`

Folder in which script resides: (not safe for symlinks)
`let s:path = expand('<sfile>:p:h')`

## 关闭 buffer 和消息

普通模式下，`;bd` 关闭当前 buffer（未保存时询问），`;bD` 强制关闭并丢弃修改，`;c` 按顶部字母选择要关闭的 buffer。

普通模式按 `Esc` 关闭 Noice 消息，也可以执行 `:Noice dismiss`。插入模式先按一次 `Esc` 回到普通模式，再按一次关闭消息。

2026-09-17（东八区）修复记录：

- 方案：修正 `lua/plugins/message.lua` 的 `keys` 嵌套结构，使 `Esc` 正确绑定消息关闭命令。
- 执行：将映射放入独立子表，绑定到 `:Noice dismiss`。
- 验证：使用无配置的 headless Neovim 加载配置表，经本机 lazy.nvim 的映射解析器解析，确认仅生成一条普通模式 `Esc` 映射，并验证 Neovim 注册的命令和 silent 属性正确；检查通过。
- 结论：映射结构已修复，重启 Neovim 后生效；弹窗实际显示和关闭尚未进行交互验证。
