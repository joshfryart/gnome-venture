local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local lilac = GV.ramp("#c3b2ea")
local ice = GV.ramp("#a9d6ea", { rim = "#c8ecdc" })

-- two short side crystals leaning outward, tall pointed centre crystal
local left  = c:poly({ {12, 55}, {17, 40}, {21, 36}, {25, 42}, {28, 55} })
local right = c:poly({ {37, 55}, {42, 43}, {47, 38}, {51, 43}, {54, 55} })
local main  = c:poly({ {32, 5}, {44, 20}, {39, 55}, {25, 55}, {20, 20} })

c:build{
  { "left",  left,  lilac, { cres = 3, gloss = { 18, 43 } } },
  { "right", right, lilac, { cres = 3, gloss = { 44, 45 } } },
  { "main",  main,  ice,   { cres = 5, gloss = { 26, 19 } } },
}
-- Y facet line
local facet = c:line({ {21, 20}, {32, 27}, {43, 20} }, 2):add(c:line({ {32, 27}, {32, 54} }, 2))
facet:clip(main:shrink(1))
facet:each(function(x, y) c:px(x, y, "#3f93b2") end)

c:ground(32, 55, 21, 1.5)
local t = c:save(O .. "aseprite/ph/rock-crystal.aseprite", O .. "png/ph/rock-crystal.png")
print(GV.report(t))
