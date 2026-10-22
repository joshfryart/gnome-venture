local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- shapes
local disc   = c:ellipse(40, 50, 36, 36)
local jacket = c:ellipse(40, 100, 34, 24):cut(c:rect(0, 0, 79, 75))
local scarf  = c:line({ {28, 79}, {40, 84}, {52, 79} }, 6)
local tail   = c:poly({ {46, 82}, {53, 82}, {54, 97}, {44, 97} })
local shell  = c:ellipse(40, 51, 31, 35):cut(c:rect(0, 52, 79, 99))
local head   = c:ellipse(40, 61, 18, 16)
local muzzle = c:ellipse(40, 67, 10, 7)

local lilac = GV.ramp("#c3b2ea", { rim = "#a894dc" })
local coat  = GV.ramp("#b8302a")
local shellR = GV.ramp("#a5663a")
local skin  = GV.ramp("#a4b86a")
local cream = GV.ramp("#f8eed2")

local p = c:build{
  { "disc",   disc,   lilac, { gloss = false, contact = false } },
  { "jacket", jacket, coat },
  { "shell",  shell,  shellR, { gloss = { 20, 26 } } },
  { "tail",   tail,   "red", { stitch = { side = "lit" } } },
  { "scarf",  scarf,  "red" },
  { "head",   head,   skin, { gloss = { 27, 49 } } },
  { "muzzle", muzzle, cream, { gloss = false } },
}

-- scute lines on the shell (only on visible shell pixels)
local vis = shell:copy():cut(head)
local inner = c:ellipse(40, 52, 20, 23)
local scutes = inner:copy():cut(inner:shrink(2))
scutes:add(c:line({ {40, 29}, {40, 50} }, 2))
scutes:add(c:line({ {29, 32}, {33, 42} }, 2))
scutes:add(c:line({ {51, 32}, {47, 42} }, 2))
-- radial marginal lines
scutes:add(c:line({ {40, 16}, {40, 29} }, 2))
scutes:add(c:line({ {26, 34}, {16, 26} }, 2))
scutes:add(c:line({ {54, 34}, {64, 26} }, 2))
scutes:add(c:line({ {21, 45}, {10, 44} }, 2))
scutes:add(c:line({ {59, 45}, {70, 44} }, 2))
scutes:clip(vis)
scutes:clip(shell:shrink(1))
c:fill(scutes, "#2a1a10")

-- scarf knot button
c:button(38, 81)

-- brows
c:paint({ ".bbbb..", "b....b." }, 29, 50, { b = "#58a03e" })
c:paint({ "..bbbb.", ".b....b" }, 44, 50, { b = "#58a03e" })

-- eyes (centred at 33,56 and 47,56)
c:eye(31, 54); c:eye(45, 54)

-- nostrils and smile
c:px(38, 64, "#4a2c1a"); c:px(42, 64, "#4a2c1a")
c:paint({ "u.......u", ".u.....u.", "..uuuuu.." }, 36, 67, { u = "#4a2c1a" })

local t = c:save(O .. "aseprite/ph/npc-pebble-barkley.aseprite", O .. "png/ph/npc-pebble-barkley.png")
print(GV.report(t))
