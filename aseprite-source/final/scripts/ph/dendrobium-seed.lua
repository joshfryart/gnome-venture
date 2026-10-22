local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a9d6ea")
local body = c:rrect(14, 22, 49, 56, 10)
local neck = c:rect(21, 15, 42, 23)
local p = c:build{
  { "neck", neck, glass, { gloss = false } },
  { "body", body, glass, { gloss = { 19, 27 } } },
  { "seed", c:ellipse(32, 43, 8, 7), "gold" },
  { "stem", c:rect(31, 31, 33, 36), "moss", { flat = true } },
  { "leaf", c:ellipse(37.5, 31, 3.5, 2), "moss", { flat = true } },
  { "leaf2", c:ellipse(27, 33, 2.5, 1.5), "moss", { flat = true } },
  { "cork", c:rrect(19, 6, 44, 17, 3), "wood" },
}
-- glass streak
c:fill(c:rect(18, 32, 19, 46), "#c8ecdc")
c:fill(c:rect(18, 49, 19, 50), "#c8ecdc")
-- cork pores
c:px(26, 11, "#8a4f2a"); c:px(37, 13, "#8a4f2a"); c:px(31, 14, "#8a4f2a")
-- string loop at neck
c:seam({ {21, 20}, {42, 20} })
-- label dots
c:px(26, 53, "#8c4a1a"); c:px(32, 53, "#8c4a1a"); c:px(38, 53, "#8c4a1a")
local t = c:save(R .. "aseprite/ph/dendrobium-seed.aseprite", R .. "png/ph/dendrobium-seed.png")
print(GV.report(t))
