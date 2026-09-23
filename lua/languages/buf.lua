return {
  server = "buf_ls",
  executable = "buf",
  config = {
    cmd = { "buf", "lsp", "serve" },
    filetypes = { "proto", "buf-config" },
    root_markers = { "buf.yaml", ".git" },
  },
}
