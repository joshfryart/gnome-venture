-- wren-portrait FIRST DRAFT. Hearth Pop v3, 72x72 portrait, bleed off bottom.
-- Wren Thimblewick: small round brown wren, cocked barred tail, satchel strap, cream chest, gold beak.
-- quirk: a metal sewing thimble worn as a hat.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "wren-portrait"
local c = HP.canvas{ w = 72, h = 72, scale = 1, name = NAME }
local D4 = { {1,0},{-1,0},{0,1},{0,-1} }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function pts(list, hex) for _, p in ipairs(list) do keep(p[1], p[2], hex) end end
local BUFF = { hi = P.cream, base = "#f0d3a6", shade = "#d9b07e", deep = P.wood.base }
local LEATHER = { hi = "#c98a56", base = "#9a5a38", shade = P.wood.shade, deep = P.wood.deep }

-- cocked tail (behind), barred
local tail = c:poly{ {50,60},{52,44},{56,32},{62,26},{66,28},{66,38},{62,52},{58,64} }
c:part(tail, "wood", { band = 2, pop = { x = 60, y = 29 } })
for _, b in ipairs{ {{54,44},{62,41}}, {{55,50},{63,47}}, {{56,38},{63,35}} } do
  c:line(b, 1):clip(tail):each(function(x, y) keep(x, y, P.wood.shade) end)
end
-- body (bleeds off bottom)
local body = c:ellipse(35.5, 66, 25, 22)
c:part(body, "wood", { band = 3, pop = { x = 19, y = 50 } })
-- wing on the right shoulder
local wing = c:poly{ {47,50},{55,54},{56,66},{50,72},{44,72},{46,60} }
c:part(wing, { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = P.ink }, { band = 1, nopop = true })
for _, y in ipairs{ 56, 61, 66 } do c:line({ {47,y},{54,y+2} }, 1):clip(wing):each(function(x, yy) keep(x, yy, P.wood.deep) end) end
-- cream chest with speckles
local chest = c:ellipse(33, 66, 14, 15):clip(c:rect(0, 52, 71, 71))
c:part(chest, BUFF, { band = 2, nopop = true })
for _, p in ipairs{ {26,56},{31,58},{37,57},{28,62},{34,63},{40,61},{25,67},{31,68},{38,67},{29,71},{36,71} } do keep(p[1], p[2], "#c9a070") end
-- satchel strap with buckle
local strap = c:line({ {16,52},{28,62},{46,72} }, 3):clip(body)
c:part(strap, LEATHER, { band = 1, nopop = true })
c:fillMask(c:line({ {16,51},{28,61},{46,71} }, 1):clip(strap), LEATHER.hi)
c:part(c:rect(29, 60, 33, 64), "gold", { band = 1, nopop = true })
c:fillMask(c:rect(30, 61, 32, 63), LEATHER.deep)
-- head
local head = c:ellipse(35.5, 36, 18, 16)
c:part(head, "wood", { band = 3, pop = { x = 24, y = 24 } })
-- feather tuft at back of head
c:part(c:poly{ {47,26},{52,20},{53,28},{50,32} }, "wood", { band = 1, nopop = true })
-- buff face patch
local face = c:ellipse(35.5, 40, 12, 8)
c:part(face, BUFF, { band = 1, nopop = true })
-- eyes, brow stripe, cheeks
c:eyeLocked(27, 30) c:eyeLocked(40, 30)
for _, p in ipairs{ {26,28},{27,27},{28,27},{29,27},{30,27},{41,27},{42,27},{43,27},{44,27},{45,28} } do c:px(p[1], p[2], P.cream) end
c:cheek(23, 38) c:cheek(47, 38)
-- designed beak: gold upper mandible with a lit ridge, darker lower, nostril, ink tip
c:paint({
  "..hhhhh..",
  ".bbbbbbb.",
  ".bbnbnbb.",
  "..ssssss.",
  "...sssss.",
  "....kk...",
}, 31, 36, { h = P.gold.hi, b = P.gold.base, n = P.gold.deep, s = P.gold.shade, k = P.ink })
-- thimble hat: dimpled metal dome with a rim band, tipped a little
local dome = c:ellipse(35.5, 20, 9, 8):clip(c:rect(0, 0, 71, 20)):add(c:rect(27, 14, 44, 20))
c:part(dome, "stone", { band = 2, pop = { x = 29, y = 14 } })
for _, p in ipairs{ {31,12},{35,12},{39,12},{29,16},{33,16},{37,16},{41,16},{31,19},{35,19},{39,19} } do
  c:px(p[1], p[2], P.stone.deep) c:px(p[1] + 1, p[2], P.stone.shade)
end
local rim = c:rrect(25, 21, 46, 24, 1)
c:part(rim, "stone", { band = 1, nopop = true })
c:fillMask(c:rect(27, 22, 43, 22), P.stone.hi)
c:sparkle(31, 9)

c:finish{ outline = true }
-- backdrop disc: warm cream-gold with a 2px shade crescent and its own darker outline
local disc = HP.ellipse(35.5, 35.5, 33, 33)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and "#fbe3a0" or "#ecc66a", "bg") end end)
local ring = disc:grow(1):cut(disc)
ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, "#c98d36", "bg") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
