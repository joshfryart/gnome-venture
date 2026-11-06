-- npc-grandmother-hoshi portrait (npc2 P1_12) species: mouse
-- Same design as the sprite: elder grey mouse, white bun + star hairpin, gold round glasses, plum kimono, red obi,
-- calico lucky-cat figurine held at her shoulder.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-grandmother-hoshi"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local O = { r = { name = "detail" } }
local function put(x, y, h) c:put(x, y, h, O) end
local function fm(m, h) m:each(function(x, y) put(x, y, h) end) end
local FUR = { hi = P.stone.base, base = "#8e8ca2", shade = P.stone.shade, deep = P.stone.deep }
local HAIR = { hi = "#faf6ff", base = P.stone.hi, shade = "#c8c3da", deep = "#b4aecb" }
local KIMO = { hi = "#c98fb8", base = "#9a5a8e", shade = "#6e3a72", deep = "#45244f" }
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
-- kimono shoulders, crossed collar with red under-layer, obi
local km = c:ellipse(39.5, 108, 31, 34):clip(c:rect(0, 72, 79, 99))
c:part(km, KIMO, { band = 3 })
fm(c:line({ { 49, 73 }, { 40, 91 } }, 3), P.ember.base)
c:part(c:line({ { 49, 72 }, { 41, 90 } }, 2), CR, { band = 1, nopop = true })
fm(c:line({ { 30, 74 }, { 40, 92 } }, 3), P.ember.base)
c:part(c:line({ { 30, 73 }, { 39, 91 } }, 2), CR, { band = 1, nopop = true })
for _, f in ipairs{ { { 18, 82 }, { 20, 99 } }, { { 60, 84 }, { 58, 99 } } } do fm(c:line(f, 1):clip(km), KIMO.shade) end
local obi = c:rect(0, 93, 79, 99):clip(km)
c:part(obi, P.ember, { band = 1, nopop = true })
for x = 10, 70 do if x % 3 < 2 and km:has(x, 96) then put(x, 96, P.gold.base) end end
-- calico lucky-cat at her right shoulder, held up by a grey paw
local cat = c:ellipse(58, 91, 6.5, 6):add(c:ellipse(58, 80.5, 6, 5))
cat:add(c:poly{ { 52, 79 }, { 53, 72 }, { 56, 77 } }):add(c:poly{ { 60, 77 }, { 63, 72 }, { 64, 79 } })
c:part(cat, CR, { band = 2, nopop = true })
c:part(c:rrect(64, 69, 67, 76, 1), CR, { band = 1, nopop = true })
put(65, 70, P.petal.base)
for _, q in ipairs{ { 53, 75 }, { 53, 76 }, { 54, 76 }, { 53, 77 }, { 54, 77 }, { 55, 77 }, { 53, 78 }, { 54, 78 } } do put(q[1], q[2], P.ember.hi) end
for _, q in ipairs{ { 61, 89 }, { 62, 89 }, { 61, 90 }, { 62, 90 }, { 63, 90 }, { 62, 91 }, { 54, 92 }, { 55, 92 }, { 54, 93 } } do put(q[1], q[2], P.gold.base) end
for _, q in ipairs{ { 54, 80 }, { 55, 79 }, { 56, 80 }, { 60, 80 }, { 61, 79 }, { 62, 80 } } do put(q[1], q[2], P.ink) end
put(58, 82, P.petal.base) put(57, 83, P.ink) put(59, 83, P.ink)
for x = 53, 63 do put(x, 86, P.ember.base) end
c:part(c:ellipse(58, 87.5, 1.5, 1.5), P.gold, { band = 1 })
c:part(c:ellipse(50.5, 92, 3, 2.5), FUR, { band = 1 })
-- round ears
for _, ex in ipairs{ 20, 59 } do
  c:part(c:ellipse(ex, 35, 9.5, 9.5), FUR, { band = 2, nopop = true })
  c:part(c:ellipse(ex + 0.5, 35.5, 5.5, 5.5), P.petal, { band = 2, nopop = true })
