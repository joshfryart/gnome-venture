local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local berryA = GV.ramp("#3f8fb0")
local berryB = GV.ramp("#2f6290")
local lid = c:poly({ {15, 12}, {49, 12}, {54, 33}, {10, 33} })
local leaf = c:poly({ {42, 9}, {50, 6}, {54, 9}, {47, 14} })
local p = c:build{
  { "lid", lid, GV.ramp("#c9c5bc") },
  { "inner", c:poly({ {14, 26}, {50, 26}, {52, 33}, {12, 33} }), "#5b6470", { flat = true } },
  { "b6", c:ellipse(33, 22, 5, 5), berryB },
  { "b4", c:ellipse(27, 29, 5, 5), berryA },
  { "b5", c:ellipse(39, 29, 5, 5), berryA },
  { "b1", c:ellipse(21, 35, 5, 5), berryB },
  { "b2", c:ellipse(33, 35, 5, 5), berryB },
  { "b3", c:ellipse(45, 35, 5, 5), berryB },
  { "box", c:rrect(10, 36, 54, 55, 3), GV.ramp("#8b8f96", { shade = "#5b6470" }) },
  { "stem", c:line({ {39, 17}, {42, 13} }, 2), "#2f5a2a", { flat = true, solid = true } },
  { "leaf", leaf, "leaf" },
  { "label", c:rect(22, 44, 42, 51), GV.ramp("#f1ece0") },
}
c:fill(c:rect(11, 34, 14, 36), "#5b6470"); c:fill(c:rect(50, 34, 53, 36), "#5b6470")
for _, x in ipairs({ 26, 31, 36 }) do c:fill(c:rect(x, 47, x + 1, 48), "#a8582f") end
for _, b in ipairs({ {33, 22}, {22, 36}, {44, 36} }) do
  c:paint({ "x.x", ".x." }, b[1] - 1, b[2] - 4, { x = "#2a3c6c" })
end
local t = c:save(O .. "aseprite/ph/blueberry-seed.aseprite", O .. "png/ph/blueberry-seed.png")
print(GV.report(t))
