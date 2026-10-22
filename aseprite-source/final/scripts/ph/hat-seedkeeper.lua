local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local teal = GV.ramp("#256a80")
local blue = GV.ramp("#3f93b2")
local brim = c:ellipse(31.5, 49, 25, 6.5)
local crown = c:poly({ {13, 47}, {15, 36}, {19, 26}, {24, 18}, {30, 11}, {37, 7}, {44, 6},
                       {50, 8}, {52, 12}, {47, 13}, {42, 14}, {38, 18}, {39, 26}, {44, 35},
                       {49, 42}, {51, 47} })
local band = c:rrect(14, 39, 49, 46, 2)
local bobble = c:ellipse(51, 11.5, 3.5, 3.5)

local p = c:build{
  { "brim", brim, teal },
  { "crown", crown, blue, { gloss = { 22, 25 } } },
  { "band", band, teal, { gloss = false } },
  { "bobble", bobble, "gold" },
}
-- seed badge on the crown
local badge = c:ellipse(30, 31, 3.5, 5)
c:part(badge, "gold", { gloss = { 28, 28 } })
c:fill(c:rect(30, 28, 30, 35), "#b07a10")
-- brim stitch and band seam
c:seam({ {9, 51}, {16, 54}, {31, 56}, {46, 54}, {54, 51} })
c:seam({ {16, 42}, {47, 42} })
c:button(46, 40)

local t = c:save(D .. "img-redraw-full/aseprite/ph/hat-seedkeeper.aseprite",
                 D .. "img-redraw-full/png/ph/hat-seedkeeper.png")
print(GV.report(t))
