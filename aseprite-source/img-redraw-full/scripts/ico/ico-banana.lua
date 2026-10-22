local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- bowed banana: thick bent line from lower-left to upper-right, sagging in the middle
local pts = { {13, 46}, {20, 46}, {28, 43}, {36, 37}, {43, 29}, {48, 21} }
local body = c:line(pts, 14)
body:add(c:line({ {16, 47}, {24, 47}, {33, 43}, {41, 35}, {47, 26} }, 12))
local stalk = c:line({ {46, 22}, {50, 15}, {53, 10} }, 7)
local tip = c:ellipse(10.5, 47.5, 3.5, 3.5)

local p = c:build{
  { "body",  body,  "gold" },
  { "stalk", stalk, "moss" },
  { "tip",   tip,   "wood", { flat = true } },
}
-- ridge line along the body
c:line({ {20, 41}, {28, 38}, {35, 33}, {41, 26} }, 2)
for _, q in ipairs({ {20,41},{21,41},{22,40},{23,40},{24,40},{25,39},{26,39},{27,39},{28,38},{29,37},{30,37},{31,36},{32,35},{33,35},{34,34},{35,33},{36,32},{37,31},{38,30},{39,29},{40,28},{41,27} }) do
  c:px(q[1], q[2] + 3, "#d0862a")
end
c:fill(c:rect(51, 7, 56, 9), "#2f5a2a")

local t = c:save(O .. "aseprite/ico/ico-banana.aseprite", O .. "png/ico/ico-banana.png")
print(GV.report(t))
