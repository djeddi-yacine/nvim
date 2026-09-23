local group = vim.api.nvim_create_augroup("NvimNext", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    (vim.hl.hl_op or vim.hl.on_yank)({ timeout = 120 })
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function(event)
    local buffer = event.buf
    vim.bo[buffer].buflisted = false
    vim.bo[buffer].bufhidden = "wipe"
    vim.bo[buffer].swapfile = false
    vim.keymap.set("n", "<leader>q", "<cmd>bdelete!<CR>", { buf = buffer, desc = "Close terminal" })
    vim.keymap.set("n", "<leader>bd", "<cmd>bdelete!<CR>", { buf = buffer, desc = "Close terminal buffer" })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buf = event.buf, desc = "Go to definition" })
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
      vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, {
        buf = event.buf,
        desc = "Request LSP completion",
      })
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = group,
  callback = function(event)
    local buffer = event.buf
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buffer) and #vim.lsp.get_clients({ bufnr = buffer }) == 0 then
        pcall(vim.keymap.del, "n", "gd", { buf = buffer })
        pcall(vim.keymap.del, "i", "<C-Space>", { buf = buffer })
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "buf-config",
  callback = function()
    vim.bo.syntax = "yaml"
  end,
})
