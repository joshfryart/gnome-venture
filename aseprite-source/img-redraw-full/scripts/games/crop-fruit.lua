local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- plump apple: two shoulders + a full belly, notch at the top
local body = c:ellipse(23, 38, 13, 15)
body:add(c:ellipse(41, 38, 13, 15))
body:add(c:ellipse(32, 43, 20, 14))
body:cut(c:ellipse(32, 21, 4, 3))
-- slight bottom dimple
body:cut(c:rect(30, 57, 33, 57))
-- stem leaning right
local stem = c:line({ {32, 25}, {32, 19}, {33, 15}, {35, 10}, {36, 8} }, 3)
-- pointed leaf
local leaf = c:poly({ {37, 15}, {40, 11}, {44, 9}, {49, 8}, {51, 9}, {48, 13}, {44, 16}, {40, 17} })
local p = c:build{
  { "stem", stem, GV.ramp("#8a4f2a"), { flat = true } },
  { "body", body, "red", { gloss = { 18, 30 } } },
  { "leaf", leaf, GV.ramp("#6a9a3a"), { gloss = false } },
}
-- leaf midrib
c:paint({ "......mmm", "...mmm...", "mmm......" }, 39, 12, { m = "#2f5a2a" })
-- gloss streak (brightest on the object)
c:paint({
  "......gg",
  "....gg..",
  "...g....",
  "..g.....",
  ".g......",
  ".g......",
  "g.......",
}, 16, 26, { g = "#ff9158" })
c:px(17, 25, "#ffc27a"); c:px(16, 26, "#ffc27a")
c:ground(32, 57.5, 14, 1)
local t = c:save(O .. "aseprite/games/crop-fruit.aseprite", O .. "png/games/crop-fruit.png")
print(GV.report(t))
