local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R

local hull = c:poly({ {11, 41}, {53, 41}, {41, 50}, {23, 50} })
local deck = c:rect(11, 41, 52, 44):clip(hull:copy():add(c:rect(11, 41, 52, 44)))
local wave = c:line({ {10, 54}, {13, 53}, {17, 54}, {21, 56}, {25, 54}, {29, 53}, {33, 54}, {37, 56}, {41, 54}, {45, 53}, {49, 54}, {53, 55} }, 3)

c:build{
  { "wave", wave, "water", { gloss = false } },
  { "mast", c:rect(29, 9, 31, 41), "wood", { gloss = false } },
  { "pennant", c:poly({ {32, 8}, {41, 11.5}, {32, 15} }), "red", { flat = true } },
  { "sailL", c:poly({ {28, 13}, {28, 39}, {12, 39} }), "cream", { gloss = { 24, 26 } } },
  { "sailR", c:poly({ {33, 17}, {33, 39}, {49, 39} }), "gold", { gloss = { 34, 26 } } },
  { "hull", hull, GV.ramp("#a8582f") },
  { "deck", deck, "wood", { gloss = false, contact = false } },
}
c:seam({ {13, 44}, {50, 44} })

local t = c:save(O .. "aseprite/ico/ico-boat.aseprite", O .. "png/ico/ico-boat.png")
print(GV.report(t))
