local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tuft = c:poly({
  {12,18},{17,12},{22,17},{27,10},{32,16},{37,10},{42,16},{47,11},{52,18},
  {57,26},{51,34},{57,46},{50,50},
  {44,49},{42,57},{38,50},{33,58},{28,50},{23,57},{20,49},
  {14,50},{8,46},{14,34},{8,26}
})
local p = c:build{
  { "tuft", tuft, GV.ramp("#f5cf6a"), { gloss = { 17, 20 } } },
}
-- strand curls
for _, s in ipairs({ { {21,24},{19,28},{21,33} }, { {35,27},{33,31},{35,36} }, { {26,41},{30,39},{35,41} }, { {44,22},{42,26},{44,30} } }) do
  c:fill(c:line(s, 2), "#dcb06a")
end
c:fill(c:line({ {28,20},{30,23} }, 2), "#d0862a")
c:fill(c:line({ {40,40},{42,44} }, 2), "#d0862a")
-- lit tips
c:fill(c:line({ {17,15},{18,17} }, 2), "#fff3c8")
c:fill(c:line({ {27,13},{28,15} }, 2), "#fff3c8")
local t = c:save(O .. "aseprite/ph/goat-hair.aseprite", O .. "png/ph/goat-hair.png")
print(GV.report(t))
