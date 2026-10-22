local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local Y = -4
local green = GV.ramp("#58a03e")
local feet = c:ellipse(14, 50 + Y, 6, 2.5):add(c:ellipse(49, 50 + Y, 6, 2.5))
local body = c:ellipse(31.5, 44 + Y, 20.5, 10.5)
local belly = c:ellipse(31.5, 48 + Y, 11, 5.5)
local head = c:ellipse(31.5, 35 + Y, 15, 7)
local domes = c:ellipse(22, 28 + Y, 6.5):add(c:ellipse(41, 28 + Y, 6.5))
local p = c:build{
  { "feet",  feet,  GV.ramp("#2e7a34") },
  { "body",  body,  green },
  { "belly", belly, GV.ramp("#b0bc66"), { gloss = false } },
  { "head",  head,  green, { gloss = false } },
  { "domes", domes, green, { gloss = false, contact = false } },
}
-- warts (beans)
c:spot(c:ellipse(16, 41 + Y, 1.5, 1))
c:spot(c:ellipse(47, 42 + Y, 1.5, 1))
c:spot(c:ellipse(22, 46 + Y, 1, 1))
c:spot(c:ellipse(42, 46 + Y, 1, 1))
c:spot(c:ellipse(31.5, 31 + Y, 1.5, 1))
-- wide grin
c:fill(c:line({ {19, 36 + Y}, {24, 38 + Y}, {31, 39 + Y}, {32, 39 + Y}, {39, 38 + Y}, {44, 36 + Y} }, 1), "#2a1a10")
c:px(18, 35 + Y, "#2a1a10"); c:px(45, 35 + Y, "#2a1a10")
-- eyes
c:eye(20, 26 + Y); c:eye(39, 26 + Y)
-- gloss on dome
c:px(17, 24 + Y, green.gloss); c:px(17, 25 + Y, green.gloss); c:px(18, 23 + Y, green.gloss)
local t = c:save(O .. "aseprite/ph/creature-bullfrog.aseprite", O .. "png/ph/creature-bullfrog.png")
print(GV.report(t))
