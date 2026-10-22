local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local handle = c:line({ {21, 49}, {35, 17} }, 6)
handle:add(c:rrect(17, 47, 24, 53, 2))
local head = c:poly({{28, 12}, {37, 12}, {45, 10}, {48, 11}, {50, 15}, {51, 20}, {50, 25}, {47, 30}, {43, 27}, {37, 22}, {28, 22}})
local edge = head:copy():cut(head:shift(-4, 0))
c:build{
  { "handle", handle, "wood" },
  { "head", head, GV.ramp("#8c4a1a"), { gloss = { 34, 14 } } },
  { "edge", edge, GV.ramp("#c9c5bc"), { gloss = false } },
}
for i = 0, 5 do c:px(22 + i, 41 - math.floor(i / 2) + 0, "#8a4f2a") end
for i = 0, 5 do c:px(25 + i, 34 - math.floor(i / 2), "#8a4f2a") end
c:fill(c:rect(36, 15, 38, 18), "#5e2f1e")
local t = c:save(O .. "aseprite/ph/hatchet.aseprite", O .. "png/ph/hatchet.png")
print(GV.report(t))
