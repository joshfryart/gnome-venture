-- ph/banana-seed (REDO): drawstring cloth pouch with a stitched banana patch
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cloth = "moss"
local seedR = GV.ramp("#6b3a22")

-- belly: plump, slightly pear-shaped
local belly = c:ellipse(31.5, 38, 19, 13.5)
belly:add(c:ellipse(31.5, 33, 15, 10))
-- gathered neck
local neck = c:poly({ {25, 17}, {39, 17}, {42, 27}, {22, 27} })
-- frill above the tie, flaring with a scalloped top
local frill = c:poly({ {21, 10}, {43, 10}, {38, 17}, {26, 17} })
frill:add(c:ellipse(23.5, 10.5, 3, 2.5)); frill:add(c:ellipse(29.5, 9.5, 3, 2.5))
frill:add(c:ellipse(35.5, 9.5, 3, 2.5)); frill:add(c:ellipse(40.5, 10.5, 3, 2.5))
-- cord band, knot, tassels
local cord = c:rrect(23, 16, 40, 19, 1)
local knot = c:ellipse(41, 18.5, 2.5, 2.5)
local str1 = c:line({ {42, 21}, {45, 28} }, 2)
local str2 = c:line({ {40, 21}, {39, 29} }, 2)
local tas1 = c:rrect(44, 27, 47, 31, 1)
local tas2 = c:rrect(37, 28, 40, 32, 1)
-- banana patch: a smiling crescent
local banana = c:ellipse(31.5, 34, 13, 11):cut(c:ellipse(31.5, 27.5, 14, 10))
banana:clip(c:rect(0, 32, 63, 63))
-- seeds spilling out at the base
local s1 = c:ellipse(11.5, 51, 2.5, 1.5)
local s2 = c:ellipse(17.5, 53.5, 2.5, 1.5)

local p = c:build{
  { "frill",  frill,  cloth, { gloss = false } },
  { "neck",   neck,   cloth, { gloss = false } },
  { "belly",  belly,  cloth, { light = belly:copy():add(neck), stitch = { side = "lit" } } },
  { "banana", banana, "gold", { gloss = false } },
  { "cord",   cord,   "gold", { gloss = false } },
  { "str1",   str1,   "gold", { flat = true } },
  { "str2",   str2,   "gold", { flat = true } },
  { "tas1",   tas1,   "gold", { flat = true } },
  { "tas2",   tas2,   "gold", { flat = true } },
  { "knot",   knot,   "gold", { gloss = false } },
  { "s1",     s1,     seedR, { flat = true } },
  { "s2",     s2,     seedR, { flat = true } },
}

-- gather pleats on the frill and neck
for _, x in ipairs({ 27, 32, 37 }) do
  c:px(x, 12, GV.R.moss.shade); c:px(x, 13, GV.R.moss.shade); c:px(x, 14, GV.R.moss.shade)
end
for _, x in ipairs({ 28, 32, 36 }) do
  c:px(x, 21, GV.R.moss.shade); c:px(x, 22, GV.R.moss.shade); c:px(x, 23, GV.R.moss.shade)
end
-- banana: stem nub at left tip, dark tip at right, running stitch along its middle
c:paint({ "ss", "ss" }, 18, 32, { s = "#5e2f1e" })
c:paint({ "tt", "tt" }, 44, 32, { t = "#5e2f1e" })
for _, q in ipairs({ {23, 39}, {26, 41}, {29, 42}, {34, 42}, {37, 41}, {40, 39} }) do
  c:px(q[1], q[2], "#b8661a")
end
c:px(22, 36, "#fff1c8"); c:px(23, 37, "#fff1c8")
-- tassel fringe lines
c:px(45, 31, "#b8661a"); c:px(38, 32, "#b8661a")
-- seed glints
c:px(11, 50, "#a8582f"); c:px(16, 53, "#a8582f")

c:ground(31.5, 52, 15, 1.5)
local t = c:save(D .. "test100/aseprite/ph/banana-seed.aseprite", D .. "test100/png/ph/banana-seed.png")
print(GV.report(t))
