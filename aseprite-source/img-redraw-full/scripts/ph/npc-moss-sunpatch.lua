local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 50, 36, 36)
local coat = c:ellipse(40, 102, 33, 26):clip(c:rect(0, 74, 79, 99))
local earL = c:ellipse(17, 42, 10, 10)
local earR = c:ellipse(63, 42, 10, 10)
local face = c:ellipse(40, 57, 20, 17)
local muzzle = c:ellipse(40, 64.5, 12, 8)
local nose = c:ellipse(40, 61, 3.5, 2.5)
local cone = c:poly({ {25, 42}, {51, 3}, {55, 3}, {57, 42} })
local brim = c:ellipse(40, 42, 23, 4)
local tip = c:poly({ {48, 2}, {57, 2}, {57, 10}, {45, 10} }):clip(cone)

local taupe = GV.ramp("#a38f80")
local p = c:build{
  { "disc", disc, GV.ramp("#b0bc66"), { stitch = { side = "lit" } } },
  { "coat", coat, taupe, { stitch = { side = "lit" } } },
  { "earL", earL, "wood" },
  { "earR", earR, "wood" },
}
c:part(c:ellipse(17, 42, 6, 6), "petal", { flat = true })
c:part(c:ellipse(63, 42, 6, 6), "petal", { flat = true })
c:build{
  { "face", face, "wood" },
  { "muzzle", muzzle, "skin" },
  { "nose", nose, GV.ramp("#d9667f"), { flat = true } },
  { "cone", cone, GV.ramp("#7b66b4") },
  { "tip", tip, GV.ramp("#3e2f66"), { flat = true } },
  { "brim", brim, GV.ramp("#4e3a8a") },
}
-- band glint on hat
c:fill(c:line({ {31, 37}, {39, 24} }, 1), "#c8b8f0")
-- brim stitch
c:seam({ {20, 44}, {30, 46}, {50, 46}, {60, 44} })
-- coat: collar seam, placket and buttons
c:seam({ {14, 80}, {28, 76}, {40, 78}, {52, 76}, {66, 80} })
c:fill(c:rect(39, 82, 40, 99), "#2a1a10")
c:button(38, 84); c:button(38, 92)
-- face
c:eye(28, 49); c:eye(47, 49)
c:fill(c:line({ {26, 62}, {18, 61} }, 1), "#2a1a10")
c:fill(c:line({ {26, 65}, {19, 68} }, 1), "#2a1a10")
c:fill(c:line({ {54, 62}, {62, 61} }, 1), "#2a1a10")
c:fill(c:line({ {54, 65}, {61, 68} }, 1), "#2a1a10")
c:paint({ "u.....u", ".uuuuu." }, 37, 67, { u = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/npc-moss-sunpatch.aseprite", O .. "png/ph/npc-moss-sunpatch.png")
print(GV.report(t))
