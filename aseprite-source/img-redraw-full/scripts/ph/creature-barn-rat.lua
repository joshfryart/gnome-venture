local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur   = GV.ramp("#a38f80")
local cream = GV.ramp("#e6d2ae")
local tailR = GV.ramp("#b79775")
local footR = GV.ramp("#8f7060")
-- tail: leaves body lower right, sweeps right and curls up into a loop
local tail = c:line({ {44,50}, {50,50}, {54,48}, {56,44}, {56,40}, {54,36}, {50,35}, {47,37}, {47,41}, {50,43} }, 3)
local earL = c:ellipse(20, 19, 6, 6)
local earR = c:ellipse(44, 19, 6, 6)
local ears = earL:copy(); ears:add(earR)
local inner = c:ellipse(20, 19, 3, 3); inner:add(c:ellipse(44, 19, 3, 3))
local feet = c:ellipse(23, 54, 6, 3); feet:add(c:ellipse(41, 54, 6, 3))
local body = c:ellipse(32, 44, 14, 11.5)
local belly = c:ellipse(32, 47, 8, 7.5)
local head = c:ellipse(32, 29, 12, 11)
local muzzle = c:ellipse(32, 35, 5, 5)
c:build{
  { "tail",  tail,  tailR, { gloss = false } },
  { "ears",  ears,  fur },
  { "inner", inner, cream, { flat = true } },
  { "feet",  feet,  footR },
  { "body",  body,  fur, { stitch = { side = "lit" } } },
  { "belly", belly, cream, { gloss = false } },
  { "head",  head,  fur },
  { "muzzle", muzzle, cream, { gloss = false } },
}
-- nose
c:paint({ ".nnn.", "nnnnn", ".nnn." }, 30, 31, { n = "#2a1a10" })
c:px(31, 31, "#5e2a3a")
-- mouth
c:paint({ "m.m", ".m." }, 31, 35, { m = "#4a2c1a" })
-- whiskers
local wk = "#4a2c1a"
for x = 15, 22 do c:px(x, 34, wk) end
c:px(22,36,wk); c:px(21,36,wk); c:px(20,37,wk); c:px(19,37,wk); c:px(18,38,wk); c:px(17,38,wk)
for x = 42, 49 do c:px(x, 34, wk) end
c:px(42,36,wk); c:px(43,36,wk); c:px(44,37,wk); c:px(45,37,wk); c:px(46,38,wk); c:px(47,38,wk)
c:eye(23, 24); c:eye(37, 24)
c:ground(32, 57, 15, 1)
local t = c:save(O .. "aseprite/ph/creature-barn-rat.aseprite", O .. "png/ph/creature-barn-rat.png")
print(GV.report(t))
