local M = {}

local function statusline_highlights(colors)
  return {
    MiniStatuslineModeNormal = { fg = colors.blue, bg = colors.none, bold = true },
    MiniStatuslineModeInsert = { fg = colors.green, bg = colors.none, bold = true },
    MiniStatuslineModeVisual = { fg = colors.mauve, bg = colors.none, bold = true },
    MiniStatuslineModeReplace = { fg = colors.red, bg = colors.none, bold = true },
    MiniStatuslineModeCommand = { fg = colors.yellow, bg = colors.none, bold = true },
    MiniStatuslineModeOther = { fg = colors.teal, bg = colors.none, bold = true },
    ConfigStatusSeparator = { fg = colors.overlay0 },
    ConfigStatusProject = { fg = colors.blue },
    ConfigStatusGit = { fg = colors.green },
    ConfigStatusDiagnostics = { fg = colors.peach },
    ConfigStatusLsp = { fg = colors.mauve },
    ConfigStatusFile = { fg = colors.text, bold = true },
    ConfigStatusSearch = { fg = colors.yellow },
    ConfigStatusFiletype = { fg = colors.sky },
    ConfigStatusEncoding = { fg = colors.lavender },
    ConfigStatusIndent = { fg = colors.teal },
    ConfigStatusPosition = { fg = colors.sapphire },
  }
end

function M.apply()
  if require("plugins.settings").theme then
    local ok, catppuccin = pcall(require, "catppuccin")
    if ok then
      catppuccin.setup({
        flavour = "mocha",
        transparent_background = true,
        float = { transparent = true },
        custom_highlights = statusline_highlights,
      })
      vim.cmd.colorscheme("catppuccin-mocha")
      return
    end
  end
  vim.cmd.colorscheme("habamax")
  local links = {
    MiniStatuslineModeNormal = "Identifier",
    MiniStatuslineModeInsert = "String",
    MiniStatuslineModeVisual = "Type",
    MiniStatuslineModeReplace = "ErrorMsg",
    MiniStatuslineModeCommand = "WarningMsg",
    MiniStatuslineModeOther = "Special",
    ConfigStatusSeparator = "Comment",
    ConfigStatusProject = "Function",
    ConfigStatusGit = "String",
    ConfigStatusDiagnostics = "DiagnosticWarn",
    ConfigStatusLsp = "Identifier",
    ConfigStatusFile = "Normal",
    ConfigStatusSearch = "Search",
    ConfigStatusFiletype = "Type",
    ConfigStatusEncoding = "Special",
    ConfigStatusIndent = "Constant",
    ConfigStatusPosition = "Number",
  }
  for group, target in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = target, bg = "none" })
  end
end

return M
