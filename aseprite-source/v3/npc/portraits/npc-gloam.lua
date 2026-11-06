-- npc-gloam portrait (npc2 P1_12) species: bat
-- Same design as the sprite: dusk bat, folded wings, gold knit sweater + cream collar, red paper lantern in hand.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-gloam"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local O = { r = { name = "detail" } }
local function put(x, y, h) c:put(x, y, h, O) end
local function fm(m, h) m:each(function(x, y) put(x, y, h) end) end
local function mir(pts) local r = {} for i, q in ipairs(pts) do r[i] = { 79 - q[1], q[2] } end return r end
local FUR = P.dusk
local WING = { hi = P.dusk.base, base = P.dusk.shade, shade = P.dusk.deep, deep = "#241a40" }
local MUZ = { hi = "#e6dcfa", base = P.dusk.hi, shade = "#a88ee0", deep = P.dusk.base }
local CR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- folded wings behind the shoulders, scalloped
local wl = { { 24, 70 }, { 8, 64 }, { 4, 74 }, { 6, 88 }, { 10, 84 }, { 13, 92 }, { 17, 87 }, { 21, 95 }, { 26, 88 } }
for side = 1, 2 do
  local w = c:poly(side == 1 and wl or mir(wl))
  c:part(w, WING, { band = 2, nopop = true })
  local function X(x) return side == 1 and x or 79 - x end
  for _, t in ipairs{ { 10, 84 }, { 17, 87 }, { 6, 76 } } do fm(c:line({ { X(22), 70 }, { X(t[1]), t[2] } }, 1):clip(w:shrink(1)), WING.deep) end
  fm(c:line({ { X(9), 66 }, { X(6), 73 } }, 1):clip(w), WING.hi)
end
-- gold sweater, cable knit, cream V collar
local sw = c:ellipse(39.5, 106, 25, 33):clip(c:rect(0, 70, 79, 99))
c:part(sw, P.gold, { band = 3 })
for x = 18, 62, 5 do for y = 78, 99 do if sw:has(x, y) and (y + x) % 3 ~= 0 and c:get(x, y) == P.gold.base then put(x, y, "#e89d28") end end end
c:part(c:poly{ { 29, 70 }, { 50, 70 }, { 39.5, 84 } }, CR, { band = 1, nopop = true })
fm(c:line({ { 31, 71 }, { 39, 82 } }, 1), CR.shade)
c:part(c:ellipse(39.5, 87.5, 1.5, 1.5), P.gold, { band = 1 })
-- lantern stick + red paper lantern, held in a wing-claw
fm(c:line({ { 56, 86 }, { 67, 63 } }, 1), P.wood.shade)
put(67, 64, P.wood.deep) put(67, 65, P.wood.deep)
local lan = c:rrect(63, 66, 71, 78, 3)
c:part(lan, P.ember, { band = 2, nopop = true })
for x = 64, 70 do put(x, 66, P.wood.deep) put(x, 78, P.wood.deep) end
for y = 69, 75 do for x = 65, 68 do put(x, y, P.gold.hi) end end
put(65, 69, P.cream) put(66, 69, P.cream) put(65, 70, P.cream) put(68, 75, P.gold.base) put(67, 75, P.gold.base)
for _, y in ipairs{ 69, 72, 75 } do put(64, y, P.ember.deep) put(70, y, P.ember.deep) end
put(67, 79, P.gold.base) put(67, 80, P.gold.base) put(67, 81, P.gold.shade)
c:part(c:ellipse(56.5, 85, 3, 2.5), FUR, { band = 1 })
-- tall ears
for side = 1, 2 do
  local e = { { 20, 44 }, { 33, 34 }, { 16, 7 } }
  local i = { { 22, 39 }, { 30, 34 }, { 18, 14 } }
  c:part(c:poly(side == 1 and e or mir(e)), FUR, { band = 2, nopop = true })
  c:part(c:poly(side == 1 and i or mir(i)), P.petal, { band = 1, nopop = true })
end
-- head
local hd = c:ellipse(39.5, 49, 20, 17)
c:part(hd, FUR, { band = 3 })
c:part(c:poly{ { 36, 33 }, { 37, 27 }, { 39, 31 }, { 41, 26 }, { 43, 32 } }, FUR, { band = 1, nopop = true })
for _, q in ipairs{ { 27, 37 }, { 28, 37 }, { 26, 38 }, { 27, 38 }, { 26, 39 } } do put(q[1], q[2], FUR.hi) end
-- muzzle, pug nose, smile + fangs
c:part(c:ellipse(39.5, 58, 9, 6), MUZ, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 54.5, 3, 2), P.petal, { band = 1, nopop = true })
put(37, 54, P.petal.hi) put(38, 55, P.petal.deep) put(41, 55, P.petal.deep)
for _, q in ipairs{ { 34, 59 }, { 35, 60 }, { 36, 60 }, { 37, 60 }, { 38, 60 }, { 39, 61 }, { 40, 61 }, { 41, 60 }, { 42, 60 }, { 43, 60 }, { 44, 60 }, { 45, 59 } } do put(q[1], q[2], P.ink) end
put(36, 61, P.cream) put(36, 62, P.cream) put(43, 61, P.cream) put(43, 62, P.cream)
c:eyeLocked(29, 45) c:eyeLocked(46, 45)
for _, q in ipairs{ { 23, 54 }, { 24, 54 }, { 25, 54 }, { 23, 55 }, { 24, 55 }, { 54, 54 }, { 55, 54 }, { 56, 54 }, { 55, 55 }, { 56, 55 } } do put(q[1], q[2], P.petal.base) end
c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
