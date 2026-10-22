local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local shell = c:poly({{32,9},{53,20},{50,46},{32,56},{14,46},{11,20}})
-- side points (crab carapace spikes)
shell:add(c:poly({{11,20},{8,24},{13,27}}))
shell:add(c:poly({{53,20},{56,24},{51,27}}))
local inner = c:poly({{32,15},{46,22},{43,40},{32,48},{21,40},{18,22}})
local p = c:build{
  { "shell", shell, GV.ramp("#7ab55c"), { light = shell } },
  { "inner", inner, GV.ramp("#58a03e"), { light = shell, gloss = {23, 25} } },
}
-- centre ridge
c:fill(c:rect(31, 11, 32, 52), "#4a8a3e")
c:fill(c:rect(31, 11, 31, 30), "#6a9a3a")
-- rim bumps
c:fill(c:ellipse(20, 19, 1.5), "#a4b86a"); c:px(19, 18, "#c8d77a")
c:fill(c:ellipse(44, 19, 1.5), "#a4b86a"); c:px(43, 18, "#c8d77a")
local t = c:save(O .. "aseprite/ph/crab-shell.aseprite", O .. "png/ph/crab-shell.png")
print(GV.report(t))
