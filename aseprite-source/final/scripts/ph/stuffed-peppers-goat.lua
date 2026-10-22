local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- very wide low plate seen from slightly above
local plate = c:ellipse(31.5, 41, 23, 10)
local well  = c:ellipse(31.5, 39.5, 17, 6.5)

-- pepper cup: round red-brown mound with a stem nub on top
local pepper = c:ellipse(31.5, 34, 12, 9)
pepper:add(c:rrect(21, 34, 42, 43, 5))
local stem = c:rrect(34, 21, 37, 26, 1)

-- crumbled goat-cheese cap, lumpy top
local cheese = c:ellipse(29, 30, 6, 3.5)
cheese:add(c:ellipse(25.5, 31, 2.5, 2))
cheese:add(c:ellipse(33, 30.5, 3, 2.5))
cheese:add(c:ellipse(28, 27.5, 2.5, 1.5))

-- herb sprig
local herb = c:ellipse(40, 36, 2.5, 2.5)

local p = c:build{
  { "plate",  plate,  GV.ramp("#d6c9b6"), { gloss = false } },
  { "well",   well,   "cream", { gloss = false, rim = false } },
  { "pepper", pepper, GV.ramp("#7a1f2e"), { gloss = { 23, 31 } } },
  { "stem",   stem,   "moss", { flat = true } },
  { "cheese", cheese, "cream", { gloss = { 26, 29 } } },
  { "herb",   herb,   "moss", { gloss = false } },
}

-- crumble dots on the cheese
c:px(30, 31, "#d6c9b6"); c:px(33, 31, "#d6c9b6"); c:px(27, 32, "#d6c9b6")
-- herb shade pixel
c:px(41, 37, "#4a8a3e")

local t = c:save(O .. "aseprite/ph/stuffed-peppers-goat.aseprite", O .. "png/ph/stuffed-peppers-goat.png")
print(GV.report(t))
