-- home-cottage: villager home interior, 240x135 grid -> 480x270 (2x nearest). Part E: opaque, no border, cap 32.
-- The villager bust stands left-centre behind the counter, which covers grid y 107..134 (exported y 214..269) on the left.
-- Light from the upper left (window). The hearth adds warmth but the crescents stay lower right.
-- Families: soil 300 (plaster), wood (beams, floor, counter, shelf), water (window sky), moss, red (curtains, rug, jam),
--           stone (hearth), soil 900 (hearth mouth), flame + gold (fire, honey), leaf (herbs, plant).
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }
local WOOD = X.ramp("wood", { gloss = "#d9a660", dot = "#d9a660" })
local RED = X.ramp("red", { gloss = "#f2793a", dot = "#f2793a", bounce = "#ae2a2a", deep = "#ae2a2a" })
local STONE = X.ramp("stone", { bounce = "#686b73" })
local GOLD = X.ramp("gold", { base = "#f5cf6a", rim = "#f5cf6a", shade = "#e8a317", bounce = "#e8a317", deep = "#e8a317", gloss = "#f1ece0", dot = "#f1ece0" })
local LEAF = X.ramp("leaf", { bounce = "#2f6a3a", deep = "#2f6a3a", gloss = "#a4b86a", dot = "#a4b86a" })
local FLAME = X.ramp("flame", { rim = "#f5cf6a", gloss = "#f5cf6a", dot = "#f1ece0", shade = "#e0501f", bounce = "#e0501f", deep = "#e0501f" })

X.layer(c, "sky")      -- what the window shows
c:fill(c:rect(24, 20, 60, 34), "#a9d6ea"); c:fill(c:rect(24, 35, 60, 56), "#c8ecdc")
c:fill(c:ellipse(52, 60, 22, 12), "#7ab55c"); c:fill(c:ellipse(28, 62, 16, 10), "#a4b86a")

X.layer(c, "far")      -- back wall: warm plaster, wainscot, floor
local wall = c:rect(0, 0, c.W - 1, 92):cut(c:rect(24, 20, 60, 56))
c:fill(wall, "#c9a96e")
c:fill(c:rect(0, 74, c.W - 1, 92):cut(c:rect(24, 20, 60, 56)), "#d2be85") -- lower wall panel, lit plaster
X.ramp("#c9a96e")
for x = 4, c.W - 1, 16 do c:fill(c:rect(x, 76, x, 91), "#ac7440") end

X.layer(c, "ground")
c:fill(c:rect(0, 93, c.W - 1, c.H - 1), "#b07a45")
for i, y in ipairs({ 98, 104, 111, 119, 128 }) do
  c:fill(c:rect(0, y, c.W - 1, y), "#8a4f2a")
  for x = (i * 13) % 37, c.W - 1, 37 do c:fill(c:rect(x, y - (i == 1 and 4 or (y - ({ 93, 98, 104, 111, 119 })[i]) + 1), x, y - 1), "#8a4f2a") end
end

