-- mini-aphid-swarm: small enemy toy miniature, 56x64, cap 16 colours, 1 px black border all round.
-- Three felt aphids (a big one, one riding on its back, a little one in front) on a round soil base, 3/4 view from above, facing right.
-- Enemy base: soil ramp, no stitching. Clear feature: antennae with club tips and the two back cornicles.
-- Families: moss (aphids), soil (base), leg lavender. 16 colours: border, 3 umber, cream eye, 6 moss, 3 soil, 2 leg.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local GV = X.GV
local c = X.canvas{ w = 56, h = 64, mode = "sticker" }
local BUG = X.ramp("moss", { dot = "#c8d77a" })
-- back aphids sit in the shade of the front one: the same moss colours, one step darker
local BACK = X.ramp("moss", { gloss = "#a4b86a", dot = "#a4b86a", rim = "#7ab55c", base = "#6a9a3a", bounce = "#4a8a3e", shade = "#4a8a3e", deep = "#2f5a2a" })
local TOP = X.ramp("soil", { shade = "#7a4a1f", deep = "#7a4a1f", bounce = "#7a4a1f" })
local SIDE = X.ramp("soil", { base = "#7a4a1f", rim = "#9a6b3f", shade = "#4a2c1a", deep = "#4a2c1a", bounce = "#7a4a1f" })

X.layer(c, "objects")
-- the base: a 6 px thick disc, 37 px wide (2/3 of the canvas), bottom on row 59 (outline + border below it)
local side = c:ellipse(27.5, 55, 18, 4):add(c:rect(10, 51, 45, 55))
c:part(side, SIDE, { gloss = false, cres = 3, deep = 0 })
c:part(c:ellipse(27.5, 51, 18, 4), TOP, { gloss = false, cres = 3, deep = 1, contact = false })

-- back aphids (smaller), drawn first so the front one overlaps them
local function aphid(bx, by, brx, bry, hx, hy, hr, o)
  local body = c:ellipse(bx, by, brx, bry)
  c:part(body, BACK, { cres = o.cres or 3, deep = 1, gloss = o.gloss })
  c:part(c:ellipse(hx, hy, hr, hr - 1), BACK, { cres = o.cres or 3, deep = 1, gloss = false })
end
aphid(14, 26, 8, 6, 23, 22, 6, { gloss = false })
-- front aphid: legs first (they tuck under), cornicles, body, big head
c:limb({ { 22, 45 }, { 21, 50 } }); c:limb({ { 29, 45 }, { 29, 50 } }); c:limb({ { 37, 41 }, { 40, 46 }, { 39, 50 } })
c:part(c:line({ { 11, 36 }, { 6, 32 } }, 3), BUG, { flat = true })   -- the two cornicles on its back
c:part(c:line({ { 13, 32 }, { 9, 28 } }, 2), BUG, { flat = true })
c:part(c:ellipse(21, 38, 12, 9), BUG, { cres = 4, deep = 2 })
local head = c:ellipse(36, 33, 10, 9)
c:part(head, BUG, { cres = 4, deep = 2 })
-- the little one in front, on the left of the base
c:limb({ { 8, 50 }, { 8, 52 } }); c:limb({ { 13, 50 }, { 14, 52 } })
c:part(c:ellipse(10, 46, 5, 4), BACK, { cres = 2, deep = 1, gloss = false })
c:part(c:ellipse(16, 44, 4, 3), BACK, { cres = 2, deep = 1, gloss = false })

X.layer(c, "detail")
-- antennae: bent lavender limbs with 2x2 club tips (small figure)
c:limb({ { 36, 25 }, { 37, 19 }, { 35, 14 } }); c:limb({ { 42, 26 }, { 46, 20 }, { 48, 15 } })
c:fill(c:rect(34, 12, 36, 14), GV.C.legTop); c:fill(c:rect(47, 13, 49, 15), GV.C.legTop)
c:limb({ { 23, 18 }, { 22, 12 } }); c:limb({ { 26, 18 }, { 28, 13 } })
c:limb({ { 17, 41 }, { 18, 38 } })
-- locked eyes on the front head (5x5), small eyes on the back aphids
c:eye(31, 30); c:eye(39, 30)
c:eye(23, 20, true); c:eye(15, 42, true)
-- mouth: a little umber smile turned right
c:paint({ "x...x", ".xxx." }, 34, 37, { x = "umber" })

X.save(c, "mini-aphid-swarm", "mini", { w = 56, h = 64, cap = 16 })
