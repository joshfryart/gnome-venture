local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local legs = c:mask()
for _, x in ipairs({ 12, 20, 32, 40 }) do legs:add(c:rrect(x, 42, x + 4, 54, 2)) end
local body = c:rrect(9, 25, 45, 46, 8)
local tail = c:ellipse(9, 26, 2.5, 3)
local head = c:ellipse(45, 26, 7, 8):add(c:poly({ {40, 26}, {54, 30}, {54, 36}, {49, 38}, {42, 34} }))
head:add(c:ellipse(51, 33, 3.5, 3.5))
local horns = c:line({ {41, 19}, {40, 14}, {37, 10}, {34, 9} }, 3)
horns:add(c:line({ {45, 18}, {45, 13}, {43, 9} }, 3))
local ear = c:poly({ {41, 23}, {32, 25}, {33, 29}, {41, 27} })
local beard = c:poly({ {47, 37}, {52, 37}, {50, 46}, {48, 46} })

c:build{
  { "tail",  tail,  GV.ramp("#e3dcc9"), { gloss = false } },
  { "legs",  legs,  GV.ramp("#a28b5f"), { gloss = false } },
  { "body",  body,  GV.ramp("#f1ece0") },
  { "horns", horns, GV.ramp("#8c7a55"), { gloss = false } },
  { "head",  head,  GV.ramp("#f1ece0"), { gloss = { 41, 22 } } },
  { "beard", beard, GV.ramp("#e3dcc9"), { flat = true } },
  { "ear",   ear,   GV.ramp("#d6cdb6"), { flat = true } },
}
-- hooves
for _, x in ipairs({ 12, 20, 32, 40 }) do c:fill(c:rect(x, 52, x + 4, 54), "#5b4630") end
-- belly fur line
c:paint({ "ff..ff..ff..ff" }, 14, 37, { f = "#d6cdb6" })
-- nostril, mouth
c:px(53, 32, "#8c7a55")
c:paint({ ".m", "m." }, 50, 35, { m = "#a28b5f" })
c:eye(45, 24, true)
c:ground(30, 57, 20, 3)
local t = c:save(O .. "aseprite/ico/ico-goat.aseprite", O .. "png/ico/ico-goat.png")
print(GV.report(t))
