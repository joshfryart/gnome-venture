local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tub = c:poly({{11,21},{53,21},{47,52},{17,52}}):add(c:ellipse(31.5,51,15,4)):add(c:ellipse(31.5,21,21,7))
local rim = c:ellipse(31.5,21,21,7):cut(c:ellipse(31.5,21,17,5))
local ash = c:ellipse(31.5,21,17,5):add(c:ellipse(31.5,18,11,6))
local p = c:build{
  { "tub", tub, GV.ramp("#a5663a"), { gloss = {15,30} } },
  { "rim", rim, GV.ramp("#dcb06a"), { gloss = false } },
  { "ash", ash, GV.ramp("#968f96"), { gloss = {25,15} } },
}
c:fill(c:line({{27,15},{31,20}},2):add(c:line({{32,20},{36,15}},2)), "#6a6070")
c:seam({{12,32},{20,35},{31,36},{43,35},{52,32}})
c:seam({{15,44},{22,46},{31,47},{41,46},{49,44}})
c:ground(31.5,55,17,2.5)
local t = c:save(O.."aseprite/ph/wood-ash.aseprite", O.."png/ph/wood-ash.png")
print(GV.report(t))
