local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:poly({{32,8},{39,14},{46,22},{51,31},{51,40},{46,47},{39,52},{32,54},{25,52},{18,47},{13,40},{13,31},{18,22},{25,14}})
c:build{
  { "stem", c:rrect(30,49,34,56,1), GV.ramp("#a8582f") },
  { "leaf", leaf, "moss", { gloss = {18,31} } },
}
local V = "#2f5a2a"
local veins = c:line({{31,50},{31,16}},2)
veins:add(c:line({{31,24},{25,18}},2)):add(c:line({{32,24},{38,18}},2))
veins:add(c:line({{31,33},{21,25}},2)):add(c:line({{32,33},{42,25}},2))
veins:add(c:line({{31,42},{21,35}},2)):add(c:line({{32,42},{42,35}},2))
c:fill(veins, V)
local t = c:save(O.."aseprite/ph/yerba-mate.aseprite", O.."png/ph/yerba-mate.png")
print(GV.report(t))
