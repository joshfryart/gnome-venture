local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- golden aura discs
local aura  = c:ellipse(31.5, 32.5, 21)
local aura2 = c:ellipse(31.5, 32.5, 15)
-- serpent S-ribbon, tapering to the tail
local body = c:line({ {22, 41}, {28, 43}, {34, 43}, {40, 39}, {44, 33}, {45, 28} }, 8)
body:add(c:line({ {15, 44}, {22, 41} }, 6))
body:add(c:line({ {10, 48}, {15, 44} }, 4))
body:add(c:poly({ {7, 45}, {12, 47}, {9, 52} }))  -- tail fin
local head = c:ellipse(45, 22, 6.5, 6)
head:add(c:poly({ {46, 22}, {54, 25}, {48, 29} }))
local water = "#3f93b2"
local p = c:build{
  { "aura",  aura,  "#f0bf56", { gloss = false } },
  { "aura2", aura2, "#f8db8c", { flat = true, contour = false, contact = false } },
  { "body",  body,  water },
  { "head",  head,  water, { gloss = { 42, 18 } } },
}
-- pale spine stripe on top of the ribbon
local spine = c:line({ {11, 46}, {16, 42}, {22, 39}, {28, 41}, {34, 41}, {39, 37}, {42, 32}, {43, 29} }, 2)
spine:clip(p.body.m)
c:fill(spine, "#b8d8d2")
-- fangs
c:px(48, 28, "#fff3c8"); c:px(48, 29, "#fff3c8")
c:px(51, 27, "#fff3c8"); c:px(51, 28, "#fff3c8")
-- floating crown above the middle
local band = c:rect(16, 29, 36, 32)
local pts = c:poly({ {16, 29}, {17, 20}, {23, 29} })
pts:add(c:poly({ {21, 29}, {26.5, 18}, {32, 29} }))
pts:add(c:poly({ {30, 29}, {36, 20}, {37, 29} }))
pts:add(c:rect(16, 25, 36, 29))
c:build{
  { "points", pts, "gold" },
  { "band", band, GV.ramp("#b07a10"), { gloss = false } },
}
c:paint({ ".rr.", "rrrr", "rrrr", ".rr." }, 25, 22, { r = "#d6322b" })
c:px(25, 23, "#ff9158")
c:paint({ "..j...j...j...j...j.." }, 16, 30, { j = "#f5cf6a" })
c:eye(43, 18, true)
c:ground(28, 51, 9, 1.5)
local t = c:save(O .. "aseprite/ph/creature-reef-leviathan.aseprite", O .. "png/ph/creature-reef-leviathan.png")
print(GV.report(t))