end
-- bun
c:part(c:ellipse(39.5, 29, 9, 6.5), HAIR, { band = 2 })
for _, q in ipairs{ { 35, 26 }, { 36, 27 }, { 37, 28 }, { 42, 25 }, { 43, 26 }, { 44, 27 }, { 45, 28 } } do put(q[1], q[2], HAIR.shade) end
-- head + scalloped white fringe
local hd = c:ellipse(39.5, 51, 20.5, 17)
c:part(hd, FUR, { band = 3 })
local hm = hd:copy():clip(c:rect(0, 0, 79, 41))
for x = 22, 58, 6 do hm:add(c:ellipse(x, 42, 3, 2)) end
hm:clip(hd)
c:part(hm, HAIR, { band = 2 })
for _, s in ipairs{ { 28, 37, 30, 41 }, { 34, 36, 35, 41 }, { 40, 36, 40, 41 }, { 46, 36, 45, 41 }, { 52, 37, 50, 41 } } do
  fm(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(hm:shrink(1)), HAIR.shade)
end
-- star hairpin through the bun
fm(c:line({ { 29, 33 }, { 52, 21 } }, 1), P.wood.shade)
for _, q in ipairs{ { 0, -3 }, { 0, -2 }, { -1, -1 }, { 0, -1 }, { 1, -1 }, { -3, 0 }, { -2, 0 }, { -1, 0 }, { 0, 0 }, { 1, 0 }, { 2, 0 }, { 3, 0 },
  { -1, 1 }, { 0, 1 }, { 1, 1 }, { -2, 2 }, { -1, 2 }, { 1, 2 }, { 2, 2 }, { -2, 3 }, { 2, 3 } } do put(55 + q[1], 19 + q[2], P.gold.base) end
put(54, 18, P.gold.hi) put(55, 18, P.gold.hi) put(56, 20, P.gold.shade) put(57, 21, P.gold.shade)
-- muzzle, nose, mouth, whiskers, cheeks
c:part(c:ellipse(39.5, 61, 10, 6.5), CR, { band = 1, nopop = true })
c:part(c:poly{ { 37, 55 }, { 42, 55 }, { 39.5, 58.5 } }, P.petal, { band = 1, nopop = true })
put(38, 55, P.petal.hi)
for _, q in ipairs{ { 39, 59 }, { 40, 59 }, { 36, 61 }, { 37, 62 }, { 38, 62 }, { 39, 61 }, { 40, 61 }, { 41, 62 }, { 42, 62 }, { 43, 61 } } do put(q[1], q[2], P.ink) end
for _, w in ipairs{ { { 30, 59 }, { 23, 57 } }, { { 30, 62 }, { 23, 63 } }, { { 49, 59 }, { 56, 57 } }, { { 49, 62 }, { 56, 63 } } } do fm(c:line(w, 1):clip(hd), FUR.deep) end
for _, q in ipairs{ { 24, 54 }, { 25, 54 }, { 26, 54 }, { 25, 55 }, { 53, 54 }, { 54, 54 }, { 55, 54 }, { 54, 55 } } do put(q[1], q[2], P.petal.base) end
-- gold round glasses with temples, locked eyes inside
for _, cx in ipairs{ 32.5, 47.5 } do
  local ring = c:ellipse(cx, 47.5, 4.5, 4.5)
  fm(ring:copy():cut(ring:shrink(1)), P.gold.base)
  ring:each(function(x, y) if not ring:has(x - 1, y) or not ring:has(x, y - 1) then if not ring:shrink(1):has(x, y) then put(x, y, P.gold.hi) end end end)
end
fm(c:line({ { 37, 46 }, { 43, 46 } }, 1), P.gold.shade)
fm(c:line({ { 28, 46 }, { 21, 45 } }, 1), P.gold.shade) fm(c:line({ { 52, 46 }, { 58, 45 } }, 1), P.gold.shade)
c:eyeLocked(30, 45) c:eyeLocked(45, 45)
c:finish{ outline = true }
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
