-- broken-tin-watering-can (aB12_5, Opus single pass). Slim upright tin can seen side-on: rolled lip with a dark mouth,
-- two raised seam bands, riveted side seam, D loop handle at the back, long thin spout with a brace and a sprinkler
-- rose. Material: per-pixel cylinder light on tin (6 tones), bright bevel on the bands, rivets, AO where handle,
-- spout and brace meet the body. broken: the body split open (torn jagged hole, lit curled edge, cracks), water
-- dribbling out, rose knocked crooked with a dent; flying tin flake.
-- quirk: a snail is riding the handle.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new("broken-tin-watering-can")
local T, W = A.TIN, A.SEA

c:groundShadow(30, 56, 15, 1)

-- handle loop at the back
local hm, hn = A.tube({ { 19, 29 }, { 7, 27 }, { 7, 49 }, { 19, 47 } }, function() return 1.25 end)
A.tone(c, hm, hn, T, { amb = 0.12 })

-- spout + brace (behind body)
local sp = { { 35, 47 }, { 43, 41 }, { 49, 31 }, { 52, 20 } }
local sm, sn, ST = A.tube(sp, function(t) return 2.0 - t * 0.85 end)
A.tone(c, sm, sn, T, { amb = 0.1 })
local br, brn = A.tube({ { 35, 33 }, { 38, 34 }, { 41, 36 }, { 44, 38 } }, function() return 0.7 end)
A.tone(c, br, brn, T, { amb = 0.1 })
-- rose (sprinkler head), knocked crooked
local rx, ry = 53.5, 16.5
local ux, uy = 0.55, -0.83
local rose = A.rell(rx, ry, ux, uy, 2.2, 4.2)
local rn = X.pillow(rose, 1.6)
A.tone(c, rose, rn, A.GOLD, { amb = 0.1 })
for _, p in ipairs{ { 52, 14 }, { 54, 15 }, { 55, 17 }, { 53, 17 } } do c:px(p[1], p[2], A.GOLD[1]) end
c:px(52, 13, A.GOLD[6])

-- body
local body = c:rrect(18, 24, 37, 53, 3)
local bb = {}
X.ao(bb, body, hm, 1, -1)
X.ao(bb, body, sm, 1, -1)
local bn = A.vcyl(body, 18, 37)
A.tone(c, body, bn, T, { bias = bb, amb = 0.08, wrap = 0.3 })
local function rowStep(y, d) for x = 18, 37 do if body:has(x, y) then A.step(c, x, y, T, d) end end end
-- rolled lip + mouth
local lip = c:rrect(17, 22, 38, 25, 1)
A.lit(c, lip, T, { R = 1.2 })
local mouth = c:ellipse(27.5, 23, 8, 0.5)
mouth:each(function(x, y) c:px(x, y, x < 22 and T[2] or T[1]) end)
-- raised seam bands (lit lip above, dark groove below)
for _, y in ipairs{ 30, 47 } do rowStep(y, 1) rowStep(y + 1, -2) end
-- riveted side seam
for y = 32, 45 do if y % 4 == 0 then c:px(22, y, T[6]) c:px(22, y + 1, T[2]) end end
c:px(20, 27, A.SPEC) c:px(20, 28, T[6])
-- bottom AO row
for x = 18, 37 do if body:has(x, 53) then c:px(x, 53, T[2]) end end

-- broken: torn split in the body
local hole = c:poly{ { 29, 34 }, { 32, 33 }, { 34.5, 36 }, { 33, 38 }, { 34, 41 }, { 31.5, 43.5 }, { 30, 40 }, { 28.5, 38 } }
hole:each(function(x, y) c:px(x, y, (x == 30 and y == 36) and "#3a2d4c" or "#1c1a2e") end)
hole:grow(1):cut(hole):each(function(x, y)
  if body:has(x, y) then
    if (not hole:has(x - 1, y) and hole:has(x + 1, y)) or hole:has(x, y + 1) then c:px(x, y, T[6]) else c:px(x, y, T[2]) end
  end
end)
for _, p in ipairs{ { 32, 32 }, { 33, 31 }, { 33, 29 }, { 30, 44 }, { 31, 45 }, { 31, 46 }, { 30, 48 } } do c:px(p[1], p[2], T[1]) end
-- water dribbling out of the split
for _, p in ipairs{ { 33, 44 }, { 33, 45 }, { 34, 46 } } do c:px(p[1], p[2], W[2]) end
c:px(33, 44, W[4])
A.rows(c, { "a", "b", "c" }, 35, 49, { a = W[4], b = W[3], c = W[2] })
-- dent on the spout
c:px(45, 39, T[1]) c:px(46, 38, T[2])
-- flying tin flake
A.rows(c, { "ab.", "bcd", ".dd" }, 42, 47, { a = T[6], b = T[5], c = T[4], d = T[2] })

-- quirk: snail riding the handle
A.rows(c, {
  "...sss..",
  "..sSpss.",
  "..spPps.",
  "e.sspss.",
  "gbbbbbbb",
}, 10, 23, { s = "#c9783e", S = "#f2b26a", p = "#8a4a2c", P = "#ffd99a", e = "#3a2a2a", g = "#a8b88a", b = "#7f9070" })

A.save(c)
