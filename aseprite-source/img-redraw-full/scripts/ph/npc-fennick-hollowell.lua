local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local blue = GV.ramp("#3f93b2")
local tan = GV.ramp("#dcb06a")
local coat = c:ellipse(40, 100, 34, 24)
local scarf = c:line({ {27, 79}, {33, 83}, {40, 85}, {47, 83}, {53, 79} }, 4)
scarf:add(c:rrect(47, 82, 51, 96, 1))
local cone = c:poly({ {19, 48}, {34, 26}, {45, 13}, {52, 5}, {50, 18}, {54, 32}, {60, 48} })
local stalkL = c:line({ {27, 52}, {23, 44}, {19, 35}, {18, 30} }, 3)
local stalkR = c:line({ {46, 52}, {50, 44}, {54, 36}, {56, 31} }, 3)
local p = c:build{
  { "backdrop", c:ellipse(40, 50, 36, 36), "moss", { gloss = false } },
  { "coat", coat, "#a5663a" },
  { "scarf", scarf, blue, { stitch = false } },
  { "shell", c:ellipse(60, 54, 15, 15), "#b5763f" },
  { "head", c:ellipse(35, 62, 17, 16), tan },
  { "muzzle", c:ellipse(35, 68, 9, 6), "#f8eed2", { gloss = false } },
  { "cone", cone, blue, { light = cone:copy():add(c:ellipse(39, 47, 24, 4.5)) } },
  { "brim", c:ellipse(39, 48, 24, 4), "#256a80", { gloss = false } },
  { "stalkL", stalkL, tan, { flat = true } },
  { "stalkR", stalkR, tan, { flat = true } },
  { "eyeL", c:ellipse(18.5, 29, 4, 4), "cream", { gloss = false, flat = true } },
  { "eyeR", c:ellipse(56.5, 30, 4, 4), "cream", { gloss = false, flat = true } },
}
-- shell spiral (visible part right of the hat)
c:fill(c:line({ {62, 54}, {64, 51}, {68, 53}, {68, 58}, {64, 62}, {58, 63} }, 2), "#5e2f1e")
c:fill(c:line({ {68, 44}, {72, 48}, {73, 54} }, 2), "#5e2f1e")
c:seam({ {16, 48}, {62, 48} })
c:seam({ {29, 82}, {40, 86}, {51, 82} })
c:button(36, 82)
c:eye(16, 27); c:eye(54, 28)
c:paint({ "u.....u", ".uuuuu." }, 32, 67, { u = "#4a2c1a" })
local t = c:save(O .. "aseprite/ph/npc-fennick-hollowell.aseprite", O .. "png/ph/npc-fennick-hollowell.png")
print(GV.report(t))
