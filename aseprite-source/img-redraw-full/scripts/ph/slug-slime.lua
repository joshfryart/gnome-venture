local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- teardrop glob: round belly plus a curved pointed top
local glob = c:ellipse(31.5, 40, 15, 12)
glob:add(c:poly({ {32, 9}, {35, 14}, {40, 22}, {45, 31}, {47, 37}, {16, 37}, {18, 31}, {23, 22}, {28, 14}, {31, 9} }))
local puddle = c:ellipse(31.5, 52, 24, 5)
-- stretched drip thread curling off the tip
local thread = c:line({ {31, 10}, {28, 7}, {24, 7}, {22, 10} }, 2)
thread:add(c:ellipse(22, 13, 2, 2.5))
local p = c:build{
  { "puddle", puddle, GV.ramp("#6a9a3a") },
  { "thread", thread, GV.ramp("#a4b86a"), { flat = true } },
  { "glob", glob, "moss", { gloss = { 23, 26 } } },
}
-- darker inner pool near the bottom
c:fill(c:ellipse(32, 46, 9, 2.5), "#4a8a3e")
-- bubbles
c:fill(c:ellipse(39, 37, 2, 2), "#c8d77a"); c:px(38, 36, "#fff1c8")
c:fill(c:ellipse(27, 33, 1.5, 1.5), "#c8d77a")
c:fill(c:ellipse(35, 28, 1, 1), "#c8d77a")
local t = c:save(O .. "aseprite/ph/slug-slime.aseprite", O .. "png/ph/slug-slime.png")
print(GV.report(t))
