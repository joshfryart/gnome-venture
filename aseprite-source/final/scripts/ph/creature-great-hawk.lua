local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local disc  = c:ellipse(32, 34, 17, 17)
local feet  = c:rrect(24, 48, 28, 52, 1):add(c:rrect(36, 48, 40, 52, 1))
local body  = c:ellipse(32, 36, 16, 15)
local chest = c:ellipse(32, 42, 8.5, 8):clip(body)
local wingL = c:poly({ {14, 31}, {19, 28}, {23, 34}, {23, 45}, {19, 50}, {15, 46}, {13, 38} })
local wingR = c:poly({ {51, 31}, {46, 28}, {42, 34}, {42, 45}, {46, 50}, {50, 46}, {52, 38} })
local beak  = c:ascii({
  "#######",
  "#######",
  "#######",
  ".######",
  "..#####",
  "...###.",
  "...###.",
  "...##..",
  "...#...",
}, 29, 28)
local crown = c:ascii({
  "........###........",
  "##......###......##",
  "##...#..###..#...##",
  "##..###.###.###..##",
  "###.###.###.###.###",
  "###.###########.###",
  "###################",
  "###################",
  "###################",
}, 23, 10)
local band = c:rect(22, 18, 42, 21)

local p = c:build{
  { "disc",  disc,  "#f8db8c", { gloss = false } },
  { "feet",  feet,  "gold", { flat = true } },
  { "body",  body,  "#a5663a" },
  { "chest", chest, "#dcb06a", { stitch = true } },
  { "wingL", wingL, "#8c4a1a", { light = body } },
  { "wingR", wingR, "#8c4a1a", { light = body } },
  { "crown", crown, "gold" },
  { "band",  band,  "#b07a10" },
  { "beak",  beak,  "gold" },
}
c:seam({ {22, 20}, {42, 20} })
c:paint({ ".r.", "rRr", ".r." }, 31, 18, { r = "#d6322b", R = "#ff9158" })
c:eye(23, 26); c:eye(36, 26)
c:fill(c:line({ {21, 23}, {28, 25} }, 2), "#2a1a10")
c:fill(c:line({ {43, 23}, {36, 25} }, 2), "#2a1a10")
local t = c:save(O .. "aseprite/ph/creature-great-hawk.aseprite", O .. "png/ph/creature-great-hawk.png")
print(GV.report(t))
