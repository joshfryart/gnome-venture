local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 50, 36, 36)
-- antennae: 2px sweeping arcs with 4x4 club tips
local antL = c:line({ {33,37}, {29,30}, {24,23}, {19,18}, {16,15} }, 2)
antL:add(c:rrect(12, 12, 16, 16, 1))
local antR = c:line({ {46,37}, {50,30}, {55,23}, {60,18}, {63,15} }, 2)
antR:add(c:rrect(63, 12, 67, 16, 1))
local ant = antL:copy(); ant:add(antR)

local tunic = c:ellipse(40, 100, 34, 24):cut(c:rect(0, 0, 79, 75))
-- pear head: wide domed top, tapered rounded chin
local head = c:ellipse(40, 49, 21, 15)
head:add(c:ellipse(40, 63, 14, 11))
head:add(c:poly({ {21,52}, {59,52}, {53,68}, {27,68} }))
head:cut(c:rect(0, 75, 79, 99))

local band = c:line({ {21,43}, {27,39}, {34,37}, {40,36}, {46,37}, {53,39}, {59,43} }, 3):clip(head)
local bead = c:ellipse(53, 37, 3, 3)

local p = c:build{
  { "disc",  disc, "#f5cf6a", { gloss = false } },
  { "ant",   ant, GV.ramp("#3e5a2a"), { flat = true } },
  { "tunic", tunic, GV.ramp("#3f93b2"), { stitch = { side = "lit" } } },
  { "head",  head, "moss" },
  { "band",  band, GV.ramp("#4a8a3e"), { flat = true } },
  { "bead",  bead, GV.ramp("#2f5a2a"), { gloss = { 52, 36 } } },
}

-- collar V
c:paint({
  "d.........d",
  ".d.......d.",
  "..d.....d..",
  "...d...d...",
  "....d.d....",
  ".....d.....",
}, 35, 77, { d = "#256a80" })
c:seam({ {40, 88}, {40, 99} })
c:button(38, 83)

-- giant bug eyes 7x7, 4x4 pupils
local L = { c = "#f2e4c0", p = "#2a1a10" }
local E = {
  ".ccccc.",
  "ccccccc",
  "ccppppc",
  "ccppppc",
  "ccppppc",
  "ccppppc",
  ".ccccc.",
}
c:paint(E, 24, 45, L); c:px(26, 47, "#fff3c8")
c:paint(E, 49, 45, L); c:px(51, 47, "#fff3c8")
-- eye rims (dark ring)
c:outline(c:ellipse(27, 48, 3.5, 3.5))
c:outline(c:ellipse(52, 48, 3.5, 3.5))

-- forehead line and smile
c:paint({ "f", "f", "f", "f" }, 40, 40, { f = "#4a8a3e" })
c:paint({
  "m.........m",
  ".mm.....mm.",
  "...mmmmm...",
}, 35, 62, { m = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/npc-ivy-brambleby.aseprite", O .. "png/ph/npc-ivy-brambleby.png")
print(GV.report(t))
