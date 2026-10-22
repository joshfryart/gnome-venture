local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local legL = c:line({ { 28, 46 }, { 19, 54 } }, 5)
legL:add(c:rrect(13, 52, 22, 57, 2))
local legR = c:line({ { 35, 46 }, { 44, 54 } }, 5)
legR:add(c:rrect(41, 52, 50, 57, 2))
local tunic = c:poly({ { 23, 37 }, { 40, 37 }, { 42, 50 }, { 21, 50 } })
local head = c:ellipse(31, 30, 8.5, 8)
local hat = c:poly({ { 31, 5 }, { 45, 24 }, { 17, 24 } })
hat:add(c:rrect(16, 21, 46, 25, 2))
c:build{
  { "legL", legL, "#6a4528" },
  { "legR", legR, "#6a4528" },
  { "tunic", tunic, "#d6322b" },
  { "head", head, "#f2e4c0", { pale = true } },
  { "hat", hat, "#58a03e" },
}
c:seam({ { 23, 44 }, { 40, 44 } })
c:eye(26, 29, true); c:eye(33, 29, true)
c:ground(31.5, 58, 18, 1.5)
local t = c:save(O .. "aseprite/ico/ico-walker.aseprite", O .. "png/ico/ico-walker.png")
print(GV.report(t))
