local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local water = c:rrect(12, 44, 51, 50, 3)
for _, x in ipairs({ 16, 26, 36, 46 }) do water:add(c:ellipse(x, 43, 4, 4)) end
local p = c:build{
  { "tail", c:line({ {20, 37}, {15, 35}, {12, 31} }, 4), "#a8582f" },
  { "body", c:ellipse(28, 37, 14, 7), "wood" },
  { "chest", c:ellipse(37.5, 33, 4, 3.5), "#f9d49c", { gloss = false } },
  { "ear", c:ellipse(36, 20, 2.5, 2.5), "#8a4f2a", { gloss = false } },
  { "head", c:ellipse(41, 26, 7.5, 7), "wood" },
  { "muzzle", c:ellipse(46.5, 29.5, 4.5, 3.5), "#f9d49c", { gloss = false } },
  { "paw", c:ellipse(43, 38, 2.5, 2.5), "wood", { gloss = false } },
  { "water", water, "water" },
}
-- crest highlights
for _, x in ipairs({ 16, 26, 36, 46 }) do
  c:paint({ ".hh.", "h..h" }, x - 2, 40, { h = "#8fcbd8" })
end
c:paint({ "nnn", "nnn", ".n." }, 48, 26, { n = "#2a1a10" })
c:paint({ "m.m", ".m." }, 45, 31, { m = "#8a4234" })
c:eye(39, 23, true)
local t = c:save(O .. "aseprite/ico/ico-otter.aseprite", O .. "png/ico/ico-otter.png")
print(GV.report(t))
