-- shop-general: general store interior strip, 240x60 grid -> 480x120 (2x nearest). Opaque, no border.
-- Banner-sized, so it keeps the banner cap of 24 colours. Counter on the right with empty wall behind it (the
-- shopkeeper bust stands there); goods on the left. Same plaster, beams and wood as home-cottage.
-- Families: soil 300 (plaster), wood (beam, shelves, floor, crate, barrel), red, gold, leaf, cream.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local c = X.canvas{ mode = "scene", w = 240, h = 60, out = 2 }
local WOOD = X.ramp("wood", { gloss = "#d9a660", dot = "#d9a660" })
local OAK = X.ramp("wood", { base = "#a8582f", rim = "#b07a45", bounce = "#8a4f2a", gloss = "#d9a660", dot = "#d9a660" })
local RED = X.ramp("red", { gloss = "#f2793a", dot = "#f2793a", bounce = "#ae2a2a", deep = "#ae2a2a" })
local GOLD = X.ramp("gold", { base = "#f5cf6a", rim = "#f5cf6a", shade = "#e8a317", bounce = "#e8a317", deep = "#e8a317", gloss = "#f1ece0", dot = "#f1ece0" })
local LEAF = X.ramp("leaf", { bounce = "#2f6a3a", deep = "#2f6a3a", gloss = "#a4b86a", dot = "#a4b86a", rim = "#a4b86a" })
local CREAM = X.ramp("cream", { rim = "#f1ece0", bounce = "#d8c49a", deep = "#d8c49a" })
local flat = { gloss = false, cres = 2, deep = 1 }

X.layer(c, "far")
c:fill(c:rect(0, 0, c.W - 1, 47), "#c9a96e")
X.ramp("#c9a96e")
c:fill(c:rect(0, 38, c.W - 1, 47), "#d2be85")
for x = 4, c.W - 1, 16 do c:fill(c:rect(x, 40, x, 47), "#ac7440") end

X.layer(c, "ground")
c:fill(c:rect(0, 48, c.W - 1, c.H - 1), "#b07a45")
c:fill(c:rect(0, 53, c.W - 1, 53), "#8a4f2a"); c:fill(c:rect(0, 57, c.W - 1, 57), "#8a4f2a")
for x = 9, c.W - 1, 31 do c:fill(c:rect(x, 49, x, 52), "#8a4f2a") end
for x = 24, c.W - 1, 31 do c:fill(c:rect(x, 54, x, 56), "#8a4f2a") end

X.layer(c, "objects")
c:part(c:rect(-3, 1, c.W + 2, 4), WOOD, flat)                     -- ceiling beam
c:part(c:rect(-3, 46, c.W + 2, 48), WOOD, { gloss = false, cres = 1, deep = 0 }) -- skirting
-- shelf unit (left): sides and two shelves
c:build{
  { "sideL", c:rect(4, 8, 6, 47), WOOD, flat },
  { "sideR", c:rect(94, 8, 96, 47), WOOD, flat },
  { "shelf1", c:rect(4, 20, 96, 22), WOOD, flat },
  { "shelf2", c:rect(4, 34, 96, 36), WOOD, flat },
}
-- top shelf: jars
for i, j in ipairs({ { 10, GOLD }, { 21, RED }, { 32, LEAF }, { 43, GOLD }, { 54, RED } }) do
  c:part(c:rrect(j[1], 12, j[1] + 7, 19, 2), j[2], { cres = 2, deep = 1, gloss = { j[1] + 2, 13 } })
end
c:part(c:rrect(66, 10, 90, 19, 3), CREAM, { cres = 3, deep = 1, gloss = false })      -- bolt of cloth
-- lower shelf: loaves and seed sacks
for _, x in ipairs({ 10, 24 }) do c:part(c:ellipse(x + 5, 30, 6, 3), WOOD, { cres = 2, deep = 1 }) end
for _, x in ipairs({ 42, 56, 70 }) do
  c:part(c:rrect(x, 25, x + 10, 33, 3):add(c:rect(x + 3, 24, x + 7, 25)), CREAM, { cres = 3, deep = 1, gloss = false })
end
-- floor goods in the middle: a barrel and a crate of apples
c:part(c:rrect(106, 30, 122, 50, 4), WOOD, { cres = 3, deep = 1 })
c:part(c:rect(130, 36, 150, 50), WOOD, { gloss = false, cres = 3, deep = 1 })
for _, x in ipairs({ 133, 139, 145 }) do c:part(c:ellipse(x, 34, 2.5, 2.5), RED, { cres = 2, deep = 0, gloss = false }) end
-- hanging lamp over the counter
c:fill(c:rect(198, 5, 198, 12), "#8a4f2a")
c:part(c:poly({ { 193, 13 }, { 204, 13 }, { 201, 19 }, { 196, 19 } }), GOLD, { cres = 2, deep = 0, gloss = false })
-- the counter on the right, empty wall behind it
c:part(c:rect(162, 40, c.W + 3, c.H + 3), OAK, { gloss = false, cres = 3, deep = 1 })
c:part(c:rect(158, 37, c.W + 3, 40), WOOD, { cres = 2, deep = 1 })
-- on the counter: brass scale (left end) and a sweet jar (right end)
local scale = c:rect(168, 35, 178, 36):add(c:rect(172, 24, 174, 35)):add(c:rect(162, 23, 184, 24))
  :add(c:poly({ { 161, 29 }, { 170, 29 }, { 168, 32 }, { 163, 32 } })):add(c:poly({ { 176, 29 }, { 185, 29 }, { 183, 32 }, { 178, 32 } }))
c:part(scale, GOLD, { flat = true })
c:part(c:rrect(222, 25, 232, 36, 3), X.ramp("glass", { gloss = "#eef8f2", dot = "#eef8f2", rim = "#eef8f2" }), { cres = 3, deep = 0, bounce = false })

X.layer(c, "detail")
for x = 186, c.W - 1, 26 do c:fill(c:rect(x, 42, x, c.H - 1), "#5e2f1e") end -- counter panels
for i, x in ipairs({ 10, 21, 32, 43, 54 }) do c:fill(c:rect(x + 1, 12, x + 6, 12), "#8a4f2a") end -- jar lids
for _, x in ipairs({ 42, 56, 70 }) do c:fill(c:rect(x + 3, 25, x + 7, 25), "#8a4f2a") end -- sack neck ties
c:fill(c:rect(162, 25, 162, 28):add(c:rect(169, 25, 169, 28)):add(c:rect(177, 25, 177, 28)):add(c:rect(184, 25, 184, 28)), "#8a4f2a") -- scale strings
c:fill(c:rect(106, 36, 122, 36), "#8a4f2a"); c:fill(c:rect(106, 44, 122, 44), "#8a4f2a")
for _, p in ipairs({ { 225, 29, "#dd3a2a" }, { 228, 31, "#f5cf6a" }, { 225, 33, "#4f9a45" }, { 229, 27, "#dd3a2a" } }) do
  c:paint({ "xx", "xx" }, p[1], p[2], { x = p[3] })
end

X.save(c, "shop-general", "scenes", { w = 480, h = 120, cap = 24 })
