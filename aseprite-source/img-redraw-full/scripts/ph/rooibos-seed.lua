local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {13, 25}, {52, 25}, {33, 58} }):add(c:rrect(13, 23, 51, 30, 4))
local fans = c:poly({ {27, 13}, {18, 7}, {17, 18}, {27, 18} }):add(c:poly({ {38, 13}, {47, 7}, {48, 18}, {38, 18} }))
local p = c:build{
  { "fans", fans, GV.ramp("#f1ece0"), { gloss = false } },
  { "neck", c:rrect(26, 12, 38, 25, 2), GV.ramp("#e8dcc0"), { gloss = false } },
  { "cone", cone, GV.ramp("#f1ece0") },
  { "band", c:rect(13, 26, 52, 30):clip(cone), GV.ramp("#3f93b2"), { gloss = false } },
  { "leaf", c:ellipse(32, 42, 5, 9):cut(c:rect(0, 51, 63, 63)), GV.ramp("#58a03e") },
}
-- fold lines on the fans and neck
c:paint({ "f....", ".f...", "..f..", "...f." }, 20, 10, { f = "#dcb06a" })
c:paint({ "....f", "...f.", "..f..", ".f..." }, 40, 10, { f = "#dcb06a" })
c:paint({ "f", "f", "f", "f", "f", "f", "f", "f" }, 32, 14, { f = "#dcb06a" })
-- leaf veins
for y = 36, 49 do c:px(32, y, "#2e5a2c") end
c:px(31, 40, "#2e5a2c"); c:px(30, 39, "#2e5a2c")
c:px(33, 44, "#2e5a2c"); c:px(34, 43, "#2e5a2c")
c:seam({ {43, 32}, {34, 53} })
local t = c:save(O .. "aseprite/ph/rooibos-seed.aseprite", O .. "png/ph/rooibos-seed.png")
print(GV.report(t))
