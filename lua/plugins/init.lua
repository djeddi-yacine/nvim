local M = {}

local specs = {
  mini = { src = "https://github.com/nvim-mini/mini.nvim", name = "mini.nvim" },
  theme = { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
}

local function installed(spec)
  return vim.uv.fs_stat(vim.fn.stdpath("data") .. "/site/pack/core/opt/" .. spec.name) ~= nil
end

local function selected(name)
  if name == "" or name == "all" then
    return { specs.mini, specs.theme }
  end
  if specs[name] then
    return { specs[name] }
  end
  error("Choose mini, theme, or all")
end

function M.setup()
  vim.api.nvim_create_user_command("ConfigPluginsInstall", function(opts)
    vim.pack.add(selected(opts.args), { confirm = false })
    if installed(specs.mini) then
      require("plugins.mini").setup()
    end
    require("config.theme").apply()
  end, {
    nargs = "?",
    complete = function()
      return { "mini", "theme", "all" }
    end,
    desc = "Install selected plugins",
  })

  vim.api.nvim_create_user_command("ConfigPluginsUpdate", function(opts)
    local chosen = selected(opts.args)
    for _, spec in ipairs(chosen) do
      if not installed(spec) then
        vim.notify(spec.name .. " is not installed", vim.log.levels.WARN)
        return
      end
      vim.pack.add({ spec })
    end
    vim.pack.update(vim.tbl_map(function(spec)
      return spec.name
    end, chosen))
  end, {
    nargs = "?",
    complete = function()
      return { "mini", "theme", "all" }
    end,
    desc = "Review selected plugin updates",
  })

  vim.api.nvim_create_user_command("ConfigPluginsStatus", function()
    local settings = require("plugins.settings")
    vim.notify(table.concat({
      "mini.nvim: " .. (installed(specs.mini) and "installed" or "missing"),
      "Catppuccin: " .. (installed(specs.theme) and "installed" or "missing") .. (settings.theme and " (on)" or " (off)"),
      "Edit lua/plugins/settings.lua to toggle Mini modules.",
    }, "\n"))
  end, { desc = "Show local plugin status without network access" })

  local settings = require("plugins.settings")
  if installed(specs.mini) and vim.tbl_contains(vim.tbl_values(settings.mini), true) then
    vim.pack.add({ specs.mini }) -- Local checkout: no remote update check.
    require("plugins.mini").setup()
  end
  if settings.theme and installed(specs.theme) then
    vim.pack.add({ specs.theme })
  end
  require("config.theme").apply()
end

return M
