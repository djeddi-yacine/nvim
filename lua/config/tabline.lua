local M = {}

local function tab_info(tab)
  local current_win = vim.api.nvim_tabpage_get_win(tab)
  local fallback, filetype, modified

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    fallback = fallback or buf

    -- Ignore floating windows so transient pickers and explorers do not rename
    -- the workspace tab.
    if vim.api.nvim_win_get_config(win).relative == "" then
      if win == current_win or filetype == nil then
        filetype = vim.bo[buf].filetype
      end
      modified = modified or vim.bo[buf].modified
    end
  end

  if filetype == nil then
    filetype = fallback and vim.bo[fallback].filetype or ""
  end
  return filetype, modified or false
end

local function short_type(filetype)
  filetype = filetype:lower()
  if filetype == "" then
    return "--"
  end
  return filetype:sub(1, 2)
end

function M.render()
  local current = vim.api.nvim_get_current_tabpage()
  local labels = {}

  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local highlight = tab == current and "ConfigTablineActive" or "ConfigTablineInactive"
    local filetype, modified = tab_info(tab)
    labels[#labels + 1] = string.format(
      "%%#%s#%%%dT %d:%s%s %%T",
      highlight,
      index,
      index,
      short_type(filetype),
      modified and "+" or ""
    )
  end

  labels[#labels + 1] = "%#ConfigTablineFill#%T"
  return table.concat(labels)
end

return M
