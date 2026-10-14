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
      model = "llama3.2",
      endpoint = "http://localhost:11434/v1/chat/completions",
    },

    -- Model settings for AGY
    agy = {
      cmd = "agy",
      model = "gemini-3.8-flash-low",
    },

    -- Prompts directory (defaults to ~/.config/nvim/prompts)
    prompts_dir = vim.fn.stdpath("config") .. "/prompts",

    -- Output insertion: "append" (below cursor) or "replace"
    insert_mode = "append",
    temperature = 0.7,
  },
}
