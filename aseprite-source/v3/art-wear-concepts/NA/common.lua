-- common.lua: Maplewold (NA) wear concepts. Reuses ../../gnome-wear/_gw.lua read-only (ramps, lit, vcyl...).
-- Run: AppRun -b --script-param png=<this dir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local N = setmetatable({ W = W, HP = HP, X = X, K = K, G = G, R = W.R, DIR = DIR }, { __index = W })
N.png = app.params.png or (DIR .. "/")

-- region ramps (dark -> light)
N.maple  = { "#5e1c2a", "#8a2632", "#b33a36", "#d4553c", "#ea7a4a", "#f8a86a" }
N.dkcheck= { "#2e2030", "#3a2a3a", "#4a3846", "#5c4854", "#715a64", "#8a7078" }
N.birch  = { "#5a5050", "#7e746c", "#a89e90", "#cbc2b0", "#e4dcc8", "#f4eedc" }
N.snow   = { "#5a6a8e", "#7c90b4", "#a2b8d4", "#c4d8ea", "#dfecf4", "#f2f8f6" }
N.gold   = { "#6a3e1a", "#9a5e1e", "#c88428", "#e6aa3a", "#f6cc5a", "#ffe8a0" }
N.navy   = { "#1a1e3e", "#252c5a", "#323e78", "#425696", "#5a74b4", "#86a2d2" }
N.aurora = { "#1d4a48", "#24705a", "#2e9a6a", "#48c07a", "#7ade8a", "#b8f2a8" }
N.slicker= { "#6a4a12", "#9a6e18", "#c89a22", "#e6c030", "#f6dc52", "#fff2a0" }
N.slate  = { "#283846", "#36506a", "#46688a", "#5c84a8", "#7ea4c4", "#b0cce0" }
N.knit   = { "#6a5a48", "#8e7c64", "#b0a084", "#cdbfa0", "#e4d8bc", "#f6eedc" }
N.duck   = { "#2e3424", "#434a30", "#5a623c", "#727a4a", "#8e955c", "#b0b47a" }
N.wheat  = { "#5e4426", "#86622e", "#a8823c", "#c6a050", "#dcbc6a", "#f0d894" }
N.rubber = { "#2a1c22", "#3a2830", "#4c363a", "#604846", "#785c52", "#927262" }
N.pine   = { "#16302a", "#1f4636", "#2a5e40", "#3a784a", "#529456", "#7cb46a" }

function N.canvas(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- lit part with a uniform tone bias
function N.lay(c, m, ramp, bias, o)
  o = o or {}
  local b = {}
  if bias and bias ~= 0 then m:each(function(x, y) b[K(x, y)] = bias end) end
  if o.biasf then m:each(function(x, y) b[K(x, y)] = (b[K(x, y)] or 0) + (o.biasf(x, y) or 0) end) end
  return W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, bias = b, cuts = o.cuts })
end
-- outline pixels of m (outer edge) in col
function N.rim(c, m, col) m:edge():each(function(x, y) c:put(x, y, col) end) end
-- pixels of m with nothing of m below / above
function N.bottom(m, f) m:each(function(x, y) if not m:has(x, y + 1) then f(x, y) end end) end
function N.top(m, f) m:each(function(x, y) if not m:has(x, y - 1) then f(x, y) end end) end
-- recolour pixels of m into another ramp at the same tone index
function N.swap(c, m, idx, ramp) m:each(function(x, y) local i = idx[K(x, y)] if i then c:put(x, y, ramp[i]) end end) end
function N.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = N.DIR .. "/" .. name .. ".aseprite", png = N.png .. name .. ".png", scale = 1 }
end
return N
