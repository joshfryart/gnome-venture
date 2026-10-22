local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local log = c:rrect(5, 24, 46, 48, 11)
local disc = c:ellipse(47, 36, 9, 12)
local p = c:build{
  { "log", log, GV.ramp("#a8582f") },
  { "disc", disc, GV.ramp("#d9a660"), { gloss = { 42, 28 }, cres = 2, deep = 1 } },
}
-- bark band dashes (curved hints of rings)
local D = "#5e2f1e"
for _, x in ipairs({ 13, 23, 33 }) do
  c:fill(c:line({ {x,28}, {x-1,33} }, 2), D)
  c:fill(c:line({ {x-1,38}, {x,44} }, 2), D)
end
c:fill(c:line({ {18,34}, {18,37} }, 2), D)
c:fill(c:line({ {28,33}, {28,36} }, 2), D)
-- end growth rings
local ring = c:ellipse(47, 36, 5, 7)
c:fill(ring:copy():cut(c:ellipse(47, 36, 4, 6)), "#b07a45")
c:fill(c:rect(46, 35, 47, 36), "#8a4f2a")
local t = c:save(O .. "aseprite/ph/palm-trunk.aseprite", O .. "png/ph/palm-trunk.png")
print(GV.report(t))
