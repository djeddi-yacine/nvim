return {
  server = "dart_next",
  executable = "dart",
  config = {
    cmd = { "dart", "language-server", "--protocol=lsp" },
    filetypes = { "dart" },
    root_markers = { "pubspec.yaml", ".git" },
  },
}
