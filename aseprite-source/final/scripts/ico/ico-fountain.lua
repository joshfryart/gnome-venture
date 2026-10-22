local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local basin = c:ellipse(31.5, 45, 25, 10)
local water = c:ellipse(31.5, 42, 21, 6.5)
local jet = c:rect(30, 20, 33, 42)
local spray = c:line({ {22, 30}, {23, 25}, {26, 20}, {29, 17}, {31, 16}, {32, 16}, {34, 17}, {37, 20}, {40, 25}, {41, 30} }, 3)
spray:add(c:ellipse(31.5, 16, 4, 3))

local p = c:build{
  { "basin", basin, GV.ramp("#968f96") },
  { "water", water, "water", { contact = false } },
  { "spray", spray, GV.ramp("#a9d6ea"), { flat = true } },
  { "jet", jet, GV.ramp("#a9d6ea"), { flat = true, contact = false } },
}
-- splash drops at the spray tips
c:fill(c:rect(21, 32, 23, 34), "#a9d6ea")
c:fill(c:rect(40, 32, 42, 34), "#a9d6ea")
-- ripples
c:fill(c:line({ {16, 43}, {19, 44}, {24, 44}, {26, 43} }, 1), "#c8ecdc")
c:fill(c:line({ {37, 43}, {39, 44}, {44, 44}, {47, 43} }, 1), "#c8ecdc")
c:fill(c:line({ {27, 45}, {29, 46}, {34, 46}, {36, 45} }, 1), "#c8ecdc")
-- highlight on jet
c:fill(c:rect(31, 22, 31, 38), "#e4f4fa")
c:px(30, 17, "#e4f4fa"); c:px(31, 16, "#e4f4fa"); c:px(28, 18, "#e4f4fa")

local t = c:save(B .. "aseprite/ico/ico-fountain.aseprite", B .. "png/ico/ico-fountain.png")
print(GV.report(t))
