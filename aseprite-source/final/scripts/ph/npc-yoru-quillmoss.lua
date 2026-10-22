local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local tan = GV.ramp("#dcb06a")
local pink = GV.ramp("#d9667f")
local berry = GV.ramp("#9c2a1e")

-- body: rounded shoulders bleeding off bottom
local body = c:ellipse(39.5, 104, 34, 28):clip(c:rect(0, 76, 79, 99))
local collar = c:poly({ {31, 77}, {40, 89}, {49, 77} })
-- scarf band + hanging tail
local scarf = c:line({ {27, 78}, {33, 82}, {40, 83}, {47, 82}, {53, 78} }, 4)
local tail = c:poly({ {44, 80}, {52, 80}, {50, 96}, {46, 96} })
-- ears with inner discs
local earL = c:ellipse(23, 35, 11, 11)
local earR = c:ellipse(57, 35, 11, 11)
local head = c:ellipse(40, 53, 21, 19)
local muzzle = c:ellipse(40, 61, 12, 9)
local nose = c:ellipse(40, 57.5, 4, 3)
-- low cap dome showing head between ears
local cap = c:ellipse(40, 43, 14, 10):cut(c:rect(0, 43, 79, 99))
cap:add(c:rrect(25, 40, 55, 45, 2))
local pom = c:ellipse(40, 31, 3, 3)

local p = c:build{
  { "backdrop", c:ellipse(40, 50, 36, 36), "petal", { gloss = false } },
  { "body", body, GV.ramp("#7a5cc0") },
  { "collar", collar, GV.ramp("#4e3a8a"), { flat = true } },
  { "tail", tail, pink },
  { "scarf", scarf, pink, { stitch = { side = "lit" } } },
  { "earL", earL, tan, { gloss = false } },
  { "earR", earR, tan, { gloss = false } },
  { "innerL", c:ellipse(23, 35, 7, 7), "petal", { contact = false, gloss = false } },
  { "innerR", c:ellipse(57, 35, 7, 7), "petal", { contact = false, gloss = false } },
  { "head", head, tan, { gloss = { 22, 50 } } },
  { "muzzle", muzzle, "cream", { gloss = false, contact = false } },
  { "nose", nose, pink, { contact = false } },
  { "cap", cap, pink, { stitch = { side = "lit" } } },
  { "fold", c:rrect(43, 40, 52, 44, 1), berry, { flat = true, contact = false } },
  { "pom", pom, berry },
}
c:seam({ {26, 45}, {54, 45} })
c:button(38, 79)

c:eye(28, 49); c:eye(48, 49)
-- smile
c:paint({ "u.....u", ".uuuuu." }, 37, 65, { u = "umber" })
c:px(40, 61, "umber")
-- whiskers
local W = "#4a2c1a"

for x = 13, 27 do c:px(x, x < 20 and 59 or 60, W) end
for x = 14, 27 do c:px(x, x < 20 and 65 or 64, W) end
for x = 53, 67 do c:px(x, x > 60 and 59 or 60, W) end
for x = 53, 66 do c:px(x, x > 60 and 65 or 64, W) end

local t = c:save(O .. "aseprite/ph/npc-yoru-quillmoss.aseprite", O .. "png/ph/npc-yoru-quillmoss.png")
print(GV.report(t))
