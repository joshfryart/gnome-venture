local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stone = GV.ramp("#6a6070")
c:build{
  { "pole", c:rect(30,30,34,53), stone },
  { "foot", c:rrect(24,52,40,56,2), stone },
  { "box", c:rrect(20,11,44,33,5), GV.ramp("#f5cf6a"), { gloss = {24,16} } },
  { "glow", c:ellipse(32,22,6), "gold", { gloss = false, rim = false } },
  { "roof", c:poly({ {16,14},{32,4},{48,14} }), stone },
}
c:fill(c:rect(31,20,32,23), "#fff1c8")
c:px(30,21,"#fff1c8"); c:px(33,22,"#fff1c8")
c:seam({ {19,13},{45,13} }, { free = false })
c:button(30, 7)
c:ground(32, 57, 12, 1.5)
local t = c:save(O .. "aseprite/ph/beeswax-candles.aseprite", O .. "png/ph/beeswax-candles.png")
print(GV.report(t))
