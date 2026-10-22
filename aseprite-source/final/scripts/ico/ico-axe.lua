local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- diagonal handle, lower left to upper right, poking above the head
local handle = c:line({ {21, 51}, {38, 12} }, 6)
local butt = c:ellipse(20.5, 51.5, 5, 4)
-- single-bit head: narrow neck at the handle, fanning out to a convex edge on the right
local head = c:poly({ {31, 16}, {40, 13}, {46, 9}, {51, 10}, {54, 16}, {55, 23}, {53, 31}, {49, 35}, {45, 32}, {40, 26}, {33, 25} })
local edge2 = head:copy():cut(head:shift(-4, 1))

local p = c:build{
  { "handle", handle, "wood" },
  { "butt",   butt,   "#8a4f2a" },
  { "head",   head,   "#8b8f96" },
  { "edge",   edge2,  "#c9c5bc", { flat = true, contact = false, contour = false } },
  { "collar", c:rrect(33, 15, 37, 23, 1), "#5b6470", { flat = true } },
}
-- handle grain
c:paint({ "g", ".", "g" }, 26, 39, { g = "#8a4f2a" })
c:paint({ "g", ".", "g" }, 30, 30, { g = "#8a4f2a" })
-- wedge rivet on collar
c:px(35, 18, "#c9c5bc")
local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-axe.aseprite", D .. "img-redraw-full/png/ico/ico-axe.png")
print(GV.report(t))
