local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local back = c:ellipse(39.5, 46, 34, 34)
local coat = c:ellipse(39.5, 104, 33, 30)
local glowO = c:ellipse(39.5, 84, 26, 24)
local glowI = c:ellipse(39.5, 84, 18, 17)
local scarf = c:line({ {27, 69}, {33, 72}, {40, 73}, {46, 72}, {52, 69} }, 4)
scarf:add(c:poly({ {45, 72}, {51, 72}, {53, 86}, {47, 86} }))
local lamp = c:ellipse(39.5, 85, 12, 9)
local head = c:ellipse(39.5, 50, 17, 16)
local cap = c:ellipse(39.5, 41, 19, 13):cut(c:rect(0, 42, 79, 99))
cap:add(c:rrect(19, 38, 60, 43, 2))
local bob = c:ellipse(39.5, 27, 3, 3)

local p = c:build{
  { "back",  back,  "#b8d8d2", { flat = true } },
  { "coat",  coat,  "#7a5cc0", { stitch = { side = "lit" } } },
  { "glowO", glowO, "#fff1c8", { flat = true } },
  { "glowI", glowI, "#f5cf6a", { flat = true } },
}
local clubs = c:line({ {31, 30}, {27, 24}, {24, 18} }, 2):add(c:line({ {48, 30}, {52, 24}, {55, 18} }, 2))
clubs:add(c:rrect(21, 14, 24, 17, 1)):add(c:rrect(55, 14, 58, 17, 1))
local p2 = c:build{
  { "clubs", clubs, "#5e2f1e", { flat = true } },
  { "head",  head,  "#6e3a1c" },
  { "scarf", scarf, "#3f93b2" },
  { "lamp",  lamp,  "gold", { gloss = { 34, 80 } } },
  { "cap",   cap,   "#3f93b2", { stitch = { side = "lit" } } },
  { "bob",   bob,   "#256a80" },
}
c:fill(c:rect(44, 39, 56, 41), "#256a80")
c:seam({ {21, 42}, {58, 42} })
c:button(38, 70)
c:eye(32, 48); c:eye(43, 48)
c:paint({ "c.......c", ".ccccccc." }, 36, 57, { c = "#f2e4c0" })
local t = c:save(O .. "aseprite/ph/npc-lantern-lou.aseprite", O .. "png/ph/npc-lantern-lou.png")
print(GV.report(t))
