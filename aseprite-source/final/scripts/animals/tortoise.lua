local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dome = c:ellipse(29.5, 41, 19, 22):cut(c:rect(0, 42, 63, 63))
local belly = c:rrect(9, 39, 50, 46, 3)
local head = c:ellipse(48, 37, 4, 3):add(c:ellipse(51, 32, 4.5, 4.5))
local p = c:build{
  { "legB", c:rrect(14, 42, 21, 52, 2), "#a4b86a" },
  { "legF", c:rrect(37, 42, 44, 52, 2), "#a4b86a" },
  { "head", head, "#a4b86a" },
  { "belly", belly, "#c9a96e" },
  { "dome", dome, "#6a9a3a", { light = dome } },
}
local scute = c:line({ {29, 20}, {29, 39} }, 2)
scute:add(c:line({ {19, 26}, {21, 39} }, 2))
scute:add(c:line({ {40, 26}, {38, 39} }, 2))
scute:add(c:line({ {12, 32}, {47, 32} }, 2))
scute:clip(p.dome.m:shrink(2))
c:fill(scute, "#3f5a22")
c:seam({ {11, 42}, {48, 42} })
c:eye(51, 30, true)
c:px(55, 34, "#4a2c1a")
local t = c:save(O .. "aseprite/animals/tortoise.aseprite", O .. "png/animals/tortoise.png")
print(GV.report(t))
