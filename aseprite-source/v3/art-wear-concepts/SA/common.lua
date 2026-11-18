-- common.lua: shared helpers for the SA (Rainroot Reaches) wearable concept icons.
-- Read-only reuse of v3/gnome-wear/_gw.lua (ramps, pillow lighting). Saves into THIS folder only.
-- Run: AppRun -b --script-param png=<this dir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
local max, min = math.max, math.min
C.out = app.params.png or (DIR .. "/")

C.R = setmetatable({
  latex  = { "#5a2e14", "#8a4a1a", "#b8701e", "#d8962e", "#eebd52", "#fbe08a" }, -- rubber-tree latex
  alpaca = { "#6a5444", "#927660", "#b59a7c", "#d2bc98", "#e8d8b6", "#f8eed4" }, -- cream fleece
  indigo = { "#1a1c40", "#262c60", "#323f80", "#4458a0", "#6278be", "#8ea2da" },
  straw  = { "#5e4018", "#86601e", "#ad8228", "#cca23a", "#e2c25a", "#f4e08e" },
  balsa  = { "#6a4a30", "#946c46", "#b8905c", "#d4b078", "#e8cc98", "#f6e4bc" },
  leafG  = { "#173a2a", "#1f5434", "#2a6e3a", "#3c8c40", "#5cac48", "#94cc5e" },
  leafY  = { "#2a4a1e", "#3e6a24", "#58882c", "#76a636", "#9cc44c", "#cce276" },
  gourd  = { "#5c3416", "#86501e", "#ae6e26", "#cc8e34", "#e2b04e", "#f2d07a" },
  palm   = { "#3a4018", "#56601e", "#748228", "#94a034", "#b4bc4c", "#d4d878" },
  string = { "#5a4a3c", "#7e6a54", "#a08a6c", "#bca888", "#d6c4a2", "#ece0c2" },
  passion= { "#2e1a3a", "#4a2650", "#6a3466", "#8a4a7c", "#a86894", "#c890b0" },
  bark   = { "#5a3a24", "#7e5634", "#a07448", "#bc925e", "#d4b07c", "#e8cea0" },
  cacao  = { "#2e1a1a", "#45261e", "#5e3426", "#7a4630", "#985c3c", "#b8784c" },
  mist   = { "#4a4058", "#6a5e7c", "#8a80a0", "#a8a0bc", "#c6c0d6", "#e2def0" },
  pink   = { "#6a1a3a", "#9a2a52", "#c8406a", "#e06486", "#f08ea6", "#fcc0cc" },
  turq   = { "#14484a", "#1e6a66", "#2a8c80", "#3cae98", "#66ccb0", "#a4e8cc" },
  frog   = { "#1b4a2a", "#24702e", "#38962e", "#5cba34", "#8ed448", "#c4ec7a" },
}, { __index = W.R })

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light a mask with its own normals, but pick the ramp per pixel (stripes, patches)
function C.multi(c, m, n, rampAt, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts = o.cuts or W.CUTS
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local val, i = v[k] or 0, 1
    for j, t in ipairs(cuts) do if val >= t then i = j + 1 end end
    if o.bias then i = i + (type(o.bias) == "number" and o.bias or (o.bias[k] or 0)) end
    i = max(1, min(6, i))
    idx[k] = i
    c:put(x, y, rampAt(x, y)[i])
  end)
  return idx
end
function C.litm(c, m, rampAt, o)
  o = o or {}
  return C.multi(c, m, X.pillow(m, o.R or 3, o.hs), rampAt, o)
end
-- uniform-bias pillow lighting
function C.lit(c, m, ramp, o)
  o = o or {}
  if type(o.bias) == "number" then local b, bb = o.bias, {} m:each(function(x, y) bb[K(x, y)] = b end) o.bias = bb end
  return W.lit(c, m, ramp, o)
end
-- recolour pixels already toned (idx) with another ramp where f(x,y) true
function C.swap(c, m, idx, ramp, f)
  m:each(function(x, y) local i = idx[K(x, y)] if i and f(x, y) then c:put(x, y, ramp[i]) end end)
end
function C.edgeLo(c, m, col) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, col) end end) end

function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = DIR .. "/" .. name .. ".aseprite", png = C.out .. name .. ".png", scale = 1 }
end
return C
