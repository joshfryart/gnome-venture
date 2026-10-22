local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fang = c:poly({{15,7},{17,8},{23,12},{30,19},{35,28},{38,38},{39,48},{39,52},{14,52},{14,44},{16,36},{17,28},{16,20},{15,13}})
fang:add(c:ellipse(26.5,51,12.5,3.5))
local gum = c:rrect(13,47,40,55,3)
local p = c:build{
  { "fang", fang, GV.ramp("#dcb06a"), { gloss = {19,18}, cres = 6 } },
  { "root", gum, GV.ramp("#a5663a"), { gloss = false } },
}
c:fill(c:line({{20,44},{22,36},{21,28}},3):clip(fang):cut(gum), "#f1ece0")
c:seam({{14,51},{39,51}})
c:ground(26.5,57,15,2.5)
local t = c:save(O.."aseprite/ph/wyrm-fang.aseprite", O.."png/ph/wyrm-fang.png")
print(GV.report(t))
