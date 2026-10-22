local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local lav = GV.ramp("#c3b2ea")
local ant = GV.ramp("#7a5cc0")
-- wings: two lobes per side, flaring out
local wl = c:ellipse(19, 50, 14, 17):add(c:ellipse(15, 70, 9, 10))
local wr = c:ellipse(60, 50, 14, 17):add(c:ellipse(64, 70, 9, 10))
-- antennae
local al = c:line({ {34, 32}, {30, 22}, {27, 13} }, 2)
local ar = c:line({ {45, 32}, {49, 22}, {52, 13} }, 2)
local head = c:ellipse(39.5, 54, 21, 22)
local body = c:ellipse(39.5, 104, 31, 24)
local scarf = c:line({ {27, 80}, {33, 83}, {40, 85}, {46, 83}, {52, 80} }, 5)
  :add(c:poly({ {44, 82}, {51, 82}, {50, 97}, {46, 97} }))
local face = c:ellipse(39.5, 58, 14, 15)
local cap = c:ellipse(39.5, 46, 21, 17):cut(c:ellipse(39.5, 61, 15, 15))
local p = c:build{
  { "wl", wl, lav, { stitch = { side = "lit" } } },
  { "wr", wr, lav, { stitch = { side = "lit" } } },
  { "al", al, ant, { flat = true } },
  { "ar", ar, ant, { flat = true } },
  { "head", head, lav },
  { "body", body, "#58a03e" },
  { "scarf", scarf, "#d9667f" },
  { "face", face, "#f8eed2" },
  { "cap", cap, "#d9667f" },
}
-- antenna clubs and barbs
c:part(c:rrect(25, 10, 28, 13, 1), ant, { flat = true })
c:part(c:rrect(51, 10, 54, 13, 1), ant, { flat = true })
for _, q in ipairs({ {29, 18}, {27, 22}, {50, 18}, {52, 22} }) do c:px(q[1], q[2], ant.base) end
-- wing eyespots
local spot = { ".ccc.", "ccccc", "ccdcc", "ccccc", ".ccc." }
c:paint(spot, 12, 46, { c = "#f8eed2", d = "#2a1a10" })
c:paint(spot, 63, 46, { c = "#f8eed2", d = "#2a1a10" })
-- collar V
c:paint({ "d.........d", ".d.......d.", "..d.....d..", "...d...d...", "....d.d....", ".....d....." }, 35, 89, { d = "#2e5a2c" })
c:button(38, 83)
c:eye(31, 54); c:eye(43, 54)
c:paint({ "u.....u", ".uuuuu." }, 36, 64, { u = "umber" })
local t = c:save(O .. "aseprite/ph/npc-woad.aseprite", O .. "png/ph/npc-woad.png")
print(GV.report(t))
