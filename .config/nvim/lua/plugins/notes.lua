local function norm(path)
  if not path or path == "" then
    return nil
  end
  return (vim.uv.fs_realpath(path) or vim.fn.fnamemodify(path, ":p")):gsub("/+$", "")
end

local function in_notebook(filepath)
  local root, file = norm(vim.env.ZK_NOTEBOOK_DIR), norm(filepath)
  return root and file and (file == root or file:sub(1, #root + 1) == root .. "/")
end

local function require_notebook()
  local dir = norm(vim.env.ZK_NOTEBOOK_DIR)
  if not dir then
    vim.notify("Set $ZK_NOTEBOOK_DIR first", vim.log.levels.WARN, { title = "Notes" })
  end
  return dir
end

-- Asynchronous debounced Git + git-crypt sync
vim.g.notes_autosync = true
local sync_running, sync_pending, sync_timer = false, false, nil

local function run(cmd, cwd, cb)
  vim.system(cmd, { cwd = cwd, text = true }, function(res)
    vim.schedule(function()
      cb(res)
    end)
  end)
end

local function sync_notes(manual)
  local root = norm(vim.env.ZK_NOTEBOOK_DIR)
  if not root or not vim.uv.fs_stat(root .. "/.git") then
    if manual then
      vim.notify("Not a Git repo: " .. (root or "$ZK_NOTEBOOK_DIR unset"), vim.log.levels.WARN, { title = "Notes Sync" })
    end
    return
  end
  if sync_running then
    sync_pending = true
    return
  end
  sync_running = true

  local function done()
    sync_running = false
    if sync_pending then
      sync_pending = false
      sync_notes(false)
    end
  end

  local function fail(msg, level)
    vim.notify(msg, level or vim.log.levels.WARN, { title = "Notes Sync" })
    done()
  end

  run({ "git", "remote", "get-url", "origin" }, root, function(rem)
    if rem.code ~= 0 then
      return manual and fail("No 'origin' remote configured") or done()
    end
    run({ "git", "add", "-A" }, root, function(add)
      if add.code ~= 0 then
        return fail("git add failed: " .. (add.stderr or ""), vim.log.levels.ERROR)
      end
      -- Security guard: abort before commit/push if any .md is unencrypted
      run({ "git-crypt", "status", "-u" }, root, function(crypt)
        if crypt.code ~= 0 then
          return fail("Sync aborted: git-crypt not initialized or failed", vim.log.levels.ERROR)
        end
        for line in (crypt.stdout or ""):gmatch("[^\r\n]+") do
          if line:match("%.md$") then
            return fail("Sync aborted: unencrypted .md -> " .. line, vim.log.levels.ERROR)
          end
        end
        run({ "git", "diff", "--cached", "--quiet" }, root, function(diff)
          local function pull_push(committed)
            run({ "git", "pull", "--rebase" }, root, function(pull)
              if pull.code ~= 0 then
                return run({ "git", "rebase", "--abort" }, root, function()
                  fail("Pull failed (offline or conflict); local commit kept")
                end)
              end
              run({ "git", "push" }, root, function(push)
                if push.code ~= 0 then
                  return fail("Push failed: " .. (push.stderr or ""):gsub("%s+$", ""))
                end
                if committed or manual then
                  vim.notify("Notes synced", vim.log.levels.INFO, { title = "Notes Sync" })
                end
                done()
              end)
            end)
          end
          if diff.code == 1 then
            run({ "git", "commit", "-m", "notes: sync" }, root, function(c)
              if c.code ~= 0 then
                return fail("git commit failed: " .. (c.stderr or ""), vim.log.levels.ERROR)
              end
              pull_push(true)
            end)
          else
            pull_push(false)
          end
        end)
      end)
    end)
  end)
end

-- Security + auto-sync autocmds (active immediately, even before lazy loads zk-nvim)
local aug = vim.api.nvim_create_augroup("NotesLeanConfig", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  group = aug,
  pattern = "*",
  callback = function(ev)
    if in_notebook(ev.file) then
      vim.b[ev.buf].copilot_enabled = false
    end
  end,
})
vim.api.nvim_create_autocmd({ "BufReadPre", "BufReadPost", "BufNewFile", "BufEnter" }, {
  group = aug,
  pattern = { "*.gpg", "*.asc", "GPGRecipients_*", "GPGOptions_*" },
  callback = function(ev)
    vim.bo[ev.buf].swapfile = false
    vim.bo[ev.buf].undofile = false
    vim.opt.backup, vim.opt.writebackup = false, false
    vim.opt.shada, vim.opt.clipboard = "", ""
    vim.b[ev.buf].copilot_enabled = false
  end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = aug,
  pattern = "*",
  callback = function(ev)
    if not vim.g.notes_autosync or not in_notebook(ev.file) then
      return
    end
    if sync_timer then
      sync_timer:stop()
      sync_timer:close()
    end
    sync_timer = vim.uv.new_timer()
    sync_timer:start(1500, 0, vim.schedule_wrap(function()
      if sync_timer then
        sync_timer:stop()
        sync_timer:close()
        sync_timer = nil
      end
      sync_notes(false)
    end))
  end,
})

return {
  {
    "zk-org/zk-nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("zk").setup({
        picker = "telescope",
        lsp = {
          config = {
            cmd = { "zk", "lsp" },
            name = "zk",
            on_attach = function(_, bufnr)
              local nmap = function(k, f, d)
                vim.keymap.set("n", k, f, { buffer = bufnr, desc = "ZK: " .. d })
              end
              nmap("gd", vim.lsp.buf.definition, "Go to linked note")
              nmap("K", vim.lsp.buf.hover, "Hover note preview")
              nmap("<leader>rn", vim.lsp.buf.rename, "Rename note/link")
            end,
          },
          auto_attach = { enabled = vim.fn.executable("zk") == 1, filetypes = { "markdown" } },
        },
      })

      local ok_wk, wk = pcall(require, "which-key")
      if ok_wk then
        wk.add({ { "<leader>n", group = "[N]otes" } })
      end

      local map = vim.keymap.set
      map("n", "<leader>nn", function()
        vim.ui.input({ prompt = "Note title (empty = Note): " }, function(t)
          if t ~= nil then
            require("zk").new(t ~= "" and { title = t } or {})
          end
        end)
      end, { desc = "[N]ew dated note" })
      map("n", "<leader>nd", function() require("zk").new({ dir = "daily" }) end, { desc = "[D]aily note" })
      map("n", "<leader>ni", function()
        local d = require_notebook()
        if d then vim.cmd.edit(d .. "/index.md") end
      end, { desc = "[I]ndex note" })
      map("n", "<leader>nf", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", { desc = "[F]ind notes" })
      map("n", "<leader>nt", "<Cmd>ZkTags<CR>", { desc = "Filter by [T]ags" })
      map("n", "<leader>nb", "<Cmd>ZkBacklinks<CR>", { desc = "[B]acklinks" })
      map("n", "<leader>nl", "<Cmd>ZkLinks<CR>", { desc = "Outgoing [L]inks" })
      map("n", "<leader>ng", function()
        local d = require_notebook()
        if d then
          require("telescope.builtin").live_grep({ prompt_title = "Grep Notes", cwd = d, file_ignore_patterns = { "^%.zk/" } })
        end
      end, { desc = "[G]rep notes" })
      map("v", "<leader>nn", ":'<,'>ZkNewFromTitleSelection<CR>", { desc = "[N]ew note from selection title" })
      map("v", "<leader>nc", ":'<,'>ZkNewFromContentSelection<CR>", { desc = "New note from [C]ontent selection" })
      map("n", "<leader>np", function() sync_notes(true) end, { desc = "[P]ush / sync notes now" })
      map("n", "<leader>nS", function()
        vim.g.notes_autosync = not vim.g.notes_autosync
        vim.notify("Auto-sync on save: " .. (vim.g.notes_autosync and "ON" or "OFF"), vim.log.levels.INFO, { title = "Notes Sync" })
      end, { desc = "Toggle auto-[S]ync on save" })
    end,
  },
}
