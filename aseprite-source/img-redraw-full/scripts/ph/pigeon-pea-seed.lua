local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local earL = c:rrect(9, 35, 15, 43, 2)
local earR = c:rrect(48, 35, 54, 43, 2)
local pot = c:rrect(13, 28, 50, 56, 9)
local lid = c:rrect(17, 19, 46, 30, 4)
local knob = c:rrect(28, 12, 35, 20, 3)
local pod = c:poly({ {20,48}, {27,40}, {36,35}, {45,33}, {44,41}, {37,46}, {28,49} })
c:build{
  { "earL", earL, "#dcb06a" },
  { "earR", earR, "#dcb06a" },
  { "pot", pot, "#f1ece0" },
  { "lid", lid, "moss" },
  { "knob", knob, "#2e5a2c" },
  { "pod", pod, "moss", { gloss = false, contour = "#4a2c1a" } },
}
for _, p in ipairs({ {27,44}, {33,41}, {39,38} }) do
  c:part(c:ellipse(p[1], p[2], 2.5), "#58a03e", { flat = true })
end
c:seam({ {19,29}, {45,29} })
c:button(30, 26)
local t = c:save(O .. "aseprite/ph/pigeon-pea-seed.aseprite", O .. "png/ph/pigeon-pea-seed.png")
print(GV.report(t))
