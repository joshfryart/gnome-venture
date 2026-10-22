local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local fur = GV.ramp("#dcb06a")
local green = GV.ramp("#58a03e")
-- tall ears, slightly splayed
local earL = c:ellipse(29, 25, 6, 19)
local earR = c:ellipse(51, 25, 6, 19)
local inL = c:ellipse(29, 26, 3, 14)
local inR = c:ellipse(51, 26, 3, 14)
local body = c:ellipse(39.5, 101, 35, 25)
local scarf = c:line({ {23, 75}, {31, 80}, {40, 82}, {49, 80}, {57, 75} }, 6)
local tail = c:poly({ {49, 79}, {56, 79}, {61, 97}, {52, 97} })
local head = c:ellipse(40, 55, 19, 17)
local muzzle = c:ellipse(40, 63, 10, 7)
local band = c:line({ {22, 47}, {28, 42}, {34, 40}, {40, 39}, {46, 40}, {52, 42}, {58, 47} }, 4):clip(head:grow(1))
local berry = c:ellipse(51, 41, 3, 3)
local leaf = c:poly({ {24, 37}, {31, 39}, {28, 44}, {22, 42} })
local p = c:build{
  { "earL", earL, fur },
  { "earR", earR, fur },
  { "inL", inL, "petal", { flat = true } },
  { "inR", inR, "petal", { flat = true } },
  { "body", body, "gold", { stitch = { side = "lit" } } },
  { "tail", tail, green },
  { "scarf", scarf, green },
  { "head", head, fur },
  { "muzzle", muzzle, "cream" },
  { "nose", c:ellipse(40, 59, 3.5, 2.5), "#d9667f", { flat = true } },
  { "band", band, green, { gloss = false } },
  { "leaf", leaf, "leaf", { flat = true } },
  { "berry", berry, "red", { gloss = { 50, 40 } } },
}
c:seam({ {53, 82}, {56, 95} })
c:button(38, 79)
c:eye(30, 48); c:eye(46, 48)
c:paint({ "s.....s", ".s...s.", "..sss.." }, 37, 64, { s = "#4a2c1a" })
for x = 23, 29 do c:px(x, 62, "#f8eed2") end
for x = 51, 57 do c:px(x, 62, "#f8eed2") end
local t = c:save(O .. "aseprite/ph/npc-poppy-puddlejump.aseprite", O .. "png/ph/npc-poppy-puddlejump.png")
print(GV.report(t))
