-- hazelnut-seed (dC11 first draft): two small round hazelnuts (pale scar, fine stripes) on an olive leaf scrap, sprout with two rounded, serrated hazel leaves.
-- quirk: the sprouting nut has cracked open and a pale root pokes out.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hazelnut-seed")
local P = D.P
local LEAF = D.r4("#d9e48a", "#8fb04f", "#587f45", "#2c4a3c")
D.scrap(c, LEAF)
-- sprout
D.ln(c, 40, 46, 39, 36, P.moss.base) D.ln(c, 40, 46, 40, 37, P.moss.shade) D.ln(c, 39, 36, 38, 26, P.moss.base)
local function hleaf(cx, cy, rx, ry, ang)
  local m = D.ell(cx, cy, rx, ry, ang)
  D.part(c, m, LEAF, 2)
  m:edge():each(function(x, y) end)
  m:each(function(x, y) if not m:has(x, y - 1) and (x % 2 == 0) then c:px(x, y, LEAF[2]) end end)
  D.ln(c, cx - math.cos(ang) * rx * .8, cy - math.sin(ang) * rx * .8, cx + math.cos(ang) * rx * .8, cy + math.sin(ang) * rx * .8, LEAF[6])
  return m
end
hleaf(31, 22, 7, 5, -0.4) hleaf(46, 19, 7, 5, 0.4)
D.ln(c, 38, 26, 33, 24, P.moss.shade) D.ln(c, 38, 26, 43, 22, P.moss.shade)
c:px(35, 14, P.moss.hi)
-- nuts
local NUT = D.r4("#e8b982", "#b97a4a", "#864c33", "#51302b")
local function nut(cx, cy)
  local m = D.sd(c, cx, cy, 4.8, 5.2, 0, NUT)
  c:fillMask(D.ell(cx, cy + 4, 2.4, 1.2), "#e8d2a2")
  for dx = -3, 3, 3 do c:px(cx + dx, cy - 1, NUT[2]) c:px(cx + dx, cy, NUT[2]) end
  return m
end
nut(18, 48)
nut(31, 50)
-- sprouting nut
local sm = D.sd(c, 41, 49, 4.8, 5.2, 0, NUT)
D.ln(c, 40, 46, 42, 53, P.ink)
c:fillMask(c:rect(41, 51, 42, 54), "#f4e3b8")
D.ln(c, 43, 54, 47, 57, "#f4e3b8") c:px(48, 57, "#d6b98a")
D.fin()
