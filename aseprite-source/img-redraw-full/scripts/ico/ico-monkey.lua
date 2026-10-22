local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local ears = c:ellipse(14.5, 30, 8, 8):add(c:ellipse(49.5, 30, 8, 8))
local fur = "#a5663a"
local p = c:build{
  { "ears", ears, fur, { gloss = false } },
}
c:fill(c:ellipse(13.5, 30, 4, 4), "#e9b98a")
c:fill(c:ellipse(50.5, 30, 4, 4), "#e9b98a")
-- face mask: heart-ish, two lobes around the eyes joining at the muzzle
local mask = c:ellipse(25.5, 28, 7, 7):add(c:ellipse(38.5, 28, 7, 7)):add(c:rect(24, 30, 40, 36))
c:build{
  { "head", c:ellipse(32, 31, 17.5, 17), fur, { gloss = { 20, 18 } } },
  { "mask", mask, "#e9b98a", { gloss = false } },
  { "muzzle", c:ellipse(32, 41, 11, 7.5), "#f8eed2", { gloss = false } },
}
-- hair tuft on top
c:fill(c:poly({ {28, 15}, {32, 11}, {33, 15} }), "#8a4f2a")
c:eye(22, 25); c:eye(37, 25)
c:paint({ "nn..nn" }, 29, 39, { n = "#2a1a10" })
c:paint({ "m.......m", ".mmmmmmm." }, 28, 43, { m = "#8a4f2a" })
local t = c:save(O .. "aseprite/ico/ico-monkey.aseprite", O .. "png/ico/ico-monkey.png")
print(GV.report(t))
