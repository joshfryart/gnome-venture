local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local p = c:build{
  { "wall", c:ellipse(31.5, 37, 21, 10), "#a5663a" },
  { "crust", c:ellipse(31.5, 33, 21, 10), "#dcb06a" },
  { "filling", c:ellipse(31.5, 33, 15, 6), "#d6322b" },
  { "strip1", c:line({ {20, 29}, {42, 37} }, 3), "#dcb06a", { gloss = false } },
  { "strip2", c:line({ {42, 29}, {20, 37} }, 3), "#dcb06a", { gloss = false } },
}
for _, q in ipairs({ {12, 32}, {50, 32}, {31, 24}, {31, 41} }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#a5663a")
end
local t = c:save(O .. "aseprite/ico/ico-pie.aseprite", O .. "png/ico/ico-pie.png")
print(GV.report(t))
