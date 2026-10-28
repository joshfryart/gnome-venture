-- Ffej scatter: Ffej (upside-down twin) tips a wooden box of puzzle pieces over his shoulder, sly grin.
-- Body shifted left to make room for the spill on the right. Pieces: dusk purple + gold (ramped).
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -4, 0
local body = K.ffejBody(c, dx, dy)

-- left arm raised in a "whoops" shrug, right arm up holding the tilted box
local arms = c:line({ {18+dx, 27+dy}, {14+dx, 20+dy} }, 5); arms:add(c:ellipse(13+dx, 17+dy, 3, 3))
arms:add(c:line({ {45+dx, 25+dy}, {52+dx, 17+dy} }, 5)); arms:add(c:ellipse(53+dx, 15+dy, 3, 3))
arms:cut(body:shrink(1))

-- box tilted up-right, lid open, in the right hand (x ~44..58, y ~8..20)
local box = c:rrect(43, 11, 55, 20, 1)
local lid = c:poly({ {40, 7}, {52, 7}, {55, 11}, {43, 11} })

-- spilled pieces tumbling down the right side
local p1 = K.miniPiece(c, 46, 25)
local p2 = K.miniPiece(c, 46, 37)
local p3 = K.miniPiece(c, 37, 47)
local p4 = K.miniPiece(c, 46, 48)

c:build{
  { "arms", arms, K.FFEJ_ARM, { flat = true } },
  { "body", body, K.FFEJ_BODY, { stitch = { side = "lit" } } },
  { "box",  box,  "wood", { gloss = { 45, 13 } } },
  { "lid",  lid,  GV.ramp("#8a4f2a"), { flat = true } },
  { "p1", p1, GV.ramp("#8a5fd0"), { gloss = { 47, 28 } } },
  { "p2", p2, "gold", { gloss = { 47, 40 } } },
  { "p3", p3, GV.ramp("#8a5fd0"), { gloss = { 38, 50 } } },
  { "p4", p4, "gold", { gloss = { 47, 51 } } },
}
c:paint({ "u.u", ".u." }, 11+dx, 13+dy, { u = "umber" })                 -- left claw
c:paint({ "aaa", "aaa" }, 44, 15, { a = "#3c8f4a" })                      -- fingers over the box
c:fill(c:rect(45, 12, 53, 12), "#5e2f1e")                                 -- dark mouth of the box
c:seam({ {45, 18}, {53, 18} })
K.ffejSeams(c, dx, dy)
K.ffejPatch(c, dx, dy)
c:eye(35+dx, 24+dy)
c:paint({ "....uuu", "..uuu..", "uuu...." }, 33+dx, 19+dy, { u = "umber" })             -- angry brow
c:paint({ "..........u", ".........u.", "uuuuuuuuu.." }, 24+dx, 33+dy, { u = "umber" })  -- sly smirk
c:paint({ "ff" }, 29+dx, 36+dy, { f = "#c8d77a" })                                       -- tooth
K.save(c, "ffej-scatter")
