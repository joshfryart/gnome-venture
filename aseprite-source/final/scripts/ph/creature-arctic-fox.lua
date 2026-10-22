local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur  = GV.ramp("#f8eed2")
local fur2 = GV.ramp("#e6d2ae")
local pink = GV.ramp("#f6b8cf")
-- plume tail sweeping up the right
local tail = c:poly({ {42,53},{50,53},{55,48},{57,41},{57,33},{55,26},{52,22},{49,24},{50,31},{49,39},{45,45},{41,49} })
local tip = c:ellipse(53, 26, 5, 5):clip(tail)
local ears = c:poly({ {17,26},{17,7},{30,17} }):add(c:poly({ {34,17},{47,7},{47,26} }))
local inner = c:poly({ {19,21},{19,12},{26,17} }):add(c:poly({ {38,17},{45,12},{45,21} }))
local p = c:build{
  { "tail",  tail, fur2 },
  { "tip",   tip, fur, { gloss = false } },
  { "ears",  ears, fur },
  { "inner", inner, pink, { flat = true, contour = false } },
  { "feet",  c:ellipse(22.5, 53, 6.5, 3.5):add(c:ellipse(41.5, 53, 6.5, 4)), fur2 },
  { "body",  c:ellipse(32, 43, 16, 13), fur },
  { "belly", c:ellipse(32, 47, 9, 8), GV.ramp("#fff8ea"), { gloss = false } },
  { "head",  c:ellipse(32, 27, 14, 12), fur },
  { "muzzle",c:ellipse(32, 32, 6.5, 4.5), GV.ramp("#fff8ea"), { gloss = false } },
}
c:eye(21, 23); c:eye(38, 23)
c:paint({ ".nnn.", "nnnnn", ".nnn." }, 30, 29, { n = "#2a1a10" })
c:paint({ "m.....m", ".mm.mm.", "...m..." }, 29, 33, { m = "#4a2c1a" })
c:ground(32, 56, 16, 1)
local t = c:save(O .. "aseprite/ph/creature-arctic-fox.aseprite", O .. "png/ph/creature-arctic-fox.png")
print(GV.report(t))
