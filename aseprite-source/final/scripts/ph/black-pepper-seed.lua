local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tall narrow envelope body
local body = c:rrect(17, 16, 46, 57, 2)
-- flap: pointed slanted top
local flap = c:poly({ {17, 17}, {17, 12}, {22, 8}, {42, 8}, {47, 12}, {47, 17} })
local label = c:rrect(20, 22, 43, 50, 5)
local paper = GV.ramp("#f1ece0")
local p = c:build{
  { "body", body, paper },
  { "flap", flap, GV.ramp("#e6dcc4"), { gloss = { 21, 10 } } },
  { "label", label, GV.ramp("#f4f0e0"), { contour = "#4a2c1a", gloss = false } },
}
-- flap fold seam
c:seam({ {18, 18}, {46, 18} })
-- dark curved pepper leaf
local leaf = c:poly({ {23, 44}, {26, 38}, {31, 33}, {37, 29}, {41, 27}, {40, 31}, {36, 37}, {30, 42}, {25, 45} })
c:part(leaf, GV.ramp("#2f2a3a"), { gloss = false, contact = false })
-- leaf vein
c:line({ {25, 43}, {31, 37}, {38, 30} }, 1)
c:fill(c:line({ {25, 43}, {31, 37}, {38, 30} }, 1), "#4a4458")
-- stem
c:fill(c:line({ {23, 44}, {21, 47} }, 2), "#2e5a2c")
-- three grey peppercorns in a row
for _, q in ipairs({ { 30, 46 }, { 35, 43 }, { 40, 40 } }) do
  c:fill(c:ellipse(q[1], q[2], 1.6, 1.6), "#6a6070")
  c:px(q[1] - 1, q[2] - 1, "#9a92a0")
end
-- tan dots along the bottom
for _, x in ipairs({ 25, 31, 37 }) do
  c:fill(c:rect(x, 53, x + 2, 55), "#8c4a1a")
end
local t = c:save(O .. "aseprite/ph/black-pepper-seed.aseprite", O .. "png/ph/black-pepper-seed.png")
print(GV.report(t))
