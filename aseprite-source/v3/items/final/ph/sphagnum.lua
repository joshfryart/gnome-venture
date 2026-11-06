-- sphagnum (lean D2o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sphagnum" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  local idx = G.tone(c, m, v, ramp)
  return v, idx, n
end
local MOSS = { "#2f4a2a", "#46702f", "#6c9a3a", "#96bf4c", "#c0dc6c", "#e3f08e" }
local PEAT = { "#2a1c16", "#43291d", "#5e3b28" }
local mound = HP.mask()
for _, b in ipairs{ {32,41,14,9}, {20,43,9,7}, {44,43,9,7}, {26,34,9,6}, {39,34,9,6}, {32,29,7,5} } do mound:add(c:ellipse(b[1], b[2], b[3], b[4])) end
mound:cut(c:rect(0, 49, 63, 63))
shade(mound, MOSS, 8)
-- peat base
mound:each(function(x, y) if y >= 47 then c:px(x, y, (y == 47 and (x % 2 == 0)) and PEAT[3] or (y >= 49 and PEAT[1] or PEAT[2])) end end)
-- fuzz
mound:each(function(x, y) if y < 47 then local h = X.hash(x, y, 5)
  if h > 0.86 then c:px(x, y, MOSS[5]) elseif h < 0.1 then c:px(x, y, MOSS[2]) end end end)
-- star rosettes
for _, s in ipairs{ {26,35}, {37,32}, {32,42}, {20,44}, {44,43}, {31,28}, {40,40}, {24,42} } do
  local x, y = s[1], s[2]
  local function p(a, b, hx) if mound:has(a, b) then c:px(a, b, hx) end end
  p(x-2,y+1,MOSS[2]) p(x+2,y+1,MOSS[2]) p(x,y+2,MOSS[2])
  p(x-1,y,MOSS[5]) p(x+1,y,MOSS[5]) p(x,y-1,MOSS[5]) p(x,y+1,MOSS[4]) p(x-2,y,MOSS[4]) p(x+2,y,MOSS[4]) p(x,y-2,MOSS[4])
  p(x,y,MOSS[6])
end
-- stems with sporophyte capsules and one rosy head (quirk)
local function stem(pts, hx) c:fillMask(c:line(pts, 1), hx) end
stem({ {25,30}, {24,21}, {23,15} }, "#b9cc8a")
stem({ {39,29}, {40,20}, {41,14} }, "#b9cc8a")
stem({ {32,26}, {33,19}, {32,17} }, "#a8c47a")
local CAP = { "#4a2a16", "#7a4a22", "#a8703a", "#d29a58" }
for _, h in ipairs{ {23,12}, {41,11} } do
  c:fillMask(c:ellipse(h[1], h[2], 2, 3), CAP[2])
  c:px(h[1], h[2]+2, CAP[1]) c:px(h[1]+1, h[2]+1, CAP[1]) c:px(h[1]-1, h[2]-1, CAP[4]) c:px(h[1], h[2]-2, CAP[3])
end
local RUB = { "#6a1c34", "#a02e4c", "#cf4e68", "#ee8294", "#ffb8c0" }
c:fillMask(c:ellipse(32, 15, 3, 3), RUB[3])
for _, p in ipairs{ {31,14,5}, {30,15,4}, {32,13,4}, {33,17,1}, {34,16,2}, {32,18,2}, {30,17,2}, {34,14,3}, {31,16,3} } do c:px(p[1], p[2], RUB[p[3]]) end
c:px(32, 15, RUB[2])
-- water drop
c:fillMask(c:ellipse(47, 46, 2, 2), "#4f9ed0")
c:px(46, 45, "#c8ecfa") c:px(48, 47, "#2f6aa0") c:px(47, 45, "#8fd0ec")
G.fin(c, "sphagnum")
