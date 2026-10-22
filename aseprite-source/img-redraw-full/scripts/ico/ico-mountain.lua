local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local right = c:poly({ {30, 53}, {45, 22}, {56, 53} })
local left  = c:poly({ {9, 53}, {24, 15}, {43, 53} })
local whole = right:copy(); whole:add(left)
local snowL = c:poly({ {24, 15}, {15, 35}, {19, 32}, {24, 38}, {29, 32}, {34, 35} }):clip(left)
local snowR = c:poly({ {45, 22}, {39, 36}, {42, 33}, {46, 38}, {50, 33}, {52, 36} }):clip(right)
c:build{
  { "right", right, GV.ramp("#968f96") },
  { "rsnow", snowR, GV.ramp("#f8eed2"), { contact = false } },
  { "left",  left,  GV.ramp("#6a6070") },
  { "lsnow", snowL, GV.ramp("#f8eed2"), { contact = false } },
}

local t = c:save(O .. "aseprite/ico/ico-mountain.aseprite", O .. "png/ico/ico-mountain.png")
print(GV.report(t))
