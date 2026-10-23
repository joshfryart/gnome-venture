-- toad-slime: a fat glossy glob of muddy toad slime sliding off into a hanging drip
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.ramp("#a4b86a")            -- moss family, yellow-olive slime
-- squat wobbly dome, flattened underside with a short drip and a long one
local glob = c:ellipse(30.5, 28, 20, 15):cut(c:rect(0, 37, 63, 63))
glob:add(c:rrect(11, 30, 50, 39, 5))
glob:add(c:ellipse(19, 40, 2.5, 3))      -- short drip, lower left
local strand = c:line({ {37, 38}, {38, 43}, {38, 46} }, 3)
local drop = c:ellipse(38, 51, 4.5, 4.5):add(c:poly({ {36, 45}, {41, 45}, {43, 48}, {34, 48} }))
local p = c:build{
  { "drop",   drop,   R, { gloss = { 36, 49 } } },
  { "strand", strand, R, { flat = true, contact = false } },
  { "glob",   glob,   R, { gloss = { 19, 20 } } },
}
-- murky inner pool (translucent slime) near the bottom
c:fill(c:ellipse(33, 34, 11, 2.5):clip(p.glob.m:shrink(3)), R.shade)
-- clay grains from the toad's coat (diamonds, like its warts)
local grain = { ".w.", "www", ".w." }
c:paint(grain, 38, 22, { w = "#9a6b3f" })
c:paint(grain, 26, 30, { w = "#9a6b3f" })
c:px(44, 30, "#9a6b3f"); c:px(32, 19, "#9a6b3f")
-- bubbles with a gloss pip
c:fill(c:ellipse(43, 25, 2, 2), R.gloss); c:px(42, 24, R.dot)
c:fill(c:ellipse(30, 25, 1.5, 1.5), R.gloss)
c:fill(c:ellipse(22, 31, 1, 1), R.gloss)
local t = c:save(D .. "final/aseprite/ph/toad-slime.aseprite", PNG .. "toad-slime.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
