local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- glass: body + shoulder/neck as one blown shape
local glass = c:rrect(14, 24, 50, 56, 8)
glass:add(c:rrect(22, 15, 42, 28, 3))
glass:add(c:ellipse(32, 25, 14, 4))
local cork = c:rrect(24, 7, 40, 16, 2)
local fruit = c:ellipse(32, 43, 10, 9.5)

local p = c:build{
  { "glass", glass, GV.ramp("#c8ecdc"), { gloss = { 18, 30 } } },
  { "fruit", fruit, GV.ramp("#f08a24", { shade = "#e0501f" }) },
  { "cork",  cork,  GV.ramp("#c9a96e") },
}
-- sprout from the top of the fruit
c:fill(c:line({ {32, 33}, {32, 28} }, 2), "#4a8a3e")
local leaf = c:poly({ {33, 29}, {36, 26}, {40, 26}, {39, 29}, {36, 31} })
c:fill(leaf, "#58a03e")
c:px(36, 27, "#a4d86a"); c:px(37, 27, "#a4d86a")

-- glass rim band at the shoulder
c:fill(c:line({ {19, 26}, {45, 26} }, 2):clip(p.glass.m:shrink(2)), "#8fcbd8")
-- glass side highlight streak
c:fill(c:line({ {18, 34}, {18, 46} }, 1), "#fff3c8")
-- seeds resting at the bottom
for _, x in ipairs({ 25, 31, 37 }) do
  c:fill(c:rect(x, 53, x + 2, 54), "#8c4a1a")
end
-- cork grain and a cork seam
c:px(28, 10, "#7a4a1f"); c:px(35, 12, "#7a4a1f"); c:px(30, 13, "#7a4a1f")
c:seam({ {25, 15}, {39, 15} })

local t = c:save(O .. "aseprite/ph/jade-vine-seed.aseprite", O .. "png/ph/jade-vine-seed.png")
print(GV.report(t))
