local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lid = c:poly({ {9, 8}, {48, 5}, {54, 20}, {10, 24} })
local bean = c:ellipse(30.5, 26, 14, 10):cut(c:ellipse(31, 15, 5, 3))
local body = c:rrect(10, 30, 54, 54, 3)
local p = c:build{
  { "lid",  lid,  GV.ramp("#c9c5bc") },
  { "bean", bean, GV.ramp("#8c4a1a") },
  { "body", body, GV.ramp("#8b8f96"), { light = body:copy():add(lid) } },
  { "rim",  c:line({ {10, 22}, {53, 19} }, 2), GV.ramp("#8b8f96"), { flat = true } },
  { "hinge", c:rect(48, 20, 53, 30), GV.ramp("#5b6470"), { flat = true } },
  { "label", c:rrect(22, 38, 42, 49, 2), GV.ramp("#f1ece0") },
}
-- bean groove and hilum
c:paint({ "gg.....", "..ggg..", ".....gg" }, 33, 21, { g = "#44281c" })
c:px(22, 25, "#f1ece0"); c:px(23, 25, "#f1ece0")
-- label seed dots
c:fill(c:rect(28, 43, 29, 44), "#8c4a1a"); c:fill(c:rect(35, 43, 36, 44), "#8c4a1a")
c:seam({ {13, 32}, {51, 32} })
c:button(16, 14)
c:ground(32, 55, 21, 1.5)
local t = c:save(O .. "aseprite/ph/kidney-bean-seed.aseprite", O .. "png/ph/kidney-bean-seed.png")
print(GV.report(t))
