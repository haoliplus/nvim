return {
  "milanglacier/minuet-ai.nvim",
  opts = {
    provider = "openai_compatible",
    provider_options = {
        openai_compatible = {
            model = 'opencode-go/deepseek-v4.1-flash',
            api_key = 'CPA_API_KEY',
            end_point = 'https://cpa.aidoki.cn/v1/chat/completions',
            name = 'CPA',
            optional = {
                thinking = { type = 'disabled' },
            },
        },
      -- openai_fim_compatible = {
      --   api_key = "DEEPSEEK_API_KEY",
      --   end_point = "https://api.deepseek.com/beta/completions",
      --   model = "deepseek-v4-flash",
      --   name = "Deepseek",
      --   optional = {
      --     max_tokens = 256,
      --     top_p = 0.9,
      --     stop = nil,
      --   },
      -- },
    },
  },
}
