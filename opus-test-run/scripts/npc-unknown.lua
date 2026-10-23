-- npc-unknown: villager not yet met, 80x100 bust. A dark umber gnome silhouette (bent hat, ears, beard,
-- shoulders) with a "?" cut out of it. Bust rules: 1 px black border on every side except the bottom edge
-- (the bust runs off the bottom), round the "?" hole too. Cap 16. Families: soil 900 (silhouette), gold thread.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local c = X.canvas{ mode = "bust" }
local INK = X.ramp("#3d2a1c")   -- soil 900 through the ramp recipe

X.layer(c, "objects")
local hat = c:poly({ { 15, 44 }, { 30, 22 }, { 38, 10 }, { 47, 4 }, { 57, 3 }, { 62, 7 }, { 55, 9 }, { 50, 14 }, { 54, 26 }, { 66, 44 } })
local brim = c:rrect(8, 39, 72, 47, 4)
local head = c:ellipse(40, 57, 17, 13)
local ears = c:ellipse(22, 56, 4, 6):add(c:ellipse(58, 56, 4, 6))
local beard = c:poly({ { 21, 60 }, { 59, 60 }, { 56, 78 }, { 47, 90 }, { 40, 93 }, { 33, 90 }, { 24, 78 } }):add(c:ellipse(40, 66, 19, 9))
local body = c:rrect(5, 76, 75, 110, 16)
-- the "?" to cut: a 5 px hook and a dot, centred on the face and beard
local q = c:line({ { 33, 57 }, { 34, 53 }, { 38, 51 }, { 43, 51 }, { 47, 54 }, { 47, 59 }, { 44, 63 }, { 40, 66 }, { 40, 73 } }, 5)
q:add(c:rrect(38, 79, 42, 84, 1))
c:build{
  { "body", body, INK, { gloss = false, cres = 6, deep = 2 } },
  { "ears", ears, INK, { gloss = false, cres = 3, deep = 1 } },
  { "head", head, INK, { gloss = false, cres = 6, deep = 2 } },
  { "beard", beard, INK, { gloss = false, cres = 6, deep = 2 } },
  { "hat", hat, INK, { gloss = false, cres = 6, deep = 2 } },
  { "brim", brim, INK, { gloss = false, cres = 3, deep = 1 } },
}

X.layer(c, "detail")
c:seam({ { 11, 43 }, { 69, 43 } })   -- hat brim seam (a real join), thread gold
c:button(56, 4)                       -- button at the head of the hat seam, by the bent tip

X.save(c, "npc-unknown", "ph", { w = 80, h = 100, cap = 16, holes = q })
