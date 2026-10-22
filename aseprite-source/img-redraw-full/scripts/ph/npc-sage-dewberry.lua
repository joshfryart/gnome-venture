local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- wings: upper and lower lobes each side
local wl = c:ellipse(19, 42, 13, 12):add(c:ellipse(22, 60, 10, 8)):add(c:rect(26, 40, 34, 62))
local wr = c:ellipse(60.5, 42, 13, 12):add(c:ellipse(57.5, 60, 10, 8)):add(c:rect(45, 40, 53, 62))
local wing = GV.ramp("#d9667f")

-- body (bleeds off bottom)
local body = c:ellipse(39.5, 102, 34, 26):cut(c:rect(0, 0, 79, 75))

-- antennae
local ant = c:line({ {34, 38}, {28, 30}, {23, 25} }, 2):add(c:rect(20, 22, 23, 25))
ant:add(c:line({ {45, 38}, {51, 30}, {56, 25} }, 2)):add(c:rect(56, 22, 59, 25))

-- head
local head = c:ellipse(39.5, 57, 15, 18)

-- scarf
local scarf = c:line({ {26, 77}, {32, 81}, {40, 83}, {47, 81}, {53, 77} }, 5)
local tail = c:poly({ {44, 80}, {50, 80}, {53, 96}, {45, 96} })

-- hat
local cone = c:poly({ {22, 45}, {48, 9}, {52, 9}, {59, 45} })
local brim = c:ellipse(40, 45, 23, 4)

c:build{
  { "wl", wl, wing },
  { "wr", wr, wing },
  { "ant", ant, "dusk", { flat = true } },
  { "body", body, "gold", { stitch = true } },
  { "head", head, GV.ramp("#f5cf6a") },
  { "tail", tail, GV.ramp("#d6322b") },
  { "scarf", scarf, GV.ramp("#d6322b") },
  { "cone", cone, GV.ramp("#d6322b"), { gloss = { 30, 32 } } },
  { "brim", brim, GV.ramp("#9c2a1e"), { gloss = false } },
}

-- wing spots
c:spot(c:ellipse(15, 41, 4, 4), "#f8eed2")
c:spot(c:ellipse(64.5, 41, 4, 4), "#f8eed2")
c:spot(c:ellipse(21, 61, 2.5, 2.5), "#f8eed2")
c:spot(c:ellipse(58.5, 61, 2.5, 2.5), "#f8eed2")

-- hat band notch + brim seam
c:paint({ "gggg" , "gggg" }, 46, 17, { g = "gold" })
c:seam({ {19, 45}, {61, 45} })

-- face
c:eye(32, 53); c:eye(43, 53)
c:paint({ "u....u", ".uuuu." }, 37, 63, { u = "umber" })

-- scarf knot button
c:button(38, 79)

local t = c:save(O .. "aseprite/ph/npc-sage-dewberry.aseprite", O .. "png/ph/npc-sage-dewberry.png")
print(GV.report(t))
