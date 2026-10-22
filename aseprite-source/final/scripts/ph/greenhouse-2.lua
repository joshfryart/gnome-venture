local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:poly({ {7, 52}, {7, 38}, {15, 20}, {50, 20}, {58, 38}, {58, 52} })
local plants = c:rect(10, 41, 54, 45)
for i, x in ipairs({ 12, 18, 24, 30, 36, 42, 48, 53 }) do
  plants:add(c:ellipse(x, (i % 2 == 0) and 39 or 40, 3.5, 3))
end
plants:clip(glass)
local base = c:rrect(7, 45, 57, 53, 2)
c:build{
  { "glass", glass, GV.ramp("#a9d6ea", { gloss = "#c8ecdc", rim = "#8fcbd8" }) },
  { "plants", plants, GV.ramp("#58a03e") },
  { "tom1", c:ellipse(20.5, 41.5, 2, 2), GV.ramp("#d6322b"), { flat = true } },
  { "tom2", c:ellipse(39.5, 40.5, 2, 2), GV.ramp("#d6322b"), { flat = true } },
  { "tom3", c:ellipse(48.5, 42.5, 2, 2), GV.ramp("#d6322b"), { flat = true } },
  { "base", base, GV.ramp("#968f96") },
  { "pole", c:rect(31, 7, 32, 19), GV.ramp("#44281c"), { flat = true } },
  { "flag", c:poly({ {33, 7}, {43, 10}, {33, 14} }), GV.ramp("#d6322b"), { flat = true } },
}
local W = "#f4f0e0"
local upper = c:rect(0, 20, 63, 38)
c:fill(glass:copy():cut(glass:shrink(2)):clip(upper), W)
c:fill(c:rect(8, 35, 57, 35), W)
for _, x in ipairs({ 22, 32, 42 }) do c:fill(c:rect(x, 21, x, 38), W) end
c:fill(c:line({ {17, 21}, {13, 35} }, 1), W)
c:fill(c:line({ {47, 21}, {51, 35} }, 1), W)
-- glints on glass panes
c:fill(c:line({ {25, 26}, {28, 23} }, 1), "#c8ecdc")
c:px(26, 27, "#c8ecdc"); c:px(9, 38, "#8fcbd8")
c:seam({ {8, 47}, {57, 47} })
c:ground(32, 54, 27, 3, "#6a4528")
local t = c:save(O .. "aseprite/ph/greenhouse-2.aseprite", O .. "png/ph/greenhouse-2.png")
print(GV.report(t))
