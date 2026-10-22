local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- wide oval plate, well, domed food mound, two round dishes, gold knob, star
local rim  = c:ellipse(31.5, 46, 25, 9)
local well = c:ellipse(31.5, 44, 19, 6)
local dome = c:ellipse(31.5, 41, 16, 15):cut(c:rect(0, 43, 63, 63))
dome:add(c:ellipse(31.5, 42, 16, 2.5))
local red   = c:ellipse(21, 38, 4.5, 4.5)
local green = c:ellipse(42, 36, 5, 5)
local knob  = c:ellipse(31.5, 28, 3.5, 3)
local star = c:poly({
  {31.5, 7}, {33.5, 11.5}, {38, 12}, {34.5, 15}, {35.5, 19.5},
  {31.5, 17.5}, {27.5, 19.5}, {28.5, 15}, {25, 12}, {29.5, 11.5},
})

c:build{
  { "rim",   rim,   GV.ramp("#d6c9b6") },
  { "well",  well,  GV.ramp("#f4f0e0"), { gloss = false } },
  { "dome",  dome,  GV.ramp("#f08a24") },
  { "red",   red,   GV.ramp("#e0501f") },
  { "green", green, "moss" },
  { "knob",  knob,  "gold" },
  { "star",  star,  "gold" },
}
local t = c:save(O .. "aseprite/ico/ico-plate-cutlery.aseprite", O .. "png/ico/ico-plate-cutlery.png")
print(GV.report(t))
