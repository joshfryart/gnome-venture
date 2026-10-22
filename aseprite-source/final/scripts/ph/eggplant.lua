local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- plump diagonal body: fat bottom-left end, narrower toward cap
local body = c:line({ {18, 44}, {44, 22} }, 14)
body:add(c:ellipse(18, 44, 10, 10)); body:add(c:ellipse(29, 35, 9, 9))
body:add(c:ellipse(43, 23, 7, 7))
local cap = c:poly({ {39, 16}, {47, 12}, {53, 18}, {50, 27}, {46, 24}, {44, 29}, {40, 23}, {35, 24} })
cap:add(c:ellipse(46.5, 18.5, 5, 5))
local stem = c:line({ {48, 15}, {53, 9} }, 3)
c:build{
  { "body", body, GV.ramp("#7a5cc0", { shade = "#4e3a8a" }), { gloss = { 16, 37 } } },
  { "stem", stem, "moss", { flat = true } },
  { "cap", cap, GV.ramp("#2f5a2a"), { gloss = false } },
}
-- cap spikes / veins
c:fill(c:line({ {44, 21}, {44, 25} }, 2), "#4a8a3e")
c:fill(c:line({ {48, 20}, {49, 24} }, 2), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/eggplant.aseprite", O .. "png/ph/eggplant.png")
print(GV.report(t))
