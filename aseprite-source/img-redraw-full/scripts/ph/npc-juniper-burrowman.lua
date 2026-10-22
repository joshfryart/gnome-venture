local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 52, 33, 33)
local coat = c:ellipse(39.5, 100, 33, 24):cut(c:rect(0, 100, 79, 120))
local earL = c:ellipse(17, 40, 9, 9)
local earR = c:ellipse(63, 40, 9, 9)
local head = c:ellipse(40, 54, 21, 18)
local muzzle = c:ellipse(40, 63, 12, 8)
local nose = c:ellipse(39.5, 58, 3.5, 2)
local cap = c:ellipse(39.5, 40, 20, 16):cut(c:rect(0, 40, 79, 99))
local fold = c:rrect(19, 37, 60, 42, 2)
local pom = c:ellipse(39.5, 22, 4.5, 4.5)

local p = c:build{
  { "disc", disc, GV.ramp("#b8d8d2"), { gloss = false } },
  { "coat", coat, GV.ramp("#a38f80"), { stitch = { side = "lit" } } },
  { "earL", earL, GV.ramp("#a5663a") },
  { "earR", earR, GV.ramp("#a5663a") },
  { "head", head, GV.ramp("#a5663a") },
  { "muzzle", muzzle, GV.ramp("#dcb06a") },
  { "nose", nose, GV.ramp("#d9667f"), { flat = true } },
  { "cap", cap, GV.ramp("#7a5cc0") },
  { "fold", fold, "dusk", { stitch = { side = "lit" } } },
  { "pom", pom, "dusk" },
}
-- inner ears (visible part below cap)
c:fill(c:ellipse(16, 41, 5, 5):cut(fold:grow(1)), "#f6b8cf")
c:fill(c:ellipse(64, 41, 5, 5):cut(fold:grow(1)), "#f6b8cf")
c:fill(c:ellipse(16, 43, 3, 2):cut(fold:grow(1)), "#e46a9b")
c:fill(c:ellipse(64, 43, 3, 2):cut(fold:grow(1)), "#e46a9b")
-- collar V and placket
c:fill(c:line({ {30, 79}, {39, 88} }, 2), "#8f7060")
c:fill(c:line({ {49, 79}, {40, 88} }, 2), "#8f7060")
c:fill(c:line({ {39, 87}, {39, 99} }, 2), "#2a1a10")
c:button(38, 89); c:button(38, 95)
-- face
c:eye(28, 48); c:eye(47, 48)
c:paint({ "u.....u", ".uuuuu." }, 37, 65, { u = "umber" })
c:px(40, 61, GV.C.umber); c:px(40, 62, GV.C.umber)
c:fill(c:line({ {28, 60}, {21, 59} }, 1), GV.C.umber)
c:fill(c:line({ {28, 63}, {21, 64} }, 1), GV.C.umber)
c:fill(c:line({ {52, 60}, {59, 59} }, 1), GV.C.umber)
c:fill(c:line({ {52, 63}, {59, 64} }, 1), GV.C.umber)

local t = c:save(O .. "aseprite/ph/npc-juniper-burrowman.aseprite", O .. "png/ph/npc-juniper-burrowman.png")
print(GV.report(t))
