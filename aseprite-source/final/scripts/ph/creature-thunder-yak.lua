local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local hair = GV.ramp("#5e3420")
local fur  = GV.ramp("#8c4a1a")
local horn = GV.ramp("#4c4658")
-- tail with tuft
local tail = c:line({ {46, 42}, {50, 40}, {52, 36} }, 3)
tail:add(c:ellipse(51.5, 33, 2.5, 3))
-- hair slabs
local slabs = c:ellipse(18, 27, 5, 9):add(c:ellipse(46, 27, 5, 9))
-- horns: C-curls out and hooking down
local hornL = c:line({ {24, 15}, {19, 11}, {14, 11} }, 4)
hornL:add(c:line({ {13, 12}, {10, 16}, {10, 21}, {13, 24} }, 3))
hornL:add(c:rect(14, 23, 15, 25))
local hornR = c:mask()
hornL:each(function(x, y) hornR:set(63 - x, y) end)
local horns = hornL:copy():add(hornR)
-- feet, body, head
local feet = c:ellipse(23, 48, 5, 3.5):add(c:ellipse(41, 48, 5, 3.5))
local body = c:ellipse(32, 39, 17, 11)
local head = c:ellipse(32, 24, 12, 12)
local muzzle = c:ellipse(32, 30, 8, 5)
local p = c:build{
  { "tail",  tail,  hair, { flat = true } },
  { "slabs", slabs, hair },
  { "horns", horns, horn, { gloss = false } },
  { "feet",  feet,  hair },
  { "body",  body,  fur, { stitch = { side = "lit" } } },
  { "head",  head,  fur },
  { "muzzle", muzzle, "#a5663a", { gloss = false, contact = false } },
}
-- forelock tuft between horns
c:paint({ ".hh.h.", "hhhhhh", ".hhhh." }, 29, 12, { h = hair.base })
-- eyes
c:eye(23, 19); c:eye(36, 19)
-- nostrils and smile
c:paint({ "n...n", "n...n" }, 30, 28, { n = "#2a1a10" })
c:paint({ "m.....m", ".mmmmm." }, 29, 32, { m = "#4a2c1a" })
c:ground(32, 52, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-thunder-yak.aseprite", O .. "png/ph/creature-thunder-yak.png")
print(GV.report(t))
