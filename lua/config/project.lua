local M = {}

function M.git_root(dir)
  local marker = vim.fs.find(".git", { path = dir, upward = true })[1]
  if not marker then return nil end

  local stat = vim.uv.fs_stat(marker)
  if stat and stat.type == "directory" and vim.uv.fs_stat(marker .. "/HEAD") then
    return vim.fs.dirname(marker)
  end
  if stat and stat.type == "file" then
    local ok, lines = pcall(vim.fn.readfile, marker, "", 1)
    if ok and (lines[1] or ""):match("^gitdir:") then return vim.fs.dirname(marker) end
  end
  return nil
end

function M.search_root(buffer)
  local path = vim.api.nvim_buf_get_name(buffer or 0)
  local cwd = vim.uv.cwd()
  local stat = path ~= "" and vim.uv.fs_stat(path) or nil
  local dir = path == "" and cwd or (stat and stat.type == "directory" and path or vim.fs.dirname(path))
  local repo = M.git_root(dir)
  if repo then return repo end
  if path == "" then return cwd end
  if cwd == vim.env.HOME then return dir end
  return vim.startswith(path, cwd .. "/") and cwd or dir
end

return M
