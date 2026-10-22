local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local root = c:ellipse(31.5, 31, 13, 10)
root:add(c:poly({ {19, 32}, {44, 32}, {38, 44}, {34, 51}, {31, 53}, {29, 51}, {24, 43} }))
root:add(c:rrect(21, 21, 42, 28, 4))
root = root:closed(2)
local lsp = c:poly({ {31, 23}, {26, 18}, {22, 13}, {21, 9}, {25, 10}, {29, 14}, {33, 21} })
local rsp = c:poly({ {32, 23}, {36, 17}, {40, 12}, {44, 9}, {44, 13}, {41, 18}, {35, 23} })
local p = c:build{
  { "root", root, GV.ramp("#dcb06a", { shade = "#b07a45" }), { gloss = { 25, 26 } } },
  { "lsp", lsp, GV.ramp("#58a03e") },
  { "rsp", rsp, GV.ramp("#58a03e") },
}
-- midribs
c:fill(c:line({ {30, 20}, {26, 15}, {23, 11} }, 1), "#2f5a2a")
c:fill(c:line({ {34, 20}, {38, 15}, {42, 11} }, 1), "#2f5a2a")
-- skin eyes
c:fill(c:line({ {23, 31}, {28, 31} }, 1), "#5e2f1e"); c:fill(c:line({ {24, 32}, {27, 32} }, 1), "#8a4f2a")
c:fill(c:line({ {34, 39}, {38, 39} }, 1), "#5e2f1e"); c:fill(c:line({ {35, 40}, {37, 40} }, 1), "#8a4f2a")
c:px(38, 27, "#8a4f2a"); c:px(39, 27, "#8a4f2a")
-- root hair at tip
c:px(30, 54, "#8a4f2a"); c:px(29, 55, "#8a4f2a")
local t = c:save(O .. "aseprite/ph/sweet-potato.aseprite", O .. "png/ph/sweet-potato.png")
print(GV.report(t))
