local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pink = GV.ramp("#f6b8cf", { shade = "#e46a9b" })
local hive = c:rrect(14, 38, 50, 50, 6):add(c:rrect(18, 28, 46, 40, 6)):add(c:ellipse(32, 23, 10, 8))
local p = c:build{
  { "feet",   c:rect(17, 53, 22, 57):add(c:rect(42, 53, 47, 57)), GV.ramp("#b6814d"), { flat = true } },
  { "stand",  c:rrect(12, 49, 52, 54, 2), GV.ramp("#c4925f") },
  { "bottom", c:rrect(14, 37, 50, 50, 6), pink, { light = hive } },
  { "middle", c:rrect(18, 27, 46, 39, 6), pink, { light = hive } },
  { "dome",   c:ellipse(32, 21, 10, 8):cut(c:rect(0, 28, 63, 63)), pink, { light = hive } },
  { "knob",   c:rrect(30, 10, 33, 13, 1), GV.ramp("#b07a10"), { flat = true } },
  { "door",   c:ellipse(32, 44, 5, 4):add(c:rect(27, 44, 37, 49)), GV.ramp("#44281c"), { gloss = false, rim = false } },
  { "fl1",    c:ellipse(14.5, 31.5, 3, 3), GV.ramp("#3f93b2"), { gloss = false } },
  { "fl2",    c:ellipse(50.5, 32.5, 3, 3), GV.ramp("#3f93b2"), { gloss = false } },
}
-- gold bands
local bands = c:rect(0, 32, 63, 33):add(c:rect(0, 43, 63, 43)):add(c:rect(0, 24, 63, 24))
local bm = bands:clip(p.bottom.m:copy():add(p.middle.m):add(p.dome.m)):cut(p.door.m)
c:fill(bm, "#e8a317")
c:seam({ {16, 46}, {26, 46} }); c:seam({ {38, 46}, {48, 46} })
c:seam({ {20, 36}, {44, 36} })
-- flower centres
c:fill(c:rect(14, 31, 15, 32), "#2a1a10"); c:fill(c:rect(50, 32, 51, 33), "#2a1a10")
c:px(13, 30, "#8fcbd8"); c:px(49, 31, "#8fcbd8")
local t = c:save(O .. "aseprite/ph/beehive-painted.aseprite", O .. "png/ph/beehive-painted.png")
print(GV.report(t))
