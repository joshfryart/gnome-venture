-- stops/orchard : map-stop round fruit tree with three red fruits on a foot bar
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon", halo = 2 }
local trunkR = GV.ramp("#a8582f")

local trunk = c:rect(22, 28, 26, 37)
trunk:add(c:line({ {23, 30}, {19, 27} }, 3))
trunk:add(c:line({ {25, 32}, {29, 28} }, 3))

c:build{
  { "trunk", trunk, trunkR, { gloss = false } },
  { "foot",  c:rrect(17, 36, 31, 39, 1), GV.ramp("#8a4f2a"), { gloss = false } },
  { "crown", c:ellipse(24, 18.5, 11.5, 10.5), "moss" },
}
-- fruits in a triangle
for _, p in ipairs({ {19, 15}, {29, 14}, {25, 22} }) do
  c:paint({
    ".rrr.",
    "rOrrr",
    "rrrrs",
    "rrrss",
    ".sss.",
  }, p[1] - 2, p[2] - 2, { r = GV.R.red.base, O = GV.R.red.dot, s = GV.R.red.shade })
end

local t = c:save(O .. "aseprite/stops/orchard.aseprite", O .. "png/stops/orchard.png")
print(GV.report(t))
