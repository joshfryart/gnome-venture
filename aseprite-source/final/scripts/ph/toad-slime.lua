-- toad-slime: a fat glossy dollop of muddy toad slime, oozing in thick drips
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.ramp("#a4b86a")            -- moss family, yellow-olive slime
-- round dollop with three thick drips sagging off the bottom edge
local glob = c:ellipse(31.5, 29, 19, 15)
glob:add(c:rrect(14, 34, 19, 44, 2)):add(c:ellipse(16.5, 44, 2.5, 2.5))
glob:add(c:rrect(26, 38, 33, 49, 3)):add(c:ellipse(29.5, 49, 3.5, 3.5))
glob:add(c:rrect(41, 36, 46, 42, 2)):add(c:ellipse(43.5, 42, 2.5, 2.5))
-- a loose drop falling free, lower right
local drop = c:ellipse(46, 52, 3, 3):add(c:poly({ {45, 46}, {47, 46}, {49, 50}, {43, 50} }))
local p = c:build{
  { "drop", drop, R, { gloss = { 45, 51 } } },
  { "glob", glob, R, { gloss = false } },
}
-- enamel gloss: a long curved streak on the lit upper left plus a dot
c:fill(c:line({ {19, 25}, {21, 20}, {25, 17} }, 2), R.gloss)
c:px(28, 16, R.gloss); c:px(29, 16, R.gloss)
c:fill(c:rect(18, 28, 19, 29), R.dot)
-- murky inner pool (translucent slime) low in the dollop
c:fill(c:ellipse(34, 37, 10, 2.5):clip(p.glob.m:shrink(3)), R.shade)
-- clay grains from the toad's coat (diamonds, like its warts)
local grain = { ".w.", "www", ".w." }
c:paint(grain, 38, 23, { w = "#9a6b3f" })
c:paint(grain, 27, 31, { w = "#9a6b3f" })
c:px(44, 31, "#9a6b3f"); c:px(33, 20, "#9a6b3f")
-- bubbles with a gloss pip
c:fill(c:ellipse(43, 25, 2, 2), R.gloss); c:px(42, 24, R.dot)
c:fill(c:ellipse(31, 26, 1.5, 1.5), R.gloss)
c:fill(c:ellipse(23, 34, 1, 1), R.gloss)
local t = c:save(D .. "final/aseprite/ph/toad-slime.aseprite", PNG .. "toad-slime.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
