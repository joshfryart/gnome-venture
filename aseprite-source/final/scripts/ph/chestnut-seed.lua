local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(19, 10, 45, 56, 3)
local flap = c:poly({ {19, 10}, {46, 10}, {32.5, 29} })
local nut = c:ellipse(32, 44, 7, 8)
local cap = c:ellipse(32, 44, 7, 8):clip(c:rect(24, 36, 40, 40))
local p = c:build{
  { "envelope", body, GV.ramp("#f1ece0", { pale = true }) },
  { "flap", flap, GV.ramp("#c9a96e"), { light = body } },
  { "nut", nut, GV.ramp("#8c4a1a") },
  { "cap", cap, GV.ramp("#44281c"), { flat = true } },
  { "wax", c:ellipse(32.5, 29, 3.5, 3), GV.ramp("#b8452f"), { gloss = false } },
}
c:seam({ {20, 11}, {32, 27} }); c:seam({ {45, 11}, {33, 27} })
c:fill(c:rect(31, 34, 33, 35), "#2e5a2c")
c:fill(c:rect(25, 53, 39, 54), "#dcb06a")
local t = c:save(O .. "aseprite/ph/chestnut-seed.aseprite", O .. "png/ph/chestnut-seed.png")
print(GV.report(t))
