-- trail-pack: small canvas rucksack, rolled striped blanket strapped on top, brass buckle.
-- quirk: a lavender sprig tucked under the blanket strap.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_gw.lua")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "trail-pack" }
local weave = function(x, y, i) if (x % 3 == 0 and y % 2 == 0) or (x % 3 == 1 and y % 2 == 1 and X.hash(x, y, 2) < .3) then return -1 end end

-- side pockets (behind the body)
local pl = c:rrect(11, 35, 18, 53, 2)
local pr = c:rrect(45, 35, 52, 53, 2)
local body = c:rrect(15, 19, 48, 56, 6)
local pb = {} pl:each(function(x, y) pb[K(x, y)] = -1 end) pr:each(function(x, y) pb[K(x, y)] = -1 end)
local pi = W.lit(c, pl, R.canvas, { R = 2, bias = pb }) W.retone(c, pl, pi, R.canvas, weave)
local pi2 = W.lit(c, pr, R.canvas, { R = 2, bias = pb }) W.retone(c, pr, pi2, R.canvas, weave)
W.hline(c, 12, 17, 39, R.canvas[2]) W.hline(c, 46, 51, 39, R.canvas[1])
W.sep(c, body, pl:copy():add(pr), R.canvas[1])
local bi = W.lit(c, body, R.canvas, { R = 5, cuts = { .24, .42, .58, .74, .9 } })
W.retone(c, body, bi, R.canvas, weave)
-- flap with a stitched edge, contact shadow below
local flap = c:poly{ {16,20}, {47,20}, {47,31}, {41,37}, {22,37}, {16,31} }
for x = 18, 45 do c:put(x, 38, R.canvas[2]) end
local fi = W.lit(c, flap, R.canvas, { R = 3, cuts = { .2, .36, .52, .7, .86 } })
W.retone(c, flap, fi, R.canvas, weave)
flap:each(function(x, y) if not flap:has(x, y + 1) then c:put(x, y, R.canvas[2]) end end)
-- leather strap and brass buckle
local strap = c:rect(29, 30, 33, 47)
W.vcyl(c, strap, R.strap, 29, 33)
W.vline(c, 29, 30, 47, R.strap[5])
local buck = c:rect(27, 39, 35, 44)
W.lit(c, buck, R.brass, { R = 1 })
c:fillMask(c:rect(29, 41, 33, 42), R.strap[3])
W.hline(c, 28, 34, 39, R.brass[6]) W.vline(c, 27, 40, 43, R.brass[5])
W.hline(c, 28, 35, 44, R.brass[2]) W.vline(c, 35, 40, 44, R.brass[2])
W.vline(c, 31, 40, 43, R.brass[3]) c:put(28, 40, W.cream)
-- strap hole + end tip below the buckle
c:put(31, 46, R.strap[1])
-- rolled blanket on top: horizontal cylinder with stripes, spiral end on the left
local bm, bn, BT = X.cyl(13, 14, 50, 14, function() return 5.5 end)
local bb = {}
bm:each(function(x, y) local u = x - 13 if (u % 9) >= 6 then bb[K(x, y)] = 0 end end)
local blk = W.toneN(c, bm, bn, R.blanket, { cuts = { .2, .36, .52, .7, .88 } })
bm:each(function(x, y)
  local u = x - 13
  if u % 9 == 6 or u % 9 == 7 then
    local i = blk[K(x, y)]
    c:put(x, y, ({ "#8a7a70", "#b8a690", "#d8c8a8", "#efe2c2", "#fff0d2", "#fff4d6" })[i])
  end
end)
local en = c:ellipse(13, 14, 3, 5.5)
c:fillMask(en, R.blanket[4])
W.put(c, { {13,12}, {14,12}, {14,13}, {14,14}, {14,15}, {13,16}, {12,16}, {11,15}, {11,14}, {11,13}, {12,11} }, R.blanket[1])
W.put(c, { {12,9}, {13,9}, {15,10} }, R.blanket[6])
c:put(12, 14, R.blanket[2]) c:put(13, 14, R.blanket[5])
-- straps around the roll
for _, sx in ipairs({ 21, 42 }) do
  for y = 8, 20 do if bm:has(sx, y) or bm:has(sx + 1, y) then c:put(sx, y, R.strap[4]) c:put(sx + 1, y, R.strap[2]) end end
  c:put(sx, 9, R.strap[6])
end
-- top grab loop
local loop = c:line({ {28,8}, {29,5}, {34,5}, {35,8} }, 2)
W.sep(c, loop, bm, R.strap[1])
loop:each(function(x, y) if not bm:has(x, y) then c:put(x, y, R.strap[y < 6 and 5 or 3]) end end)
-- blanket glint
c:put(17, 10, R.blanket[6]) c:put(18, 10, W.cream)
-- quirk: lavender sprig under the right strap
local stem = c:line({ {43,13}, {45,8}, {47,4} }, 1)
stem:each(function(x, y) if not bm:has(x, y) or y < 10 then c:put(x, y, "#3f9150") end end)
W.put(c, { {46,3}, {47,2}, {48,3}, {45,5}, {48,5}, {46,6} }, R.lav[3])
W.put(c, { {47,3}, {46,5} }, R.lav[5]) c:put(47, 1, R.lav[4])
-- canvas pop
c:put(19, 24, R.canvas[6]) c:put(20, 24, R.canvas[6])
W.save(c, "trail-pack")
