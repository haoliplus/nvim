-- Run with the normal config: nvim --headless -i NONE "+luafile tests/treesitter_spec.lua" +qa
local root = vim.fn.getcwd()
vim.cmd.edit(root .. "/tests/fixtures/javascript_highlight.js")
local bufnr = vim.api.nvim_get_current_buf()
assert(vim.bo.filetype == "javascript", "fixture should be detected as JavaScript")
assert(vim.treesitter.highlighter.active[bufnr], "FileType should enable Tree-sitter highlighting")
local parser = vim.treesitter.get_parser(bufnr)
assert(not parser:parse()[1]:root():has_error(), "template strings and escaped quotes should parse")

local function assert_capture(row, col, expected)
  local captures = vim.treesitter.get_captures_at_pos(bufnr, row, col)
  for _, capture in ipairs(captures) do
    assert(capture.capture ~= "string", "string highlighting must not leak into subsequent code")
  end
  for _, capture in ipairs(captures) do
    if capture.capture == expected then
      return
    end
  end
  error("missing " .. expected .. " capture at row " .. row)
end

assert_capture(7, 2, "keyword.conditional")
assert_capture(8, 4, "keyword.return")
assert_capture(18, 0, "keyword")
assert_capture(20, 0, "keyword.function")
print("treesitter spec passed")
