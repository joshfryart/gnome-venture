-- camp-kit: a strapped felt bedroll with a lidded tin billy lashed on top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local TIN = GV.ramp("#c9c5bc")           -- stone family, pale tin
-- tin billy sitting on the roll (its foot hidden behind the roll)
local billy = c:rrect(29, 15, 46, 32, 2)
local lid = c:rrect(27, 12, 48, 16, 2)
local knob = c:rrect(35, 8, 40, 12, 1)
-- the roll: a fat cylinder lying on its side, end cap at the left
local roll = c:rrect(9, 27, 55, 49, 10)
local cap = c:ellipse(15, 38, 6.5, 11)
-- straps over the roll
local s1 = c:rect(22, 26, 25, 50)
local s2 = c:rect(42, 26, 45, 50)
local whole = roll:copy():add(billy)
local p = c:build{
  { "knob",  knob,  TIN, { flat = true } },
  { "billy", billy, TIN, { gloss = { 32, 20 } } },
  { "lid",   lid,   GV.ramp("#8b8f96"), { light = billy, gloss = false } },
  { "roll",  roll,  "red", { gloss = false, stitch = { side = "lit" } } },
  { "cap",   cap,   "red", { light = roll, gloss = false } },
  { "s1",    s1:clip(roll:grow(1)), "wood", { light = roll, gloss = false } },
  { "s2",    s2:clip(roll:grow(1)), "wood", { light = roll, gloss = false } },
}
-- rolled cloth spiral on the end cap
c:fill(c:ellipse(15, 38, 4, 7):edge(), "#ae2a2a")
c:fill(c:ellipse(15, 38, 1.5, 3):edge(), "#6b1b2c")
-- cloth gloss on the roll, lit upper left between cap and strap
c:fill(c:rect(28, 31, 32, 31), "#ff9158"); c:px(27, 32, "#ff9158"); c:px(35, 31, "#ffc27a")
-- hem seam where the outer flap wraps, button at its head
c:seam({ {27, 45}, {41, 45} })
c:button(46, 43)
-- tin dents / billy rim line
c:fill(c:rect(30, 21, 45, 21):clip(p.billy.m:shrink(1)), "#8b8f96")
-- strap buckles
c:fill(c:rect(22, 36, 25, 39), "#e8a317"); c:fill(c:rect(23, 37, 24, 38), "#8a4f2a")
c:fill(c:rect(42, 36, 45, 39), "#e8a317"); c:fill(c:rect(43, 37, 44, 38), "#8a4f2a")
local t = c:save(D .. "final/aseprite/ph/camp-kit.aseprite", PNG .. "camp-kit.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
