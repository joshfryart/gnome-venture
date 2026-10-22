local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local blade = c:ellipse(31.5, 34, 17, 13):add(c:poly({ {32, 8}, {48, 32}, {16, 32} }))
blade:cut(c:poly({ {29, 48}, {35, 48}, {32, 45} }))   -- heart notch
local stem = c:rect(31, 45, 32, 51)
c:build{
  { "stem", stem, "wood", { flat = true } },
  { "blade", blade, GV.ramp("#6fb04d") },
}
local inner = blade:shrink(2)
local veins = c:line({ {31.5, 12}, {31.5, 45} }, 2)
veins:add(c:line({ {31, 26}, {23, 20} }, 2)):add(c:line({ {32, 26}, {40, 20} }, 2))
veins:add(c:line({ {31, 33}, {21, 27} }, 2)):add(c:line({ {32, 33}, {42, 27} }, 2))
veins:add(c:line({ {31, 40}, {23, 35} }, 2)):add(c:line({ {32, 40}, {40, 35} }, 2))
c:fill(veins:clip(inner), "#4a8a3e")
c:ground(32, 53, 9, 1)
local t = c:save(O .. "aseprite/animals/item-mulberry-leaf.aseprite", O .. "png/animals/item-mulberry-leaf.png")
print(GV.report(t))
