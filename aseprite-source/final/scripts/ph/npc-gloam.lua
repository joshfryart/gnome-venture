local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 50, 36, 36)
local coat = c:ellipse(39.5, 102, 34, 28):cut(c:rect(0, 0, 79, 73))
local shirt = c:poly({ {29, 74}, {40, 88}, {51, 74} })
local wingL = c:poly({ {4, 76}, {4, 56}, {9, 46}, {18, 44}, {26, 54}, {26, 74}, {21, 69}, {15, 76}, {9, 70} })
local wingR = c:poly({ {76, 76}, {76, 56}, {71, 46}, {62, 44}, {54, 54}, {54, 74}, {59, 69}, {65, 76}, {71, 70} })
local earL = c:poly({ {23, 46}, {20, 8}, {37, 38} })
local earR = c:poly({ {57, 46}, {60, 8}, {43, 38} })
local head = c:ellipse(40, 55, 19, 18)
local muzzle = c:ellipse(40, 64.5, 10, 6.5)

local violet = GV.ramp("#7a5cc0")
local p = c:build{
  { "disc", disc, GV.ramp("#e6d2ae"), { pale = true, gloss = false } },
  { "coat", coat, "gold", { stitch = { side = "lit" } } },
  { "shirt", shirt, GV.ramp("#f8eed2"), { pale = true, flat = true } },
  { "wingL", wingL, GV.ramp("#4e3a8a") },
  { "wingR", wingR, GV.ramp("#4e3a8a"), { gloss = false } },
  { "earL", earL, violet, { gloss = false } },
  { "earR", earR, violet, { gloss = false } },
  { "head", head, violet },
  { "muzzle", muzzle, GV.ramp("#c3b2ea"), { gloss = false } },
}
-- pink ear linings
c:fill(c:poly({ {25, 42}, {22, 16}, {33, 37} }), "#f6b8cf")
c:fill(c:poly({ {55, 42}, {58, 16}, {47, 37} }), "#f6b8cf")
c:fill(c:poly({ {27, 41}, {24, 24}, {31, 38} }), "#e46a9b")
c:fill(c:poly({ {53, 41}, {56, 24}, {49, 38} }), "#e46a9b")
-- wing finger ribs
c:fill(c:line({ {12, 49}, {12, 72} }, 1), "#3e2f66")
c:fill(c:line({ {19, 49}, {19, 68} }, 1), "#3e2f66")
c:fill(c:line({ {68, 49}, {68, 72} }, 1), "#3e2f66")
c:fill(c:line({ {61, 49}, {61, 68} }, 1), "#3e2f66")
-- collar shade
c:fill(c:line({ {28, 75}, {40, 89}, {52, 75} }, 1), "#b07a10")
c:seam({ {22, 80}, {30, 77} }); c:seam({ {50, 77}, {58, 80} })
c:button(38, 77)
-- face
c:eye(30, 48); c:eye(45, 48)
c:paint({ "nn.nn", ".nnn." }, 38, 60, { n = "#3e2f66" })
c:paint({ "m.......m", ".mmmmmmm." }, 36, 64, { m = "#2a1a10" })
c:paint({ "ff.ff", "f...f" }, 37, 66, { f = "#fff3c8" })
local t = c:save(O .. "aseprite/ph/npc-gloam.aseprite", O .. "png/ph/npc-gloam.png")
print(GV.report(t))
