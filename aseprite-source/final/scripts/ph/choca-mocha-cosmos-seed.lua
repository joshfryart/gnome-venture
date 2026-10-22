local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lid = c:ellipse(32, 22, 11, 7):cut(c:rect(0, 23, 63, 63))
c:build{
  { "foot",  c:rrect(23, 47, 41, 52, 2), GV.ramp("#2f6290") },
  { "belly", c:ellipse(32, 38, 16, 13), GV.ramp("#5a86b8") },
  { "rim",   c:rrect(17, 22, 47, 27, 2), GV.ramp("#8fcbd8") },
  { "lid",   lid, GV.ramp("#3f8fb0") },
  { "knob",  c:ellipse(32, 12.5, 3.5, 3), "gold" },
  { "label", c:ellipse(32, 39, 9.5, 8), GV.ramp("#f4f0e0"), { gloss = false } },
  { "bloom", c:ellipse(31, 40, 4.5, 4.5), GV.ramp("#f08a24"), { flat = true } },
  { "leaf",  c:ellipse(36.5, 35.5, 3, 1.5), GV.ramp("#58a03e"), { flat = true } },
}
c:seam({ {20, 24}, {44, 24} })
local t = c:save(O .. "aseprite/ph/choca-mocha-cosmos-seed.aseprite", O .. "png/ph/choca-mocha-cosmos-seed.png")
print(GV.report(t))
