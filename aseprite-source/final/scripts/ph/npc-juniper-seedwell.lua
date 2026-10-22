local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- wings (pale, behind)
local wingL = c:ellipse(17, 29, 10, 7)
local wingR = c:ellipse(63, 29, 10, 7)
local wings = wingL:copy(); wings:add(wingR)

-- body + apron
local body = c:ellipse(40, 102, 34, 24):cut(c:rect(0, 0, 79, 77))
local apron = c:poly({ {28, 80}, {53, 80}, {56, 100}, {25, 100} })

-- leafy cloak: hood + shoulder drapes with a front opening
local cloak = c:ellipse(40, 49, 27, 28)
cloak:add(c:poly({ {14, 54}, {67, 54}, {75, 100}, {55, 100}, {51, 74}, {30, 74}, {26, 100}, {6, 100} }))
-- leaf tips on the hood crown
cloak:add(c:poly({ {28, 25}, {33, 15}, {36, 24} }))
cloak:add(c:poly({ {45, 24}, {48, 15}, {53, 25} }))
-- scalloped drape hems
cloak:cut(c:poly({ {12, 101}, {16, 95}, {20, 101} }))
cloak:cut(c:poly({ {61, 101}, {65, 95}, {69, 101} }))

-- face
local face = c:ellipse(40, 54, 20.5, 19.5)
local band1 = c:line({ {16, 43}, {28, 45}, {40, 46}, {52, 45}, {64, 43} }, 4):clip(face)
local band2 = c:line({ {16, 58}, {28, 60}, {40, 61}, {52, 60}, {64, 58} }, 4):clip(face)

local p = c:build{
  { "wings", wings, "cream" },
  { "body",  body,  "#a38f80" },
  { "apron", apron, "#f8eed2" },
  { "cloak", cloak, "#58a03e", { stitch = { side = "lit" } } },
  { "face",  face,  "gold" },
  { "band1", band1, "dusk", { gloss = false } },
  { "band2", band2, "dusk", { gloss = false } },
}

-- antennae poking through the hood
local antL = c:line({ {34, 28}, {29, 18}, {26, 13} }, 2)
local antR = c:line({ {45, 28}, {50, 18}, {53, 13} }, 2)
antL:add(c:rrect(23, 9, 26, 12, 1)); antR:add(c:rrect(53, 9, 56, 12, 1))
c:part(antL, "dusk", { flat = true })
c:part(antR, "dusk", { flat = true })

c:seam({ {29, 81}, {52, 81} })
c:button(38, 76)

c:eye(29, 49); c:eye(46, 49)
c:paint({ "u.....u", ".u...u.", "..uuu.." }, 37, 64, { u = "umber" })

local t = c:save(O .. "aseprite/ph/npc-juniper-seedwell.aseprite", O .. "png/ph/npc-juniper-seedwell.png")
print(GV.report(t))
