local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

-- Helper para obter o nome do componente normal baseado no arquivo e pasta pai (se index)
local function get_component_name()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return "MyComponent"
  end

  local filename = vim.fs.basename(file_path)
  local name = filename:match("^(.+)%..+$") or filename

  if name:lower() == "index" then
    local dirname = vim.fs.dirname(file_path)
    if dirname then
      name = vim.fs.basename(dirname)
    end
  end

  -- Converte kebab-case e snake_case para PascalCase
  name = name:gsub("[-_](%w)", function(c) return c:upper() end)
  name = name:gsub("^%l", function(c) return c:upper() end)

  if not name:match("^[%a_$][%w_$]*$") then
    name = "MyComponent"
  end

  return name
end

-- Helper universal para Expo Router e Next.js (suporta _layout, layout, index, page, rotas dinâmicas e route groups)
local function get_expo_or_next_name(suffix)
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return "My" .. suffix
  end

  local filename = vim.fs.basename(file_path)
  local basename = filename:match("^(.+)%..+$") or filename

  local dirname = vim.fs.dirname(file_path)
  if not dirname then
    return "My" .. suffix
  end

  local folder = vim.fs.basename(dirname)

  -- Identifica e ignora route groups como (tabs), (auth), etc.
  local group = nil
  while folder and folder:match("^%b()$") do
    group = folder:match("^%((.+)%)$")
    dirname = vim.fs.dirname(dirname)
    folder = dirname and vim.fs.basename(dirname) or nil
  end

  local name = ""

  if basename == "layout" or basename == "_layout" then
    if not folder or folder == "app" or folder == "src" or folder == "/" or folder == "." then
      name = group and (group:gsub("^%l", string.upper)) or "Root"
    else
      name = folder
    end
    name = name .. suffix
  elseif basename == "page" or basename == "index" then
    if not folder or folder == "app" or folder == "src" or folder == "/" or folder == "." then
      name = "Home" .. suffix
    else
      name = folder .. suffix
    end
  else
    name = basename .. (suffix ~= "Layout" and suffix or "")
  end

  -- Remove identificadores de rotas dinâmicas como [id] ou [...slug]
  name = name:gsub("^%[+%.*", ""):gsub("%]+$", "")

  -- Converte para PascalCase
  name = name:gsub("[-_](%w)", function(c) return c:upper() end)
  name = name:gsub("^%l", function(c) return c:upper() end)

  if not name:match("^[%a_$][%w_$]*$") then
    name = "My" .. suffix
  end

  return name
end

local function comp_name_node()
  return sn(nil, {
    i(1, get_component_name()),
  })
end

local function router_name_node(suffix)
  return function()
    return sn(nil, {
      i(1, get_expo_or_next_name(suffix)),
    })
  end
end

return {
  -- 1. RFC: React Functional Component (SEM props por padrão)
  s(
    "rfc",
    fmt(
      [[
export default function {}() {{
  return (
    {}
  )
}}
]],
      {
        d(1, comp_name_node, {}),
        i(0),
      }
    )
  ),

  -- 2. RAC: React Arrow Component (SEM props por padrão)
  s(
    "rac",
    fmt(
      [[
export const {} = () => {{
  return (
    {}
  )
}}
]],
      {
        d(1, comp_name_node, {}),
        i(0),
      }
    )
  ),

  -- 3. RFCP: React Functional Component COM Props (herda React.PropsWithChildren)
  s(
    "rfcp",
    fmt(
      [[
interface {}Props extends React.PropsWithChildren {{
  {}
}}

export default function {}({{ {} }}: {}Props) {{
  return (
    {}
  )
}}
]],
      {
        d(1, comp_name_node, {}),
        i(2),
        rep(1),
        i(3),
        rep(1),
        i(0),
      }
    )
  ),

  -- 4. RACP: React Arrow Component COM Props (herda React.PropsWithChildren)
  s(
    "racp",
    fmt(
      [[
interface {}Props extends React.PropsWithChildren {{
  {}
}}

export const {} = ({{ {} }}: {}Props) => {{
  return (
    {}
  )
}}
]],
      {
        d(1, comp_name_node, {}),
        i(2),
        rep(1),
        i(3),
        rep(1),
        i(0),
      }
    )
  ),

  -- 5. Page / Screen: Next.js & Expo (SEM props por padrão)
  s(
    { trig = "page", name = "Next.js / Expo Page (sem props)" },
    fmt(
      [[
export default function {}() {{
  return (
    {}
  )
}}
]],
      {
        d(1, router_name_node("Page"), {}),
        i(0),
      }
    )
  ),
  s(
    { trig = "screen", name = "Expo Screen (sem props)" },
    fmt(
      [[
export default function {}() {{
  return (
    {}
  )
}}
]],
      {
        d(1, router_name_node("Screen"), {}),
        i(0),
      }
    )
  ),

  -- 6. Page COM Props (opcional)
  s(
    { trig = "pagep", name = "Next.js / Expo Page (com props)" },
    fmt(
      [[
interface {}Props {{
  {}
}}

export default function {}({{ {} }}: {}Props) {{
  return (
    {}
  )
}}
]],
      {
        d(1, router_name_node("Page"), {}),
        i(2),
        rep(1),
        i(3),
        rep(1),
        i(0),
      }
    )
  ),

  -- 7. Layout: Next.js & Expo Router (SEM props por padrão - ideal para Expo Stack/Slot/Tabs)
  s(
    { trig = "layout", name = "Next.js / Expo Layout (sem props)" },
    fmt(
      [[
export default function {}() {{
  return (
    {}
  )
}}
]],
      {
        d(1, router_name_node("Layout"), {}),
        i(0),
      }
    )
  ),

  -- 8. Layout COM Children: Next.js & Expo (com React.PropsWithChildren)
  s(
    { trig = "layoutp", name = "Layout com Children (React.PropsWithChildren)" },
    fmt(
      [[
export default function {}({{ children }}: React.PropsWithChildren) {{
  return (
    <>
      {{children}}
      {}
    </>
  )
}}
]],
      {
        d(1, router_name_node("Layout"), {}),
        i(0),
      }
    )
  ),
}
