local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {16,12},{48,12},{52,18},{52,57},{13,57},{13,18} })
local flap = c:poly({ {16,12},{48,12},{52,18},{52,19},{13,19},{13,18} })
local p = c:build{
  { "body", body, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#dcb06a"), { gloss = { 18, 14 } } },
  { "frame", c:rrect(18, 23, 46, 50, 5), GV.ramp("#3f93b2"), { flat = true } },
  { "panel", c:rrect(20, 25, 44, 48, 4), GV.ramp("#f4f0e0"), { gloss = false, contour = false } },
  { "seed", c:ellipse(32, 38, 7, 7), "water" },
}
c:seam({ {13, 19}, {51, 19} })
c:paint({ ".llll", "ssll.", ".sl..", ".s..." }, 31, 27, { l = "#4a8a3e", s = "#2f5a2a" })
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x, 53, x + 1, 54), "#8a4f2a") end
local t = c:save(O .. "aseprite/ph/bird-of-paradise-seed.aseprite", O .. "png/ph/bird-of-paradise-seed.png")
print(GV.report(t))
