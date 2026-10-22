local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- curved tapered canine: left edge bows out, tip leans up-right
local tooth = c:poly({
  {16,50},{15,42},{16,34},{19,26},{24,18},{30,12},{38,7},
  {36,13},{33,19},{32,26},{33,34},{35,42},{37,50},
})
local cap = c:rrect(13, 46, 39, 57, 3)
local p = c:build{
  { "tooth", tooth, "cream", { light = tooth } },
  { "cap",   cap,   GV.ramp("#a8582f"), { stitch = false } },
}
-- enamel shine down the left edge
c:fill(c:line({ {19,40},{19,33},{21,27},{25,21} }, 1):clip(tooth), "#fff3c8")
-- tip
c:fill(c:poly({ {33,10},{38,7},{36,13} }):clip(tooth), "#d9a660")
-- root groove
c:fill(c:line({ {26,50},{26,55} }, 1), "#8a4f2a")
c:seam({ {15,48},{37,48} })
c:button(14, 50 - 0) 
local t = c:save(O .. "aseprite/ph/fox-fang.aseprite", O .. "png/ph/fox-fang.png")
print(GV.report(t))
