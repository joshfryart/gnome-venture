local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy egg: tall ellipse with knobbly warts pushed out of the outline
local body = c:ellipse(32, 38, 14, 17)
body:add(c:ellipse(18.5, 31, 2, 2)):add(c:ellipse(46, 36, 2, 2))
body:add(c:ellipse(20, 47, 2, 2)):add(c:ellipse(41, 52, 2, 2))
body:add(c:ellipse(38, 22, 2, 2))
local stem = c:rrect(30, 13, 33, 23, 1)
local leaf = c:poly({ {33, 17}, {36, 12}, {41, 9}, {47, 7}, {52, 7}, {49, 11}, {44, 15}, {38, 18} })
local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "fruit", body, "water", { gloss = { 22, 27 } } },
  { "leaf", leaf, "leaf", { cres = 2, deep = 1, gloss = false } },
}
-- dimple pits: dark 2x2 with a light lip at the upper left, evenly scattered
local pits = { {27, 25}, {35, 28}, {24, 35}, {32, 37}, {40, 40}, {28, 45}, {36, 48}, {22, 41}, {41, 31} }
for _, q in ipairs(pits) do
  local x, y = q[1], q[2]
  c:px(x - 1, y - 1, "#8fcbd8")
  c:fill(c:rect(x, y, x + 1, y + 1), "#2a3c6c")
  c:px(x + 1, y + 1, "#2f6290")
end
-- leaf vein
c:fill(c:line({ {37, 15}, {43, 11}, {49, 9} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/noni.aseprite", O .. "png/ph/noni.png")
print(GV.report(t))
