local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local leaf = GV.ramp("#58a03e")
local root = c:poly({ {20, 22}, {45, 22}, {34, 57}, {31, 57} })
root:add(c:rrect(20, 18, 44, 27, 5))

local p = c:build{
  { "lfrond", c:poly({ {30, 21}, {24, 13}, {22, 5}, {28, 7}, {33, 14}, {34, 21} }), leaf },
  { "rfrond", c:poly({ {31, 21}, {32, 14}, {37, 7}, {43, 5}, {41, 13}, {35, 21} }), leaf },
  { "root", root, GV.ramp("#f08a24"), { gloss = { 25, 22 } } },
}
-- ridge dashes
c:fill(c:rect(24, 30, 30, 31), "#e0501f")
c:fill(c:rect(34, 38, 39, 39), "#e0501f")
c:fill(c:rect(28, 46, 32, 47), "#e0501f")
local t = c:save(B .. "img-redraw-full/aseprite/ico/ico-carrot.aseprite",
                 B .. "img-redraw-full/png/ico/ico-carrot.png")
print(GV.report(t))
