local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- teardrop bulb: round belly narrowing up into a neck
local bulb = c:ellipse(31.5, 38, 16, 13)
bulb:add(c:poly({ {19, 32}, {28, 20}, {36, 20}, {45, 32} }))
-- pointed brown neck tuft
local tuft = c:poly({ {27, 22}, {30, 13}, {33, 10}, {35, 13}, {37, 22} })
-- tiny green sprout
local sprout = c:line({ {33, 12}, {34, 10}, {36, 8} }, 2)

local roots = c:line({ {28, 49}, {27, 53} }, 2):add(c:line({ {31, 50}, {31, 54} }, 2)):add(c:line({ {35, 49}, {36, 53} }, 2))
c:build{
  { "roots", roots, "#8a4f2a", { flat = true } },
  { "bulb", bulb, "gold" },
  { "tuft", tuft, "wood", { gloss = false } },
  { "sprout", sprout, "#7ab55c", { flat = true } },
}

-- three skin ridges converging at the neck
local ridge = GV.R.gold.bounce
c:fill(c:line({ {30, 23}, {25, 29}, {22, 36}, {22, 43} }, 1), ridge)
c:fill(c:line({ {32, 24}, {32, 36}, {32, 48} }, 1), ridge)
c:fill(c:line({ {34, 23}, {39, 29}, {42, 36}, {42, 43} }, 1), ridge)


local t = c:save(O .. "aseprite/ph/onion.aseprite", O .. "png/ph/onion.png")
print(GV.report(t))
