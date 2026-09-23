local M = {}
local ready = {}

function M.setup()
  local settings = require("plugins.settings").mini
  if settings.icons and not ready.icons then
    require("mini.icons").setup()
    ready.icons = true
  end
  if settings.pick and not ready.pick then
    require("mini.pick").setup()
    ready.pick = true
  end
  if settings.files and not ready.files then
    require("mini.files").setup({ mappings = { close = "<Esc>", go_in_plus = "<CR>" } })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "minifiles-help",
      callback = function(event)
        vim.keymap.set("n", "<Esc>", "<Cmd>close<CR>", { buf = event.buf, desc = "Close explorer help" })
      end,
    })
    ready.files = true
  end
  if settings.statusline and not ready.statusline then
    require("mini.statusline").setup({
      use_icons = settings.icons,
      content = { active = require("plugins.statusline").active },
    })
    ready.statusline = true
  end
  if settings.pairs and not ready.pairs then
    require("mini.pairs").setup()
    ready.pairs = true
  end
  if settings.clue and not ready.clue then
    require("mini.clue").setup({
      triggers = { { mode = { "n", "x" }, keys = "<Leader>" } },
      window = { delay = 0 },
    })
    ready.clue = true
  end
  if settings.ai and not ready.ai then
    require("mini.ai").setup({ mappings = { around_next = "aa", inside_next = "ii" } })
    ready.ai = true
  end
  if settings.surround and not ready.surround then
    require("mini.surround").setup()
    ready.surround = true
  end
end

local function available(module)
  if ready[module] then
    return true
  end
  vim.notify("Enable mini." .. module .. " and run :ConfigPluginsInstall mini", vim.log.levels.INFO)
  return false
end

function M.files()
  if available("files") then
    local path = vim.api.nvim_buf_get_name(0)
    require("mini.files").open(path ~= "" and path or vim.uv.cwd(), true)
  else
    vim.cmd.Explore()
  end
end

function M.pick_files()
  if available("pick") then
    local pick = require("mini.pick")
    pick.builtin.cli({ command = { "rg", "--files", "--hidden", "--glob", "!.git" } }, {
      source = {
        name = "Find files",
        cwd = require("config.project").search_root(),
        show = function(buffer, items, query)
          pick.default_show(buffer, items, query, { show_icons = true })
        end,
      },
    })
  else
    vim.ui.input({ prompt = "Find file: " }, function(path)
      if path and path ~= "" then
        vim.cmd.find(vim.fn.fnameescape(path))
      end
    end)
  end
end

function M.pick_grep()
  if available("pick") then
    require("mini.pick").builtin.grep_live({ tool = "rg" }, {
      source = { cwd = require("config.project").search_root() },
    })
  else
    vim.ui.input({ prompt = "Search text: " }, function(pattern)
      if pattern and pattern ~= "" then
        vim.cmd.grep({ args = { pattern }, bang = true })
        vim.cmd.copen()
      end
    end)
  end
end

function M.pick_buffers()
  if available("pick") then
    require("mini.pick").builtin.buffers()
  else
    vim.cmd.buffers()
  end
end

function M.pick_help()
  if available("pick") then
    require("mini.pick").builtin.help()
  else
    vim.ui.input({ prompt = "Help topic: " }, function(topic)
      if topic and topic ~= "" then
        vim.cmd.help(topic)
      end
    end)
  end
end

return M
