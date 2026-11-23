-- pl-cblo-3-perch.lua : chibi perch of the lavender bow plush pal (36x36)
-- Palette from spec.md; light from upper-left.
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-3-perch-20261120-172104/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- palette-true outline tones (spec: dark palette colour, never pure black inside art)
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#4e3e59", "#2b1c26", "#2b1c26"

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, deep = 1, margin = 3 }

local FLAT = { flat = true, gloss = false, contour = false, contact = false } -- silhouettes (block-in)

-- ramps (base hexes from the 64px pal; tone overrides keep its key colours)
local bodyR   = GV.ramp("#7b6594", { gloss = "#d7dbec", dot = "#d7dbec", rim = "#baaac9",
                                     shade = "#603e6e", deep = "#3e274b", bounce = "#6e5e8e" })
local bowR    = GV.ramp("#ac303e", { gloss = "#de7a73", dot = "#de7a73", rim = "#d1473d",
                                     shade = "#a5273d", deep = "#781c42", bounce = "#b84549" })
local ruffleR = GV.ramp("#d7dbec", { gloss = "#eef1f8", dot = "#eef1f8", rim = "#d7dbec",
                                     shade = "#a9bce2", bounce = "#b7c4e2", deep = "#8ea0d9", pale = false })
local footR   = GV.ramp("#aa857b", { gloss = "#c9a692" })
local wingR   = { base = "#a9bce2", rim = "#b7c4e6", shade = "#8ea0d9", deep = "#6d79d7" }
local cushR   = GV.ramp("#4e3e59", { rim = "#6e5e8e", gloss = "#7a6b8a", dot = "#8a7a9a",
                                     shade = "#3e274b", deep = "#2b1c26", bounce = "#5a4a68" })

-- gloss handled by hand in the detail pass
local NOGL = { gloss = false }

local head = c:mask():ellipse(16, 14, 8):add(c:rrect(11, 19, 21, 26, 3))
local cush = c:mask():ellipse(16.5, 25, 8, 2):add(c:rrect(9, 25, 24, 28, 2))

local parts = c:build{
  -- back to front
  { "cushionTop", c:ellipse(16.5, 25, 8, 2),                      cushR,  { gloss = false, contour = false, cres = 3, deep = 1 } },
  { "cushion",    cush,                                           cushR,  { gloss = false, contour = false } },
  { "feather",    c:ellipse(5, 24, 1.4, 2),                       ruffleR, FLAT },
  { "body",       head,                                           bodyR,  { gloss = false, cres = 5 } },
  { "footL",      c:rrect(11, 27, 14, 28, 1),                     footR,  { flat = true, gloss = false, contour = false } },
  { "footR",      c:rrect(18, 27, 21, 28, 1),                     footR,  { flat = true, gloss = false, contour = false } },
  { "wing",       c:ellipse(23.5, 18, 2, 1.6),                    wingR,  { flat = true, gloss = false } },
  { "ruffle",     c:ellipse(28, 17, 2.6, 3),                      ruffleR, { gloss = false, contour = false } },
  { "bowL",       c:poly({ { 9, 4 }, { 15, 6.5 }, { 9, 9 } }),    bowR,   { gloss = false, contour = false } },
  { "bowR",       c:poly({ { 23, 4 }, { 17, 6.5 }, { 23, 9 } }),  bowR,   { gloss = false, contour = false } },
  { "bowKnot",    c:rrect(14, 5, 16, 7, 1),                       bowR,   { gloss = false, contour = false } },
}

-- texture (tone-on-tone, 1 shade step, following the form)
-- the pal's lighter forehead/face patch (lit upper-left of the head)
local faceM = c:mask():ellipse(14.5, 12, 6.2, 4.8):clip(parts.body.m)
faceM:each(function(x, y)
  local v = c:get(x, y)
  if v == "#7b6594" or v == "#baaac9" then c:px(x, y, "#baaac9") end
end)
-- speckles: darker tone-on-tone dots, denser mid, sparser at the edges
for _, p in ipairs({ { 12, 11 }, { 15, 10 }, { 18, 12 },                     -- on the pale face
                     { 10, 17 }, { 14, 18 }, { 17, 17 }, { 13, 21 }, { 16, 20 } } ) do -- on the base
  c:px(p[1], p[2], p[2] <= 12 and "#7b6594" or "#6e5e8e")
