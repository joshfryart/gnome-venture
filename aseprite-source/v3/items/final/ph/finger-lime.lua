-- finger-lime (lean E2_01)
local NAME = "finger-lime"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, ceil = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.ceil
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function inter(a, b) local r = HP.mask() a:each(function(x, y) if b:has(x, y) then r:set(x, y) end end) return r end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local RIND = { "#1f3a22", "#2f5a2c", "#4a7d32", "#6f9e3c", "#9bc254", "#c8e28a" }
local PEARL = { "#8a2a4a", "#c43e5e", "#e8667a", "#f59aa0", "#ffd0c8" }
local BROWN = { "#2a1a14", "#4a2e1e", "#6e4a2c", "#8f6a3e" }
c:groundShadow(30, 56, 19, 3)
local tm, tn = G.tube({ {12,50}, {24,50}, {38,38}, {45,17} }, function(t) return 3.2 + 0.9 * sin(pi * t) end)
local tok = { r = { name = "rind" } }
local idx = X.tone(c, tm, X.light(tn, { amb = 0.08, wrap = 0.22 }), RIND, { cuts = CUTS, tok = tok })
tm:shrink(1):each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 5) > 0.88 and idx[k] >= 3 then c:put(x, y, RIND[idx[k] - 2], tok) end end)
local bx, by = G.specAt(tm, tn, 24)
if bx then c:put(bx, by, "#f4ffd0", tok) c:put(bx + 1, by + 1, RIND[6], tok) c:put(bx - 1, by - 1, RIND[6], tok) end
-- brown stem nub
local nub = c:ellipse(11, 50, 2.6, 3.4)
X.tone(c, nub, X.light(X.pillow(nub, 2.4), { amb = 0.1, wrap = 0.2 }), BROWN, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "nub" } } })
-- cut face with pearls
local ring = c:ellipse(45, 16, 5.4, 4.2)
local ftok = { r = { name = "face" } }
X.tone(c, ring, X.light(X.pillow(ring, 3), { amb = 0.15, wrap = 0.3 }), { "#6f9e3c", "#9bc254", "#c8e28a", "#e4efb0" }, { cuts = { 0.3, 0.55, 0.8 }, tok = ftok })
local inner = c:ellipse(45, 16, 4.0, 2.9)
inner:each(function(x, y)
  local cx, cy = floor(x / 2), floor(y / 2)
  local col = PEARL[2 + (cx * 3 + cy * 5) % 3]
  if x % 2 == 0 and y % 2 == 0 then col = PEARL[5] elseif x % 2 == 1 and y % 2 == 1 then col = PEARL[1] end
  c:put(x, y, col, ftok)
end)
-- spilled pearls
for i, p in ipairs{ {53,23}, {56,29}, {51,31}, {44,52} } do
  local t = { r = { name = "bead" .. i } }
  c:put(p[1], p[2], PEARL[4], t) c:put(p[1] + 1, p[2], PEARL[3], t)
  c:put(p[1], p[2] + 1, PEARL[2], t) c:put(p[1] + 1, p[2] + 1, PEARL[1], t)
  c:put(p[1], p[2], PEARL[5], t)
end
G.save(c, NAME)
