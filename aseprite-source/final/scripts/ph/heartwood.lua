local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local log = c:rrect(7, 24, 50, 48, 11)
local face = c:ellipse(48, 36, 7, 12)
local p = c:build{
  { "log",  log,  GV.ramp("#8c4a1a"), { gloss = { 14, 28 } } },
  { "face", face, GV.ramp("#dcb06a"), { gloss = false, cres = 2 } },
}
-- growth rings (2px) and pith
local ring = c:ellipse(48, 36, 4.5, 7.5):cut(c:ellipse(48, 36, 2.5, 5.5))
c:fill(ring:clip(p.face.m), "#a5663a")
c:fill(c:rect(47, 35, 48, 36), "#8a4f2a")
-- bark grain
c:fill(c:line({ { 18, 30 }, { 36, 30 } }, 2), "#5e2f1e")
c:fill(c:line({ { 12, 40 }, { 24, 40 }, { 26, 41 }, { 36, 41 } }, 2), "#5e2f1e")
c:fill(c:line({ { 28, 35 }, { 34, 35 } }, 2), "#5e2f1e")
local t = c:save(O .. "aseprite/ph/heartwood.aseprite", O .. "png/ph/heartwood.png")
print(GV.report(t))
