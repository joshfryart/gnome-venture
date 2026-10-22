local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- leaves on the right (tilted ellipses as polys)
local leafR = c:poly({ {44,24}, {47,18}, {52,14}, {55,14}, {55,18}, {52,23}, {47,27} })
local leafL = c:poly({ {34,20}, {37,18}, {41,19}, {44,23}, {45,28}, {41,28}, {37,26} })
local stem = c:line({ {45,33}, {45,25} }, 3)
-- yellow banana peel arc
local peel = c:line({ {26,33}, {28,27}, {31,23}, {35,20}, {38,20} }, 4)
-- apple scraps heap top-left
local apple1 = c:ellipse(20, 26, 8, 6)
local apple2 = c:ellipse(32, 30, 5, 4)
-- bin body
local bin = c:rrect(11, 32, 52, 52, 3)
local rimband = c:rect(11, 32, 52, 35)

local p = c:build{
  { "leafR", leafR, GV.ramp("#58a03e") },
  { "leafL", leafL, GV.ramp("#6a9a3a") },
  { "stem",  stem,  "moss", { flat = true } },
  { "apple1", apple1, "red" },
  { "apple2", apple2, "red" },
  { "peel",  peel,  GV.ramp("#f2cf4a"), { gloss = false } },
  { "bin",   bin,   "wood", { light = bin } },
}
-- apple core bite (cream flesh) on apple1 and seeds
c:fill(c:ellipse(18, 23, 2.5, 2), "#f5e3b0")
c:px(18, 23, "#35161f"); c:px(19, 24, "#35161f")
-- apple stem
c:fill(c:rect(20, 18, 21, 20), "#5e2f1e")
-- leaf veins
c:fill(c:line({ {47,22}, {53,16} }, 1), "#2f5a2a")
c:fill(c:line({ {38,21}, {43,26} }, 1), "#2f5a2a")
-- rim band shading under the top lip
c:fill(c:rect(13, 36, 50, 36), "#5e2f1e")
-- slats
c:fill(c:rect(13, 42, 50, 43), "#4a2c1a")
c:fill(c:rect(13, 48, 50, 48), "#4a2c1a")
-- vertical slat gaps
for _, x in ipairs({ 24, 39 }) do
  c:fill(c:rect(x, 37, x, 51), "#8a4f2a")
end
c:seam({ {13, 34}, {50, 34} })

local t = c:save(O .. "aseprite/ico/ico-compost.aseprite", O .. "png/ico/ico-compost.png")
print(GV.report(t))
