-- hat-rootwarden (lean W2_6)
local NAME = "hat-rootwarden"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, amb, wrap)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = {.22,.4,.56,.72,.86} })
  return v, n
end
local c = HP.canvas{ w=64, h=64, scale=1, name=NAME }
local BARK = { "#3a2230", "#5a3a3a", "#7d5440", "#a07350", "#c49a68", "#e6c68e" }
local DOME = { "#3f2a2c", "#664434", "#8c6140", "#b08550", "#d3ab6c", "#f0d28e" }
local GOLD = { "#6b4a1e", "#9a6a22", "#c8932c", "#e8b83c", "#f6d868", "#fff2a8" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 57, 20, 2)
-- hanging root legs under brim (drawn first, brim covers tops)
local roots = { {14,41,12,50,14,56}, {22,43,21,52,19,57}, {32,44,33,53,32,58}, {42,43,44,52,46,57}, {50,41,52,49,50,55} }
for _, r in ipairs(roots) do
  local m, n = G.tube({ {r[1], r[2]}, {r[3], r[4]}, {r[3], r[4]+1}, {r[5], r[6]} }, function(t) return 2.0 - 1.3*t end)
  shade(c, m, 2, BARK)
end
-- brim: wide flat ellipse, bark grain
local brim = HP.mask() brim:add(c:ellipse(32, 40, 25, 7))
local v = shade(c, brim, 9, BARK, 0.15, 0.3)
brim:each(function(x, y) if (x + y*3) % 7 == 0 and X.hash(x,y,2) > 0.4 and y > 37 then c:px(x, y, BARK[2]) end end)
-- dome crown
local dome = HP.mask() dome:add(c:ellipse(32, 33, 15, 13)):cut(c:rect(0, 38, 63, 63))
shade(c, dome, 10, DOME)
dome:each(function(x, y) if X.hash(x,y,5) > 0.93 and y < 33 then c:px(x, y, DOME[5]) end end)
-- gold band with woven stitches
local band = HP.mask() band:add(c:rect(17, 33, 47, 38)):clip(c:ellipse(32, 36, 16, 9))
shade(c, band, 3, GOLD)
band:each(function(x, y) if x % 3 == 0 and y > 34 and y < 38 then c:px(x, y, GOLD[2]) end end)
-- sprout on top
local st = G.tube({ {32,22}, {32,18}, {31,15}, {31,13} }, function(t) return 1.4 end)
shade(c, st, 1.5, LEAF)
for _, d in ipairs{ -1, 1 } do
  local m, n = G.blade(31, 14, 31 + d*7, 7, 31 + d*12, 10, function(t) return 3.2 * sin(pi*min(1,t+0.1)) end)
  shade(c, m, 2, LEAF)
  m:each(function(x,y) if abs(y - (14 - (abs(x-31)*0.5))) < 0.6 then c:px(x,y,LEAF[5]) end end)
end
-- quirk: tiny pink worm on the band
c:px(45, 31, "#e88aa8") c:px(46, 30, "#e88aa8") c:px(46, 29, "#f6b4c6") c:px(45, 32, "#c25a7e")
c:px(26, 27, DOME[6]) c:px(27, 27, DOME[6]) c:px(26, 28, DOME[6])
G.save(c, NAME)
