local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- squat jar: wide body + short neck
local jar = c:rrect(12, 24, 51, 56, 7)
jar:add(c:rrect(17, 18, 46, 28, 3))
local cork = c:rrect(20, 9, 43, 20, 2)
cork:add(c:rrect(18, 8, 45, 12, 2))
local bean = c:ellipse(31.5, 39, 11, 7.5):cut(c:ellipse(31.5, 31, 4, 3))
local leaf = c:ellipse(39, 26, 3, 2)
local p = c:build{
  { "jar",  jar,  GV.ramp("#f4f0e0", { rim = "#c8ecdc" }) },
  { "cork", cork, "wood" },
  { "bean", bean, GV.ramp("#44281c") },
}
c:part(c:line({ {33, 33}, {34, 29}, {36, 26} }, 2), GV.ramp("#4a8a3e"), { flat = true })
c:part(leaf, GV.ramp("#7ab55c"), { flat = true })
-- bean back line + dots
c:paint({ "..bbbbbbb..", ".b.......b.", "b.........b" }, 26, 35, { b = "#7a4a1f" })
c:px(29, 34, "#7a4a1f"); c:px(31, 34, "#7a4a1f"); c:px(34, 34, "#7a4a1f")
-- glass glint streak
for y = 30, 46 do c:px(16, y, "#c8ecdc") end
for y = 31, 37 do c:px(17, y, "#fff3c8") end
-- cork band
for x = 21, 42 do c:px(x, 17, "#8a4f2a") end
-- label dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 51, x + 2, 53), "#8c4a1a") end
c:seam({ {20, 19}, {43, 19} })
local t = c:save(O .. "aseprite/ph/black-bean-seed.aseprite", O .. "png/ph/black-bean-seed.png")
print(GV.report(t))
