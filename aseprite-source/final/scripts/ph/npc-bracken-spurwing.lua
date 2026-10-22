local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- coat shoulders (bleed off bottom)
local coat = c:ellipse(39.5, 104, 34, 30):cut(c:rect(0, 0, 79, 73))
-- antennae: curved stalks with 4x4 clubs
local antL = c:line({ {31, 34}, {28, 26}, {23, 20}, {18, 18} }, 2)
antL:add(c:rrect(14, 15, 18, 19, 1))
local antR = c:line({ {48, 34}, {51, 26}, {56, 20}, {61, 18} }, 2)
antR:add(c:rrect(61, 15, 65, 19, 1))
-- round brown head
local head = c:ellipse(39.5, 50, 22, 21)
-- curling mandible arms at the lower cheeks
local manL = c:line({ {22, 58}, {17, 64}, {16, 70}, {19, 74}, {24, 73} }, 3)
local manR = c:line({ {57, 58}, {62, 64}, {63, 70}, {60, 74}, {55, 73} }, 3)
-- purple captain's band across the brow
local band = c:line({ {16, 43}, {26, 38}, {39, 36}, {52, 38}, {63, 43} }, 5):clip(head:grow(1))
local knot = c:ellipse(56, 40, 3.5, 3.5)
local tails = c:poly({ {58, 42}, {62, 41}, {67, 50}, {63, 51} })
tails:add(c:poly({ {57, 43}, {60, 44}, {61, 53}, {58, 53} }))
-- shirt V and collar
local collar = c:poly({ {27, 72}, {40, 90}, {53, 72} })
local shirt = c:poly({ {31, 72}, {40, 85}, {49, 72} })

local dark = GV.ramp("#5e2f1e")
c:build{
  { "coat",  coat, "#d6322b", { stitch = { side = "lit" } } },
  { "collar", collar, "#9c2a1e", { flat = true } },
  { "shirt", shirt, "cream", { flat = true } },
  { "antL",  antL, dark, { flat = true } },
  { "antR",  antR, dark, { flat = true } },
  { "head",  head, "#8c4a1a" },
  { "manL",  manL, "#b6814d", { flat = true } },
  { "manR",  manR, "#b6814d", { flat = true } },
  { "tails", tails, "#4e3a8a", { flat = true } },
  { "band",  band, "#7a5cc0", { gloss = false } },
  { "knot",  knot, "#4e3a8a", { flat = true } },
}
c:seam({ {12, 82}, {26, 76} }); c:seam({ {54, 76}, {68, 82} })
c:button(38, 76)
c:eye(29, 46); c:eye(46, 46)
c:paint({ "u.......u", ".uuuuuuu." }, 35, 59, { u = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/npc-bracken-spurwing.aseprite", O .. "png/ph/npc-bracken-spurwing.png")
print(GV.report(t))
