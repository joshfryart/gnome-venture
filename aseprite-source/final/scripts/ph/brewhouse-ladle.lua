local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- Brewhouse Ladle: deep copper bowl low-left, long handle rising to a hanging
-- hook upper-right, wooden grip, a dent knocked into the bowl's front.
local copper = GV.ramp("#e0501f", { rim = "#f08a24", gloss = "#ffc27a", shade = "#b8452f", deep = "#6b1b2c" })
local copperD = GV.ramp("#b8661a", { rim = "#f08a24" })
local wood = "wood"
-- handle shaft with a hook curl at the top
local shaft = c:line({ { 33, 36 }, { 45, 20 } }, 4)
local hook = c:line({ { 48, 12 }, { 50, 8 }, { 53, 8 }, { 55, 11 }, { 54, 15 } }, 3)
local grip = c:line({ { 44, 22 }, { 50, 12 } }, 6)
-- bowl: hemisphere below an open elliptical mouth
local bowl = c:ellipse(24, 40, 17, 15):clip(c:rect(0, 40, 63, 63))
bowl:add(c:ellipse(24, 40, 17, 6))
-- the dent flattens the lower-left of the bowl
bowl:cut(c:ellipse(9, 51, 5, 4))
local inside = c:ellipse(24, 39.5, 14, 4)
c:build{
  { "hook", hook, copperD, { flat = true } },
  { "shaft", shaft, copperD },
  { "grip", grip, wood },
  { "bowl", bowl, copper, { gloss = { 12, 46 } } },
  { "inside", inside, GV.ramp("#6b1b2c", { rim = "#ae2a2a" }), { gloss = false, contact = false, rim = false, bounce = false } },
}
-- lit lip of the far rim inside the mouth
c:fill(c:ellipse(24, 39.5, 14, 4):cut(c:ellipse(24, 40.5, 14, 4)), "#b8452f")
-- dent crease: shadowed upper-left wall, lit lower-right wall
c:fill(c:line({ { 13, 47 }, { 15, 50 }, { 15, 53 } }, 1), "#6b1b2c")
c:fill(c:line({ { 16, 48 }, { 17, 51 } }, 1), "#ffc27a")
-- twine wrap on the grip (a real join): seam across it, rivet button where handle meets bowl
c:seam({ { 46, 21 }, { 51, 13 } })
c:button(34, 33)
local t = c:save(D .. "final/aseprite/ph/brewhouse-ladle.aseprite", PNG .. "brewhouse-ladle.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
