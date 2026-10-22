local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- nut: round belly, slightly pointed top hidden under the cap
local nut = c:ellipse(31.5, 38, 15, 15)
nut:add(c:ellipse(31.5, 30, 11, 12))
-- cap: dome with a three-bump scalloped lower edge
local cap = c:ellipse(31.5, 29, 17, 11):cut(c:rect(0, 30, 63, 63))
for _, bx in ipairs({ 20, 31.5, 43 }) do cap:add(c:ellipse(bx, 30, 6, 4.5)) end
cap:cut(c:rect(0, 0, 63, 17))
cap:add(c:ellipse(31.5, 20, 9, 3))
local p = c:build{
  { "stem", c:rrect(30, 12, 33, 22, 1), GV.ramp("#2f5a2a"), { flat = true } },
  { "nut",  nut, GV.ramp("#a5663a"), { gloss = { 21, 39 } } },
  { "cap",  cap, GV.ramp("#8c4a1a"), { gloss = { 22, 23 } } },
}
-- smile-shaped hilum scar on the lower belly
c:fill(c:line({ { 26, 44 }, { 29, 46 }, { 34, 46 }, { 37, 44 } }, 2):clip(p.nut.m), "#5e2f1e")
local t = c:save(O .. "aseprite/ph/hazelnut.aseprite", O .. "png/ph/hazelnut.png")
print(GV.report(t))
