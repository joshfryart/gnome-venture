-- silverfish-scales (lean E2_07)
local NAME = "silverfish-scales"
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
-- quirk: one scale carries a rainbow shimmer along its rim, and a drop of moisture
c:groundShadow(32, 56, 22, 3)
local PAL = { "#3c4666", "#59658c", "#7a88ae", "#a0acce", "#c4cee6", "#e4eaf6" }
local PAL2 = { "#46406c", "#625a8c", "#837aae", "#a89ece", "#cac2e8", "#e8e4f6" }
-- fan scale: root at (rx,ry), pointing angle a, length L, half-spread
local function scale(rx, ry, a, L, ramp, name, rib)
  local m = HP.mask()
  for y = ry - L - 2, ry + L + 2 do for x = rx - L - 2, rx + L + 2 do
    local dx, dy = x - rx, y - ry
    local r = sqrt(dx * dx + dy * dy)
    local ang = math.atan(dy, dx) - a
    while ang > pi do ang = ang - 2 * pi end while ang < -pi do ang = ang + 2 * pi end
    local lim = 1.02 * (0.35 + 0.65 * min(1, r / (L * 0.55)))
    if abs(ang) <= lim and r <= L * (0.93 + 0.07 * cos(ang * 5)) and r >= 1 then m:set(x, y) end
  end end
  local n, tok = shade(c, m, ramp, 7, name, 0.08, 0.22)
  -- radial ribs and growth arcs
  m:each(function(x, y)
    local dx, dy = x - rx, y - ry
    local r = sqrt(dx * dx + dy * dy)
    local ang = math.atan(dy, dx) - a
    local k = floor(ang * rib / 0.55 + 0.5)
    if r > 5 and abs(ang * r - k * (0.55 / rib) * r) < 0.5 and ((x + y) % 2 == 0) then c:put(x, y, ramp[2], tok) end
    if abs(r - L * 0.55) < 0.55 and r > 4 then c:put(x, y, ramp[2], tok) end
  end)
  return m, tok, n
end
local aL = scale(22, 42, -1.9, 17, PAL, "sA", 3)
local aR = scale(42, 42, -1.25, 17, PAL2, "sB", 3)
local aF = scale(32, 55, -1.57, 19, PAL, "sC", 3)
-- bright rim catch on front scale and the shimmer quirk on the right one
local fm = c:poly({{0,0}})
aR:edge():each(function(x, y) if y < 34 and x > 38 then local t = (x + y) % 4 c:put(x, y, ({ "#f2a0c8", "#ffe08a", "#8ee8c8", "#a8b8ff" })[t + 1], { r = { name = "shim" } }) end end)
c:put(26, 36, "#e4eaf6") c:put(27, 36, "#e4eaf6") c:put(26, 37, "#c4cee6")
-- water drop
c:put(52, 50, "#7ab8e8") c:put(53, 50, "#b4e0f8") c:put(52, 51, "#4a86c0") c:put(53, 51, "#7ab8e8") c:put(52, 52, "#3a66a0")
c:sparkle(10, 22)
G.save(c, NAME)
