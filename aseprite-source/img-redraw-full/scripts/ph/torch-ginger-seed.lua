local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tuft = c:ellipse(27.5, 16, 3.5, 4):add(c:ellipse(36.5, 16, 3.5, 4))
local neck = c:poly({ {28, 18}, {37, 18}, {40, 31}, {25, 31} })
local body = c:ellipse(32, 40, 18, 12.5)
local band = c:rect(26, 24, 39, 26)
local knot = c:rrect(30, 22, 34, 27, 1)
local rhiz = c:poly({ {27, 33}, {38, 33}, {36, 42}, {33, 51}, {32, 51}, {29, 42} })
local leafL = c:ascii({
  "xx....",
  "xxxx..",
  ".xxxxx",
  "..xxxx",
  "....xx",
}, 25, 28)
local leafR = c:ascii({
  "....xx",
  "..xxxx",
  "xxxxx.",
  "xxxx..",
  "xx....",
}, 34, 28)

c:build{
  { "tuft", tuft, "#ecc58a", { gloss = false } },
  { "neck", neck, "#d9a660", { gloss = false } },
  { "body", body, "#d9a660", { stitch = true } },
  { "rhiz", rhiz, "#c9a96e" },
  { "leafL", leafL, "#7ab55c", { gloss = false } },
  { "leafR", leafR, "#7ab55c", { gloss = false } },
  { "band", band, "#a8582f", { flat = true } },
  { "knot", knot, "#a8582f", { gloss = false } },
}
-- string tails
c:fill(c:line({ {28, 27}, {24, 32} }, 2), "#a8582f")
c:fill(c:line({ {36, 27}, {40, 32} }, 2), "#a8582f")
-- rhizome ring dashes
c:paint({ "dd" }, 30, 38, { d = "#2a1a10" })
c:paint({ "dd" }, 33, 44, { d = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/torch-ginger-seed.aseprite", O .. "png/ph/torch-ginger-seed.png")
print(GV.report(t))
