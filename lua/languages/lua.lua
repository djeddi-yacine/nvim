return {
  server = "lua_ls",
  executable = "lua-language-server",
  config = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", "init.lua", ".git" },
    workspace_required = false,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { library = { vim.env.VIMRUNTIME .. "/lua/vim/_meta" } },
      },
    },
  },
}
