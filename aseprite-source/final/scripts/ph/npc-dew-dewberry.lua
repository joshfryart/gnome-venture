local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- backdrop disc
local disc = c:ellipse(40, 50, 36, 36)

-- coat dome
local coat = c:ellipse(39.5, 102, 34, 28):cut(c:rect(0, 0, 79, 73))

-- antennae (behind body)
local ant = c:line({ {33, 38}, {29, 30}, {23, 25} }, 2)
ant:add(c:line({ {47, 38}, {51, 30}, {57, 25} }, 2))
ant:add(c:rrect(19, 21, 23, 25, 1))
ant:add(c:rrect(56, 21, 60, 25, 1))

-- body/head
local body = c:ellipse(39.5, 55, 22, 20)

-- black head-cap: top of body down to a brow line
local cap = body:copy():clip(c:poly({ {0, 0}, {79, 0}, {79, 47}, {58, 47}, {40, 45}, {22, 47}, {0, 47} }))

-- hat cone tipped up-right
local cone = c:poly({ {19, 43}, {33, 24}, {44, 11}, {49, 7}, {50, 12}, {55, 26}, {62, 43} })
local brim = c:ellipse(40, 43, 27, 4)

c:build{
  { "disc",  disc, "#c3b2ea", { gloss = false, contact = false } },
  { "coat",  coat, "#58a03e", { stitch = { side = "lit" } } },
  { "ant",   ant,  "dusk",   { flat = true } },
  { "body",  body, "#d6322b" },
  { "cap",   cap,  "dusk",   { gloss = false } },
  { "cone",  cone, "gold" },
  { "brim",  brim, "#b07a10" },
}

-- scarf / collar on the coat
c:fill(c:line({ {28, 76}, {34, 79}, {40, 80}, {46, 79}, {52, 76} }, 3), "#e8a317")
c:paint({ "gg", "gg", "gg", "GG" }, 49, 80, { g = "#e8a317", G = "#b8661a" })
c:seam({ {14, 90}, {28, 86} })
c:seam({ {52, 86}, {66, 90} })

-- spots
c:spot(c:ellipse(25.5, 63, 3.5, 3))
c:spot(c:ellipse(53.5, 63, 3.5, 3))
c:spot(c:ellipse(39.5, 70, 3, 2.5))

-- hem seam along brim
c:seam({ {16, 43}, {64, 43} })
c:button(47, 8)

-- face
c:eye(29, 49); c:eye(46, 49)
c:paint({ "u.......u", ".uuuuuuu." }, 35, 59, { u = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/npc-dew-dewberry.aseprite", O .. "png/ph/npc-dew-dewberry.png")
print(GV.report(t))
