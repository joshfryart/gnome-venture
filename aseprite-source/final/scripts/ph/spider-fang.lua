local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bristles = c:line({ {22,38}, {15,33} }, 2):add(c:line({ {21,45}, {13,45} }, 2)):add(c:line({ {24,51}, {18,55} }, 2))
local hook = c:poly({ {27,40}, {27,33}, {29,27}, {32,21}, {36,16}, {40,13}, {42,13}, {41,17}, {39,22}, {37,28}, {36,34}, {36,40} })
c:build{
  { "bristles", bristles, "#5e2f1e", { flat = true } },
  { "bulb", c:ellipse(31, 45, 10, 9), GV.ramp("#9a5a32"), { gloss = { 23, 39 } } },
  { "hook", hook, GV.ramp("#5e2f1e", { rim = "#a8582f" }), { gloss = false } },
}
c:paint({ "..g", ".g.", ".g.", "g..", "g.." }, 28, 25, { g = "#d9a660" })
local t = c:save(O .. "aseprite/ph/spider-fang.aseprite", O .. "png/ph/spider-fang.png")
print(GV.report(t))
