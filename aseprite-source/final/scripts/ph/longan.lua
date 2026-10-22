-- ph/longan : plump orange sphere, green stalk and leaf
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/longan"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

c:build{
  { "stalk", c:rect(31, 14, 33, 22), GV.ramp("#2f5a2a", { base = "#2f5a2a" }), { flat = true } },
  { "fruit", c:ellipse(32, 37, 15), GV.ramp("#f08a24"), { cres = 6, deep = 3 } },
  { "leaf",  c:poly({ {33,19}, {33,14}, {36,10}, {41,6}, {41,12}, {37,17} }), GV.ramp("#58a03e"), { gloss = false, contact = false } },
}
c:fill(c:line({ {34, 17}, {39, 9} }, 1), "#2f5a2a")
c:ground(32, 54, 15, 2, "#8a4f2a")
local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))
