local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local twig = c:line({ {31, 9}, {32, 20} }, 3)
local leaf = c:poly({ {33, 17}, {37, 10}, {43, 6}, {49, 5}, {47, 10}, {42, 15}, {36, 18} })
local body = c:ellipse(31.5, 38, 14, 18)

c:build{
  { "twig", twig, "wood", { flat = true } },
  { "leaf", leaf, "moss", { gloss = { 39, 10 } } },
  { "body", body, "moss" },
}
c:fill(c:line({ {35, 16}, {40, 11}, {46, 7} }, 1), "#4a8a3e")
-- pimento in the stuffing hole
c:part(c:ellipse(35, 47, 3.5, 3), "red", { gloss = { 34, 46 }, contact = false })

local t = c:save(O .. "aseprite/ico/ico-olive.aseprite", O .. "png/ico/ico-olive.png")
print(GV.report(t))
