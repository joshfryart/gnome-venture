local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local D, L = GV.ramp("#4e3a8a"), GV.ramp("#7a5cc0")
local r = 7
local all = c:mask()
local function b(x,y) local m = c:ellipse(x,y,r,r); all:add(m); return m end
local b1,b2,b3 = b(18,45), b(32,45), b(46,45)
local b4,b5 = b(25,35), b(39,35)
local b6 = b(32,25)
c:build{
  { "stem", c:line({{31,19},{31,13}}, 3), "#2f5a2a", { flat = true } },
  { "b1", b1, D, { light = all, gloss = false } },
  { "b2", b2, L, { light = all, gloss = false } },
  { "b3", b3, D, { light = all, gloss = false } },
  { "b4", b4, L, { light = all } },
  { "b5", b5, D, { light = all, gloss = false } },
  { "b6", b6, L, { light = all } },
  { "leaf", c:poly({{33,16},{35,11},{39,8},{42,7},{42,10},{40,14},{36,17}}), "#58a03e", { gloss = false } },
}
local t = c:save(O .. "aseprite/ico/ico-grapes.aseprite", O .. "png/ico/ico-grapes.png")
print(GV.report(t))
