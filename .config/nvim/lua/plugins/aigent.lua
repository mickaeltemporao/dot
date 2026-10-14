return {
  "mickaeltemporao/aigent.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    -- Default provider: "ollama" (local LLM) or "agy" (Google Antigravity CLI)
    provider = "ollama",

    -- Model settings for Ollama
    ollama = {
      model = "muse-glimmer:30b-mlx",
      endpoint = "http://localhost:11434/v1/chat/completions",
    },

    -- Prompts directory (defaults to ~/.config/nvim/prompts)
    prompts_dir = vim.fn.stdpath("config") .. "/prompts",

    -- Output insertion: "append" (below cursor) or "replace"
    insert_mode = "append",
    temperature = 0.7,
  },
}
