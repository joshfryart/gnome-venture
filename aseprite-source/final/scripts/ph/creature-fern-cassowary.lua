local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dark = GV.ramp("#3e2f66")
local gold = "gold"

-- legs with splayed toes
local legs = c:rect(25, 48, 27, 55):add(c:rect(37, 48, 39, 55))
legs:add(c:rect(22, 55, 29, 56)):add(c:rect(35, 55, 42, 56))

local body  = c:ellipse(32, 37, 16, 14)
local belly = c:ellipse(32, 43, 9, 7):clip(body)
local wingL = c:poly({ {19, 28}, {23, 31}, {22, 46}, {17, 52}, {13, 48}, {13, 36} })
local wingR = c:poly({ {45, 28}, {41, 31}, {42, 46}, {47, 52}, {51, 48}, {51, 36} })
local head  = c:ellipse(32, 21, 9, 8.5)
local wattle = c:poly({ {27, 26}, {38, 26}, {34, 36}, {31, 36} })
local casque = c:poly({ {27, 15}, {28, 10}, {30, 7}, {35, 7}, {37, 10}, {38, 15} })

local p = c:build{
  { "legs",   legs,   gold, { flat = true } },
  { "body",   body,   dark, { stitch = { side = "lit" } } },
  { "belly",  belly,  "#8f7060" },
  { "wingL",  wingL,  dark },
  { "wingR",  wingR,  dark },
  { "head",   head,   dark },
  { "wattle", wattle, "water" },
  { "casque", casque, gold },
}

c:eye(24, 18); c:eye(35, 18)
-- small beak tip between eyes
c:paint({ "gg", "gg" }, 31, 23, { g = "#e8a317" })

c:ground(32, 56.5, 14, 1)
local t = c:save(O .. "aseprite/ph/creature-fern-cassowary.aseprite", O .. "png/ph/creature-fern-cassowary.png")
print(GV.report(t))
