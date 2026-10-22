local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- backdrop disc
local disc = c:ellipse(39.5, 50, 36, 36)
-- vest (bleeds off bottom)
local vest = c:ellipse(39.5, 100, 34, 24):cut(c:rect(0, 100, 79, 140))
-- antennae (stalks + clubs), drawn before the face so the face overlaps the base
local antL = c:line({ {33, 40}, {28, 33}, {22, 28} }, 2):add(c:rrect(17, 23, 21, 27, 1))
local antR = c:line({ {47, 40}, {54, 32}, {60, 26} }, 2):add(c:rrect(59, 21, 63, 25, 1))
-- face
local face = c:ellipse(39.5, 55, 21, 19)
-- hat cone: curved left side, tip upper right
local cone = c:poly({ {16, 43}, {20, 32}, {27, 22}, {36, 14}, {45, 8}, {50, 7}, {52, 10}, {54, 20}, {58, 32}, {64, 43} })
-- brim
local brim = c:ellipse(39.5, 42, 28, 4.5)

local p = c:build{
  { "disc", disc, GV.ramp("#b8d8d2"), { gloss = false } },
  { "vest", vest, GV.ramp("#d9667f") },
  { "antL", antL, "#3e2f66", { flat = true } },
  { "antR", antR, "#3e2f66", { flat = true } },
  { "face", face, GV.ramp("#8f7060") },
  { "cone", cone, GV.ramp("#7a5cc0"), { stitch = { side = "lit" } } },
  { "brim", brim, GV.ramp("#4e3a8a"), { gloss = false } },
}
-- tip bead
c:part(c:rrect(48, 5, 52, 9, 1), GV.ramp("#e8a317"), { flat = true })

-- cream shirt V and collar
c:fill(c:poly({ {28, 77}, {40, 90}, {52, 77}, {46, 74}, {34, 74} }), "#f8eed2")
c:line({ {29, 77}, {40, 89}, {51, 77} }, 1)
c:fill(c:line({ {29, 77}, {40, 89} }, 1), "#c9a96e")
c:fill(c:line({ {40, 89}, {51, 77} }, 1), "#c9a96e")
c:button(38, 80)
-- seam on brim
c:seam({ {14, 44}, {24, 46}, {40, 47}, {56, 46}, {66, 44} })

-- face
c:eye(29, 50); c:eye(46, 50)
c:fill(c:rect(39, 50, 40, 57), "#2a1a10")
c:paint({ "s.........s", ".sssssssss." }, 35, 62, { s = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/npc-bram.aseprite", O .. "png/ph/npc-bram.png")
print(GV.report(t))
