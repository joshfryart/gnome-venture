local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plus = c:rect(10, 24, 51, 37):add(c:rect(24, 10, 37, 51))
-- toothed holly edges: 3-wide points sticking out 2 px
local function toothH(y0, dir)
  for x = 11, 49, 5 do if x < 22 or x > 38 then
    plus:add(c:rect(x, y0, x + 2, y0)); plus:add(c:rect(x + 1, y0 + dir, x + 1, y0 + dir))
    plus:add(c:rect(x + 1, y0 + dir, x + 2, y0 + dir))
  end end
end
local function toothV(x0, dir)
  for y = 11, 49, 5 do if y < 22 or y > 38 then
    plus:add(c:rect(x0, y, x0, y + 2)); plus:add(c:rect(x0 + dir, y + 1, x0 + dir, y + 2))
  end end
end
toothH(23, -1); toothH(38, 1); toothV(23, -1); toothV(38, 1)
-- toothed arm ends
for _, e in ipairs({ {9, 27}, {9, 33} }) do plus:add(c:rect(e[1]-1, e[2], e[1], e[2]+1)) end
for _, e in ipairs({ {52, 27}, {52, 33} }) do plus:add(c:rect(e[1], e[2], e[1]+1, e[2]+1)) end
for _, e in ipairs({ {27, 9}, {33, 9} }) do plus:add(c:rect(e[1], e[2]-1, e[1]+1, e[2])) end
for _, e in ipairs({ {27, 52}, {33, 52} }) do plus:add(c:rect(e[1], e[2], e[1]+1, e[2]+1)) end
local shadow = plus:shift(2, 3):cut(plus)
c:build{
  { "shadow", shadow, GV.ramp("#6a4528"), { flat = true } },
  { "hedge",  plus,   GV.ramp("#4a8a3e"), { cres = 5, gloss = { 13, 26 } } },
}
-- light ridge dashes
local L = "#b8d47c"
for x = 13, 48 do if (x < 24 or x > 37) and x % 4 ~= 0 then c:px(x, 27, L) end end
for y = 13, 48 do if (y < 24 or y > 37) and y % 4 ~= 0 then c:px(27, y, L) end end
-- dark leaf veins for prickly texture
local V = "#2f5a2a"
for _, v in ipairs({ {18,31},{43,30},{30,18},{31,43},{46,34},{16,35} }) do
  c:px(v[1], v[2], V); c:px(v[1]+1, v[2]-1, V)
end
-- berries: 3x3 discs in pairs
local function berry(x, y)
  c:paint({ ".r.", "rrr", ".rd" }, x, y, { r = "#d6322b", d = "#ae2a2a" })
  c:px(x, y + 1, "#ff9158")
end
for _, b in ipairs({ {12,30},{14,33},{48,31},{50,34},{28,12},{31,14},{30,47},{33,49},{31,31} }) do
  berry(b[1], b[2])
end
local t = c:save(B .. "aseprite/ph/holly-hedge-cross.aseprite", B .. "png/ph/holly-hedge-cross.png")
print(GV.report(t))
