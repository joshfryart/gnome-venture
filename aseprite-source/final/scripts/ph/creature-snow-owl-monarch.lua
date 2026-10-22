local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tufts = c:poly({ {16,27}, {19,13}, {29,21} }):add(c:poly({ {48,27}, {45,13}, {35,21} }))
local feet = c:rrect(24, 51, 28, 56, 1):add(c:rrect(36, 51, 40, 56, 1))
local body = c:ellipse(32, 39, 16, 15.5):add(c:ellipse(32, 44, 9.5, 10.5))
local wingL = c:ellipse(17, 42, 5, 10):add(c:ellipse(15, 46, 3.5, 6))
local wingR = c:ellipse(47, 42, 5, 10):add(c:ellipse(49, 46, 3.5, 6))
local faceL = c:ellipse(24, 28, 7, 7)
local faceR = c:ellipse(40, 28, 7, 7)
local rimL = c:ellipse(24, 28, 3.8, 3.8)
local rimR = c:ellipse(40, 28, 3.8, 3.8)
local beak = c:poly({ {29,31}, {36,31}, {32,37} })
local points = c:poly({ {22,20}, {24,10}, {29,20} })
  :add(c:poly({ {27,20}, {32,7}, {38,20} }))
  :add(c:poly({ {35,20}, {40,10}, {43,20} }))
  :add(c:ellipse(24, 10, 1.5, 1.5)):add(c:ellipse(40, 10, 1.5, 1.5)):add(c:ellipse(32, 7, 1.5, 1.5))
local band = c:rrect(22, 17, 41, 21, 1)

local snow = GV.ramp("#f8eed2")
local wing = GV.ramp("#b8d8d2")
c:build{
  { "tufts", tufts, GV.ramp("#e6d2ae") },
  { "feet", feet, "gold", { flat = true } },
  { "body", body, snow, { stitch = { side = "lit" } } },
  { "wingL", wingL, wing },
  { "wingR", wingR, wing },
  { "faceL", faceL, snow, { gloss = false } },
  { "faceR", faceR, snow, { gloss = false } },
  { "rimL", rimL, "gold", { gloss = false, flat = true } },
  { "rimR", rimR, "gold", { gloss = false, flat = true } },
  { "beak", beak, "gold", { flat = true } },
  { "points", points, "gold" },
  { "band", band, GV.ramp("#b07a10") },
}
-- chest chevrons (snowy owl barring)
local m = { "b...b", ".b.b.", "..b.." }
c:paint({ "b.b", ".b." }, 28, 41, { b = "#8fb0b4" })
c:paint({ "b.b", ".b." }, 34, 41, { b = "#8fb0b4" })
c:paint({ "b.b", ".b." }, 31, 46, { b = "#8fb0b4" })
c:paint({ "b.b", ".b." }, 25, 46, { b = "#8fb0b4" })
c:paint({ "b.b", ".b." }, 37, 46, { b = "#8fb0b4" })
-- crown jewels
c:spot(c:ellipse(32, 14, 1.5, 1.5), "#d6322b", "#ff9158")
c:seam({ {23, 19}, {40, 19} })
c:eye(22, 26); c:eye(38, 26)
local t = c:save(O .. "aseprite/ph/creature-snow-owl-monarch.aseprite", O .. "png/ph/creature-snow-owl-monarch.png")
print(GV.report(t))
