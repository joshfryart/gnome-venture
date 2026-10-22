local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-hybrid/"

local glass = c:rrect(18, 22, 46, 54, 7)
local fill  = c:rrect(20, 29, 44, 52, 5)
local label = c:rrect(22, 36, 42, 45, 1)
local lid   = c:rrect(17, 13, 47, 24, 4)

c:build{
  { "glass", glass, GV.ramp("#a9d6ea", { rim = "#8fcbd8" }), { gloss = { 22, 26 } } },
  { "fill",  fill,  GV.ramp("#d6322b"), { gloss = { 23, 31 }, light = glass } },
  { "label", label, "cream", { gloss = false, light = glass } },
  { "lid",   lid,   "gold",  { gloss = { 21, 15 } } },
}
-- lid band seam
c:seam({ {19, 21}, {45, 21} })
-- label text ticks
c:paint({ "xx.xxx.xx.xxxx",
          "..............",
          "xxx.xx.xxx.xx." }, 25, 39, { x = "#2a1a10" })
c:ground(32, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/apple-chutney.aseprite", O .. "png/ph/apple-chutney.png")
print(GV.report(t))
