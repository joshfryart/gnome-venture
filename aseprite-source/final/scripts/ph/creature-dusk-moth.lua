local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lilac = GV.ramp("#c3b2ea")
local violet = GV.ramp("#7a5cc0")
-- antennae (behind)
local ant = c:line({ {30,16}, {28,13}, {25,12} }, 2)
ant:add(c:line({ {34,16}, {36,13}, {39,12} }, 2))
local clubs = c:rrect(21,10,24,13,1):add(c:rrect(40,10,43,13,1))
-- upper wings: big rounded lobes, right one a touch higher (slight lean)
local uwL = c:ellipse(20.5, 25, 10.5, 10):add(c:poly({ {24,30}, {32,24}, {32,38}, {22,36} }))
local uwR = c:ellipse(43.5, 23.5, 10, 10):add(c:poly({ {32,24}, {40,28}, {42,35}, {32,38} }))
-- lower wings: smaller violet lobes
local lwL = c:ellipse(23.5, 42, 8, 7.5)
local lwR = c:ellipse(41, 42.5, 7.5, 7.5)
local body = c:ellipse(32, 36, 3.5, 13.5)
local head = c:ellipse(32, 20, 5, 4.5)
local p = c:build{
  { "ant", ant, violet, { flat = true } },
  { "clubs", clubs, violet, { flat = true } },
  { "uwL", uwL, lilac, { stitch = { side = "lit" } } },
  { "uwR", uwR, lilac, { stitch = { side = "lit" } } },
  { "lwL", lwL, violet },
  { "lwR", lwR, violet },
  { "body", body, "cream" },
  { "head", head, "cream" },
}
-- eyespots: cream ring with violet core (distinct from the face eyes)
local spot = { ".ccc.", "cvvvc", "cvgvc", "cvvvc", ".ccc." }
local lg = { c = "#f8eed2", v = "#3e2f66", g = "#a894dc" }
c:paint(spot, 16, 22, lg)
c:paint(spot, 42, 20, lg)
-- bean markings on lower wings
c:spot(c:ellipse(22, 44, 1.5, 1)); c:spot(c:ellipse(42, 45, 1.5, 1))
-- body fur seam
c:seam({ {32, 26}, {32, 48} })
-- face
c:eye(28, 19, true); c:eye(34, 19, true)
local t = c:save(O .. "aseprite/ph/creature-dusk-moth.aseprite", O .. "png/ph/creature-dusk-moth.png")
print(GV.report(t))
