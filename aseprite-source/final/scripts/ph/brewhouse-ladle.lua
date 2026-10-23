local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- Brewhouse Ladle: deep copper bowl low-left, copper strap handle riveted on,
-- flat hang-loop end upper-right, a dent knocked into the bowl.
local copper = GV.ramp("#e0501f", { rim = "#f08a24", gloss = "#ffc27a", shade = "#b8452f", deep = "#6b1b2c" })
local copperD = GV.ramp("#b8661a", { rim = "#f08a24" })
-- handle, bowl-end to tip: one copper strap ending in a flat hang-loop paddle
local shaft = c:line({ { 31, 37 }, { 46, 17 } }, 4)
local cap = c:ellipse(49.5, 12.5, 5, 4.5)
-- bowl: hemisphere below an open elliptical mouth; the dent flattens its lower-left
local bowl = c:ellipse(24, 40, 17, 15):clip(c:rect(0, 40, 63, 63))
bowl:add(c:ellipse(24, 40, 17, 6))
bowl:cut(c:ellipse(9, 51, 4.5, 3.5))
local inside = c:ellipse(24, 39.5, 14, 4)
c:build{
  { "shaft", shaft, copper, { cres = 2, deep = 1 } },
  { "cap", cap, copper, { gloss = { 47, 10 } } },
  { "bowl", bowl, copper, { gloss = { 12, 45 } } },
  { "inside", inside, GV.ramp("#6b1b2c", { rim = "#ae2a2a" }), { gloss = false, contact = false, rim = false, bounce = false } },
}
-- hang hole in the cap
c:fill(c:rect(50, 12, 51, 13), "#2a1a10"); c:px(50, 12, "#4a2c1a")
-- lit lip of the far rim inside the mouth
c:fill(c:ellipse(24, 39.5, 14, 4):cut(c:ellipse(24, 40.5, 14, 4)), "#b8452f")
-- dent crease: shadowed upper-left wall, lit lower-right wall
c:fill(c:line({ { 13, 46 }, { 14, 48 }, { 14, 51 }, { 13, 53 } }, 1), "#6b1b2c")
c:fill(c:line({ { 15, 48 }, { 15, 51 } }, 1), "#ffc27a")
-- rivet where the strap is fixed to the bowl (the one real join)
c:button(32, 31)
local t = c:save(D .. "final/aseprite/ph/brewhouse-ladle.aseprite", PNG .. "brewhouse-ladle.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
