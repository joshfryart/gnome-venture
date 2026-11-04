-- stage-vegetable-4 (lean W2_27)
-- Ripe striped melon on a soil mound, two crescent leaves, hooked stem and curly tendril. Quirk: a ladybug on the rind.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 }) G.tone(c, m, v, ramp, o.cuts, o.bias) return n, v end
local function maskf(x0, y0, x1, y1, f) local m = HP.mask() for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end return m end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-vegetable-4" }
local SOIL = { "#2a1a1c", "#47291f", "#69402a", "#8c5b36", "#b0804a", "#cfa466" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local MEL  = { "#23504a", "#2f6e55", "#459063", "#65b16f", "#8fcf84", "#c4eba0" }
local STEM = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
c:groundShadow(32, 54, 22, 3)
-- soil mound
local mound = maskf(8, 44, 56, 56, function(x, y) return ((x - 32) / 24)^2 + ((y - 51) / 5.5)^2 <= 1 end)
shade(c, mound, SOIL, 4)
mound:each(function(x, y) if X.hash(x, y, 3) > 0.9 then c:px(x, y, SOIL[6]) elseif X.hash(x, y, 8) > 0.9 then c:px(x, y, SOIL[1]) end end)
-- crescent leaves (behind melon)
local function leaf(p, w)
  local m, n, T, S = G.tube(p, function(t) return w * sin(pi * min(1, t * 0.95 + 0.03)) ^ 0.7 end)
  shade(c, m, LEAF, w)
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.9 then c:px(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end
    if T[k] > 0.2 and T[k] < 0.8 and abs(abs(S[k]) - 0.55) < 0.12 and floor(T[k] * 22) % 3 == 0 then c:px(x, y, LEAF[2]) end end)
end
leaf({ {22, 49}, {5, 48}, {3, 32}, {14, 21} }, 4.6)
leaf({ {42, 49}, {59, 48}, {61, 32}, {50, 21} }, 4.6)
-- melon
local mm = maskf(16, 20, 48, 52, function(x, y) return ((x - 32) / 14.5)^2 + ((y - 37) / 14)^2 <= 1 end)
local n, v = X.pillow(mm, 13), nil
v = X.light(n, { amb = 0.08, wrap = 0.22 })
G.tone(c, mm, v, MEL, { 0.2, 0.38, 0.55, 0.72, 0.87 })
local inner = mm:copy():shrink(1)
inner:each(function(x, y)
  local u = max(-1, min(1, (x - 32) / 14.5))
  local a = math.asin(u) / (pi / 6)
  local d = abs(a - floor(a + 0.5))
  if d < 0.11 + 0.06 * (1 - abs(u)) and abs(floor(a + 0.5)) <= 2 then c:px(x, y, v[K(x, y)] > 0.55 and MEL[3] or MEL[1]) end
end)
mm:edge():each(function(x, y) if x > 32 and y > 38 then c:px(x, y, "#4f8f9a") end end)
c:px(25, 29, "#f4fff0") c:px(26, 29, "#f4fff0") c:px(25, 30, MEL[6]) c:px(27, 28, MEL[6])
-- ladybug quirk
c:px(38, 33, "#d83a38") c:px(39, 33, "#d83a38") c:px(38, 34, "#b02a30") c:px(39, 34, "#b02a30") c:px(38, 32, "#2b1c26") c:px(39, 35, "#2b1c26")
-- hooked stem
local sm, sn = G.tube({ {32, 25}, {32, 18}, {37, 12}, {43, 15} }, function(t) return 2.2 - 0.9 * t end)
shade(c, sm, STEM, 2.2)
c:fillMask(c:rect(29, 23, 35, 23), STEM[1])
-- tendril spiral
local pts = { {35, 20} }
for i = 0, 22 do local a = i * 0.45 local r = 6.5 - i * 0.22 pts[#pts + 1] = { floor(47 + r * cos(a + 3.3) + 0.5), floor(14 + r * sin(a + 3.3) + 0.5) } end
G.line(c, pts, STEM[2])
c:px(54, 10, STEM[4]) c:px(53, 9, STEM[3])
G.fin(c, "stage-vegetable-4")
