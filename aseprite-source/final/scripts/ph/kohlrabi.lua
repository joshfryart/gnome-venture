local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local purple = GV.ramp("#7a5cc0", { shade = "#3e2f66" })
-- inverted drop: flat-ish top, round shoulders, tapering to root
local bulb = c:poly({ {24, 22}, {41, 22}, {45, 27}, {45, 33}, {42, 40}, {37, 46}, {34, 50}, {31, 50}, {28, 46}, {23, 40}, {20, 33}, {20, 27} })
bulb:add(c:rrect(20, 22, 45, 33, 5))
local root = c:line({ {32, 49}, {32, 53} }, 2)
local leafL = c:poly({ {30, 23}, {24, 16}, {22, 10}, {26, 8}, {30, 13}, {32, 21} })
local leafR = c:poly({ {33, 23}, {35, 13}, {39, 8}, {43, 10}, {41, 16}, {35, 23} })
local p = c:build{
  { "leafL", leafL, GV.ramp("#58a03e"), { gloss = false } },
  { "leafR", leafR, "moss", { gloss = false } },
  { "root", root, "#291d4a", { flat = true } },
  { "bulb", bulb, purple, { gloss = { 25, 25 } } },
}
-- leaf scar bars
c:fill(c:rect(28, 30, 33, 31), "#4e3a8a")
c:fill(c:rect(35, 37, 39, 38), "#4e3a8a")
c:fill(c:rect(26, 39, 29, 40), "#4e3a8a")
-- leaf midribs
c:fill(c:line({ {29, 20}, {25, 11} }, 1), "#2f5a2a")
c:fill(c:line({ {34, 20}, {39, 11} }, 1), "#2f5a2a")
local t = c:save(O .. "aseprite/ph/kohlrabi.aseprite", O .. "png/ph/kohlrabi.png")
print(GV.report(t))
