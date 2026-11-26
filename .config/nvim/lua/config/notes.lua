-- Lean, zero-plugin notes setup:
-- 1. Native `zk lsp` on markdown files inside a .zk/ notebook (gd, K hover, gr backlinks)
-- 2. Copilot-off guard inside $ZK_NOTEBOOK_DIR (+ strict guard for *.gpg/*.asc)
-- 3. Debounced, git-crypt-verified auto-sync on save (:NotesSync / :NotesSyncToggle)

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

-- 1. Async debounced Git + git-crypt sync
vim.g.notes_autosync = true
local sync_running, sync_pending, sync_timer = false, false, nil
local last_pull_ms = 0

local function run(cmd, cwd, cb)
  vim.system(cmd, { cwd = cwd, text = true }, function(res)
    vim.schedule(function()
      cb(res)
    end)
  end)
end

local function in_conflict_state(root)
  local git_dir = root .. "/.git"
  return vim.uv.fs_stat(git_dir .. "/MERGE_HEAD") ~= nil
    or vim.uv.fs_stat(git_dir .. "/rebase-merge") ~= nil
    or vim.uv.fs_stat(git_dir .. "/rebase-apply") ~= nil
end

local function is_conflict_output(res)
  local text = (res.stdout or "") .. "\n" .. (res.stderr or "")
  return text:match("CONFLICT") ~= nil
    or text:match("could not apply") ~= nil
    or text:match("Merge conflict") ~= nil
end

local function pull_on_enter(root)
  if sync_running or in_conflict_state(root) then
    return
  end
  local now = vim.uv.now()
  if now - last_pull_ms < 60000 then
    return
  end
  last_pull_ms = now
  run({ "git", "status", "--porcelain" }, root, function(st)
    if st.code ~= 0 or (st.stdout and st.stdout:match("%S")) then
      return
    end
    run({ "git", "rev-parse", "HEAD" }, root, function(before)
      run({ "git", "pull", "--rebase" }, root, function(pull)
        if pull.code ~= 0 then
          if is_conflict_output(pull) then
            run({ "git", "rebase", "--abort" }, root, function()
              vim.notify("Sync conflict pulling notes; run 'nsync' in terminal to resolve", vim.log.levels.ERROR, { title = "Notes Sync" })
            end)
          end
          return
        end
        run({ "git", "rev-parse", "HEAD" }, root, function(after)
          if before.code == 0 and after.code == 0 and before.stdout ~= after.stdout then
            vim.cmd("checktime")
            vim.notify("Notes pulled from origin", vim.log.levels.INFO, { title = "Notes Sync" })
          end
        end)
      end)
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
  if in_conflict_state(root) then
    if manual then
      vim.notify("Sync paused: resolve Git merge/rebase conflict first", vim.log.levels.WARN, { title = "Notes Sync" })
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
          if line:match("%.md$") and not line:match("not encrypted:%s+README%.md$") then
            return fail("Sync aborted: unencrypted .md -> " .. line, vim.log.levels.ERROR)
          end
        end
        run({ "git", "diff", "--cached", "--quiet" }, root, function(diff)
          local function pull_push(committed)
            run({ "git", "pull", "--rebase" }, root, function(pull)
              if pull.code ~= 0 then
                local conflict = is_conflict_output(pull)
                return run({ "git", "rebase", "--abort" }, root, function()
                  if conflict then
                    fail("Sync conflict in notes; run 'nsync' in terminal to resolve", vim.log.levels.ERROR)
                  else
                    fail("Pull failed (offline?); local commit kept")
                  end
                end)
              end
              last_pull_ms = vim.uv.now()
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

-- 2. Native zk LSP + security + auto-sync autocmds
local aug = vim.api.nvim_create_augroup("NotesConfig", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern = "markdown",
  callback = function(ev)
    if vim.fn.executable("zk") ~= 1 then
      return
    end
    local root = vim.fs.root(ev.buf, ".zk")
    if root then
      vim.lsp.start({
        name = "zk",
        cmd = { "zk", "lsp" },
        root_dir = root,
      })
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = aug,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "zk" then
      return
    end
    local nmap = function(k, f, d)
      vim.keymap.set("n", k, f, { buffer = ev.buf, desc = "ZK: " .. d })
    end
    nmap("gd", vim.lsp.buf.definition, "Go to linked note")
    nmap("K", vim.lsp.buf.hover, "Preview linked note")
    nmap("gr", function()
      local ok, tb = pcall(require, "telescope.builtin")
      if ok then
        tb.lsp_references()
      else
        vim.lsp.buf.references()
      end
    end, "Backlinks (references)")
    nmap("<leader>rn", vim.lsp.buf.rename, "Rename note/link")
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  group = aug,
  pattern = "*",
  callback = function(ev)
    if in_notebook(ev.file) then
      vim.b[ev.buf].copilot_enabled = false
      if ev.event == "BufEnter" and vim.g.notes_autosync then
        local root = norm(vim.env.ZK_NOTEBOOK_DIR)
        if root and vim.uv.fs_stat(root .. "/.git") then
          pull_on_enter(root)
        end
      end
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

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = aug,
  callback = function()
    local had_pending = sync_timer ~= nil
    if sync_timer then
      sync_timer:stop()
      sync_timer:close()
      sync_timer = nil
    end

    -- Wait briefly if an async sync is mid-flight so .git/index.lock isn't left behind
    if sync_running then
      vim.wait(8000, function()
        return not sync_running
      end, 50)
    end

    if not had_pending or not vim.g.notes_autosync then
      return
    end

    local root = norm(vim.env.ZK_NOTEBOOK_DIR)
    if not root or not vim.uv.fs_stat(root .. "/.git") then
      return
    end
    if vim.system({ "git", "remote", "get-url", "origin" }, { cwd = root }):wait().code ~= 0 then
      return
    end
    if vim.system({ "git", "add", "-A" }, { cwd = root }):wait().code ~= 0 then
      return
    end

    -- Security guard before committing on exit
    local crypt = vim.system({ "git-crypt", "status", "-u" }, { cwd = root, text = true }):wait()
    if crypt.code ~= 0 then
      return
    end
    for line in (crypt.stdout or ""):gmatch("[^\r\n]+") do
      if line:match("%.md$") and not line:match("not encrypted:%s+README%.md$") then
        vim.api.nvim_err_writeln("Sync aborted on exit: unencrypted .md -> " .. line)
        return
      end
    end

    if vim.system({ "git", "diff", "--cached", "--quiet" }, { cwd = root }):wait().code == 1 then
      if vim.system({ "git", "commit", "-m", "notes: sync" }, { cwd = root }):wait().code ~= 0 then
        return
      end
      -- Finish pull --rebase && push detached so :wq returns immediately
      if vim.fn.has("win32") == 1 then
        vim.system({ "cmd", "/c", "git pull --rebase && git push || git rebase --abort" }, { cwd = root }):wait()
      else
        vim.system(
          { "sh", "-c", "git pull --rebase >/dev/null 2>&1 && git push >/dev/null 2>&1 || git rebase --abort >/dev/null 2>&1" },
          { cwd = root, detach = true }
        )
      end
    end
  end,
})

vim.api.nvim_create_user_command("NotesSync", function()
  sync_notes(true)
end, { desc = "Verify git-crypt, commit, pull --rebase, and push notes" })

vim.api.nvim_create_user_command("NotesSyncToggle", function()
  vim.g.notes_autosync = not vim.g.notes_autosync
  vim.notify("Auto-sync on save: " .. (vim.g.notes_autosync and "ON" or "OFF"), vim.log.levels.INFO, { title = "Notes Sync" })
end, { desc = "Toggle automatic Git sync when saving notes" })
