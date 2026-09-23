return {
  server = "gopls",
  executable = "gopls",
  config = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gosum" },
    root_markers = { "go.work", "go.mod", ".git" },
  },
}
