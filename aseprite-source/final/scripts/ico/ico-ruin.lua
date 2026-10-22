local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local st = GV.ramp("#968f96")
local dk = GV.ramp("#6a6070")
local all = c:rrect(9, 10, 55, 54, 2)
local p = c:build{
  { "slab",  c:rrect(9, 47, 55, 54, 2), dk },
  { "left",  c:poly({ {11,48},{11,30},{14,26},{17,30},{22,24},{22,48} }), st, { light = all } },
  { "right", c:poly({ {43,48},{43,35},{47,31},{50,37},{53,33},{53,48} }), st, { light = all } },
  { "pillar",c:poly({ {25,48},{25,22},{29,14},{32,19},{37,10},{41,18},{41,48} }), st, { light = all } },
  { "rub1",  c:rrect(10, 44, 17, 50, 1), dk },
  { "rub2",  c:rrect(46, 43, 53, 49, 1), st },
  { "rub3",  c:rrect(37, 49, 44, 53, 1), st },
}
local door = c:ellipse(33, 33, 3, 3):add(c:rect(30, 33, 36, 47))
c:fill(door, "#3e3448")
c:fill(c:rect(31, 34, 31, 46), "#4a3e58")
c:fill(c:rect(14, 35, 18, 43), "#3e3448")
c:fill(c:rect(14, 35, 14, 43), "#4a3e58")
c:paint({ "u.", "u.", ".u", ".u", "u.", "u." }, 28, 20, { u = "#2a1a10" })
c:paint({ "u.", ".u", ".u", "u." }, 38, 21, { u = "#2a1a10" })
c:paint({ "u", "u", ".u" }, 48, 37, { u = "#2a1a10" })
local t = c:save(O .. "aseprite/ico/ico-ruin.aseprite", O .. "png/ico/ico-ruin.png")
print(GV.report(t))
