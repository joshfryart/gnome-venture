-- scorpion-plate (lean W2_17)
-- Chitin breastplate: shingled tergite bands narrowing downward under a domed carapace with keel and two eyes,
-- granulated amber shell, leather side straps. Quirk: a tiny stinger charm hangs from the bottom band.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function lit(m, R, amb, wrap) return X.light(X.pillow(m, R), { amb = amb or 0.08, wrap = wrap or 0.25 }) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scorpion-plate" }
local AM = { "#3a2218", "#6a3d22", "#9a5e2c", "#c58a3c", "#e6b45a", "#fadc92" }
local LT = { "#2e1a1c", "#52302a", "#7c4c38", "#a67352" }
local ST = { "#2a1a2a", "#4a2c3a", "#7a4a54" }
local CUT = { 0.2, 0.38, 0.55, 0.72, 0.88 }
-- straps (behind)
local function strap(p)
  local m, n, T = G.tube(p, function(t) return 1.6 end)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.3 }), LT, { 0.3, 0.55, 0.8 })
  m:each(function(x, y) if (T[K(x, y)] * 9) % 1 < 0.15 then c:px(x, y, LT[1]) end end)
end
strap({ {22, 14}, {10, 14}, {8, 28}, {14, 38} })
strap({ {42, 14}, {54, 14}, {56, 28}, {50, 38} })
-- bands, bottom up
local bands = { {24, 52, 8}, {22, 45, 10}, {20, 38, 12}, {19, 31, 13}, {18, 24, 14} }
local function band(y0, y1, hw, id)
  local m = c:rrect(32 - hw, y0, 32 + hw - 1, y1, 4)
  local v = lit(m, 5, 0.06, 0.2)
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    if y >= y1 - 1 then bias[k] = -1 end
    if (x * 7 + y * 13) % 11 == 0 and X.hash(x, y, id) > 0.4 then bias[k] = 1 end
  end)
  G.tone(c, m, v, AM, CUT, bias)
  m:each(function(x, y)
    if abs(x - 32) <= 0.5 and y < y1 - 1 then c:px(x, y, AM[5]) end
    if abs(x - 32) == 2 and y < y1 - 1 and y > y0 + 1 then c:px(x, y, AM[2]) end
  end)
  -- side spikes
  c:px(32 - hw - 1, y1 - 3, AM[4]) c:px(32 - hw - 2, y1 - 4, AM[5])
  c:px(32 + hw, y1 - 3, AM[2]) c:px(32 + hw + 1, y1 - 4, AM[3])
end
band(46, 54, 8, 1) band(39, 47, 10, 2) band(32, 40, 12, 3)
-- stinger charm (quirk), hangs from bottom band
local sm, sn = G.tube({ {32, 53}, {32, 57}, {38, 58}, {37, 53} }, function(t) return 1.5 * (1 - t) + 0.5 end)
G.tone(c, sm, X.light(sn, { amb = 0.1, wrap = 0.3 }), { "#2a1a2a", "#5a2c4a", "#8e4a6a", "#c07a8a" }, { 0.3, 0.55, 0.8 })
c:px(37, 53, "#fff0e0")
-- upper band and carapace
band(25, 33, 13, 4)
local car = c:rrect(18, 9, 45, 26, 6)
local cv = lit(car, 9, 0.05, 0.2)
local cb = {}
car:each(function(x, y) local k = K(x, y)
  if y >= 25 then cb[k] = -1 end
  if (x * 5 + y * 9) % 10 == 0 and X.hash(x, y, 9) > 0.35 then cb[k] = 1 end
end)
G.tone(c, car, cv, AM, CUT, cb)
car:each(function(x, y)
  if abs(x - 32) <= 0.5 and y > 19 and y < 25 then c:px(x, y, AM[5]) end
  if abs(abs(x - 32) - 7) < 0.6 and y > 18 and y < 24 then c:px(x, y, AM[2]) end
end)
-- eyes mound + eyes
local mound = c:ellipse(32, 15, 6.5, 4)
G.tone(c, mound, lit(mound, 4, 0.05, 0.2), AM, CUT)
for _, e in ipairs{ {29, 15}, {35, 15} } do
  local em = c:ellipse(e[1], e[2], 1.7, 1.9)
  c:fillMask(em, ST[1]) c:px(e[1] - 1, e[2] - 1, "#fff0e0")
end
c:px(25, 17, ST[1]) c:px(39, 17, ST[1]) c:px(24, 18, ST[2]) c:px(40, 18, ST[2])
c:px(22, 12, AM[6]) c:px(23, 12, AM[6]) c:px(23, 11, AM[5])
c:sparkle(50, 10)
G.fin(c, "scorpion-plate")
