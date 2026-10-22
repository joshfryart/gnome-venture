local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "back",  c:ellipse(27.5, 19, 10, 7),   GV.ramp("#6a6070") },
  { "mid",   c:ellipse(43.5, 32, 12, 8),   GV.ramp("#d6c9b6") },
  { "front", c:ellipse(20.5, 43, 12.5, 8.5), GV.ramp("#968f96") },
}
-- pale chips on each stone's upper-left
c:px(23, 15, "#c9c5bc"); c:px(24, 15, "#c9c5bc"); c:px(21, 17, "#c9c5bc")
c:px(37, 27, "#fffaf0"); c:px(38, 27, "#fffaf0"); c:px(35, 29, "#fffaf0")
c:px(14, 39, "#e0dcd4"); c:px(15, 39, "#e0dcd4"); c:px(12, 41, "#e0dcd4")
-- a few speckles for stone texture
c:px(31, 22, "#4f4858"); c:px(29, 23, "#4f4858")
c:px(48, 35, "#b2a48e"); c:px(46, 36, "#b2a48e")
c:px(24, 46, "#6f6874"); c:px(26, 45, "#6f6874")
c:ground(32, 55, 20, 3, "#6a4528")
local t = c:save(B .. "aseprite/ph/stone-path.aseprite", B .. "png/ph/stone-path.png")
print(GV.report(t))
