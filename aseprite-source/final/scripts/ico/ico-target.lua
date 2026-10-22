local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local red = GV.ramp("#9c2a1e")
local cream = GV.ramp("#f8eed2")
local cx, cy = 30, 34

local outer = c:ellipse(cx, cy, 19, 19)
local p = c:build{
  { "outer", outer,                      red },
  { "mid",   c:ellipse(cx, cy, 13, 13),  cream, { light = outer } },
  { "inner", c:ellipse(cx, cy, 7, 7),    red,   { light = outer, gloss = false } },
  { "dot",   c:ellipse(cx, cy, 3, 3),    cream, { flat = true } },
  { "shaft", c:line({ { 34, 30 }, { 47, 17 } }, 3), "wood", { flat = true } },
  { "flet",  c:ascii({ "..xx.", ".xxxx", "xxxxx", "xxxx.", ".xx.." }, 45, 11), "gold", { flat = true } },
}
-- fletching vane split
c:px(47, 13, GV.C.goldS); c:px(48, 14, GV.C.goldS)
local t = c:save(O .. "aseprite/ico/ico-target.aseprite", O .. "png/ico/ico-target.png")
print(GV.report(t))
