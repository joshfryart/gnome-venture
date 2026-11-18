-- common.lua: shared helpers for the SEA "Monsoon Tangle" wearable concepts (Hearth Pop v3).
-- Read-only reuse of v3/gnome-wear/_gw.lua (ramps, pillow lighting, sep/retone). Saves into THIS folder.
-- Run: AppRun -b --script-param png=<outdir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
C.png = app.params.png or (DIR .. "/")
local floor, max, min = math.floor, math.max, math.min

-- region ramps, dark -> light (6 tones)
local R = setmetatable({}, { __index = W.R })
C.R = R
R.pandan = { "#3b3a1e", "#5a5a26", "#7d7a30", "#a39a3c", "#c8b850", "#e6d67a" } -- green palm leaf strip
R.straw  = { "#4e3420", "#7a5228", "#a6772f", "#c99a40", "#e2bc5c", "#f4dc8c" } -- dried palm frond
R.rattan = { "#5a3418", "#8a5420", "#b47a2a", "#d29a3a", "#e8bc56", "#f8dc8a" } -- split cane
R.indigo = { "#18183c", "#22265a", "#2e3c7c", "#3e5698", "#5c78b6", "#8aa2d2" }
R.wax    = { "#6a7698", "#94a0bc", "#b8c2d4", "#d8dcd8", "#ece6d4", "#f6f0dc" } -- wax-resist pale
R.leaf   = { "#173a26", "#1f5a2c", "#2c7a32", "#40983a", "#64b848", "#a0dc6c" } -- banana leaf
R.jade   = { "#1e3e3a", "#2a5e52", "#3c7e68", "#5aa080", "#86c49e", "#c0e6c4" } -- celadon glaze
R.clay   = { "#4a2018", "#72321e", "#9a4a26", "#be6632", "#da8a48", "#f0b26c" }
R.olive  = { "#22261a", "#343a22", "#4a522c", "#646c36", "#808a44", "#a6ae60" } -- waxed oilcloth
R.sage   = { "#2a3a32", "#3c5444", "#547056", "#6e8c68", "#8eaa80", "#b8cc9e" } -- kapok quilt
R.mango  = { "#7a2e14", "#a84a18", "#d06e1c", "#ec9422", "#f8b83a", "#ffdc72" } -- rubberised poncho
R.mint   = { "#3e5e5a", "#5a807a", "#7aa49a", "#9cc4b4", "#c0dece", "#e2f2e4" } -- netting
R.soga   = { "#2e1a14", "#4a2a1c", "#6a3e24", "#8c5630", "#b0743e", "#d49a5a" } -- brown batik dye
R.mudrub = { "#1e2a2a", "#2c3e3a", "#3e564c", "#56705e", "#728c70", "#9cb08c" } -- grey-green rubber
R.gecko  = { "#3e4a1e", "#5c6e24", "#7e9230", "#a2b440", "#c6d45e", "#e4ec9a" }
R.petal  = { "#8a5a4a", "#c08a6a", "#e2bc96", "#f2dcbc", "#fbead0", "#fff4d6" } -- frangipani / kapok fluff
R.hibis  = { "#5a1428", "#8a1e34", "#b8283c", "#dc3c48", "#f2645a", "#ff9a7e" }
R.orchid = { "#3c1840", "#62245e", "#8a3484", "#b450a8", "#d47cc6", "#f0b4e2" }
R.king   = { "#14305a", "#1c4a8a", "#2468b4", "#2e8ad4", "#4cb0ea", "#9adcf6" } -- kingfisher blue
R.cream  = "#f2e2b8"

function C.canvas(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function C.bmap(m, v, into)
  local b = into or {}
  if v and v ~= 0 then m:each(function(x, y) b[K(x, y)] = (b[K(x, y)] or 0) + v end) end
  return b
end
-- pillow-lit with a constant bias
function C.lit(c, m, ramp, bias, o)
  o = o or {}
  o.bias = C.bmap(m, bias, o.bias)
  return W.lit(c, m, ramp, o)
end
-- repaint pixels of m where f(x,y) is true using ramp2 at the same tone index (+d)
function C.motif(c, m, idx, ramp2, f, d)
  m:each(function(x, y)
    local i = idx[K(x, y)]
    if i and f(x, y, i) then c:put(x, y, ramp2[max(1, min(#ramp2, i + (d or 0)))]) end
  end)
end
-- textures (retone deltas)
function C.check(s) return function(x, y) if ((x // s) + (y // s)) % 2 == 0 then return -1 end end end
function C.twill(s) return function(x, y) if (x + y) % s == 0 then return -1 elseif (x - y) % (s * 2) == 0 then return 1 end end end
function C.bottomEdge(c, m, col) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, col) end end) end
function C.flower(c, cx, cy, ramp, centre)
  -- 5-petal blossom, ~7 px
  local pts = { {0,-2}, {-2,-1}, {2,-1}, {-1,1}, {1,1}, {-1,-2}, {1,-2}, {-2,0}, {2,0}, {-2,1}, {2,1}, {-1,2}, {1,2}, {0,0}, {0,-1}, {-1,0}, {1,0}, {0,1} }
  for _, p in ipairs(pts) do
    local lx = (p[1] < 0 or p[2] < 0) and 5 or 3
    c:put(cx + p[1], cy + p[2], ramp[lx])
  end
  c:put(cx - 2, cy - 1, ramp[6]) c:put(cx - 1, cy - 2, ramp[6])
  c:put(cx, cy, centre) c:put(cx + 1, cy + 1, ramp[2]) c:put(cx, cy + 2, ramp[2])
end

function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.png .. name .. ".png", scale = 1 }
end
return C
