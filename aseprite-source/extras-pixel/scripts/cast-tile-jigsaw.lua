-- Jigsaw hub tile: one big jigsaw piece (knob top + right, notch left + bottom) whose face is a scrap of
-- the picture: sky, sun, cloud, rolling hills and a red-cap cottage. 64x64 icon mode, chunky.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local piece = c:rrect(8, 16, 47, 54, 3)
piece:add(c:ellipse(27.5, 12, 5.5, 5)); piece:add(c:rrect(24, 13, 31, 17, 1))
piece:add(c:ellipse(51, 35, 5, 5.5)); piece:add(c:rrect(45, 31, 49, 39, 1))
piece:cut(c:ellipse(9, 35, 5, 5.5)); piece:cut(c:ellipse(27.5, 55, 5.5, 4.5))
-- picture parts are clipped to the piece and lit as one object (crescent measured on the whole piece)
local hillB = c:ellipse(46, 54, 26, 15):clip(piece)
local hillA = c:ellipse(12, 58, 26, 17):clip(piece)
local sun = c:ellipse(39, 23, 4.5, 4.5)
local cloud = c:ellipse(16, 25, 4, 3):add(c:ellipse(21, 22, 4.5, 4)):add(c:ellipse(26, 24.5, 4, 3)):add(c:rect(14, 25, 28, 27))
local house = c:rect(30, 39, 39, 47)
local roof = c:ellipse(34.5, 39, 8, 5):clip(c:rect(0, 33, 63, 40))
c:build{
  { "piece", piece, GV.ramp("#7fc0de"), { gloss = { 14, 20 }, stitch = { side = "lit" } } },
  { "sun", sun, GV.ramp("#f5cf6a"), { gloss = { 37, 21 }, contact = false, cres = 2, deep = 0 } },
  { "cloud", cloud, GV.ramp("#f1ece0", { pale = true, dot = "#fff3c8" }), { gloss = false, contact = false, cres = 2, deep = 0 } },
  { "hillB", hillB, GV.ramp("#94c46e"), { gloss = false, contact = false, light = piece } },
  { "hillA", hillA, GV.ramp("#5fa24e"), { gloss = false, contact = false, light = piece } },
  { "house", house, GV.ramp("#f1ece0", { pale = true, dot = "#fff3c8" }), { gloss = false, cres = 2, deep = 1 } },
  { "roof", roof, "red", { gloss = { 30, 35 } } },
}
c:fill(c:rect(33, 43, 35, 47), "#8a4f2a"); c:px(33, 43, "#b07a45")                    -- door
c:spot(c:rect(29, 36, 30, 37), "#f1ece0"); c:spot(c:rect(36, 35, 37, 36), "#f1ece0")   -- cap spots
c:fill(c:rect(37, 42, 38, 43), "#7fc0de")                                              -- window
c:seam({ {24, 18}, {31, 18} })                                                         -- knob join
c:button(48, 33)
c:paint({ "g", "g" }, 46, 23, { g = "#f5cf6a" }); c:paint({ "gg" }, 45, 17, { g = "#f5cf6a" })  -- sun rays
local t = K.save(c, "tile-jigsaw")
