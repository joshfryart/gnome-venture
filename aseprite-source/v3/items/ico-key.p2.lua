-- ico-key (pass 2, final). Chunky upright gold key: big heart bow with a clear round hole, a collar ring,
-- short 7 px shaft, 3-tooth bit (long / short / long). Reads at 16 px as "gold key with heart".
-- quirk: a little red luggage tag tied to the bow on a cream string, eyelet + gold 2-on-1-off hem stitch.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ico-key" }
local cx = 38
-- string first (tag and bow sit on top of its ends); it gets the ink outline like everything else
c:part(c:line({ {17, 36}, {19, 33}, {22, 30}, {26, 28}, {30, 27} }, 1), { hi = P.cream, base = P.cream, shade = P.cream, deep = P.cream }, { noshade = true, nopop = true, inner = false })
-- tag: clipped top corners, eyelet, hem stitch
local tag = c:poly{ {11,38},{14,35},{20,35},{23,38},{23,51},{11,51} }
tag:cut(c:rect(17, 37, 17, 37))                        -- eyelet (becomes an ink dot)
c:part(tag, "ember", { band = 2, pop = { x = 13, y = 39 } })
c:stitch({ {13, 48}, {21, 48} })
-- key: shaft + bit
local shaft = c:rect(cx - 3, 36, cx + 3, 57)
shaft:add(c:rect(cx + 3, 45, cx + 11, 47)):add(c:rect(cx + 3, 50, cx + 9, 52)):add(c:rect(cx + 3, 55, cx + 11, 57))
shaft:add(c:rect(cx + 3, 45, cx + 5, 57))
c:part(shaft, "gold", { band = 2, nopop = true })
-- heart bow with hole
local bow = c:ellipse(cx - 8, 17, 8, 8):add(c:ellipse(cx + 8, 17, 8, 8)):add(c:poly{ {cx-16.5,19},{cx+17.5,19},{cx+0.5,37} })
bow:cut(c:rrect(cx - 3, 15, cx + 3, 21, 2))
c:part(bow, "gold", { band = 3, sep = true, pop = { x = cx - 12, y = 12 } })
c:px(cx - 13, 14, P.cream)                             -- the one sparkle
-- collar ring over the heart point (separated by a gold.deep line)
c:part(c:rrect(cx - 5, 33, cx + 5, 37, 1), "gold", { band = 1, nopop = true, sep = true })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "ico-key.aseprite", png = out .. "ico-key.png" }
