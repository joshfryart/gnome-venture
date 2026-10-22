local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local violet = GV.ramp("#7a5cc0")
local body = c:ellipse(31.5, 38, 16, 15):add(c:ellipse(31.5, 30, 14, 10))
local crest = c:poly({ {26,21}, {18,14}, {21,14}, {28,19} }):add(c:poly({ {37,19}, {43,14}, {46,14}, {38,21} }))
local wingL = c:ellipse(15.5, 37, 4, 6):add(c:ellipse(13.5, 44, 3.5, 5))
local wingR = c:ellipse(47.5, 37, 4, 6):add(c:ellipse(49.5, 44, 3.5, 5))
local points = c:poly({ {24,19}, {26,10}, {29,19} }):add(c:poly({ {27,19}, {31.5,8}, {36,19} })):add(c:poly({ {34,19}, {37,10}, {39,19} }))
local beak = c:poly({ {29,27}, {35,27}, {36,29}, {35,32}, {33,36}, {32,33}, {30,31}, {29,30} })
local p = c:build{
  { "crest", crest, "#4e3a8a", { flat = true } },
  { "footL", c:rrect(24, 49, 27, 54, 1), "gold" },
  { "footR", c:rrect(36, 49, 39, 54, 1), "gold" },
  { "body", body, violet },
  { "chest", c:ellipse(31.5, 43, 9, 8.5), "#c3b2ea", { stitch = { side = "lit" } } },
  { "wingL", wingL, violet, { gloss = false } },
  { "wingR", wingR, violet, { gloss = false } },
  { "points", points, "gold", { gloss = false } },
  { "band", c:rect(24, 18, 39, 21), GV.ramp("#d0901a"), { gloss = false } },
  { "beak", beak, "gold" },
}
c:seam({ {25,19}, {39,19} })
c:paint({ ".r.", "rrr", ".r." }, 30, 13, { r = "#d6322b" })
c:px(31, 13, "#ff9158")
c:line({ {21,23}, {27,26} }, 2):each(function(x, y) c:px(x, y, "#2a1a10") end)
c:line({ {41,23}, {35,26} }, 2):each(function(x, y) c:px(x, y, "#2a1a10") end)
c:eye(22, 27); c:eye(36, 27)
c:ground(31.5, 54, 12, 1.5)
local t = c:save(O .. "aseprite/ph/creature-storm-eagle.aseprite", O .. "png/ph/creature-storm-eagle.png")
print(GV.report(t))
