local M = {}
local cache = {}
local roots = {}
local git = vim.fn.exepath("git")
local project = require("config.project")

local function root(buffer)
  local name = vim.api.nvim_buf_get_name(buffer)
  local dir = name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
  if roots[dir] == nil then
    roots[dir] = project.git_root(dir)
  end
  return roots[dir]
end

local function parse(output)
  local result = { branch = "", staged = 0, unstaged = 0, untracked = 0, ahead = 0, behind = 0 }
  for line in output:gmatch("[^\n]+") do
    if line:find("# branch.head ", 1, true) == 1 then
      result.branch = line:sub(15)
    elseif line:find("# branch.ab ", 1, true) == 1 then
      local ahead, behind = line:match("^# branch%.ab %+(%d+) %-(%d+)")
      result.ahead, result.behind = tonumber(ahead) or 0, tonumber(behind) or 0
    elseif line:match("^[12u] ") then
      local x, y = line:match("^[12u] (.)(.)")
      if x ~= "." then result.staged = result.staged + 1 end
      if y ~= "." then result.unstaged = result.unstaged + 1 end
    elseif line:find("? ", 1, true) == 1 then
      result.untracked = result.untracked + 1
    end
  end
  if result.branch == "(detached)" then result.branch = "HEAD" end
  return result.branch ~= "" and result or nil
end

local function publish(repo, value)
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].buftype == "" and root(buffer) == repo then
      vim.b[buffer].config_git_status = value
    end
  end
  vim.cmd.redrawstatus()
end

function M.refresh(buffer, force)
  if git == "" then return end
  buffer = buffer or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buffer) or vim.bo[buffer].buftype ~= "" then return end
  local repo = root(buffer)
  if not repo then return end

  local entry = cache[repo] or { updated = 0 }
  cache[repo] = entry
  if entry.value then vim.b[buffer].config_git_status = entry.value end
  if entry.running then
    entry.rerun = entry.rerun or force
    return
  end
  if not force and vim.uv.now() - entry.updated < 10000 then return end

  entry.running = true
  vim.system({
    git, "--no-optional-locks", "-c", "core.fsmonitor=false", "-C", repo,
    "status", "--porcelain=v2", "--branch", "--untracked-files=normal",
  }, {
    text = true,
    timeout = 3000,
    env = { GIT_LFS_SKIP_SMUDGE = "1", GIT_TERMINAL_PROMPT = "0" },
  }, function(process)
    vim.schedule(function()
      entry.running = false
      entry.updated = vim.uv.now()
      entry.value = process.code == 0 and parse(process.stdout or "") or nil
      publish(repo, entry.value)
      if entry.rerun then
        entry.rerun = false
        if vim.api.nvim_buf_is_valid(buffer) then M.refresh(buffer, true) end
      end
    end)
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ConfigGitStatus", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(event)
      vim.defer_fn(function() M.refresh(event.buf, false) end, 150)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained", "DirChanged" }, {
    group = group,
    callback = function(event)
      M.refresh(event.buf or vim.api.nvim_get_current_buf(), true)
    end,
  })
  vim.api.nvim_create_user_command("ConfigGitRefresh", function() M.refresh(nil, true) end, {
    desc = "Refresh Git status for the current file",
  })
  vim.defer_fn(function() M.refresh(nil, false) end, 150)
end

return M
