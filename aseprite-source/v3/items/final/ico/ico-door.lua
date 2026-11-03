local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-door: arched wooden plank door in a pale stone frame with iron hinges and a brass knob.
-- quirk: a little heart-shaped window is cut in the planks, and a tiny round mouse hole sits at the foot.
local c = D.new("ico-door")
c:groundShadow(32, 58, 20, 2)
local frame = D.sub(c:rrect(12, 6, 52, 57, 2), c:rect(0, 0, 0, 0)):add(D.ell(32, 18, 20, 13))
frame:cut(c:rect(0, 0, 63, 3))
D.lit(frame, D.P.stone, 6)
local door = c:rect(17, 18, 47, 56):add(D.ell(32, 22, 15, 15)):clip(c:rect(0, 0, 63, 56))
door:cut(c:rect(0, 0, 63, 7))
D.lit(door, D.BRN, 8, { amb = 0.15 })
for _, x in ipairs{ 24, 32, 40 } do D.fill(D.isect(door, c:rect(x, 0, x, 63)), D.BRN[1]) D.fill(D.isect(door, c:rect(x + 1, 0, x + 1, 63)), D.BRN[5]) end
-- hinges
for _, y in ipairs{ 24, 46 } do D.fill(c:rect(17, y, 27, y + 2), D.STEEL[1]) D.fill(c:rect(17, y, 27, y), D.STEEL[4]) end
-- knob
D.lit(D.disc(42, 40, 3), D.GOLD, 2)
-- heart window
local hw = c:poly{ { 28, 18 }, { 29, 16 }, { 32, 17 }, { 35, 16 }, { 36, 18 }, { 32, 23 } }:add(c:rect(29, 17, 35, 19))
D.fill(hw, "#fde79a")
D.fill(D.isect(hw, c:rect(0, 20, 63, 24)), "#f5b82e")
-- mouse hole
D.fill(D.isect(D.disc(23, 56, 3), c:rect(0, 0, 63, 56)), D.INK)
D.fin()
