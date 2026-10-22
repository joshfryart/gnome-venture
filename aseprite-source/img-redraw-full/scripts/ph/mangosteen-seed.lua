local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc", { rim = "#8fcbd8", shade = "#8fcbd8", deep = "#3f8fb0", bounce = "#5a86b8" })
local cork = GV.ramp("#d9a660", { shade = "#a8582f", deep = "#8a4f2a" })
local neck = c:rect(24, 16, 40, 24)
local body = c:rrect(16, 22, 48, 52, 9)
local stopper = c:rrect(22, 9, 42, 17, 2)
local seed = c:ellipse(32, 33, 7, 7)
local leaf = c:ellipse(35, 24.5, 3, 2)
local label = c:rect(18, 42, 46, 49)
c:build{
  { "neck", neck, glass, { gloss = false } },
  { "body", body, glass, { gloss = false } },
  { "cork", stopper, cork, { gloss = false } },
  { "seed", seed, GV.ramp("#e8a317", { shade = "#f08a24" }) },
  { "leaf", leaf, "#58a03e", { flat = true } },
  { "label", label, "#f4f0e0", { gloss = false } },
}
-- cork grain + 2px gold highlight
c:fill(c:rect(27, 12, 31, 12), "#8a4f2a"); c:fill(c:rect(34, 14, 38, 14), "#8a4f2a")
c:fill(c:rect(24, 10, 25, 10), "#f5cf6a")
-- glass gloss comma on the upper-left wall
c:fill(c:rect(20, 26, 21, 34), "#fff3c8"); c:px(22, 26, "#fff3c8"); c:px(20, 37, "#fff3c8")
-- label: tiny seed tick marks
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x, 45, x + 1, 46), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/mangosteen-seed.aseprite", O .. "png/ph/mangosteen-seed.png")
print(GV.report(t))
