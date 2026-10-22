local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:rrect(14, 20, 50, 54, 9)
jar:add(c:rect(22, 15, 42, 22))
local p = c:build{
  { "jar", jar, "glass" },
  { "cork", c:rrect(19, 6, 45, 16, 2), GV.ramp("#d9a660", { shade = "#b07a45", deep = "#8a4f2a" }) },
}
-- fat tilted yam tuber
local yam = c:ellipse(32, 39, 13, 9)
yam:add(c:ellipse(25, 42, 7, 7)); yam:add(c:ellipse(40, 36, 7, 6))
yam:add(c:poly({ {43, 31}, {47, 29}, {46, 34} }))
c:part(yam, GV.ramp("#e0501f", { shade = "#a8582f", deep = "#6e3020" }))
c:paint({ "r.", ".r", "r." }, 16, 44, { r = "#5a1410" })
c:paint({ "rr", "..", "r." }, 17, 48, { r = "#5a1410" })
-- tuber eyes / skin marks
c:px(30, 37, "#a8582f"); c:px(36, 41, "#a8582f"); c:px(27, 44, "#a8582f")
-- cork rings
c:paint({ "d.d..d.d", }, 24, 9, { d = "#b07a45" })
c:paint({ ".d..d..d" }, 26, 12, { d = "#b07a45" })
-- glass gloss streak
c:line({ {18, 26}, {18, 34} }, 1); c:fill(c:line({ {18, 26}, {18, 34} }, 1), "#fff1c8")
c:fill(c:rect(18, 37, 18, 38), "#fff1c8")
c:ground(32, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/yam-seed.aseprite", O .. "png/ph/yam-seed.png")
print(GV.report(t))
