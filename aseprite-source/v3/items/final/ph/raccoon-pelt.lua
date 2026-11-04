-- raccoon-pelt (lean W2_15)
-- Flat spread pelt: head with bandit mask, four paw-tipped limbs, belly seam stitched with red thread, ringed tail curling out.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "raccoon-pelt" }
local abs, sqrt, floor = math.abs, math.sqrt, math.floor
local FUR  = { "#2f2c3a", "#4a4756", "#6a6776", "#8b8896", "#aeabb6", "#d2cfd4" }
local DARK = { "#1e1a24", "#2f2a36", "#473f4a", "#645a62" }
local CREAM = { "#8a8290", "#b4adb4", "#d9d3d3", "#f3eeea" }
local THREAD = "#d4453a"
-- tail first (behind body)
local tm, tn, T = G.tube({ {33, 46}, {30, 58}, {44, 62}, {52, 55} }, function(t) return 4.0 - 1.4 * t end)
tm:cut(c:rect(0, 59, 63, 63))
local tv = X.light(X.pillow(tm, 5), { amb = 0.15, wrap = 0.3 })
tm:each(function(x, y) local t = T[K(x, y)] or 0
  if t > 0.15 and floor(t * 8) % 2 == 1 then tv[K(x, y)] = tv[K(x, y)] - 0.3 end
  if X.hash(x, y, 1) > 0.88 then tv[K(x, y)] = tv[K(x, y)] + 0.12 end end)
G.tone(c, tm, tv, FUR, { 0.18, 0.34, 0.5, 0.68, 0.85 })
tm:each(function(x, y) local t = T[K(x, y)] or 0 if t > 0.88 then c:px(x, y, DARK[2]) end end)
-- body
local L = { {26,19},{19,21},{10,23},{7,27},{9,30},{15,31},{23,31},{22,38},{14,42},{11,47},{15,50},{23,47},{29,49} }
local pts = {}
for _, p in ipairs(L) do pts[#pts + 1] = p end
for i = #L, 1, -1 do pts[#pts + 1] = { 64 - L[i][1], L[i][2] } end
local body = c:poly(pts)
local bn = X.pillow(body, 7)
local bv = X.light(bn, { amb = 0.25, wrap = 0.3 })
body:each(function(x, y) local h = X.hash(x, y, 5)
  if h > 0.9 then bv[K(x, y)] = bv[K(x, y)] + 0.16 elseif h < 0.09 then bv[K(x, y)] = bv[K(x, y)] - 0.16 end
  if (x + 2 * y) % 7 == 0 and h > 0.4 then bv[K(x, y)] = bv[K(x, y)] - 0.08 end end)
G.tone(c, body, bv, FUR, { 0.18, 0.34, 0.5, 0.68, 0.85 })
-- paws
for _, p in ipairs{ {8, 28}, {56, 28}, {12, 48}, {52, 48} } do
  body:each(function(x, y) local d = sqrt((x - p[1])^2 + (y - p[2])^2)
    if d < 3.6 then c:px(x, y, (x + y) % 3 == 0 and DARK[3] or DARK[2]) end end)
end
-- belly seam with stitches
for y = 33, 46 do c:px(32, y, FUR[2]) end
for y = 34, 46, 3 do c:px(31, y, THREAD) c:px(33, y, THREAD) c:px(32, y, THREAD) end
-- head
local head = c:ellipse(32, 13, 10, 8)
local ears = c:ellipse(23, 7, 3, 3):add(c:ellipse(41, 7, 3, 3))
head:add(ears)
local hv = X.light(X.pillow(head, 7), { amb = 0.25, wrap = 0.3 })
head:each(function(x, y) local h = X.hash(x, y, 9) if h > 0.9 then hv[K(x, y)] = hv[K(x, y)] + 0.15 elseif h < 0.08 then hv[K(x, y)] = hv[K(x, y)] - 0.15 end end)
G.tone(c, head, hv, FUR, { 0.18, 0.34, 0.5, 0.68, 0.85 })
c:fillMask(c:ellipse(23, 7, 1, 1), CREAM[2]) c:fillMask(c:ellipse(41, 7, 1, 1), CREAM[1])
-- white brow and cheeks, bandit mask, eyes, snout
c:fillMask(c:ellipse(32, 9, 6, 1), CREAM[3])
c:fillMask(c:ellipse(25, 15, 2, 2), CREAM[3]) c:fillMask(c:ellipse(39, 15, 2, 2), CREAM[3])
local mask = c:ellipse(27, 12, 4, 2):add(c:ellipse(37, 12, 4, 2)):add(c:rect(29, 12, 35, 12))
c:fillMask(mask, DARK[2])
c:px(27, 11, "#f0d878") c:px(37, 11, "#f0d878") c:px(27, 12, DARK[1]) c:px(37, 12, DARK[1])
c:fillMask(c:ellipse(32, 16, 3, 2), CREAM[3]) c:px(31, 14, CREAM[4]) c:px(32, 14, DARK[1]) c:px(31, 14, DARK[1]) c:px(33, 14, DARK[1])
c:px(32, 17, DARK[1]) c:px(32, 18, DARK[3])
c:px(32, 5, FUR[6]) c:px(31, 6, FUR[5])
G.fin(c, "raccoon-pelt")
