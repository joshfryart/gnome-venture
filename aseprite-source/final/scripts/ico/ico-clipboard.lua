local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local p = c:build{
  { "board", c:rrect(12, 10, 52, 57, 5), GV.ramp("#a5663a") },
  { "paper", c:rect(16, 17, 48, 53), GV.ramp("#f4f0e0"), { gloss = false } },
  { "clip", c:rrect(23, 6, 41, 16, 2), GV.ramp("#968f96") },
}
-- hole in the clip
c:fill(c:rrect(30, 8, 34, 11, 1), "#5b6470")

-- text bars
c:fill(c:rect(31, 23, 45, 25), "#d6c9b6")
c:fill(c:rect(31, 33, 45, 35), "#d6c9b6")
c:fill(c:rect(31, 43, 45, 45), "#b8b2aa")

-- ticks
c:fill(c:line({ { 19, 24 }, { 22, 27 }, { 27, 21 } }, 3), "#4a8a3e")
c:fill(c:line({ { 19, 34 }, { 22, 37 }, { 27, 31 } }, 3), "#4a8a3e")
c:px(19, 24, "#7ab55c"); c:px(19, 34, "#7ab55c")
-- empty box
local box = c:rect(19, 41, 26, 48)
c:fill(box:copy():cut(c:rect(21, 43, 24, 46)), "#b8b2aa")

local t = c:save(O .. "aseprite/ico/ico-clipboard.aseprite", O .. "png/ico/ico-clipboard.png")
print(GV.report(t))
