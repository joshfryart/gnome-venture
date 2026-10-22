local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local tan = GV.ramp("#dcb06a")
local dress = GV.ramp("#a8582f")

local shell = c:ellipse(54, 40, 18, 18)
local body = c:ellipse(39.5, 104, 34, 27)
local apron = c:poly({ {27, 82}, {53, 82}, {58, 100}, {22, 100} })
local stalkL = c:line({ {29, 46}, {26, 38}, {22, 30} }, 3)
local stalkR = c:line({ {43, 46}, {45, 38}, {46, 30} }, 3)
local knobL = c:ellipse(21.5, 26.5, 5, 5)
local knobR = c:ellipse(46.5, 25.5, 5, 5)
local face = c:ellipse(36, 60, 19, 18)
local scarf = c:ellipse(36, 55, 23, 18):cut(c:ellipse(36, 67, 16, 19)):cut(c:rect(0, 66, 79, 99))

local p = c:build{
  { "shell",  shell,  "wood" },
  { "body",   body,   dress },
  { "apron",  apron,  "cream", { gloss = false } },
  { "stalkL", stalkL, tan, { flat = true } },
  { "stalkR", stalkR, tan, { flat = true } },
  { "knobL",  knobL,  tan, { gloss = false } },
  { "knobR",  knobR,  tan, { gloss = false } },
  { "face",   face,   tan },
  { "muzzle", c:ellipse(36, 67, 11, 7), "cream", { gloss = { 30, 62 } } },
  { "scarf",  scarf,  "water", { stitch = { side = "lit" } } },
}
-- shell spiral (2px, umber-dark)
c:fill(c:line({ {54, 40}, {56, 38}, {58, 40}, {57, 44}, {53, 46}, {49, 43}, {48, 38}, {51, 33}, {57, 32}, {62, 36}, {64, 42}, {62, 48} }, 2), "#5e2f1e")
-- apron straps + button
c:fill(c:line({ {28, 80}, {31, 84} }, 2), "#f9d49c")
c:fill(c:line({ {52, 80}, {49, 84} }, 2), "#f9d49c")
c:button(38, 84)
-- eyes on stalk tips
c:eye(19, 24); c:eye(44, 23)
-- nostrils and smile
c:px(32, 63, "#8a4234"); c:px(40, 63, "#8a4234")
c:paint({ "u.....u", ".uuuuu." }, 33, 67, { u = "umber" })
local t = c:save(D .. "test100/aseprite/ph/npc-clementine-moss.aseprite", D .. "test100/png/ph/npc-clementine-moss.png")
print(GV.report(t))
