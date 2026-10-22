local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#5f6a62")
local light = GV.ramp("#8d9a90")
local legs = c:line({{11,42},{9,48}}, 3):add(c:line({{19,44},{17,50}}, 3))
legs:add(c:line({{45,44},{47,50}}, 3)):add(c:line({{52,42},{54,48}}, 3))
local p = c:build{
  { "legs",  legs, dark, { flat = true } },
  { "earL",  c:ellipse(18, 17, 4.5), light },
  { "earR",  c:ellipse(45, 17, 4.5), light },
  { "body",  c:ellipse(31.5, 33, 22, 14), dark },
  { "face",  c:ellipse(31.5, 27, 19, 9.5), light },
}
-- ear holes
c:fill(c:ellipse(18, 16, 1.5), "#4a5160")
c:fill(c:ellipse(45, 16, 1.5), "#4a5160")
-- rock pits
for _, q in ipairs{ {15,27}, {48,27}, {27,20}, {37,19}, {12,37}, {51,37} } do
  c:spot(c:ellipse(q[1], q[2], 1), "#4f5852")
end
-- brow arc
c:seam({ {15,23}, {22,20}, {31,19}, {32,19}, {41,20}, {48,23} }, { on = 99, off = 0, gap = "#8f7fc9", free = true })
-- mouth: gaping crescent
local mouth = c:ellipse(31.5, 35, 13, 9):cut(c:ellipse(31.5, 31, 13, 4.5)):cut(c:rect(0, 0, 63, 31))
local lip = mouth:copy():cut(mouth:shift(0, -2))
c:fill(mouth, "#2f3440")
c:fill(lip, "#8f7fc9")
c:fill(lip:copy():cut(lip:shift(0, -1)), "#5e4f99")
-- eyes
c:eye(21, 23); c:eye(38, 23)
c:ground(31.5, 54, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-old-holler.aseprite", O .. "png/ph/creature-old-holler.png")
print(GV.report(t))
