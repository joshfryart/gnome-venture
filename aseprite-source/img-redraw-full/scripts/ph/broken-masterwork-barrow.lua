local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- handles behind the tub
local upper = c:line({ {39, 26}, {50, 18} }, 5)
local grip = c:rrect(48, 14, 53, 19, 2)
local lower = c:line({ {33, 38}, {43, 45} }, 5)
-- jagged snapped end
lower:add(c:poly({ {41, 42}, {47, 44}, {44, 46}, {46, 48}, {42, 49}, {40, 47} }))

-- tub: wide-top trapezoid with a rolled rim, chipped top-left corner
local notch = c:poly({ {11, 19}, {17, 19}, {11, 25} })
local tub = c:poly({ {13, 22}, {43, 22}, {36, 43}, {21, 43} })
tub:add(c:rrect(11, 20, 44, 25, 2))
tub:cut(notch)

local leg = c:line({ {35, 42}, {38, 49} }, 2)
local wheel = c:ellipse(23, 48, 7, 7)
local hub = c:ellipse(23, 48, 2.5, 2.5)
-- loose chip fallen on the ground
local chip = c:poly({ {33, 55}, {38, 51}, {39, 55} })

local p = c:build{
  { "upper", upper, "wood" },
  { "grip",  grip,  "wood" },
  { "lower", lower, "wood" },
  { "leg",   leg,   "#8a4f2a", { flat = true } },
  { "tub",   tub,   "gold" },
  { "wheel", wheel, "#3e2f2a" },
  { "hub",   hub,   "#b07a10", { flat = true } },
  { "chip",  chip,  "gold", { flat = true } },
}

-- line under the rolled lip
for x = 15, 42 do if (x % 3) ~= 0 then c:px(x, 26, GV.R.gold.shade) end end
-- rivets where the handles meet the tub
c:paint({ "rr", "rr" }, 38, 28, { r = "#7a3a14" })
c:paint({ "rr", "rr" }, 33, 38, { r = "#7a3a14" })
-- crack zig-zag from rim down
c:fill(c:line({ {29, 22}, {27, 28}, {31, 32}, {28, 37}, {31, 42} }, 2), "#2a1a10")
-- splinters on the snapped handle
c:px(45, 48, "#ecc58a"); c:px(46, 45, "#ecc58a")
-- tyre tread notches
for _, d in ipairs({ { 23, 41 }, { 16, 48 }, { 30, 48 }, { 23, 55 } }) do c:px(d[1], d[2], "#5a4a44") end

c:ground(28, 56, 13, 1.5)
local t = c:save(O .. "aseprite/ph/broken-masterwork-barrow.aseprite", O .. "png/ph/broken-masterwork-barrow.png")
print(GV.report(t))
