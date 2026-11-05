-- puddle-hat (lean P1b_O7)
-- A golden straw hat floating brim-down in a blue puddle: woven crown + wide brim (6-tone straw), red band,
-- ripple rings, reflection streaks in the water. quirk: a little green frog squats on the brim edge.
local NAME = "puddle-hat"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local WAT   = { "#1c3e7a", "#2a5fa8", "#3f84cc", "#66aee4", "#9ad2f2", "#d4f0fc" }
local STRAW = { "#7a4a1e", "#a8702a", "#d49a3a", "#eebc4c", "#f8d870", "#fff0a4" }
local RED   = { "#4a1424", "#7a2234", "#a83446", "#d05060" }
local FROG  = { "#1c4a32", "#2e7a40", "#52b04c", "#92dc6a" }
-- puddle
local pud = c:ellipse(32, 44, 28, 13)
local pn = X.pillow(pud, 9, 0.5)
local pb = {}
pud:each(function(x, y)
  local d = sqrt(((x - 32) / 28) ^ 2 + ((y - 44) / 13) ^ 2)
  if d > 0.82 then pb[K(x, y)] = -1 end
  if (floor(d * 14) % 4 == 0) and d < 0.8 and d > 0.45 and X.hash(x, y, 3) > 0.45 then pb[K(x, y)] = 1 end
end)
G.toneN(c, pud, pn, WAT, { bias = pb, amb = 0.35, wrap = 0.5, cuts = { 0.3, 0.5, 0.65, 0.8, 0.92 } })
for x = 47, 55 do c:px(x, 49, WAT[6]) end
for x = 10, 16 do c:px(x, 40, WAT[5]) end
-- reflection streaks
for _, s in ipairs{ { 24, 52, 8 }, { 30, 54, 6 }, { 36, 51, 7 } } do for x = s[1], s[1] + s[3] do c:px(x, s[2], STRAW[3]) end end
-- shadow of the brim on water
c:fillMask(c:ellipse(34, 42, 22, 6), WAT[1])
-- brim
local brim = c:ellipse(32, 35, 24, 9)
local bn = {}
brim:each(function(x, y) bn[K(x, y)] = { G.norm((x - 32) / 40 - 0.15, (y - 35) / 14 - 0.25, 1) } end)
local bb = {}
brim:each(function(x, y)
  local d = sqrt(((x - 32) / 24) ^ 2 + ((y - 35) / 9) ^ 2)
  if floor(d * 9) % 2 == 1 then bb[K(x, y)] = -1 end
  if d > 0.88 then bb[K(x, y)] = -1 end
end)
G.toneN(c, brim, bn, STRAW, { bias = bb, amb = 0.25, wrap = 0.3 })
-- crown dome
local crown = c:ellipse(32, 27, 12, 12):clip(c:rect(0, 0, 63, 35)):add(c:rect(20, 27, 44, 35))
crown = crown:clip(c:ellipse(32, 25, 12, 12):add(c:rect(20, 25, 44, 35)))
local cn = X.pillow(crown, 7, 1.4)
local cb = {}
crown:each(function(x, y)
  local wv = (floor((x + (floor(y / 2) % 2) * 2) / 4) + floor(y / 2)) % 2
  if wv == 0 then cb[K(x, y)] = -1 end
end)
G.toneN(c, crown, cn, STRAW, { bias = cb, amb = 0.12, wrap = 0.2 })
-- band
local band = crown:copy():clip(c:rect(0, 28, 63, 31))
local bv = X.light(cn, { amb = 0.1, wrap = 0.2 })
X.tone(c, band, bv, RED, { cuts = { 0.4, 0.7, 0.9 } })
c:px(40, 32, RED[2]) c:px(41, 32, RED[1]) c:px(42, 32, RED[1]) c:px(41, 33, RED[1])
for x = 21, 43 do c:px(x, 32, STRAW[1]) end
c:px(26, 29, "#f08090") c:px(27, 29, "#f08090")
-- spec on crown
c:px(27, 19, STRAW[6]) c:px(28, 18, STRAW[6]) c:px(26, 20, STRAW[5]) c:px(29, 17, STRAW[5])
-- frog quirk on the right brim
local fm = c:ellipse(48, 35, 4, 3)
G.toneN(c, fm, X.pillow(fm, 3.5), FROG, { amb = 0.15 })
c:px(46, 32, FROG[4]) c:px(47, 32, "#ffffff") c:px(50, 32, FROG[4]) c:px(51, 32, FROG[2]) c:px(46, 31, FROG[2]) c:px(47, 31, "#1c1c24") c:px(50, 31, FROG[2]) c:px(51, 31, "#1c1c24")
c:px(49, 37, FROG[1]) c:px(47, 37, FROG[1]) c:px(50, 35, FROG[1])
G.save(c, NAME)
