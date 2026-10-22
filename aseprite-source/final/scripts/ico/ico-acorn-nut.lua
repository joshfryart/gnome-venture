local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- egg-shaped hazelnut: narrower top, round belly
local nut = c:ellipse(31.5, 38, 15, 16)
nut:add(c:ellipse(31.5, 31, 12, 12))
-- cap band: dome of the top, bottom edge a shallow smile
local cap = c:ellipse(31.5, 31, 12.5, 12.5):copy()
cap:add(c:ellipse(31.5, 38, 15.5, 16.5))
cap:clip(c:rect(0, 0, 63, 27))
cap:cut(c:ellipse(31.5, 38, 14, 9):cut(c:rect(0, 0, 63, 30)))
local stem = c:poly({ {30,13}, {34,13}, {35,23}, {30,23} })

local p = c:build{
  { "stem", stem, GV.ramp("#2e5a2c", { rim = "#4a8a3e" }), { flat = true } },
  { "nut", nut, GV.ramp("#a5663a"), { gloss = { 22, 33 } } },
  { "cap", cap, GV.ramp("#7a3f18"), { gloss = { 23, 21 } } },
}
c:fill(c:rect(31, 13, 33, 14), "#4a8a3e")
-- groove
c:fill(c:line({ {38,36}, {40,40}, {40,45}, {38,49} }, 2), "#5e2f1e")
-- shell beans
c:fill(c:rect(40, 31, 41, 33), "#8a4f2a")
c:fill(c:rect(23, 36, 24, 38), "#8a4f2a")
c:fill(c:rect(27, 46, 28, 48), "#8a4f2a")

local t = c:save(O .. "aseprite/ico/ico-acorn-nut.aseprite", O .. "png/ico/ico-acorn-nut.png")
print(GV.report(t))
