local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local kraft = "#dcb06a"
local p = c:build{
  { "cone",   c:poly({ {14,23},{51,23},{34,58},{30,58} }), "#f1ece0" },
  { "gather", c:poly({ {20,23},{45,23},{35,13},{30,13} }), "#f1ece0", { gloss = false } },
  { "seed",   c:ellipse(42, 17, 5.5, 5.5), GV.ramp("#3f93b2", { shade = "#256a80" }) },
  { "leaf",   c:poly({ {14,13},{29,9},{29,18} }), "#2f5a2a", { gloss = false } },
  { "lip",    c:rrect(13, 20, 51, 25, 2), kraft },
  { "bowL",   c:poly({ {24,4},{32,8},{32,10},{24,14} }), kraft, { flat = true } },
  { "bowR",   c:poly({ {41,4},{33,8},{33,10},{41,14} }), kraft, { flat = true } },
}
c:fill(c:line({ {23,28}, {30,52} }, 2):clip(p.cone.m:shrink(2)), "#e2c38c")
c:seam({ {15,22}, {49,22} })
c:button(30, 7)
local t = c:save(O .. "aseprite/ph/noni-seed.aseprite", O .. "png/ph/noni-seed.png")
print(GV.report(t))
