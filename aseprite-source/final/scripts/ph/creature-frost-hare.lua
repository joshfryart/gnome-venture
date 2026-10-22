local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local fur   = GV.ramp("#b8d8d2")
local blue  = GV.ramp("#3f93b2")
local cream = GV.ramp("#f8eed2")

-- tall ears, slightly splayed
local earL = c:poly({ {23,24}, {21,16}, {22,11}, {25,9}, {28,11}, {29,17}, {28,24} })
local earR = c:poly({ {35,24}, {35,17}, {36,11}, {39,9}, {42,11}, {43,16}, {41,24} })
local inL  = c:poly({ {24,22}, {23,15}, {25,12}, {27,15}, {27,22} })
local inR  = c:poly({ {37,22}, {37,15}, {39,12}, {41,15}, {40,22} })

local p = c:build{
  { "tail",  c:ellipse(44.5, 45, 3.5, 3.5), blue },
  { "earL",  earL, fur },
  { "earR",  earR, fur },
  { "inL",   inL, "petal", { flat = true, contour = false, contact = false } },
  { "inR",   inR, "petal", { flat = true, contour = false, contact = false } },
  { "feet",  c:ellipse(24, 50, 5, 2.5):add(c:ellipse(39, 50, 5, 2.5)), blue },
  { "body",  c:ellipse(31.5, 42, 12, 9.5), fur },
  { "belly", c:ellipse(31.5, 44.5, 7, 6), cream, { contour = false, gloss = false } },
  { "head",  c:ellipse(31.5, 28, 11, 9.5), fur },
  { "muzzle",c:ellipse(31.5, 32.5, 5, 3.5), cream, { contour = false, gloss = false, contact = false } },
}

c:eye(23, 24); c:eye(35, 24)
-- nose and smile
c:paint({ "nnn", ".n." }, 30, 30, { n = "#2a1a10" })
c:paint({ "u.u", ".u." }, 30, 33, { u = "#4a2c1a" })
-- whiskers out past the cheeks
c:paint({ "www.....", "...wwwww" }, 16, 31, { w = "#4a2c1a" })
c:paint({ "...wwwww", "www....." }, 16, 34, { w = "#4a2c1a" })
c:paint({ ".....www", "wwwww..." }, 39, 31, { w = "#4a2c1a" })
c:paint({ "wwwww...", ".....www" }, 39, 34, { w = "#4a2c1a" })

local t = c:save(O .. "aseprite/ph/creature-frost-hare.aseprite", O .. "png/ph/creature-frost-hare.png")
print(GV.report(t))
