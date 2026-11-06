-- _aR0_2.lua: private helpers for ico-thermometer, ico-thumbs-down, ico-thumbs-up, ico-tier-advanced (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local D = setmetatable({}, { __index = G })
D.INK, D.CREAM = "#2b1c26", "#fff4d6"
D.CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }
-- 6-tone ramps, dark -> light
D.SKIN  = { "#6e3434", "#a35a45", "#cf835f", "#eaa677", "#f8c99c", "#ffe7c6" }
D.MOSS  = { "#1d4a40", "#2c6a49", "#3f9150", "#62b157", "#8fcf69", "#c8e67e" }
D.EMBER = { "#5a1a34", "#8c2539", "#b8303f", "#e44a3a", "#ff7c55", "#ffb48a" }
D.GOLD  = { "#74391c", "#a5591f", "#d98322", "#f5b82e", "#ffd65c", "#fff0a6" }
D.TEAL  = { "#1f3d66", "#2a5d8c", "#3a86b0", "#56b8c4", "#8be0d6", "#d2f8ec" }
D.GLASS = { "#4f86b8", "#7fb6dc", "#a9d8ee", "#c9ebf6", "#e6f8fb", "#fffaf0" }
D.CARD  = { "#4a3530", "#6e5242", "#94735a", "#c2a585", "#e9d8b8" }
function D.new(name)
  D.name = name
  return HP.canvas{ w = 64, h = 64, scale = 1, name = name }
end
-- pillow-lit part with a 6-tone ramp; returns idx, n
function D.lit(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 3, o.hs)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or D.CUTS, bias = o.bias, tok = o.tok })
  return idx, n
end
-- paint pixels of mask m (not in `excl`) that 4-touch mask `other` with hex
function D.seam(c, m, other, hex)
  local g = other:grow(1)
  m:each(function(x, y) if g:has(x, y) and not other:has(x, y) then c:put(x, y, hex) end end)
end
function D.put(c, pts, hex) for _, p in ipairs(pts) do c:put(p[1], p[2], hex) end end
function D.save(c)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or "./"
  c:save{ aseprite = out .. D.name .. ".aseprite", png = out .. D.name .. ".png", scale = 1 }
end
return D
