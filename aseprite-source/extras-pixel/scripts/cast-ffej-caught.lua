-- Ffej caught: red-handed. Hands up, a stolen purple piece still in the right claw, good eye wide and
-- looking sideways, brow up, wobbly worried mouth. Same body as ffej-v1.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 0, 0
local body = K.ffejBody(c, dx, dy)

-- arms straight up, claws open
local arms = c:line({ {18+dx, 26+dy}, {12+dx, 19+dy} }, 5); arms:add(c:ellipse(11+dx, 16+dy, 3, 3))
arms:add(c:line({ {45+dx, 26+dy}, {51+dx, 19+dy} }, 5)); arms:add(c:ellipse(52+dx, 16+dy, 3, 3))
arms:cut(body:shrink(1))
local loot = K.miniPiece(c, 47, 8)                                  -- the stolen piece, held up

c:build{
  { "arms", arms, K.FFEJ_ARM, { flat = true } },
  { "body", body, K.FFEJ_BODY, { stitch = { side = "lit" } } },
  { "loot", loot, GV.ramp("#8a5fd0"), { gloss = { 48, 11 } } },
}
c:paint({ "u.u", ".u." }, 9+dx, 12+dy, { u = "umber" })               -- left claw, open
K.ffejSeams(c, dx, dy)
K.ffejPatch(c, dx, dy)
-- good eye: pupil pushed to the far right (glancing away), brow lifted high
c:eye(35+dx, 24+dy)
c:fill(c:rect(36+dx, 25+dy, 38+dx, 27+dy), "#f1ece0"); c:fill(c:rect(37+dx, 25+dy, 39+dx, 27+dy), "#2a1a10")
c:px(37+dx, 25+dy, "#f1ece0")
c:paint({ ".uuuuu.", "u.....u" }, 33+dx, 18+dy, { u = "umber" })     -- raised, worried brow
c:paint({ ".uu...uu.", "u..uuu..u" }, 25+dx, 34+dy, { u = "umber" })  -- wobbly mouth
-- a couple of sweat-free "caught" lines: cream flick marks by the head
c:paint({ "c..", ".c.", "..c" }, 48+dx, 23+dy, { c = "#f1ece0" })
c:paint({ "ccc" }, 49+dx, 28+dy, { c = "#f1ece0" })
K.save(c, "ffej-caught")
