local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local disc = c:ellipse(31.5, 31.5, 26, 26)
local face = c:ellipse(31.5, 31.5, 21.5, 21.5)
local ring = disc:copy():cut(face)
-- awning trapezoid with scalloped bottom (four bumps)
local awn = c:poly({ {18, 28}, {23, 17}, {41, 17}, {46, 28} })
for i = 0, 3 do awn:add(c:ellipse(21 + i * 7, 28, 3.5, 3)) end
awn:clip(c:rect(0, 0, 63, 31))
c:build{
  { "ring", ring, "wood", { cres = 3, deep = 2 } },
  { "face", face, GV.ramp("#f1ece0"), { contour = false, contact = false, gloss = false } },
  { "postL", c:rect(20, 28, 22, 44), "wood", { flat = true } },
  { "postR", c:rect(41, 28, 43, 44), "wood", { flat = true } },
  { "counter", c:rrect(17, 37, 46, 42, 1), "wood", { cres = 2, deep = 1 } },
  { "crate", c:rect(36, 31, 44, 36), GV.ramp("#c9a96e"), { cres = 1, deep = 1, gloss = false } },
  { "fruitA", c:ellipse(26, 33.5, 3.5, 3.5), GV.ramp("#e0501f"), { cres = 2, deep = 1 } },
  { "fruitB", c:ellipse(31.5, 34, 2.5, 2.5), GV.ramp("#f08a24"), { flat = true } },
  { "awning", awn, GV.ramp("#d6322b"), { cres = 3, deep = 2 } },
}
-- awning stripes (cream bands)
for _, x in ipairs({ 27, 36 }) do
  c:line({ {x, 18}, {x + (x < 32 and -2 or 2), 27} }, 2):clip(awn:shrink(1)):each(function(px, py) c:px(px, py, "#f6c8a8") end)
end
-- crate slats
c:fill(c:rect(37, 33, 43, 33), "#a8582f")
-- hem stitch along scallops
c:seam({ {19, 27}, {45, 27} })
-- dashed outer ring
c:seam({ {31, 6}, {44, 9}, {54, 18}, {57, 31}, {54, 45}, {44, 54}, {31, 57}, {19, 54}, {9, 45}, {6, 31}, {9, 18}, {19, 9}, {31, 6} }, { gap = "#a8582f" })
local t = c:save(O .. "aseprite/stops/stamp-market.aseprite", O .. "png/stops/stamp-market.png")
print(GV.report(t))