end
-- 1px dither where the shade crescent borders the base (upper end of the curve)
for _, p in ipairs({ { 20, 12 }, { 19, 14 }, { 18, 17 }, { 16, 21 } }) do
  if c:get(p[1], p[2]) == "#7b6594" and c:get(p[1] + 2, p[2] + 2) == "#603e6e" then
    c:px(p[1], p[2], "#6e5e8e")
  end
end
-- enamel gloss comma on the forehead
c:px(12, 11, "#d7dbec"); c:px(13, 11, "#d7dbec"); c:px(14, 11, "#d7dbec"); c:px(14, 12, "#d7dbec")
-- feather spine mark
c:px(5, 24, "#a9bce2"); c:px(5, 23, "#a9bce2")
-- 1px dither where the pale face patch borders the shade crescent
parts.body.m:each(function(x, y)
  if c:get(x, y) == "#baaac9" and c:get(x + 1, y + 1) == "#603e6e" then c:px(x, y, "#7b6594") end
end)
-- the patch is the face: below the eyes the pal is its mid purple again
parts.body.m:each(function(x, y)
  if c:get(x, y) == "#baaac9" and y >= 15 then c:px(x, y, "#7b6594") end
end)
-- belly: bounce light in from the cushion (lower edge), lift the lower-left arc
parts.body.m:each(function(x, y)
  if c:get(x, y) == "#603e6e" and not parts.body.m:has(x, y + 2) then c:px(x, y, "#6e5e8e") end
end)
parts.body.m:each(function(x, y)
  if c:get(x, y) == "#603e6e" and x <= 13 and y >= 21 then c:px(x, y, "#6e5e8e") end
end)
-- belly speckles (light dots on the mid, subtle on the shade)
for _, p in ipairs({ { 12, 18 }, { 16, 19 }, { 19, 17 }, { 15, 23 }, { 18, 24 } }) do
  local v = c:get(p[1], p[2])
  if v == "#7b6594" then c:px(p[1], p[2], "#baaac9") elseif v == "#603e6e" then c:px(p[1], p[2], "#6e5e8e") end
end
-- stitched lip on the cushion's lit side (fabric signature, top face only)
c:stitch(parts.cushionTop.m, { side = "lit" })

-- detail: enamel gloss accents on the bow and ruffle (brightest on each part)
c:px(10, 5, "#de7a73"); c:px(10, 6, "#de7a73"); c:px(11, 6, "#de7a73"); c:px(11, 7, "#de7a73")  -- left lobe
c:px(22, 5, "#de7a73"); c:px(21, 6, "#de7a73"); c:px(22, 6, "#de7a73"); c:px(20, 7, "#de7a73")  -- right lobe
c:px(15, 5, "#de7a73")                                                                          -- knot
c:px(26, 14, "#eef1f8"); c:px(26, 15, "#eef1f8")                                                -- ruffle

-- face: sleepy closed-eye arcs + tiny mouth (kept from the pal)
local ink = "#2b1c26"
for _, p in ipairs({ { 10, 14 }, { 11, 13 }, { 12, 13 }, { 13, 14 },
                     { 18, 14 }, { 19, 13 }, { 20, 13 }, { 21, 14 } }) do
  c:px(p[1], p[2], ink)
end
c:px(15, 17, ink); c:px(16, 17, ink)

-- soft ground shadow (under the perch, peeking at its sides)
c:ground(17.5, 29.5, 11, 2, "#6e5e8e")

local t = c:save(D .. "out/pl-cblo-3-perch.aseprite", D .. "out/pl-cblo-3-perch.png")
print(GV.report(t))
