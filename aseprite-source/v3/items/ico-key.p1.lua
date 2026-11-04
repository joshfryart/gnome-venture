-- ico-key pass 1 (form): chunky upright gold key, heart bow with a big round hole, 7 px shaft, 2-tooth bit.
-- quirk: a little red cloth tag hangs from the bow on a cream string, gold 2-on-1-off stitch along its hem.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ico-key.p1" }
local cx = 37
-- cloth tag first (it hangs behind the shaft edge)
local tag = c:poly{ {9,33},{14,28},{21,28},{21,47},{9,47} }
c:part(tag, "ember", { band = 2 })
c:stitch({ {11, 44}, {20, 44} })
-- key
local shaft = c:rect(cx - 3, 30, cx + 3, 56)
shaft:add(c:rect(cx + 3, 45, cx + 10, 56)):cut(c:rect(cx + 6, 49, cx + 10, 52))
c:part(shaft, "gold", { band = 2, nopop = true })
local bow = c:ellipse(cx - 7, 16, 7, 7):add(c:ellipse(cx + 7, 16, 7, 7)):add(c:poly{ {cx-14.5,18},{cx+15.5,18},{cx+0.5,35} })
bow:cut(c:rrect(cx - 3, 15, cx + 3, 21, 2))
c:part(bow, "gold", { band = 2 })
-- string: from the bow's lower-left edge to the tag's top
c:finish{ outline = true }
c:fillMask(c:line({ {26, 22}, {22, 24}, {18, 27}, {16, 29} }, 1), P.cream)
HP.report(c) HP.assertClean(c)
c:save{ png = out .. "ico-key.p1.png" }
