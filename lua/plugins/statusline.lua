local M = {}

local function git_status()
  local git = vim.b.config_git_status
  if type(git) ~= "table" then return "" end
  local parts = { "Git " .. git.branch }
  if git.ahead > 0 then parts[#parts + 1] = "↑" .. git.ahead end
  if git.behind > 0 then parts[#parts + 1] = "↓" .. git.behind end
  if git.staged > 0 then parts[#parts + 1] = "+" .. git.staged end
  if git.unstaged > 0 then parts[#parts + 1] = "~" .. git.unstaged end
  if git.untracked > 0 then parts[#parts + 1] = "?" .. git.untracked end
  return table.concat(parts, " "):gsub("%%", "%%%%")
end

local function lsp_names()
  if vim.api.nvim_win_get_width(0) < 100 then return "" end
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = client.name
  end
  return #names > 0 and "LSP " .. table.concat(names, ","):gsub("%%", "%%%%") or ""
end

local function indentation()
  if vim.api.nvim_win_get_width(0) < 100 or vim.bo.buftype ~= "" then return "" end
  return (vim.bo.expandtab and "S" or "T") .. vim.fn.shiftwidth()
end

local function add(parts, group, value)
  if value ~= "" then parts[#parts + 1] = "%#ConfigStatus" .. group .. "#" .. value end
end

local function join(parts)
  return table.concat(parts, "%#ConfigStatusSeparator# | ")
end

local function rendered_width(parts, prefix)
  if #parts == 0 then return 0 end
  return vim.api.nvim_eval_statusline((prefix or "") .. join(parts), {
    winid = vim.api.nvim_get_current_win(),
  }).width
end

local function filename(max_width)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or max_width < 3 then return "" end

  local width = vim.api.nvim_win_get_width(0)
  local name
  if vim.bo.buftype == "terminal" then
    name = vim.fn.fnamemodify(path, ":t")
  else
    name = vim.fn.fnamemodify(path, width < 80 and ":." or ":~:.")
  end

  local flags = (vim.bo.modified and " [+]" or "") .. (vim.bo.readonly and " [RO]" or "")
  local name_width = max_width - vim.fn.strdisplaywidth(flags)
  if name_width < 3 then return "" end

  if vim.fn.strdisplaywidth(name) > name_width then
    local prefix, prefix_width = "", name_width - 3
    for index = 1, vim.fn.strchars(name) do
      local candidate = vim.fn.strcharpart(name, 0, index)
      if vim.fn.strdisplaywidth(candidate) > prefix_width then break end
      prefix = candidate
    end
    name = prefix .. "..."
  end

  return (name .. flags):gsub("%%", "%%%%")
end

function M.active()
  local statusline = require("mini.statusline")
  local mode, mode_hl = statusline.section_mode({ trunc_width = 80 })
  local width = vim.api.nvim_win_get_width(0)
  local project = width >= 100 and vim.fn.fnamemodify(vim.uv.cwd(), ":t"):gsub("%%", "%%%%") or ""
  local left = { "%#" .. mode_hl .. "#" .. mode }
  add(left, "Project", project)
  add(left, "Git", git_status())
  add(left, "Diagnostics", statusline.section_diagnostics({ trunc_width = 80 }))
  add(left, "Lsp", lsp_names())

  local right = {}
  add(right, "Search", statusline.section_searchcount({ trunc_width = 80 }))
  add(right, "Filetype", vim.bo.filetype:gsub("%%", "%%%%"))
  if width >= 100 and vim.bo.buftype == "" then
    add(right, "Encoding", (vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding):upper())
  end
  add(right, "Indent", indentation())
  add(right, "Position", "%l:%c")

  local width_used = rendered_width(left, "%S") + rendered_width(right)
  local file_width = width - width_used - vim.fn.strdisplaywidth(" | ") - 1
  add(left, "File", filename(file_width))

  return "%S" .. join(left) .. "%=" .. join(right)
end

return M
