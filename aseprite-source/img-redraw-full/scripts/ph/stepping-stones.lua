local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local slate = GV.ramp("#6a6070")
local lime  = GV.ramp("#d6c9b6")
local grey  = GV.ramp("#968f96")
local back  = c:ellipse(29, 17, 10, 6)
local right = c:ellipse(44, 31, 11, 7)
local front = c:ellipse(20, 43, 13, 8)
c:build{
  { "back",  back,  slate },
  { "right", right, lime },
  { "front", front, grey, { gloss = { 13, 39 } } },
}
-- pit marks: short dark dashes
c:px(25, 15, slate.deep); c:px(26, 15, slate.deep)
c:px(32, 19, slate.shade)
c:px(47, 33, lime.shade); c:px(48, 33, lime.shade)
c:px(40, 28, lime.shade)
c:px(22, 46, grey.deep); c:px(23, 46, grey.deep)
c:px(27, 41, grey.shade)
local t = c:save(O .. "aseprite/ph/stepping-stones.aseprite", O .. "png/ph/stepping-stones.png")
print(GV.report(t))
