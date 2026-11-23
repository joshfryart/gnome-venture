-- pl-flmk-2-perch.lua  36x36 perch: chibi fez-potato pal on a wooden stump
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flmk-2-perch-20261120-184434/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- ramps (from the pal's palette)
local hatR  = GV.ramp("#c43b2d", { shade = "#8a2a3a", deep = "#4c171e", gloss = "#e8503a" })
local headR = GV.ramp("#905933", { shade = "#6c3024", deep = "#4c171e", gloss = "#e6bf7d" })
local feetR = GV.ramp("#6c3024", { deep = "#4c171e" })
local woodR = GV.R.wood

-- shapes
local hat   = c:poly({ { 11.5, 4 }, { 20.5, 4 }, { 22.5, 12 }, { 9.5, 12 } })
local head  = c:ellipse(15.5, 18, 7, 6)                    -- potato head x8..23, y12..24
local footL = c:rrect(10, 22, 13, 24.5, 1)
local footR = c:rrect(17, 22, 20, 24.5, 1)
local topF  = c:ellipse(15.5, 23.2, 8.5, 2.2)              -- stump top face y21..25
local trunk = c:rrect(10, 25, 21, 28, 2)                   -- stump body
local shadow = c:ellipse(15.5, 29.7, 10, 0.9)              -- soft purple shadow (no outline)
local feet  = footL:add(footR)
local perch = topF:add(trunk)

local p = c:build{
  { "perch",  perch,  woodR, { cres = 0, deep = 0, gloss = false } },
  { "feet",   feet,   feetR, { cres = 1, deep = 0 } },
  { "head",   head,   headR, { gloss = false } },
  { "hat",    hat,    hatR },
}

-- soft shadow, two purple tones like the pal's own base art
c:fill(shadow, "#4a3a68")
c:fill(c:ellipse(15.5, 29.2, 10, 0.9), "#6e5e8e")

-- stump shading, hand-hewn: lit top face, soft lower band, shaded trunk right/bottom
local face = topF:copy(); face:cut(p.feet.m); face:cut(p.head.m)
c:fill(face, woodR.rim)
local zb = c:ellipse(16.5, 23.6, 7.5, 1.6); zb:clip(face)
c:fill(zb, woodR.bounce)
local zs = c:ellipse(17.5, 23.9, 6, 1.0); zs:clip(face)
c:fill(zs, woodR.shade)
local tr = c:rect(16, 25, 21, 28); tr:clip(trunk)
c:fill(tr, woodR.bounce)
local te = c:rect(18, 26, 22, 29); te:clip(trunk)
c:fill(te, woodR.shade)
local tb = c:rect(12, 27, 20, 29); tb:clip(trunk)
c:fill(tb, woodR.shade)

-- face (from the 64px pal)
local ink = "#2b1c26"
local glow = "#e6bf7d"
c:px(13, 13, headR.gloss); c:px(12, 13, headR.gloss); c:px(11, 14, headR.gloss); c:px(12, 14, headR.gloss)
c:px(13, 14, headR.dot); c:px(10, 14, headR.gloss); c:px(12, 15, headR.gloss); c:px(9, 16, headR.rim)
c:px(10, 17, glow); c:px(11, 17, ink); c:px(10, 18, ink); c:px(11, 18, ink)          -- left eye, glint
c:px(10, 19, ink);  c:px(11, 19, ink)
c:px(19, 17, glow); c:px(20, 17, ink); c:px(19, 18, ink); c:px(20, 18, ink)          -- right eye, glint
c:px(19, 19, ink);  c:px(20, 19, ink)
c:px(14, 20, ink); c:px(16, 20, ink); c:px(15, 21, ink)                              -- tiny mouth
c:px(9, 20, "#a1765b"); c:px(10, 20, "#a1765b"); c:px(21, 20, "#a1765b"); c:px(22, 20, "#a1765b") -- cheeks
c:px(21, 10, glow); c:px(22, 10, glow); c:px(21, 11, glow)                           -- hat gold trim
-- gold sparkle accents (hand-painted, like the pal's)
c:px(26, 14, "#e8d088"); c:px(25, 15, glow); c:px(27, 15, glow); c:px(26, 16, glow); c:px(26, 15, "#e8d088")
c:px(29, 11, "#e8d088"); c:px(28, 12, glow); c:px(30, 12, glow); c:px(29, 13, glow); c:px(29, 12, "#e8d088")

-- texture: subtle, following the form
c:px(13, 26, woodR.shade); c:px(13, 27, woodR.shade)       -- wood grain dash
c:px(17, 26, woodR.shade)                                  -- wood grain dash
c:px(9, 23, woodR.bounce)                                  -- top face grain mark
c:px(20, 6, hatR.dot); c:px(12, 8, hatR.dot)               -- felt weave speckles
c:px(11, 27, woodR.bounce)                                 -- edge wear on trunk foot

local t = c:save(D .. "out/pl-flmk-2-perch.aseprite", D .. "out/pl-flmk-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 2 and t.bw == 0)
