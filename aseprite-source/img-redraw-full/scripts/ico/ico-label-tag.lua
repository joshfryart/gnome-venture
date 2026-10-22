local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local body = c:poly({ {13, 32}, {26, 17}, {52, 17}, {52, 48}, {26, 48} })
local p = c:build{
  { "tag", body, GV.ramp("#dcb06a"), { stitch = true } },
}
-- hole: umber ring with a pale centre
c:fill(c:ellipse(26, 32, 5.5), GV.C.umber)
c:fill(c:ellipse(26, 32, 4), "#f8eed2")
c:px(25, 30, "#fff3c8")
-- decoration bars
c:fill(c:rect(33, 27, 47, 28), "#b8661a")
c:fill(c:rect(33, 34, 44, 35), "#b8661a")
-- string loop through the hole, out to the upper left
local str = c:line({ {26, 30}, {21, 24}, {17, 19}, {15, 14}, {18, 11}, {22, 13}, {23, 18}, {25, 26} }, 2)
c:part(str, "#8c4a1a", { flat = true })
local t = c:save(O .. "aseprite/ico/ico-label-tag.aseprite", O .. "png/ico/ico-label-tag.png")
print(GV.report(t))
