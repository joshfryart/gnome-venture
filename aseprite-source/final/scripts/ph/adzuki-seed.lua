local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#f1ece0")
local tan = GV.ramp("#dcb06a")
-- tin body with slightly rounded bottom corners
local body = c:rrect(13, 19, 51, 55, 3)
-- lid: wider band, top corners cut
local lid = c:poly({ {16, 11}, {49, 11}, {53, 14}, {53, 21}, {11, 21}, {11, 14} })
local label = c:rrect(18, 25, 46, 49, 6)
local p = c:build{
  { "body", body, cream },
  { "lid", lid, cream },
  { "label", label, tan, { gloss = false } },
}
-- inner label window (cream panel inside tan border)
c:part(c:rrect(20, 27, 44, 47, 5), GV.ramp("#f4f0e0"), { gloss = false, contour = false, contact = false })
-- pod: curved band rising to the right
local pod = c:poly({ {23, 42}, {28, 37}, {35, 33}, {43, 30}, {41, 34}, {35, 38}, {28, 41} })
c:part(pod, tan, { gloss = false })
-- beans in the pod
for _, b in ipairs({ {28.5, 38.5}, {33.5, 36}, {38.5, 33.5} }) do
  c:fill(c:ellipse(b[1], b[2], 2, 1.5), "#a5663a")
  c:px(math.floor(b[1]) - 1, math.floor(b[2]) - 1, "#d08a5a")
end
-- green stem tail at the left
c:fill(c:line({ {22, 42}, {20, 41}, {20, 38} }, 2), "#58a03e")
c:px(20, 37, "#8cc864")
-- lid seam and hinge button
c:seam({ {13, 21}, {51, 21} })
c:button(44, 14)
-- three bean dots along the bottom
for _, x in ipairs({ 25, 31, 37 }) do
  c:fill(c:rrect(x, 51, x + 2, 53, 1), "#8c4a1a")
  c:px(x, 51, "#b8703a")
end
local t = c:save(O .. "aseprite/ph/adzuki-seed.aseprite", O .. "png/ph/adzuki-seed.png")
print(GV.report(t))
