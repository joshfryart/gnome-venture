-- ph/npc-clover-puddlejump : ladybird bust (red face, dark cap band, antennae, gold tunic)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local R = GV.R

-- antennae (behind the head): 2px dark stalks with 4x4 clubs
local ant = c:line({ {33, 30}, {30, 22}, {26, 16}, {24, 13} }, 2)
  :add(c:line({ {46, 30}, {49, 22}, {53, 16}, {55, 13} }, 2))
local clubs = c:rrect(20, 9, 24, 13, 1):add(c:rrect(55, 9, 59, 13, 1))

local head = c:ellipse(39.5, 48, 24, 22)
local cap = c:ellipse(39.5, 47, 25, 23):clip(c:rect(0, 0, 79, 43))
local band = c:line({ {15, 45}, {22, 42}, {30, 40}, {40, 39}, {49, 40}, {57, 42}, {64, 45} }, 5)
  :clip(c:ellipse(39.5, 47, 26, 24))

c:build{
  { "ant",   ant,  "dusk", { flat = true } },
  { "clubs", clubs, "dusk", { gloss = false } },
  { "tunic", c:rrect(7, 74, 72, 112, 16), "gold" },
  { "head",  head, "red" },
  { "cap",   cap,  "dusk" },
  { "band",  band, "moss", { gloss = false } },
}

-- tunic: collar V seam, button at collar point, centre seam
c:seam({ {24, 76}, {39, 86} }); c:seam({ {55, 76}, {40, 86} })
c:button(38, 86)
c:seam({ {40, 91}, {40, 99} })

-- shell spots on the lower sides of the face
c:spot(c:ellipse(21, 57, 2, 3))
c:spot(c:ellipse(58, 57, 2, 3))

-- clover bead on the headband
c:paint({
  ".g.g.",
  "ggLgg",
  ".ggg.",
  "..d..",
}, 50, 38, { g = "#2f5a2a", L = "#7ab55c", d = "#2f5a2a" })

-- face
c:eye(28, 48); c:eye(47, 48)
c:paint({
  "u.....u",
  ".u...u.",
  "..uuu..",
}, 36, 60, { u = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/npc-clover-puddlejump.aseprite", O .. "png/ph/npc-clover-puddlejump.png")
print(GV.report(t))
