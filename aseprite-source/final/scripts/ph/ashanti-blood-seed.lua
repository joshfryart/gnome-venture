local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0")
local body = c:rrect(18, 8, 45, 56, 2)
local flap = c:poly({ {18, 8}, {46, 8}, {32, 27} }):clip(body)
local label = c:rrect(21, 30, 42, 51, 3)
local p = c:build{
  { "body", body, paper },
  { "flap", flap, paper, { light = body } },
  { "label", label, GV.ramp("#7b66b4"), { flat = true } },
  { "panel", label:shrink(2), GV.ramp("#f4f0e0"), { flat = true, contour = false } },
  { "stem", c:rect(31, 31, 33, 37), "moss", { flat = true } },
  { "leaf", c:ellipse(37, 33, 3, 2), "leaf", { flat = true } },
  { "berry", c:ellipse(32, 42.5, 7), GV.ramp("#7a5cc0", { shade = "#3e2f66" }) },
}
c:seam({ {19, 10}, {32, 25}, {45, 10} })
c:fill(c:rect(26, 53, 27, 54), "#8c4a1a"); c:fill(c:rect(31, 53, 32, 54), "#8c4a1a"); c:fill(c:rect(36, 53, 37, 54), "#8c4a1a")
local t = c:save(O .. "aseprite/ph/ashanti-blood-seed.aseprite", O .. "png/ph/ashanti-blood-seed.png")
print(GV.report(t))
