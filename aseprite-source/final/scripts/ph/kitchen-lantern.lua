local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local chim = c:rect(41, 16, 47, 28)
local cap = c:rect(39, 13, 49, 17)
local smoke = c:ellipse(46, 10, 3.5, 2.5):add(c:ellipse(51, 8.5, 2.5, 2))
local walls = c:rect(12, 33, 52, 55)
local roof = c:poly({ {6, 37}, {32, 15}, {59, 37} })
local eave = c:rect(7, 35, 57, 38)
local door = c:rrect(16, 42, 26, 55, 4):cut(c:rect(16, 42, 26, 44)):add(c:ellipse(21, 46, 5, 4.5)):clip(c:rect(16, 41, 26, 55))
local win = c:rect(33, 41, 46, 50)
local lampL = c:rrect(8, 37, 13, 44, 2)
local lampR = c:rrect(51, 37, 56, 44, 2)
local p = c:build{
  { "chim", chim, GV.ramp("#8b8f96") },
  { "cap", cap, GV.ramp("#6a6070"), { flat = true } },
  { "smoke", smoke, GV.ramp("#d6c9b6") , { flat = true } },
  { "walls", walls, GV.ramp("#d9a660") },
  { "roof", roof, "red" },
  { "eave", eave, GV.ramp("#c66b50"), { gloss = false } },
  { "door", door, GV.ramp("#44281c"), { gloss = false } },
  { "win", win, "gold" },
  { "lampL", lampL, "gold", { flat = true } },
  { "lampR", lampR, "gold", { flat = true } },
}
-- plank bands on walls (not over door / window)
local band = c:rect(13, 41, 51, 41):add(c:rect(13, 48, 51, 48))
band:cut(door:grow(1)):cut(win:grow(1))
c:fill(band, "#b07a45")
-- window cross
c:fill(c:rect(39, 42, 40, 49), "#4a2c1a")
c:fill(c:rect(34, 45, 45, 46), "#4a2c1a")
c:px(35, 42, "#fff1c8"); c:px(36, 42, "#fff1c8"); c:px(35, 43, "#fff1c8")
-- door knob
c:fill(c:rect(23, 49, 24, 50), "#e8a317"); c:px(23, 49, "#fff1c8")
-- lamp glow cores
c:fill(c:rect(10, 39, 11, 41), "#fff1c8"); c:fill(c:rect(53, 39, 54, 41), "#fff1c8")
c:seam({ {9, 36}, {55, 36} })
c:ground(32, 57, 22, 1.5)
local t = c:save(O .. "aseprite/ph/kitchen-lantern.aseprite", O .. "png/ph/kitchen-lantern.png")
print(GV.report(t))
