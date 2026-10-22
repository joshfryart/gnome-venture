local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local SACK = GV.ramp("#c9a96e")
-- body: plump pouch, flat bottom
local body = c:ellipse(31.5, 38, 20, 16):cut(c:rect(0, 53, 63, 63))
body:add(c:poly({ {25, 21}, {39, 21}, {49, 32}, {14, 32} }))
-- neck + frilled top
local neck = c:rect(25, 13, 38, 23)
local frill = c:rect(21, 11, 42, 15)
for _, x in ipairs({ 22.5, 28, 35, 40.5 }) do frill:add(c:ellipse(x, 10, 3, 3)) end
frill:add(neck)
-- twine band + bow loops
local twine = c:rrect(22, 20, 41, 23, 1)
twine:add(c:ellipse(17.5, 19, 4, 3):cut(c:ellipse(17.5, 19, 1.5, 1)))
twine:add(c:ellipse(45.5, 19, 4, 3):cut(c:ellipse(45.5, 19, 1.5, 1)))
twine:add(c:line({ {29, 23}, {27, 28} }, 2)); twine:add(c:line({ {34, 23}, {36, 28} }, 2))
-- patch
local patchO = c:rrect(20, 29, 43, 50, 5)
local patchI = patchO:shrink(2)
-- bud
local bud = c:ellipse(31.5, 42, 5.5, 5)
bud:add(c:poly({ {26, 41}, {29, 35}, {31, 39}, {33, 35}, {35, 39}, {37, 35}, {38, 41} }))
local p = c:build{
  { "body", body, SACK, { stitch = { side = "lit" } } },
  { "neck", frill, SACK },
  { "twine", twine, "#9a6b3f", { gloss = false } },
  { "patchO", patchO, "petal", { gloss = false } },
  { "patchI", patchI, "#f4f0e0", { flat = true } },
  { "stalk", c:line({ {31, 31}, {31, 34} }, 2), "#2e5a2c", { flat = true } },
  { "leaf", c:ellipse(35, 32, 2.5, 1.5), "#58a03e", { flat = true } },
  { "bud", bud, "petal" },
}
c:seam({ {15, 51}, {48, 51} })
c:button(30, 19)
c:paint({ "u....u....u" }, 26, 47, { u = "#8c4a1a" })
c:px(24, 26, "#8c4a1a"); c:px(40, 27, "#8c4a1a"); c:px(17, 38, "#8c4a1a"); c:px(46, 40, "#8c4a1a")
local t = c:save(O .. "aseprite/ph/african-tulip-tree-seed.aseprite", O .. "png/ph/african-tulip-tree-seed.png")
print(GV.report(t))
