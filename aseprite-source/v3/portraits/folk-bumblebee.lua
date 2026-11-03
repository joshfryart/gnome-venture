-- folk-bumblebee PASS 2 (polish). Hearth Pop v3, 80x100 stop-folk species portrait, neutral outfit
-- (accessory slot = none). Chubby fuzzy bumblebee, cream bib apron, paired wings behind the shoulders.
-- quirk: mismatched antenna tips, a fuzz ball on one and a glinting pink heart on the other.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-bumblebee"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade) end end)
end
local function pts(list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end
local function overlay(mask, r, baseOf)
  mask:each(function(x, y)
    local v = c:get(x, y)
    if v == baseOf.base or v == baseOf.hi then c:put(x, y, r.base, baseOf)
    elseif v == baseOf.shade then c:put(x, y, r.shade, baseOf) end
  end)
end
local FUR = { hi = P.dusk.shade, base = P.dusk.deep, shade = P.ink, deep = P.ink }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function fuzz(m, bumps) -- scallop a mask edge with small round tufts
  for _, b in ipairs(bumps) do m:add(HP.ellipse(b[1], b[2], b[3] or 1.5, b[3] or 1.5)) end
  return m
end

---------------------------------------------------------------- wings (fore + hind, teardrops up-and-out)
local WING = { hi = P.cream, base = P.sky.hi, shade = P.sky.base, deep = P.sky.shade }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
for _, sgn in ipairs{ -1, 1 } do
  local hind = oval(39.5 + sgn * 27, 72, 7, 4.5, sgn * -15)
  local fore = oval(39.5 + sgn * 26, 61, 11, 6, sgn * -55)
  c:part(hind, WING, { band = 1, nopop = true })
  c:part(fore, WING, { band = 2, nopop = true })
  c:fillMask(c:line({ { 39.5 + sgn * 22, 68 }, { 39.5 + sgn * 29, 56 } }, 1):clip(fore:shrink(1)), P.sky.base)
end

---------------------------------------------------------------- fuzzy body with stripes and apron
local body = c:ellipse(39.5, 104, 36, 33):clip(c:rect(0, 70, 79, 99))
fuzz(body, { {11,86},{14,81},{19,77},{25,74},{54,74},{60,77},{65,81},{68,86} })
c:part(body, "gold", { band = 3, pop = { x = 14, y = 84 } })
-- fur stripes with zigzag fuzzy edges
local s1, s2 = HP.mask(), HP.mask()
for x = 0, 79 do
  local z = (x % 2 == 0) and 0 or 1
  for y = 81 + z, 86 - z do s1:set(x, y) end
  for y = 93 + z, 99 do s2:set(x, y) end
end
overlay(s1:clip(body), FUR, P.gold) overlay(s2:clip(body), FUR, P.gold)
-- bib apron: rounded bib, straps over the shoulders, hem stitch
local bib = c:rrect(29, 78, 50, 99, 4)
c:part(bib, CR, { nopop = true, band = 2 })
c:part(c:line({ {31,79},{29,72} }, 3), CR, { nopop = true, band = 1 })
c:part(c:line({ {48,79},{50,72} }, 3), CR, { nopop = true, band = 1 })
c:part(c:rrect(34, 88, 45, 95, 2), { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { nopop = true, band = 1 })
c:stitch{ {35, 89}, {44, 89} }

---------------------------------------------------------------- head: round, scalloped fuzz, tufted crown
local head = c:ellipse(39.5, 47, 21, 18.5)
c:part(head, "gold", { band = 3, pop = { x = 27, y = 40 } })
local cap = c:ellipse(39.5, 33, 22, 9):clip(head:copy():add(c:rect(0, 0, 79, 34)))
fuzz(cap, { {23,33,2},{28,28,2.5},{34,25,2.5},{40,24,2.5},{46,25,2.5},{52,28,2.5},{57,33,2} })
cap:cut(c:rect(0, 39, 79, 99))
-- zigzag hairline into the gold
for x = 20, 59 do if (x % 3) == 1 and cap:has(x, 38) then cap:set(x, 39) end end
c:part(cap, FUR, { band = 1, pop = { x = 30, y = 29 } })
-- cowlick tuft
c:part(c:poly{ {37,24},{39,18},{43,16},{42,20},{41,24} }, FUR, { band = 1, nopop = true })
-- face
c:eyeLocked(30, 45) c:eyeLocked(45, 45)
c:paint({ "i....i", ".iPPi.", "..ii.." }, 38, 54, { i = "ink", P = "petal.shade" }) -- open grin
c:paint({ "PPP", "PPP" }, 26, 52, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 51, 52, { P = "petal.base" })
pts({ {26,52},{51,52} }, P.petal.hi)

---------------------------------------------------------------- antenna tips (stalks drawn after the outline)
c:part(c:ellipse(24, 11, 3, 3), FUR, { band = 1, pop = { x = 23, y = 10 } })
c:paint({ ".hh.XX.", "hhXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." }, 51, 4, { X = "petal.base", h = "petal.hi" })
pts({ {56,7},{55,8},{54,9},{56,6} }, P.petal.shade)

c:finish{ outline = true }
-- stalks: left one curls once, right one straight and proud
c:fillMask(c:line({ {33,26},{31,22},{29,19},{28,17},{29,15},{27,14} }, 1), P.ink)
c:fillMask(c:line({ {45,26},{48,20},{52,14},{54,10} }, 1), P.ink)
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
