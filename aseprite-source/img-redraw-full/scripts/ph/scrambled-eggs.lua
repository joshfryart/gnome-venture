local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plate = c:ellipse(31.5, 44, 23, 9)
local pile = c:ellipse(21, 37, 7, 6)
pile:add(c:ellipse(32, 30, 8, 7)); pile:add(c:ellipse(43, 37, 7, 6))
pile:add(c:ellipse(27, 43, 7, 5)); pile:add(c:ellipse(38, 43, 7, 5))
pile:add(c:ellipse(26, 34, 5, 5)); pile:add(c:ellipse(38, 34, 5, 5))
local yel = GV.ramp("#f5cf6a", { shade = "#e8a317", bounce = "#d0862a" })
local p = c:build{
  { "plate", plate, "#f1ece0", { gloss = false } },
  { "pile", pile, yel, { light = pile, gloss = { 26, 26 } } },
}
-- plate rim ring
c:fill(c:ellipse(31.5, 44, 21, 7):cut(c:ellipse(31.5, 44, 19, 6)):cut(pile), "#d6c9b6")
-- curd cracks between lumps
c:line({ {25,39},{27,37} }, 1); 
for _, s in ipairs({ { {26,39},{28,37} }, { {35,37},{37,39} }, { {31,40},{33,42} }, { {28,33},{29,31} }, { {36,31},{37,33} } }) do
  local m = c:line(s, 2); m:clip(pile); c:fill(m, "#d0862a")
end
-- chive sprig
local ch = c:line({ {30,28},{36,22} }, 2); ch:add(c:line({ {35,27},{43,23} }, 2))
c:part(ch, GV.ramp("#4a8a3e"), { flat = true })
-- salt specks
for _, d in ipairs({ {22,35},{40,36},{29,44},{44,40},{36,44} }) do c:px(d[1], d[2], "#f1ece0") end
local t = c:save(O .. "aseprite/ph/scrambled-eggs.aseprite", O .. "png/ph/scrambled-eggs.png")
print(GV.report(t))
