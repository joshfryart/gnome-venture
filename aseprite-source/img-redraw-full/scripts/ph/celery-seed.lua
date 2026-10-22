local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(31.5, 39, 18, 14)
local rim  = c:rrect(18, 23, 45, 28, 2)
local lid  = c:ellipse(31.5, 24, 12, 10):cut(c:rect(0, 25, 63, 63))
lid:add(c:rrect(19, 21, 44, 25, 1))
local knob = c:ellipse(31.5, 11, 3.5, 3)
local labelB = c:ellipse(31.5, 40, 8.5, 7.5)
local label  = c:ellipse(31.5, 40, 7.5, 6.5)

local p = c:build{
  { "body",  body,  GV.ramp("#c9c5bc") },
  { "rim",   rim,   GV.ramp("#8b8f96"), { gloss = false } },
  { "lid",   lid,   GV.ramp("#a4b86a") },
  { "knob",  knob,  GV.ramp("#4a8a3e") },
  { "lborder", labelB, GV.ramp("#a4b86a"), { flat = true, solid = false, contour = false, contact = false } },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false, contour = false, contact = false, cres = 1 } },
}
-- celery seed bean, tilted
c:paint({
  ".......gg",
  ".....gggg",
  "...ggbbgg",
  ".ggbbbgg.",
  "ggbbbgg..",
  "gbbgg....",
  "dgg......",
}, 27, 37, { g = "#b0bc66", b = "#58a03e", d = "#2e5a2c" })
c:seam({ {20, 25}, {43, 25} })

local t = c:save(O .. "aseprite/ph/celery-seed.aseprite", O .. "png/ph/celery-seed.png")
print(GV.report(t))
