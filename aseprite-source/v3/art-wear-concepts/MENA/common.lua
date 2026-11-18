-- common.lua: shared helpers for the MENA "Dunewhisper" wear concepts (Hearth Pop v3).
-- Read-only reuse of v3/gnome-wear/_gw.lua (ramps, pillow lighting, centre). Saves into THIS folder.
-- Run: AppRun -b --script-param png=<outdir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({}, { __index = W })
local max, min, floor = math.max, math.min, math.floor
C.DIR = DIR
C.out = app.params.png or (DIR .. "/")

-- region ramps, dark -> light
C.R = setmetatable({
  sand   = { "#6e4a34", "#94663f", "#b8874f", "#d4a865", "#e8c886", "#f6e2b0" },
  ochre  = { "#6a3418", "#9a521c", "#c4761e", "#e09a2c", "#f2bf4a", "#fbe08a" },
  indigo = { "#1a1a44", "#24286a", "#2e3a8e", "#3e56ac", "#5a7cc8", "#8eaee0" },
  madder = { "#4e1626", "#7a2030", "#a32e36", "#c4443c", "#dc6450", "#ee9070" },
  palm   = { "#4a3a1e", "#6e5628", "#957a36", "#b89c4a", "#d4bc66", "#ecda96" },
  cedar  = { "#3a1e18", "#5c2e20", "#7e4228", "#a05a32", "#c07a42", "#dc9e5e" },
  copper = { "#4a1e18", "#7a3020", "#a8482a", "#cc6a36", "#e8925a", "#f8c294" },
  camel  = { "#4e3222", "#74492e", "#98643a", "#b8824a", "#d2a062", "#e8c48a" },
  goat   = { "#1e1620", "#2e2228", "#3e3030", "#52403a", "#6a5446", "#86705a" },
  teal   = { "#123a3e", "#185452", "#1f6e66", "#2a8a7a", "#45a892", "#7ccab0" },
  gourd  = { "#5a2e14", "#8a4a1a", "#b8681e", "#d88c2a", "#eeb04a", "#f8d47e" },
  date   = { "#2e1218", "#4a1a1e", "#6a2422", "#8a3426", "#a84a30", "#c8683e" },
  mint   = { "#1c3a26", "#25573a", "#2f7444", "#3f9150", "#62b25e", "#9ad27c" },
  turq   = { "#16485a", "#1e6e80", "#2896a0", "#3cb8b4", "#6ed6c4", "#b4f0dc" },
  rose   = { "#5a1838", "#842448", "#ac3658", "#cc5068", "#e47884", "#f4a8a4" },
  linen  = { "#5a4a3e", "#7e6a56", "#a08a6e", "#c0ac8a", "#dccaa6", "#f2e6c8" },
}, { __index = W.R })
local R = C.R

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- constant bias map over mask
function C.bmap(m, b, t)
  t = t or {}
  if b and b ~= 0 then m:each(function(x, y) t[K(x, y)] = (t[K(x, y)] or 0) + b end) end
  return t
end
-- pillow-lit layer with optional flat bias and texture fn
function C.lay(c, m, ramp, o)
  o = o or {}
  local bias = o.bmap or C.bmap(m, o.bias)
  local idx, n = W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, bias = bias, cuts = o.cuts, amb = o.amb, wrap = o.wrap })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx, n
end
-- lit tube along bezier (from _bbg)
function C.tube(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = G.tube(pts, wfn, { steps = o.steps })
  local idx = W.toneN(c, m, n, ramp, { bias = o.bias and C.bmap(m, o.bias) or nil, cuts = o.cuts })
  return m, idx, T, S
end
function C.mask() return HP.mask() end
-- 1px line of colour clipped to optional mask
function C.stroke(c, pts, col, clip)
  c:line(pts, 1):each(function(x, y) if not clip or clip:has(x, y) then c:put(x, y, col) end end)
end
-- darken the bottom edge / lighten the top-left edge of a mask
function C.rimlight(c, m, hi, lo)
  m:each(function(x, y)
    if lo and not m:has(x, y + 1) then c:put(x, y, lo)
    elseif hi and (not m:has(x, y - 1) or not m:has(x - 1, y)) then c:put(x, y, hi) end
  end)
end
C.weave = function(x, y, i) if (x % 3 == 0 and y % 2 == 0) or (x % 3 == 1 and y % 2 == 1 and X.hash(x, y, 2) < .3) then return -1 end end
C.wool = function(x, y, i) if (x + y) % 4 == 0 and X.hash(x, y, 5) < 0.6 then return -1 elseif X.hash(x, y, 9) > 0.93 then return 1 end end

function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = DIR .. "/" .. name .. ".aseprite", png = C.out .. name .. ".png", scale = 1 }
end
return C
