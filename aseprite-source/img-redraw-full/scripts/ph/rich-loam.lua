local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {11,24}, {53,24}, {47,57}, {17,57} })
body:add(c:rrect(17,50,46,56,4))
local soil = c:ellipse(31.5, 25, 18, 13)
local rim = c:rrect(8, 21, 55, 28, 2)
local p = c:build{
  { "tub",  body, GV.ramp("#a5663a") },
  { "soil", soil, GV.ramp("#5a3420"), { gloss = {20,17} } },
  { "rim",  rim,  GV.ramp("#dcb06a") },
}
-- staves on the tub
local stv = GV.ramp("#a5663a")
for _, s in ipairs({ {{22,30},{23,54}}, {{31,30},{31,55}}, {{41,30},{40,54}} }) do
  c:fill(c:line(s,1):clip(p.tub.m), stv.deep)
end
-- V scoop mark in the mound
c:fill(c:line({ {25,13}, {31,19}, {38,13} }, 2):clip(soil), "#2e1a12")
c:fill(c:line({ {26,15}, {31,20}, {37,15} }, 1):clip(soil), "#8c4a1a")
-- crumbs
c:px(19,20,"#3d2a1c"); c:px(20,20,"#3d2a1c")
c:px(43,16,"#3d2a1c"); c:px(42,18,"#8c4a1a")
c:px(35,9,"#8c4a1a"); c:px(36,9,"#8c4a1a")
c:seam({ {12,24.5}, {52,24.5} })
c:ground(31.5, 58, 17, 1.5)
local t = c:save(O.."aseprite/ph/rich-loam.aseprite", O.."png/ph/rich-loam.png")
print(GV.report(t))
