local M = {}

local function is_file_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted or vim.bo[buf].buftype ~= "" then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf)
  return name == "" or vim.fn.isdirectory(name) == 0
end

function M.cycle(direction)
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  table.sort(buffers)

  local candidates = {}
  for _, buf in ipairs(buffers) do
    if is_file_buffer(buf) then
      candidates[#candidates + 1] = buf
    end
  end
  if #candidates == 0 then return end

  local current_index
  for index, buf in ipairs(candidates) do
    if buf == current then
      current_index = index
      break
    end
  end

  local target_index
  if current_index then
    target_index = ((current_index - 1 + direction) % #candidates) + 1
  elseif direction > 0 then
    target_index = 1
    for index, buf in ipairs(candidates) do
      if buf > current then
        target_index = index
        break
      end
    end
  else
    target_index = #candidates
    for index = #candidates, 1, -1 do
      if candidates[index] < current then
        target_index = index
        break
      end
    end
  end

  vim.api.nvim_set_current_buf(candidates[target_index])
end

return M
