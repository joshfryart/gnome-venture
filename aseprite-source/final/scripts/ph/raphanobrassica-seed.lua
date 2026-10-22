local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f1ece0", { shade = "#dcb06a" })
local pink = GV.ramp("#e46a9b", { deep = "#a8241f" })
local str = GV.ramp("#8c4a1a")
-- lumpy angular bundle with two pointed ears
local body = c:rrect(14, 26, 50, 55, 6)
body:add(c:poly({ {16, 30}, {18, 13}, {29, 27} }))
body:add(c:poly({ {35, 27}, {46, 13}, {49, 30} }))
body:add(c:poly({ {26, 27}, {32, 22}, {39, 27} }))
local p = c:build{
  { "body", body, cloth, { stitch = { side = "lit" }, gloss = { 20, 31 } } },
}
-- string X across the front
local x = c:line({ {17, 29}, {47, 52} }, 2):add(c:line({ {47, 29}, {17, 52} }, 2))
x:clip(body:shrink(1))
local b = c:build{
  { "string", x, str, { flat = true } },
  { "badge", c:ellipse(23.5, 36, 5, 5), pink, { gloss = { 21, 33 } } },
  { "knot", c:rrect(29, 39, 34, 44, 1), str, { gloss = false } },
}
-- tails from knot
c:paint({ "s....s", ".s..s.", ".s..s." }, 29, 45, { s = "#8c4a1a" })
-- cloth dots
c:paint({ "dd", "dd" }, 40, 34, { d = "#dcb06a" })
c:paint({ "dd", "dd" }, 23, 48, { d = "#dcb06a" })
c:paint({ "dd", "dd" }, 41, 47, { d = "#dcb06a" })
c:ground(32, 57, 16, 1.5)
local t = c:save(O .. "aseprite/ph/raphanobrassica-seed.aseprite", O .. "png/ph/raphanobrassica-seed.png")
print(GV.report(t))
