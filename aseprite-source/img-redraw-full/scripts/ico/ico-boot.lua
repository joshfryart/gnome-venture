local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local upper = c:poly({ {13, 14}, {34, 14}, {34, 31}, {43, 34}, {49, 39}, {51, 44}, {51, 47}, {13, 47} })
upper:add(c:rrect(13, 14, 34, 30, 2))
local cuff = c:rrect(11, 11, 36, 20, 2)
local sole = c:rrect(11, 45, 52, 52, 2)

local p = c:build{
  { "upper", upper, GV.ramp("#a5663a") },
  { "sole", sole, GV.ramp("#b6814d") },
  { "cuff", cuff, "#f8eed2" },
}
-- toe cap patch
c:fill(c:poly({ {41, 37}, {46, 38}, {49, 42}, {43, 42} }), "#d9a660")
-- heel/tread line on the sole
c:fill(c:rect(12, 50, 52, 50):clip(p.sole.m:shrink(1)), GV.R.wood.shade)
-- lace eyelets
c:fill(c:rect(29, 23, 31, 25), "#5e2f1e")
c:fill(c:rect(29, 29, 31, 31), "#5e2f1e")
c:fill(c:rect(29, 35, 31, 37), "#5e2f1e")
-- seams
c:seam({ {13, 20}, {34, 20} }, { free = true })
c:seam({ {13, 45}, {50, 45} }, { free = true })

local t = c:save(O .. "aseprite/ico/ico-boot.aseprite", O .. "png/ico/ico-boot.png")
print(GV.report(t))