X.layer(c, "objects")
-- beams, skirting
c:build{
  { "beamTop", c:rect(-3, 4, c.W + 2, 9), WOOD, { gloss = false, cres = 2, deep = 1 } },
  { "postL", c:rect(74, 10, 79, 92), WOOD, { gloss = false, cres = 2, deep = 1 } },
  { "postR", c:rect(156, 10, 161, 92), WOOD, { gloss = false, cres = 2, deep = 1 } },
  { "skirt", c:rect(-3, 90, c.W + 2, 93), WOOD, { gloss = false, cres = 1, deep = 0 } },
}
-- window with cross bars, sill and red curtains
local frame = c:rect(20, 16, 64, 60):cut(c:rect(24, 20, 60, 56)):add(c:rect(41, 20, 43, 56)):add(c:rect(24, 37, 60, 39))
c:part(frame, WOOD, { gloss = false, cres = 2, deep = 1 })
c:part(c:rect(16, 60, 68, 63), WOOD, { gloss = false, cres = 2, deep = 1 })
c:part(c:poly({ { 14, 12 }, { 30, 12 }, { 24, 40 }, { 28, 58 }, { 16, 58 }, { 17, 40 } }), RED, { cres = 3, deep = 1, gloss = false })
c:part(c:poly({ { 54, 12 }, { 70, 12 }, { 67, 40 }, { 68, 58 }, { 56, 58 }, { 60, 40 } }), RED, { cres = 3, deep = 1, gloss = false })
c:part(c:rect(10, 9, 74, 12), WOOD, { gloss = false, cres = 1, deep = 0 }) -- curtain rail
-- shelf with three jars
c:part(c:rect(90, 46, 146, 49), WOOD, { gloss = false, cres = 1, deep = 0 })
c:part(c:poly({ { 94, 50 }, { 99, 50 }, { 94, 55 } }), WOOD, { flat = true }); c:part(c:poly({ { 137, 50 }, { 142, 50 }, { 142, 55 } }), WOOD, { flat = true })
c:part(c:rrect(96, 33, 106, 45, 2), GOLD, { cres = 3, deep = 1 })
c:part(c:rrect(112, 36, 121, 45, 2), RED, { cres = 3, deep = 1 })
c:part(c:rrect(127, 31, 137, 45, 2), LEAF, { cres = 3, deep = 1 })
-- hearth: stone surround, wooden mantel, dark mouth, logs and fire
local hearth = c:rect(170, 38, 228, 92):cut(c:rect(182, 62, 216, 92)):cut(c:ellipse(199, 62, 17, 8))
c:part(hearth, STONE, { cres = 4, deep = 2, gloss = false })
c:fill(c:rect(182, 62, 216, 89):add(c:ellipse(199, 62, 17, 8)):cut(c:rect(170, 38, 228, 53)), "#3d2a1c")
c:part(c:rect(165, 32, 233, 37), WOOD, { gloss = false, cres = 2, deep = 1 })
c:part(c:rrect(186, 84, 212, 89, 2), WOOD, { gloss = false, cres = 2, deep = 1 })
c:part(c:poly({ { 189, 85 }, { 192, 72 }, { 196, 78 }, { 199, 64 }, { 203, 76 }, { 206, 70 }, { 210, 85 } }), FLAME, { outline = false, cres = 3, deep = 0 })
c:fill(c:poly({ { 194, 85 }, { 197, 78 }, { 199, 72 }, { 202, 79 }, { 205, 85 } }), "#f5cf6a")
-- mantel things: a candle and a little clock-free honey pot
c:part(c:rrect(177, 22, 181, 31, 1), "cream", { gloss = false, rim = false, bounce = false, cres = 2, deep = 0 })
c:part(c:rect(174, 30, 184, 31), GOLD, { flat = true }) -- candle dish
c:part(c:rrect(216, 25, 224, 31, 2), GOLD, { cres = 2, deep = 1, gloss = false })
-- rug in front of the hearth (felt: hem stitch is a real join)
local rug = c:ellipse(196, 114, 34, 7)
c:part(rug, RED, { outline = false, cres = 2, deep = 0, gloss = false, stitch = true })
-- dried herbs hanging from the beam
for _, x in ipairs({ 98, 112, 126, 140 }) do
  c:fill(c:rect(x, 10, x, 15), "#8a4f2a")
  c:part(c:poly({ { x - 1, 14 }, { x + 2, 14 }, { x + 5, 27 }, { x - 4, 27 } }), LEAF, { cres = 2, deep = 0, gloss = false })
  c:fill(c:rect(x - 1, 16, x + 1, 17), "#d9a660") -- string tie
end
-- the counter across the bottom left (hides the villager's cut-off bust)
c:part(c:rect(-4, 110, 141, c.H + 4), X.ramp("wood", { base = "#a8582f", rim = "#b07a45", bounce = "#8a4f2a" }), { gloss = false, cres = 4, deep = 2 }) -- darker oak front
c:part(c:rect(-4, 106, 145, 110), WOOD, { cres = 2, deep = 1 })

X.layer(c, "detail")
for x = 22, 140, 30 do c:fill(c:rect(x, 113, x, c.H - 1), "#5e2f1e") end -- counter panel joints
c:fill(c:rect(0, 122, 136, 122), "#5e2f1e")
c:px(179, 19, "#e0501f"); c:px(179, 20, "#f5cf6a"); c:px(179, 21, "#f5cf6a") -- candle flame
c:paint({ "xxxxx" }, 97, 34, { x = "#8a4f2a" }); c:paint({ "xxxx" }, 115, 37, { x = "#8a4f2a" }); c:paint({ "xxxxx" }, 130, 32, { x = "#8a4f2a" }) -- jar lids

X.save(c, "home-cottage", "scenes", { w = 480, h = 270, cap = 32 })
