local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sackR = GV.ramp("#d9a660", { shade = "#b07a45", deep = "#8a4f2a" })
local body = c:ellipse(31.5, 41, 19.5, 12.5)
body:add(c:poly({ {26, 22}, {38, 22}, {46, 32}, {17, 32} }))
local frill = c:ellipse(26, 18, 3, 4):add(c:ellipse(31.5, 16, 3, 5)):add(c:ellipse(37, 18, 3, 4))
frill:add(c:rect(24, 18, 39, 23))
local patch = c:rrect(23, 36, 34, 45, 2)
local P = c:build{
  { "frill", frill, sackR, { gloss = false } },
  { "body", body, sackR, { gloss = { 18, 34 }, stitch = { side = "lit" } } },
  { "patch", patch, GV.ramp("#b07a45"), { gloss = false } },
}
-- frill folds
for _, x in ipairs({ 28, 34 }) do for y = 15, 21 do c:px(x, y, "#b07a45") end end
-- cord band across the neck
c:fill(c:rect(25, 23, 38, 24), "#f5cf6a")
for x = 25, 38 do c:px(x, 24, "#e8a317") end
-- bow loops and tails
c:paint({
  ".gggg........gggg.",
  "gg..gg......gg..gg",
  "gg..gg......gg..gg",
  ".gggg........gggg.",
}, 22, 25, { g = "#f5cf6a" })
c:line({ {29, 28}, {28, 33} }, 2)
c:fill(c:line({ {29, 28}, {28, 33} }, 2), "#e8a317")
c:fill(c:line({ {34, 28}, {35, 33} }, 2), "#e8a317")
c:button(30, 24)
-- patch hem stitch
c:seam({ {25, 38}, {32, 38}, {32, 43}, {25, 43}, {25, 38} })
-- belly creases
c:fill(c:line({ {16, 44}, {19, 50} }, 1), "#8a4f2a")
c:fill(c:line({ {47, 44}, {44, 50} }, 1), "#8a4f2a")
c:ground(31.5, 54, 15, 1.5)
local t = c:save(O .. "aseprite/ph/harvest-sack.aseprite", O .. "png/ph/harvest-sack.png")
print(GV.report(t))
