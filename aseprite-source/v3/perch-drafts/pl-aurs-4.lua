-- pl-aurs-4-perch: chibi bulb pal on a mossy stump perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurs-4-perch-20261120-164752/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

local rampBody  = GV.ramp("#5bc682")
local rampLeaf  = GV.ramp("#5fae4a", { gloss = "#c8d77a", rim = "#8fd05a", shade = "#3f8a4a", deep = "#2f5a2a", bounce = "#46814d" })
local rampStick = GV.ramp("#8b5532")
local rampPetal = GV.ramp("#e46a9b", { gloss = "#f8b8cf", rim = "#f08aa0", shade = "#c04a78", deep = "#8a2a50", bounce = "#c05a60" })
local rampMoss  = "moss"

-- perch: small wood stump + moss cap (back to front)
local stump = c:rrect(11, 23, 24, 28, 3)
local mossTop = c:ellipse(17.5, 23.5, 6.5, 2.5)
-- pal body: big round blob
local body = c:ellipse(16.5, 16, 9, 7.5)
-- leaves on stems above the head
local stemL = c:line({{14, 9}, {13, 7}}, 1)
local leafL = c:ellipse(12.5, 6, 2.5, 1.5)
local stemR = c:line({{19, 9}, {20, 7}}, 1)
local leafR = c:ellipse(20.5, 6, 2.5, 1.5)
-- flower wand (accent, right): stem + petal head
local wandStem = c:line({{27, 19}, {27, 12}}, 1)
local flower = c:rrect(25, 7, 29, 11, 1)
-- gold sparkle accent (upper-left)
local sparkle = c:ascii({ ".G.", "GGG", ".G." }, 5, 10)

local NoGloss = { gloss = false, contact = true }
c:build{
  { "stump",  stump,     "wood",    { gloss = false, deep = 3, contact = true } },
  { "moss",   mossTop,   rampMoss,  { gloss = false, deep = 3, contact = true } },
  { "body",   body,      rampBody,  { contact = true, gloss = { 11, 14 } } },
  { "stemL",  stemL,     rampLeaf,  { gloss = false, contact = false, flat = true } },
  { "leafL",  leafL,     rampLeaf,  { gloss = false, rim = false, cres = 1, deep = 0 } },
  { "stemR",  stemR,     rampLeaf,  { gloss = false, contact = false, flat = true } },
  { "leafR",  leafR,     rampLeaf,  { gloss = false, rim = false, cres = 1, deep = 0 } },
  { "wand",   wandStem,  rampStick, { gloss = false, contact = false, flat = true } },
  { "flower", flower,    rampPetal, { cres = 1, contact = true } },
  { "sparkle", sparkle,  "gold",   { flat = true, rim = false, contact = false, solid = false } },
}

-- texture: leaf veins, moss specks, wood sheen, terminator dither (all 1 step)
local rampWood = GV.ramp("wood")
local rampMossR = GV.ramp("moss")
c:px(11, 6, rampLeaf.rim); c:px(12, 6, rampLeaf.rim)      -- leaf veins
c:px(19, 6, rampLeaf.rim); c:px(20, 6, rampLeaf.rim)
c:px(11, 25, rampMossR.gloss); c:px(24, 22, rampMossR.gloss) -- moss specks
c:px(13, 24, rampMossR.bounce); c:px(22, 24, rampMossR.bounce)
c:px(13, 26, rampWood.bounce); c:px(20, 28, rampWood.bounce) -- stump edge sheen
c:px(22, 20, rampBody.shade); c:px(21, 21, rampBody.base)    -- terminator dither
c:px(10, 14, rampBody.shade); c:px(13, 12, rampBody.rim)     -- skin pits
c:px(27, 9, rampPetal.rim)                                   -- petal centre
for x = 14, 21 do c:px(x, 23, rampMossR.bounce) end          -- soften body/moss join

-- face: wide-set eyes, tiny mouth, pink cheeks
local C = GV.C
c:eye(12, 15, true)
c:eye(20, 15, true)
c:px(16, 19, C.ol3); c:px(17, 19, C.ol3)
c:px(10, 18, "#f5a0b8"); c:px(23, 18, "#f5a0b8")
c:ground(17.5, 27.5, 12, 2)

local t = c:save(D .. "out/pl-aurs-4-perch.aseprite", D .. "out/pl-aurs-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
