-- nvim --headless -i NONE "+luafile tests/just_highlight_spec.lua" +qa
vim.cmd.enew()
vim.api.nvim_buf_set_name(0, vim.fn.tempname() .. "/justfile")
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
  "[unix]",
  "import 'justfiles/justfile'",
  "",
  "# Show available commands.",
  "[unix]",
  "default:",
  "  echo hello",
})
vim.bo.modified = false
vim.cmd("filetype detect")
assert(vim.bo.filetype == "just", "fixture should be detected as Just")

local function assert_highlight(row, col, expected)
  local id = vim.fn.synID(row, col, 1)
  local group = vim.fn.synIDattr(vim.fn.synIDtrans(id), "name")
  assert(group == expected, string.format("%d:%d expected %s, got %s", row, col, expected, group))
end

assert_highlight(1, 2, "Type")
assert_highlight(2, 1, "PreProc")
assert_highlight(4, 1, "Comment")
assert_highlight(6, 1, "Function")
print("just highlight spec passed")
