local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "belly", c:ellipse(32, 41, 18, 14), GV.ramp("#3f93b2", { shade = "#256a80" }) },
  { "lid",   c:ellipse(32, 25, 14, 9):cut(c:rect(0, 26, 63, 63)), GV.ramp("#5a86b8") },
  { "rim",   c:rrect(17, 24, 47, 29, 2), GV.ramp("#8fcbd8"), { gloss = false } },
  { "knob",  c:ellipse(32, 13, 4, 3.5), "gold" },
  { "emb",   c:ellipse(32, 43, 6, 6), GV.ramp("#f4f0e0"), { gloss = false, contact = false } },
  { "dot",   c:ellipse(32, 43, 2.5, 2.5), GV.ramp("#3f93b2"), { flat = true, contour = false } },
  { "stem",  c:rect(31, 33, 32, 37), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf",  c:ellipse(36, 33, 3, 2), GV.ramp("#58a03e"), { flat = true } },
}
c:seam({ {21, 27}, {29, 27} })
local t = c:save(O .. "aseprite/ph/rose-of-sharon-seed.aseprite", O .. "png/ph/rose-of-sharon-seed.png")
print(GV.report(t))
