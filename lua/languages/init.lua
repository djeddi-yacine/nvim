local M = {}

local names = { "go", "c", "dart", "buf", "lua" }
local settings = require("languages.settings")
local definitions = {}

local function set_language(name, enabled, quiet)
  local definition = definitions[name]
  if not definition then
    vim.notify("Unknown language: " .. name, vim.log.levels.ERROR)
    return
  end
  if enabled and vim.fn.executable(definition.executable) == 0 then
    vim.notify(definition.executable .. " is not on PATH", vim.log.levels.ERROR)
    return
  end
  settings[name] = enabled
  vim.lsp.enable(definition.server, enabled)
  if not enabled then
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_loaded(buffer) and vim.tbl_contains(definition.config.filetypes, vim.bo[buffer].filetype)
      then
        local active = vim.iter(vim.lsp.get_clients({ bufnr = buffer })):any(function(client)
          return not client:is_stopped()
        end)
        if not active then
          pcall(vim.keymap.del, "n", "gd", { buf = buffer })
          pcall(vim.keymap.del, "i", "<C-Space>", { buf = buffer })
        end
      end
    end
  end
  if enabled then
    -- Re-run FileType so a command entered after startup also attaches to
    -- already-open buffers. Neovim's enable() handles future buffers itself.
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_loaded(buffer) and vim.tbl_contains(definition.config.filetypes, vim.bo[buffer].filetype)
      then
        vim.api.nvim_exec_autocmds("FileType", { buf = buffer, modeline = false })
        if #vim.lsp.get_clients({ bufnr = buffer, name = definition.server }) == 0 then
          vim.api.nvim_buf_call(buffer, function()
            vim.lsp.start(vim.tbl_extend("force", { name = definition.server }, definition.config))
          end)
        end
      end
    end
  end
  if not quiet then
    vim.notify(name .. (enabled and " enabled" or " disabled") .. " for this session")
  end
end

function M.setup()
  vim.filetype.add({
    filename = {
      ["buf.yaml"] = "buf-config",
      ["buf.gen.yaml"] = "buf-config",
      ["buf.policy.yaml"] = "buf-config",
      ["buf.lock"] = "buf-config",
    },
  })

  for _, name in ipairs(names) do
    local definition = require("languages." .. name)
    definitions[name] = definition
    vim.lsp.config(definition.server, definition.config)
    if settings[name] then
      set_language(name, true, true)
    end
  end

  local completion = function()
    return names
  end
  vim.api.nvim_create_user_command("ConfigLangEnable", function(opts)
    set_language(opts.args, true)
  end, { nargs = 1, complete = completion, desc = "Enable a language for this session" })
  vim.api.nvim_create_user_command("ConfigLangDisable", function(opts)
    set_language(opts.args, false)
  end, { nargs = 1, complete = completion, desc = "Disable a language for this session" })
  vim.api.nvim_create_user_command("ConfigLanguages", function()
    local lines = {}
    for _, name in ipairs(names) do
      local definition = definitions[name]
      lines[#lines + 1] = string.format(
        "%s: %s (%s %s)",
        name,
        settings[name] and "on" or "off",
        definition.executable,
        vim.fn.executable(definition.executable) == 1 and "found" or "missing"
      )
    end
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  end, { desc = "Show language status" })
end

return M
