-- 复制为同目录的 env.local.lua，再按需修改每行 or 后的默认值。
-- env.local.lua 已被 Git 忽略；此示例文件可纳入版本控制。
-- 重启 Neovim 后生效，仅影响 Neovim 及随后启动的子进程。
-- 已有非空环境变量优先；nil 表示未提供本地默认值。
-- 当前 Neovim 的 vim.env 将空值读作 nil，因此空值也会使用默认值。
-- 在私有文件中将 nil 替换成字符串即可，例如：
-- vim.env.NICKNAME = vim.env.NICKNAME or "your-name"

-- 一、用户 / 本仓库约定的变量（包括用来配置插件的变量）
-- 这些名称由本仓库选择；不是仅凭 NVIM_ 前缀或插件用途就归为原生变量。

-- 模板作者信息：lua/setup.lua、lua/init.lua；MAIL 在这里用作作者邮箱。
vim.env.NICKNAME = vim.env.NICKNAME or nil
vim.env.MAIL = vim.env.MAIL or nil
vim.env.LICENSE = vim.env.LICENSE or nil


-- 用户指定名称、插件读取：lua/plugins/minute.lua 将 "CPA_API_KEY" 配给 Minuet。
-- Minuet 按 api_key 配置读取同名环境变量；CPA_API_KEY 并非插件固定名称。
vim.env.CPA_API_KEY = vim.env.CPA_API_KEY or nil

-- 网络工具通用代理变量：供子进程使用，实际支持情况取决于具体工具。
vim.env.HTTP_PROXY = vim.env.HTTP_PROXY or nil
vim.env.HTTPS_PROXY = vim.env.HTTPS_PROXY or nil
vim.env.NO_PROXY = vim.env.NO_PROXY or nil
