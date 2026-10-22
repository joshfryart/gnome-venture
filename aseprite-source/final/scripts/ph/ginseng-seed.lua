local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(33, 41, 18, 13)
body:add(c:poly({ { 22, 24 }, { 42, 24 }, { 50, 38 }, { 16, 38 } }))
local tuft = c:poly({ { 22, 10 }, { 28, 13 }, { 32, 8 }, { 37, 13 }, { 43, 9 }, { 40, 18 }, { 25, 18 } })
local neck = c:rrect(26, 15, 38, 24, 2)
local twine = c:rrect(24, 21, 40, 23, 1)
local patch = c:rrect(23, 32, 43, 49, 4)
local p = c:build{
  { "tuft", tuft, "wood" },
  { "body", body, "wood" },
  { "neck", neck, "wood" },
  { "twine", twine, GV.ramp("#d9a660"), { flat = true } },
  { "patch", patch, GV.ramp("#b0bc66"), { gloss = false } },
}
-- twine loose end
c:fill(c:line({ { 40, 23 }, { 42, 26 }, { 42, 28 } }, 1), "#d9a660")
-- root drawing
c:paint({
  "..g...g..",
  "..gg.gg..",
  "...ggg...",
  "..rrrrr..",
  ".rrrrrrr.",
  ".rrrrrrr.",
  "..rrrrr..",
  "..rrrrr..",
  "...rrr...",
  "...rrr...",
  "...r.r...",
  "....r....",
}, 29, 35, { g = "#58a03e", r = "#dfe3b8" })
c:px(31, 39, "#c9b98a"); c:px(34, 42, "#c9b98a")
c:stitch(p.patch.m)
-- weave marks
c:px(18, 40, "#8a4f2a"); c:px(19, 40, "#8a4f2a")
c:px(46, 44, "#8a4f2a"); c:px(47, 44, "#8a4f2a")
c:px(21, 50, "#8a4f2a"); c:px(22, 50, "#8a4f2a")
c:seam({ { 18, 30 }, { 17, 40 }, { 19, 48 } })
c:ground(33, 56, 15, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/ginseng-seed.aseprite", D .. "img-redraw-full/png/ph/ginseng-seed.png")
print(GV.report(t))
