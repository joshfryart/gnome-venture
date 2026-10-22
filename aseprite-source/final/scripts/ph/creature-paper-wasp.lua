local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wingR = GV.ramp("#e6f1ec")
-- wings angled slightly up and out
local wl = c:ellipse(19.5, 29, 10.5, 6)
local wr = c:ellipse(43.5, 29, 10.5, 6)
local abd = c:ellipse(31.5, 41, 9.5, 11)
local sting = c:poly({ {29, 51}, {35, 51}, {32, 57} })
local head = c:ellipse(31.5, 23, 10, 8.5)
local antL = c:line({ {27, 16}, {25, 13}, {23, 11} }, 2)
local antR = c:line({ {36, 16}, {38, 13}, {40, 11} }, 2)
local clubL = c:rrect(19, 8, 22, 11, 1)
local clubR = c:rrect(41, 8, 44, 11, 1)
antL:add(clubL); antR:add(clubR)
local p = c:build{
  { "wingL", wl, wingR },
  { "wingR", wr, wingR },
  { "sting", sting, "dusk", { flat = true } },
  { "abd", abd, "gold" },
  { "antL", antL, "dusk", { flat = true } },
  { "antR", antR, "dusk", { flat = true } },
  { "head", head, "dusk" },
}
-- wing veins
c:paint({ "vvvvv....", ".....vvv." }, 13, 29, { v = wingR.shade })
c:paint({ "....vvvvv", ".vvv....." }, 41, 29, { v = wingR.shade })
-- three smile stripes on abdomen
local dk = GV.R.dusk.shade
for _, yc in ipairs({ 36, 42, 48 }) do
  local band = c:ellipse(31.5, yc - 7, 13, 8):cut(c:ellipse(31.5, yc - 9, 13, 8))
  band:clip(abd:shrink(1))
  c:fill(band, dk)
end
-- face patch (gold muzzle)
c:fill(c:ellipse(31.5, 28, 3, 1.5), GV.R.gold.base)
c:px(31, 28, GV.R.gold.gloss)
c:eye(24, 20); c:eye(34, 20)
c:ground(31.5, 55, 12, 1.5)
local t = c:save(O .. "aseprite/ph/creature-paper-wasp.aseprite", O .. "png/ph/creature-paper-wasp.png")
print(GV.report(t))
