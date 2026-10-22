local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- soil mound: half dome with flat base
local mound = c:ellipse(32, 46, 22, 14):cut(c:rect(0, 47, 63, 63))
-- worm: bumpy two-hump wave rising out of the mound
local worm = c:line({ {13, 36}, {14, 28}, {17, 20}, {21, 17}, {25, 19}, {28, 24}, {32, 22}, {36, 17}, {40, 17}, {44, 20} }, 6)
worm:add(c:ellipse(46.5, 21, 4.5, 4))
local band = worm:copy():clip(c:rect(27, 0, 31, 63))

local p = c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "worm", worm, "petal" },
  { "band", band, GV.ramp("#f6b8cf"), { gloss = false, contact = false } },
}
-- ring segments across the tube
local inner = worm:shrink(1)
for _, x in ipairs({ 18, 23, 35, 40 }) do
  inner:copy():clip(c:rect(x, 0, x, 63)):each(function(px, py) c:px(px, py, "#b8456f") end)
end
-- soil texture dashes
c:paint({ "dddddd" }, 18, 35, { d = "#4a2c1a" })
c:paint({ "dddddd" }, 34, 39, { d = "#4a2c1a" })
c:paint({ "dddddd" }, 23, 43, { d = "#4a2c1a" })
-- eyes on the raised head
c:eye(44, 18, true); c:eye(48, 18, true)
c:ground(32, 47, 20, 1.5)
local t = c:save(O .. "aseprite/ph/earthworm.aseprite", O .. "png/ph/earthworm.png")
print(GV.report(t))
