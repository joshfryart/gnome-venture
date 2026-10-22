local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(19, 12, 44, 56, 2)
local flap = c:poly({ {19, 12}, {45, 12}, {32, 29} })
local tab = c:poly({ {41, 7}, {47, 7}, {47, 18}, {40, 18} })
local fruit = c:ellipse(31.5, 43, 8, 8.5)
local leaf = c:ellipse(36.5, 32, 3, 2)
local stem = c:rect(31, 32, 32, 35)

c:build{
  { "tab",   tab,   "#2e5a2c", { gloss = false } },
  { "body",  body,  "#f1ece0", { pale = true } },
  { "flap",  flap,  "#e6dcc4", { pale = true, light = body } },
  { "stem",  stem,  "#2e5a2c", { flat = true } },
  { "leaf",  leaf,  "#58a03e", { flat = true } },
  { "fruit", fruit, "#e8a317" },
}
-- fold crease along top
c:fill(c:line({ {21, 13}, {43, 13} }, 1), "#dcb06a")
-- seam along flap edges
c:seam({ {22, 15}, {31, 26} }, { free = true })
c:seam({ {42, 15}, {33, 26} }, { free = true })
c:button(30, 25)
-- fruit blossom end
c:paint({ ".b.", "bbb" }, 30, 50, { b = "#7a3a14" })
c:ground(31.5, 58, 14, 1.5)
local t = c:save(O .. "aseprite/ph/feijoa-seed.aseprite", O .. "png/ph/feijoa-seed.png")
print(GV.report(t))
