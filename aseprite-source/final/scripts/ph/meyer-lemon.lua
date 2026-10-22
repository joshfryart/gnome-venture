local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local fruit = c:ellipse(31.5, 36, 16, 15.5)
fruit:add(c:rrect(29, 49, 34, 53, 1))          -- bottom nipple, part of the silhouette
local stem = c:rect(30, 14, 32, 22)
local leaf = c:poly({ {33, 18}, {37, 12}, {43, 8}, {49, 7}, {47, 12}, {42, 17}, {36, 19} })

local p = c:build{
  { "stem", stem, "#4a8a3e", { flat = true } },
  { "leaf", leaf, "moss", { gloss = false } },
  { "fruit", fruit, GV.ramp("#f5cf6a", { shade = "#ebb326", deep = "#c9781f", bounce = "#f0c23e" }), { gloss = { 21, 27 }, cres = 3 } },
}

-- leaf vein
c:line({ {36, 16}, {46, 9} }, 1)
c:fill(c:line({ {36, 16}, {46, 9} }, 1), "#4a8a3e")

-- peel dimples
c:px(37, 31, "#e8a317"); c:px(27, 41, "#e8a317"); c:px(40, 42, "#e8a317"); c:px(33, 25, "#e8a317")

local t = c:save(O .. "aseprite/ph/meyer-lemon.aseprite", O .. "png/ph/meyer-lemon.png")
print(GV.report(t))
