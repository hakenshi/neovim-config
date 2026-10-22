local function expand_react_snippet(trigger)
  local ls = require("luasnip")
  local ft = vim.bo.filetype
  require("luasnip.loaders.from_lua")._load_lazy_loaded_ft(ft)
  local snips = ls.get_snippets(ft)
  for _, snip in ipairs(snips) do
    if snip.trigger == trigger then
      local line = vim.api.nvim_get_current_line()
      if line:match("%S") then
        vim.cmd("normal! o")
      end
      vim.cmd("startinsert")
      ls.snip_expand(snip)
      return
    end
  end
  vim.notify("Snippet '" .. trigger .. "' não encontrado para " .. ft, vim.log.levels.WARN)
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        -- Grupo Which-Key
        ["<Leader>r"] = { desc = "React / Next / Expo" },

        -- Padrão: SEM PROPS
        ["<Leader>rc"] = { function() expand_react_snippet("rfc") end, desc = "Component (function)" },
        ["<Leader>ra"] = { function() expand_react_snippet("rac") end, desc = "Arrow Component" },
        ["<Leader>rn"] = { function() expand_react_snippet("page") end, desc = "Page / Screen" },
        ["<Leader>rl"] = { function() expand_react_snippet("layout") end, desc = "Layout (sem props)" },

        -- Opcional: COM PROPS
        ["<Leader>rp"] = { function() expand_react_snippet("rfcp") end, desc = "Component with Props" },
        ["<Leader>rP"] = { function() expand_react_snippet("racp") end, desc = "Arrow with Props" },
        ["<Leader>rL"] = { function() expand_react_snippet("layoutp") end, desc = "Layout with Children" },
      },
    },
  },
}
