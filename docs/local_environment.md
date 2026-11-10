# 本地环境变量配置

## 方案

- 私有文件固定为 `init.vim` 同目录的 `env.local.lua`，不依赖启动工作目录。
- `init.vim` 检查文件是否可读，可读时加载，不存在时跳过。
- 加载发生在 `require('init')` 之前，让启动配置和插件能够读取变量。
- `.gitignore` 忽略根目录的私有文件；仓库保留加载逻辑、示例和使用说明。
- `env.local.example.lua` 是可纳入版本控制的模板，手动复制为 `env.local.lua`
  后使用；每项优先使用已有环境变量，再使用 `or` 后的本地默认值。
- 未提供默认值的可选项使用 `nil`，不伪造凭据、作者信息或机器路径；当前
  Neovim 的 `vim.env` 将空值读为 `nil`，因此空值也使用默认值。
  示例覆盖当前 Lua/Vim 配置直接读取及明确传给插件的变量，
  包括 legacy 配置和禁用的启动面板，不枚举依赖库隐式支持的全部变量。
- 文件使用 `vim.env.NAME = "value"`，不解析 shell 或 dotenv 格式。

## 变量归属

按当前仓库的接入方式分类，同时说明谁读取变量。用于配置插件不等于插件定义了
这个变量名；沿用服务商常见名称也不代表插件会自动读取它。

| 分类 | 变量 | 当前读取方 / 约定来源 |
| --- | --- | --- |
| 用户 / 本仓库 | `NICKNAME`、`MAIL`、`LICENSE` | `setup.lua` 和模板配置；`MAIL` 在此用作作者邮箱，区别于 shell 中常见的邮箱文件路径含义 |
| 用户 / 本仓库 | `VIM_CONFIG_DIR`、`NVIM_LSP_CLANGD_CMD` | 启动配置、SetupInit 与 LSP 配置；不是 Neovim 原生变量 |
| 用户 / 本仓库 | `NVIM_BIN`、`NVIM_SETUP_LOCKFILE` | 仓库自己的初始化脚本，`NVIM_` 前缀不表示原生支持 |
| 用户为插件指定 | `CPA_API_KEY` | 配置将变量名交给 Minuet，Minuet 按该名称读取环境 |
| 用户为插件指定 | `OPENROUTER_API_KEY`、`DEEPSEEK_API_KEY`、`VOLCENGINE_API_KEY`、`AIDOKI_AUTH_TOKEN` | legacy 配置读取后，将值传给 Parrot、aice_craft 或 CodeCompanion 参数 |
| Neovim 原生 | `VIMINIT` | Neovim 启动入口；加载私有文件前已读取，示例只保留注释 |
| Neovim 历史原生 | `NVIM_TUI_ENABLE_TRUE_COLOR` | 旧版真彩色变量；当前应使用 `termguicolors`，保留此项仅因仓库仍写入它 |
| 插件固定名称接口 | 本次清单没有独立项 | 当前显式配置的密钥均由用户选择名称或由仓库读值传参，不枚举未使用的插件默认 provider |
| 系统共享 | `HOME`、`PATH`、`XDG_CONFIG_HOME` | 系统 / XDG 约定，Neovim 也原生读取；不属于 Neovim 独有变量 |
| 外部工具 | `VIRTUAL_ENV`、`DEVELOPER_DIR` | Python 虚拟环境、Apple 工具链；本仓库读取或提供默认值 |
| 外部工具展示 | `ANTHROPIC_AUTH_TOKEN`、`ANTHROPIC_MODEL`、`ANTHROPIC_FAST_MODEL`、`ANTHROPIC_SMALL_FAST_MODEL`、`ANTHROPIC_BASE_URL` | 禁用的启动面板展示 Claude 相关环境；不是 dashboard-nvim 定义的接口，不保证外部工具当前版本支持全部名称 |
| 网络工具共享 | `HTTP_PROXY`、`HTTPS_PROXY`、`NO_PROXY` | 可选子进程代理，具体行为由网络工具决定 |

依据：仓库读取位置、已安装 Minuet 的 `get_api_key` 实现，以及 Neovim 官方
[启动说明](https://neovim.io/doc/user/starting/)、
[历史真彩色说明](https://neovim.io/news/2015/04/)与
[当前 termguicolors 选项](https://neovim.io/doc/user/options/#'termguicolors')。

## 执行记录

- 2026-11-10（东八区）：检查启动入口，原配置没有提前加载私有环境变量文件的逻辑。
- 已添加可选加载逻辑、Git 忽略规则及 README 使用说明。
- 验证通过：在包含空格的临时目录复制实际 `init.vim`，使用 Neovim headless
  加载；以占位 `init` 模块记录读取时机，未加载完整插件配置。
  私有文件不存在时正常跳过；存在时变量在 `require('init')` 前生效。
- 验证通过：Neovim 启动的 `printenv` 子进程继承新值，父 shell 保持原值。
- 验证通过：`git check-ignore env.local.lua` 命中忽略规则；`git diff --check`
  未发现空白问题。未添加单元测试文件。
- 2026-11-10（东八区）：添加 `env.local.example.lua`，包含自定义变量、代理及
  PATH 示例，README 补充复制命令。
- 示例验证通过：Neovim headless 可解析并执行；模板未被 Git 忽略，私有文件
  仍被忽略；`git diff --check` 通过。
- 2026-11-10（东八区）：扫描 `init.vim`、`lua/` 和 SetupInit 脚本，补齐模板
  变量；检查已安装 Minuet 的 `get_api_key`，确认 `CPA_API_KEY` 是环境变量名。
- 将原配置对 `DEVELOPER_DIR` 和 `NVIM_TUI_ENABLE_TRUE_COLOR` 的强制赋值改为
  缺省赋值，避免启动后覆盖继承值或私有文件中的设置。
- 初次验证发现空环境值经 `vim.env` 读取为 `nil`，与 Lua 空字符串本身为真值
  的规则不同；据本机 Neovim 实测修正示例和文档中的空值语义。
- 最终验证通过：Neovim headless 检查 26 个赋值项的继承值优先、空值及缺失值
  回退、本地默认值可修改；执行实际主题配置验证颜色变量优先级，并在隔离的
  macOS 平台条件下执行启动配置前段验证工具链变量优先级。未在 macOS 实机
  执行编译，也未运行完整插件启动。Lua 语法、Git 忽略规则和差异空白检查通过。
- 2026-11-10（东八区）：根据变量接入约定重新分组并逐项标注消费者；单列
  系统 / 外部工具变量，避免将它们误归为 Neovim 或插件独有变量。
- 分类调整验证通过：Neovim headless 加载示例，确认仍有 26 个不重复的赋值项；
  本轮仅调整分组与说明，默认值逻辑保持不变；`git diff --check` 通过。
