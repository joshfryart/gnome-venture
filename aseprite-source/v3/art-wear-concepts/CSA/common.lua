-- common.lua: helpers for the Spicepeak (CSA) wear concept icons. Read-only reuse of ../../gnome-wear/_gw.lua.
-- Run: AppRun -b --script-param png=<dir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
C.png = app.params.png or (DIR .. "/")

-- regional ramps, dark -> light
C.R = setmetatable({
  madder  = { "#4a1424", "#6e1e2c", "#962a32", "#b83c38", "#d65a44", "#ec8a5e" },
  saffron = { "#6a3a12", "#9a5a14", "#c8801a", "#e8a524", "#f6c84a", "#fde68a" },
  indigo  = { "#16183e", "#1f2a5e", "#2c3f82", "#3d58a2", "#5a7cc0", "#8eaedc" },
  feltc   = { "#5e5048", "#857565", "#a89a84", "#c8bca2", "#e0d6bc", "#f2ead2" },
  yak     = { "#2e1c18", "#45291f", "#5e3a28", "#7a4e34", "#966746", "#b2865e" },
  bamboo  = { "#4e3a18", "#76582a", "#9c7a38", "#bf9c4c", "#d8bb68", "#ecd890" },
  copper  = { "#4a1e18", "#7a3320", "#a84e2a", "#c86c38", "#e2925a", "#f4bc88" },
  turq    = { "#14504e", "#1e7a70", "#2ea08e", "#4cc0a6", "#7edcc0", "#bff2de" },
  palm    = { "#4a3e1a", "#6c5c22", "#8e7c2e", "#ae9a3e", "#c8b55a", "#e2d282" },
  leaf    = { "#1c3a22", "#265430", "#33703a", "#468c44", "#62a850", "#94c870" },
  char    = { "#221c26", "#2f2832", "#403840", "#544a50", "#6a5e62", "#867876" },
  plum    = { "#3a1e3a", "#56294e", "#743a62", "#924e74", "#ae6a88", "#cc92a6" },
  crocus  = { "#35295f", "#5a459e", "#8a6fd0", "#b69ae8", "#d6c4f6", "#efe4ff" },
  goose   = { "#3a3a44", "#55556a", "#76768a", "#9a9aac", "#c0c0cc", "#e2e2ea" },
}, { __index = W.R })

-- constant bias table for a mask
function C.bias(m, v, b)
  b = b or {}
  m:each(function(x, y) b[K(x, y)] = (b[K(x, y)] or 0) + v end)
  return b
end
-- pillow-lit part with optional constant bias and texture fn
function C.part(c, m, ramp, o)
  o = o or {}
  local b = o.bias or {}
  if o.b then C.bias(m, o.b, b) end
  local idx, n = W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, bias = b, cuts = o.cuts, amb = o.amb, wrap = o.wrap })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx, n
end
-- re-paint pixels of an already-toned part with a different ramp, same index
function C.swap(c, m, idx, rampFn)
  m:each(function(x, y)
    local k = K(x, y)
    local r = rampFn(x, y)
    if r and idx[k] then c:put(x, y, r[idx[k]]) end
  end)
end
-- outline a mask's outer edge (inside pixels) in a colour
function C.rimIn(c, m, col, f)
  m:edge():each(function(x, y) if not f or f(x, y) then c:put(x, y, col) end end)
end
-- ink separation line drawn between two already-painted masks: pixels of `back` touching `front`
function C.inkSep(c, front, back) W.sep(c, front, back, W.ink) end
C.weave = function(x, y) if (x % 3 == 0 and y % 2 == 0) then return -1 end end
C.felt = function(x, y) local h = X.hash(x, y, 7) if h < .12 then return -1 elseif h > .93 then return 1 end end

function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = DIR .. "/" .. name .. ".aseprite", png = C.png .. name .. ".png", scale = 1 }
end
return C
