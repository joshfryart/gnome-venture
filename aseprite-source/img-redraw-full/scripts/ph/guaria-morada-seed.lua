local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaves = c:line({{24,33},{15,25}}, 3):add(c:line({{40,33},{49,25}}, 3))
local petals = c:ellipse(25, 24, 6, 5):add(c:ellipse(39, 24, 6, 5)):add(c:ellipse(32, 18.5, 5.5, 5.5))
local p = c:build{
  { "leaves", leaves, "#7ab55c", { flat = true } },
  { "petals", petals, "#9a78c8" },
  { "lip", c:ellipse(32, 29, 6, 3.5), "#e46a9b" },
  { "crate", c:rect(15, 36, 49, 52), "#b07a45", { gloss = false } },
  { "posts", c:rect(15, 35, 19, 52):add(c:rect(45, 35, 49, 52)), "#8a4f2a", { gloss = false } },
  { "rim", c:rect(13, 32, 51, 36), "#d9a660" },
}
c:fill(c:rect(31, 22, 33, 24), "#e8a317")
for _, y in ipairs({41, 46}) do c:fill(c:rect(20, y, 44, y + 1), "#8a4f2a") end
for _, xy in ipairs({{16,38},{46,38},{16,49},{46,49}}) do c:fill(c:rect(xy[1], xy[2], xy[1]+1, xy[2]+1), "#5e2f1e") end
local t = c:save(O .. "aseprite/ph/guaria-morada-seed.aseprite", O .. "png/ph/guaria-morada-seed.png")
print(GV.report(t))
