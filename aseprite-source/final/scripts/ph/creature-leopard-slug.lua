local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local foot = c:ellipse(30, 54, 18, 3.5)
foot:add(c:poly({ {10, 57}, {22, 50}, {22, 58} }))
local head = c:ellipse(42.5, 45.5, 6, 6):add(c:rrect(34, 46, 47, 55, 3))
local stalks = c:line({ {40, 41}, {38, 32} }, 2):add(c:line({ {45, 41}, {48, 32} }, 2))
stalks:add(c:rrect(34, 27, 40, 32, 2)):add(c:rrect(46, 27, 52, 32, 2))
local hump = c:ellipse(26.5, 48.5, 16, 6)
c:build{
  { "foot", foot, tan },
  { "stalks", stalks, tan, { flat = true } },
  { "head", head, tan },
  { "hump", hump, tan, { light = hump:copy():add(foot) } },
}
local sp = "#a5663a"
local dia = { ".x.", "xxx", ".x." }
c:spot(c:ascii(dia, 17, 46), sp)
c:spot(c:ellipse(24, 45, 1.5, 1), sp)
c:spot(c:ascii(dia, 30, 44), sp)
c:spot(c:ellipse(36.5, 49, 1, 1.5), sp)
c:spot(c:ellipse(27.5, 50, 1.5, 1), sp)
c:spot(c:ascii(dia, 18, 51), sp)
-- eyes on clubs (small), sleepy lids
c:eye(36, 28, true); c:eye(48, 28, true)
-- sly smirk
c:paint({ "u..u", ".uu." }, 43, 48, { u = "#2a1a10" })
c:ground(31, 58, 20, 1.5)
local t = c:save(O .. "aseprite/ph/creature-leopard-slug.aseprite", O .. "png/ph/creature-leopard-slug.png")
print(GV.report(t))
