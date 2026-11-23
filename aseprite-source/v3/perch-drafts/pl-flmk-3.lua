-- pl-flmk-3-perch: 36x36 chibi perch of the fisher flatfish pal
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flmk-3-perch-20261120-184524/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, ol = 1 }

local moss   = GV.ramp("#6a8a50")
local stone  = GV.R.stone
local body   = GV.ramp("#59636f", { deep = "#3b3f54" })
local gray   = GV.ramp("#8a979c")
local navy   = GV.ramp("#2466a8")
local sky    = GV.ramp("#70bbe1", { gloss = "#abe4ed", rim = "#c8ecdc", shade = "#3f8fb0", deep = "#2466a8", bounce = "#5a86b8" })
local wood   = GV.ramp("#a27350")
local pink   = GV.ramp("#f06a8a", { gloss = "#ffb0c4", shade = "#d9637f", deep = "#c94f84", bounce = "#df9a86" })
local gold   = GV.ramp("#d99a32")

local hat = c:ellipse(17.5, 8, 6, 3):add(c:rrect(9, 10, 26, 12, 1))
local bobber = c:ellipse(26.5, 6.5, 2, 1.2)

local p = c:build{
  { "perch",  c:ellipse(17.5, 27.5, 9.5, 2.5), moss },
  { "pebble", c:rrect(27, 27.5, 29, 29.5, 1), stone },
  { "coin",   c:ellipse(7.5, 28.5, 1.5, 1.5), gold },
  { "rod",    c:line({ { 25, 26 }, { 26.5, 8 } }, 2), wood, { contour = false } },
  { "bobber", bobber, sky, { cres = 1 } },
  { "body",   c:rrect(14, 20, 22, 26, 3), body, { contour = "#2b1c26", cres = 1 } },
  { "pincer", c:rrect(9, 22, 12, 25, 1), pink },
  { "head",   c:ellipse(17.5, 15.5, 7.5, 6.5), gray, { contour = false } },
  { "hat",    hat, navy },
}

-- TEXTURE: hand-placed, tone-on-tone, 1 shade step from base
-- face: 1px dither where the shade crescent meets the flat gray (softens the terminator)
c:px(20, 19, gray.shade); c:px(21, 18, gray.shade); c:px(19, 20, gray.shade)
-- head: two pale speckles upper-left (skin-pit tones from the pal's grain), following the form
c:px(13, 14, gray.rim); c:px(15, 12, gray.rim)
-- hat: 1px dimple shade on the dome's lit side (worn felt)
c:px(11, 8, navy.shade)
-- perch: mossy speckles following the curve + stone joint
c:px(12, 27, moss.rim); c:px(16, 28, moss.rim); c:px(20, 27, moss.rim)
c:px(14, 28, moss.deep); c:px(18, 29, moss.deep); c:px(22, 28, moss.deep)
-- pebble: one speckle
c:px(28, 28, stone.bounce)
-- body: fabric-side sheen px on its lit flank
c:px(16, 24, body.rim); c:px(15, 25, body.shade)

-- DETAIL: face, gloss, accents
c:eye(12, 14); c:eye(18, 14)                       -- big round eyes, set wide
c:px(15, 19, "#2b1c26"); c:px(16, 19, "#2b1c26")   -- tiny mouth
c:px(21, 17, gold.base)                            -- gold cheek spot from the pal
c:gloss(p.head.m, gray, { 13, 14 })                -- enamel comma on the lit cheek
local bx0, by0 = p.bobber.m:bbox()                 -- hand glaze on the tiny bobber cap
c:px(bx0 + 1, by0 + 1, sky.gloss); c:px(bx0 + 2, by0 + 1, sky.gloss)

c:ground(17.5, 30.5, 11, 1)

local t = c:save(D .. "out/pl-flmk-3-perch.aseprite", D .. "out/pl-flmk-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
