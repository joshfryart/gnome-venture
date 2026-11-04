-- starfruit (lean W2_27)
-- Ridged oblong carambola with wavy outline and green tips, plus a cut star slice with seeds. Quirk: a juice drip on the slice.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 }) G.tone(c, m, v, ramp, o.cuts, o.bias) return n, v end
local function maskf(x0, y0, x1, y1, f) local m = HP.mask() for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end return m end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "starfruit" }
local YEL = { "#8a4a1c", "#b9741f", "#e0a22c", "#f5c63e", "#ffe063", "#fff4a8" }
local GRN = { "#3a5a2a", "#5f8a32", "#8db13e", "#b5cf55" }
local STEM = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
c:groundShadow(34, 56, 24, 3)
local CX, Y0, Y1 = 22, 10, 52
local function hw(y) local t = (y - Y0) / (Y1 - Y0) return 9 * sin(pi * min(1, max(0, t))) ^ 0.5 + 0.7 * sin(y * 1.1) end
local fr = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do fr:set(x, y) end end
local n = X.pillow(fr, 9)
local v = X.light(n, { amb = 0.08, wrap = 0.25 })
G.tone(c, fr, v, YEL, { 0.2, 0.38, 0.55, 0.72, 0.88 })
fr:each(function(x, y)
  local h = hw(y)
  local f = (x - CX) / h
  for _, r in ipairs{ -0.62, -0.2, 0.22, 0.64 } do
    if abs(f - r) < 0.5 / h + 0.02 then c:px(x, y, v[K(x, y)] > 0.5 and YEL[3] or YEL[2]) end
  end
  if y < Y0 + 7 or y > Y1 - 7 then
    local g = (y < Y0 + 7) and (Y0 + 7 - y) or (y - (Y1 - 7))
    if g > 3 + X.hash(x, y, 2) * 2 then c:px(x, y, v[K(x, y)] > 0.55 and GRN[3] or GRN[2]) elseif g > 1.5 then c:px(x, y, v[K(x, y)] > 0.55 and YEL[4] or GRN[3]) end
  end
end)
-- ridge shadow edge + specular
fr:edge():each(function(x, y) if x > CX and y > 22 and y < 46 then c:px(x, y, YEL[1]) end end)
c:px(17, 20, "#fffbe8") c:px(17, 21, "#fffbe8") c:px(18, 19, YEL[6]) c:px(17, 24, YEL[6])
-- stem + tiny leaf
local sm = G.tube({ {22, 10}, {22, 7}, {24, 4}, {27, 4} }, function(t) return 1.5 - 0.4 * t end)
shade(c, sm, STEM, 1.5)
c:fillMask(c:ellipse(29, 3, 2, 1), GRN[3]) c:px(30, 3, GRN[4])
-- star slice
local cx, cy, Ro, Ri = 46, 40, 13, 6.2
local star = maskf(30, 24, 62, 56, function(x, y)
  local dx, dy = x - cx, y - cy
  local ang = math.atan(dy, dx) + pi / 2
  local s = (ang % (2 * pi / 5)) / (2 * pi / 5)
  local k = 1 - abs(s * 2 - 1)
  local r = Ri + (Ro - Ri) * (k ^ 0.9)
  return sqrt(dx*dx + dy*dy) <= r * 0.5 + (Ro * 0.5) * (k ^ 0.9) * 0.0 + r * 0.5
end)
local sn = X.pillow(star, 5)
local sv = X.light(sn, { amb = 0.18, wrap = 0.35 })
G.tone(c, star, sv, YEL, { 0.12, 0.26, 0.4, 0.58, 0.8 })
local rind = star:copy():shrink(2)
star:copy():cut(rind):each(function(x, y) c:px(x, y, GRN[3]) end)
star:copy():cut(star:copy():shrink(1)):each(function(x, y) if x + y < 84 then c:px(x, y, GRN[4]) end end)
rind:each(function(x, y) if (x - cx)^2 + (y - cy)^2 < 9 then c:px(x, y, YEL[6]) end end)
c:px(43, 38, "#6b3a1c") c:px(44, 39, "#6b3a1c") c:px(49, 43, "#6b3a1c") c:px(48, 42, "#8a4a1c")
c:px(41, 33, "#fffbe8") c:px(42, 33, "#fffbe8") c:px(40, 35, YEL[6])
-- juice drip (quirk)
c:px(52, 52, YEL[5]) c:px(52, 53, YEL[4]) c:px(52, 54, YEL[3])
G.fin(c, "starfruit")
