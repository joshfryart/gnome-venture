-- pl-ffy-3-perch.lua : 36x36 chibi perch of the teal beret pal
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ffy-3-perch-20261120-182206/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", cres = 2, deep = 1, ol = 1, olx = 1 }

local teal = GV.ramp("#48c4cf")                              -- water family
local moss = GV.ramp("#7ab55c", { base = "#8cd47c" })        -- moss family
local wood = GV.ramp("#9a6a45")                              -- wood family
local tan  = GV.ramp("#b2703f")                              -- bill tan
local pal  = GV.ramp("#b8a468", { shade = "#8a7a4a" })       -- pal's own foot tan
local pole = GV.ramp("#9a6a45", { rim = "#d8c8f0", shade = "#5b3a2c", deep = "#5b3a2c" })

-- DETAIL
c:fill(c:ellipse(18.5, 30.5, 8, 1), "#134153")
c:build{
  { "pole",  c:rrect(23, 4, 24, 12, 0),       pole, { flat = true } },
  { "stump", c:rrect(12, 25, 25, 30, 2),      wood, { gloss = { 15, 25 } } },
  { "lip",   c:ellipse(18.5, 25.5, 6, 1.5),   wood, { flat = true } },
  { "leaf",  c:ellipse(29, 29, 1.5, 1),       moss, { flat = true } },
  { "body",  c:ellipse(18.5, 18, 8.5, 7.5),   teal, { gloss = false } },
  { "beret", c:ellipse(16.5, 10, 9, 3.5),     moss, { gloss = { 13, 9 } } },
  { "bill",  c:rrect(18, 19, 20, 20, 0),      tan,  { flat = true, contour = false } },
}
c:eye(12, 16); c:eye(21, 16)

-- feet: hand-placed tan feet peeking over the stump lip
for x = 13, 15 do c:px(x, 26, pal.base); c:px(x, 27, pal.shade) end
for x = 21, 23 do c:px(x, 26, pal.base); c:px(x, 27, pal.shade) end
c:px(13, 27, pal.base)                                   -- lit left corner of the left foot

-- gloss: brightest thing on the ball, upper-left curve (auto comma was swallowed by the beret)
c:px(11, 15, teal.gloss); c:px(11, 16, teal.gloss); c:px(10, 16, teal.gloss)
c:px(12, 15, teal.dot)

-- TEXTURE: hand-placed, 1 tone step, following the form
c:px(14, 28, wood.bounce)
c:px(21, 28, wood.bounce)
c:px(15, 21, teal.shade); c:px(20, 22, teal.shade)       -- skin-tone tone marks on the ball
c:px(12, 17, teal.base)
c:px(11, 12, moss.shade); c:px(22, 8, moss.base)         -- felt fibre tone marks on the beret
c:px(30, 28, moss.gloss)                                 -- leaf tip highlight

local t = c:save(D .. "out/pl-ffy-3-perch.aseprite", D .. "out/pl-ffy-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
