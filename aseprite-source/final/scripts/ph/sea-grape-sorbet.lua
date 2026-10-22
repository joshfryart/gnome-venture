local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wide low dish: flared rim, tapering to a foot
local bowl = c:poly({ {11, 38}, {53, 38}, {48, 49}, {16, 49} })
bowl:add(c:rrect(11, 37, 52, 41, 2))
local foot = c:rrect(23, 48, 40, 52, 2)

-- sorbet scoop: dome with three scalloped lobes hanging over the rim
local scoop = c:ellipse(31.5, 34, 18, 9):cut(c:rect(0, 37, 63, 63))
scoop:add(c:ellipse(19, 37, 5.5, 3.5))
scoop:add(c:ellipse(31.5, 38, 6.5, 4))
scoop:add(c:ellipse(44, 37, 5.5, 3.5))
scoop:add(c:ellipse(31.5, 31, 14, 8))
scoop:add(c:ellipse(29.5, 25, 7, 4))

local stick = c:rrect(34, 15, 37, 27, 1)
local leaf = c:poly({ {36, 8}, {41, 12}, {36, 17}, {31, 12} })

c:build{
  { "foot",  foot, GV.ramp("#dcb06a", { rim = "#ecc58a" }) },
  { "bowl",  bowl, GV.ramp("#dcb06a", { rim = "#ecc58a" }) },
  { "stick", stick, "#f6b8cf", { gloss = false } },
  { "scoop", scoop, GV.ramp("#7a5cc0") },
  { "leaf",  leaf, "gold", { gloss = { 34, 11 } } },
}
-- leaf vein
c:px(36, 12, GV.R.gold.shade); c:px(36, 13, GV.R.gold.shade); c:px(36, 14, GV.R.gold.shade)
-- sea-grape beads on the scoop
c:spot(c:ellipse(25, 31, 1.5, 1.5), "#4a3488", "#a894dc")
c:spot(c:ellipse(39, 30, 1.5, 1.5), "#4a3488", "#a894dc")
c:spot(c:ellipse(31, 35, 1.5, 1.5), "#4a3488", "#a894dc")
-- rim seam on the bowl
c:seam({ { 14, 44 }, { 50, 44 } })
c:ground(32, 55, 16, 2.5)
local t = c:save(O .. "aseprite/ph/sea-grape-sorbet.aseprite", O .. "png/ph/sea-grape-sorbet.png")
print(GV.report(t))
