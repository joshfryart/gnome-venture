local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local legs = c:line({ {30, 33}, {25, 40}, {20, 48} }, 3)
legs:add(c:line({ {31, 33}, {37, 40}, {41, 48} }, 3))
legs:add(c:line({ {30, 31}, {25, 24}, {22, 17} }, 3))
legs:add(c:line({ {32, 31}, {37, 24}, {41, 17} }, 3))
local ant = c:line({ {15, 26}, {11, 20}, {12, 15} }, 3)
ant:add(c:rect(10, 11, 13, 14))
local abd = c:ellipse(47, 32, 10, 9)
local thx = c:ellipse(31, 32, 5, 5)
local head = c:ellipse(18, 31, 7, 7)

local tan = GV.ramp("#a27e55")
local p = c:build{
  { "legs", legs, tan, { flat = true } },
  { "ant",  ant,  tan, { flat = true } },
  { "abd",  abd,  "#7a3a1e" },
  { "thx",  thx,  "#d9731f" },
  { "head", head, "#7a3a1e" },
}
c:eye(14, 27, true); c:eye(20, 27, true)
-- mouth
c:px(18, 34, "#2a1a10"); c:px(19, 35, "#2a1a10"); c:px(20, 35, "#2a1a10")
-- abdomen bands
c:fill(c:line({ {45, 24}, {44, 32}, {45, 40} }, 1), "#5e2f1e")

local t = c:save(O .. "aseprite/ico/ico-ant.aseprite", O .. "png/ico/ico-ant.png")
print(GV.report(t))
