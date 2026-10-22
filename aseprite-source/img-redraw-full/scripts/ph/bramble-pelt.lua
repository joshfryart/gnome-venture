local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pelt = GV.ramp("#c47a52")
-- flat hide body
local hide = c:rrect(19, 20, 44, 44, 3)
-- scalloped / thorny top and bottom edges
for _, x in ipairs({ 21, 27, 33, 39 }) do
  hide:add(c:poly({ {x, 21}, {x + 2, 16}, {x + 4, 16}, {x + 6, 21} }))
  hide:add(c:poly({ {x, 44}, {x + 2, 49}, {x + 4, 49}, {x + 6, 44} }))
end
-- ragged side edges (small notches)
hide:cut(c:poly({ {19, 30}, {22, 32}, {19, 34} }))
hide:cut(c:poly({ {45, 29}, {42, 31}, {45, 33} }))
-- four leg stubs out at the corners, notched at the tip
local legs = c:mask()
legs:add(c:line({ {22, 23}, {14, 15} }, 6))
legs:add(c:line({ {41, 23}, {49, 15} }, 6))
legs:add(c:line({ {22, 41}, {14, 49} }, 6))
legs:add(c:line({ {41, 41}, {49, 49} }, 6))
legs:cut(c:poly({ {11, 12}, {15, 15}, {12, 16} })):cut(c:poly({ {52, 12}, {48, 15}, {51, 16} }))
legs:cut(c:poly({ {11, 52}, {15, 49}, {12, 48} })):cut(c:poly({ {52, 52}, {48, 49}, {51, 48} }))
hide:add(legs)
local p = c:build{
  { "hide", hide, pelt, { stitch = true } },
}
-- lit patch upper-left
c:fill(c:ellipse(27, 27, 3, 2):clip(hide), "#d9885a")
-- scratch marks (2 px curved strokes)
local sc = "#5e2f1e"
c:paint({ "s....", "ss...", ".ss..", "..ss.", "...s." }, 33, 25, { s = sc })
c:paint({ "...s", "..ss", ".ss.", "ss..", "s..." }, 25, 34, { s = sc })
c:paint({ "s....", "sss..", "..sss", "....s" }, 33, 37, { s = sc })
-- thorn pricks along the edges
for _, q in ipairs({ {30, 18}, {36, 47}, {21, 37}, {42, 26} }) do
  c:paint({ "tt" }, q[1], q[2], { t = "#2a1a10" })
end
local t = c:save(O .. "aseprite/ph/bramble-pelt.aseprite", O .. "png/ph/bramble-pelt.png")
print(GV.report(t))
