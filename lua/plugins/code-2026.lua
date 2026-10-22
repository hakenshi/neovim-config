---@type LazySpec
return {
  {
    "code-2026-theme/nvim",
    name = "code-2026",
    lazy = false,
    priority = 1000,
    opts = {
      background = "dark",
      styles = {
        comments = { italic = true },
      },
    },
  },
}
