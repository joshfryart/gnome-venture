-- snake-skin (lean E2_07)
local NAME = "snake-skin"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, name, amb, wrap)
  local n = X.pillow(m, R)
  local tok = { r = { name = name } }
  X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.25 }), ramp, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = tok })
  return n, tok
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- quirk: the shed skin still has two hollow eye-caps at its head and a torn notch
c:groundShadow(32, 57, 22, 3)
local sm, sn, ST = G.tube({ {10,50}, {6,12}, {56,58}, {52,16} }, function(t) if t > 0.9 then return 4 + (1 - t) * 40 end return 4.2 + 5 * sin(pi * min(1, t * 1.1)) ^ 0.6 end)
local PAL = { "#6a6a3c", "#8a8a4c", "#a8a85e", "#c4c47a", "#dcdc9a", "#f0efba" }
local tok = { r = { name = "skin" } }
local v = X.light(sn, { amb = 0.1, wrap = 0.3 })
local idx = X.tone(c, sm, v, PAL, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = tok })
-- diamond lattice (dark diamonds alternate), scale edges
sm:each(function(x, y) local k = K(x, y) local i = idx[k]
  local a, b = (x + y) % 6, (x - y) % 6
  local da, db = floor((x + y) / 6), floor((x - y) / 6)
  if (da + db) % 2 == 0 and a > 0 and a < 5 and b > 0 and b < 5 and abs(a - 2.5) + abs(b - 2.5) < 3 then c:put(x, y, PAL[math.max(1, i - 2)], tok)
  elseif a == 0 or b == 0 then c:put(x, y, PAL[math.min(6, i + 1)], tok) end
end)
-- head end (t near 1): empty eye caps, hollow
local hx, hy = 50, 22
c:ellipse(49, 20, 1.5, 1.5):each(function(x, y) c:put(x, y, "#2b1c26", tok) end)
c:ellipse(54, 21, 1.5, 1.5):each(function(x, y) c:put(x, y, "#2b1c26", tok) end)
c:put(49, 19, "#f0efba") c:put(54, 20, "#f0efba")
-- torn notch in the tail end
for _, p in ipairs{ {12,52},{13,53},{11,51} } do end
c:sparkle(30, 30)
G.save(c, NAME)
