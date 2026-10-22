local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local violet = GV.ramp("#7a5cc0")
local green = GV.ramp("#58a03e")

-- backdrop disc
local disc = c:ellipse(39.5, 50, 36, 36)
-- coat dome
local coat = c:ellipse(39.5, 104, 34, 28):cut(c:rect(0, 0, 79, 75))
-- hood back: smooth dome with short flaps
local hood = c:ellipse(39.5, 44, 29, 30):add(c:rrect(11, 44, 68, 80, 6))
-- head
local head = c:ellipse(39.5, 60, 25, 17)
local eyes = c:ellipse(27, 42, 9, 9):add(c:ellipse(52, 42, 9, 9))

local p = c:build{
  { "disc", disc, "#f6b8cf", { gloss = false, contact = false } },
  { "coat", coat, "gold", { stitch = { side = "lit" } } },
  { "hood", hood, violet, { stitch = { side = "lit" } } },
  { "eyes", eyes, green, { light = eyes:copy():add(head), gloss = false } },
  { "head", head, green, { light = head:copy():add(eyes) } },
}
-- belly / chin
c:fill(c:ellipse(39.5, 67, 15, 7):clip(head:shrink(2)), "#b0bc66")
-- brow line: darker arc framing the face inside the hood
c:fill(c:ellipse(39.5, 46, 26, 27):cut(c:ellipse(39.5, 46, 24, 25)):cut(c:rect(0, 47, 79, 99)):clip(hood):cut(eyes:grow(1)):cut(head), "#4e3a8a")
-- bobble on crown
c:part(c:ellipse(39.5, 12, 3.5, 3.5), "gold", { gloss = { 38, 10 } })
-- scarf
local scarf = c:line({ {24, 79}, {32, 84}, {40, 86}, {48, 84}, {56, 79} }, 3):clip(coat)
c:part(scarf:add(c:rect(47, 82, 50, 96)):clip(coat), violet, { gloss = false })
c:button(38, 82)
-- gloss on head
c:gloss(head, green, { 24, 52 })
-- eyes on domes
c:eye(25, 39); c:eye(50, 39)
-- wide smile
c:fill(c:line({ {25, 62}, {32, 67}, {40, 69}, {47, 67}, {54, 62} }, 2), "#2a1a10")
c:px(36, 56, "#2e5a2c"); c:px(43, 56, "#2e5a2c")
local t = c:save(O .. "aseprite/ph/npc-fern-sunpatch.aseprite", O .. "png/ph/npc-fern-sunpatch.png")
print(GV.report(t))
