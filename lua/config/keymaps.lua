local map = vim.keymap.set
local buffers = require("config.buffers")

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Close window" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>t", "<cmd>tabnew | terminal<CR>", { desc = "Open terminal tab" })

map("n", "[b", function() buffers.cycle(-1) end, { desc = "Previous file buffer" })
map("n", "]b", function() buffers.cycle(1) end, { desc = "Next file buffer" })
map("n", "<C-PageUp>", "<C-b>", { desc = "Scroll up one page" })
map("n", "<C-PageDown>", "<C-f>", { desc = "Scroll down one page" })
map({ "n", "t" }, "<C-S-Left>", function()
  vim.cmd.tabprevious()
end, { desc = "Previous tab" })
map({ "n", "t" }, "<C-S-Right>", function()
  vim.cmd.tabnext()
end, { desc = "Next tab" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

map("n", "<leader>e", function()
  require("plugins.mini").files()
end, { desc = "File explorer" })
map("n", "<leader>ff", function()
  require("plugins.mini").pick_files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
  require("plugins.mini").pick_grep()
end, { desc = "Search text" })
map("n", "<leader>fb", function()
  require("plugins.mini").pick_buffers()
end, { desc = "Find buffers" })
map("n", "<leader>fh", function()
  require("plugins.mini").pick_help()
end, { desc = "Search help" })

map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "All diagnostics" })

local function jump_diagnostic(count)
  vim.diagnostic.jump({
    count = count,
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  })
end

map("n", "[d", function()
  jump_diagnostic(-1)
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
  jump_diagnostic(1)
end, { desc = "Next diagnostic" })
map("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format with LSP" })
