local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local mint = GV.ramp("#b8d8d2", { gloss = "#c8ecdc" })
local lav = GV.ramp("#7b66b4")
local ant = GV.ramp("#3e2f66")
-- antennae: thin curves sweeping up and out, 4x4 clubs
local antL = c:line({ {35,32}, {30,24}, {23,17}, {17,13} }, 2)
antL:add(c:rrect(13, 10, 17, 14, 1))
local antR = c:line({ {44,32}, {49,24}, {56,17}, {62,13} }, 2)
antR:add(c:rrect(62, 10, 66, 14, 1))
-- tall U head
local head = c:ellipse(39.5, 42, 17, 12)
head:add(c:rrect(22, 40, 57, 70, 13))
local body = c:ellipse(39.5, 104, 34, 29)
local p = c:build{
  { "disc", c:ellipse(39.5, 50, 36, 36):cut(c:rect(0, 88, 79, 99)), mint },
  { "antL", antL, ant, { flat = true } },
  { "antR", antR, ant, { flat = true } },
  { "neck", c:rrect(33, 62, 46, 80, 3), "moss" },
  { "body", body, "#d6322b", { stitch = { side = "lit" } } },
  { "head", head, "moss" },
  { "bugL", c:ellipse(22.5, 52, 6.5, 7), "moss", { gloss = false } },
  { "bugR", c:ellipse(56.5, 52, 6.5, 7), "moss", { gloss = false } },
  { "band", c:line({ {22,44}, {31,41}, {40,40}, {49,41}, {57,44} }, 4), lav },
  { "bead", c:ellipse(52, 42, 2.5, 2.5), "#4e3a8a", { flat = true } },
}
-- forehead stripe above the band
c:fill(c:rect(39, 31, 40, 37), "#4a8a3e")
-- collar seam and button
c:seam({ {14, 84}, {30, 77} })
c:seam({ {49, 77}, {65, 84} })
c:button(37, 80)
-- eyes on the bulges
c:eye(20, 50); c:eye(54, 50)
-- smile
c:paint({ "u.......u", ".uu...uu.", "...uuu..." }, 35, 61, { u = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/npc-moss-petalwing.aseprite", O .. "png/ph/npc-moss-petalwing.png")
print(GV.report(t))
