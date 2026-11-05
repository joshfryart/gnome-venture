-- hat-rootwarden (lean E2_02)
local NAME = "hat-rootwarden"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, nm, o)
  o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = CUTS, tok = { r = { name = nm or "p" } } })
  return idx, n
end
local function px(x, y, col, nm) c:put(x, y, col, { r = { name = nm or "d" } }) end
local function spec(m, n, col)
  local x, y = G.specAt(m, n, 30)
  if x then px(x, y, col or "#fff4dc", "spec") end
end
c:groundShadow(32, 58, 22, 2)
local HAT = { "#2e1c16", "#503024", "#76482c", "#9c6a3c", "#c4925a", "#e6bc86" }
local ROOT = { "#3a2218", "#5e3a24", "#85583a", "#b0805a", "#d6aa80" }
local LF = { "#17401f", "#236b2c", "#37923a", "#5cb848", "#8ad868", "#bdf090" }
-- hanging roots first (behind brim)
local function root(pts, w)
  local m, n = G.tube(pts, function(t) return w - 0.5 * t end)
  G.toneN(c, m, n, ROOT, { tok = { r = { name = "root" .. pts[1][1] } } })
end
root({ {16,46},{13,51},{17,55},{13,55} }, 1.6)
root({ {30,48},{32,53},{28,57},{31,56} }, 1.4)
root({ {45,46},{49,50},{45,55},{49,54} }, 1.6)
-- brim
local brim = c:ellipse(32, 43, 26, 8)
shade(brim, HAT, 8, "brim")
-- brim underside shadow row + stitch
brim:each(function(x, y) if y >= 47 then px(x, y, HAT[2], "bu") end end)
-- crown
local crown = c:poly{ {20,43}, {23,28}, {27,18}, {37,18}, {41,28}, {44,43} }
crown:add(c:ellipse(32, 20, 7, 4))
shade(crown, HAT, 7, "crown")
crown:each(function(x, y) if x % 3 == 0 and y < 33 and X.hash(x, y, 9) > 0.45 then px(x, y, HAT[2], "gr") end end)
-- woven band
crown:each(function(x, y) if y >= 35 and y <= 39 then
  local w = (x + y) % 2 == 0
  px(x, y, y == 39 and "#6a5018" or (w and "#d8b840" or "#a88a2c"), "band") end end)
for yy = 35, 39 do for xx = 30, 34 do px(xx, yy, (xx == 30 or xx == 34 or yy == 35 or yy == 39) and "#c8d0d8" or "#3a2a1c", "buck") end end
px(31, 36, "#f0f4f8", "buck")
-- sprout
local sm, sn = G.tube({ {32,18},{32,13},{33,10},{32,10} }, function(t) return 1 end)
G.toneN(c, sm, sn, LF, { tok = { r = { name = "stem" } } })
local function lf(ax, ay, cx, cy, bx, by, nm)
  local m, n = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 4 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.75) end, { fold = 0.5 })
  G.toneN(c, m, n, LF, { tok = { r = { name = nm } }, amb = 0.1, wrap = 0.25 })
  return m, n
end
lf(32, 11, 26, 6, 18, 10, "l1")
local m2, n2 = lf(33, 11, 40, 5, 48, 9, "l2")
spec(crown, X.pillow(crown, 7), "#fff0d0")
G.save(c, NAME)
