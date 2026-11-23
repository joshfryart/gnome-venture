-- pl-cblo-1-perch.lua : 36x36 chibi perch of the blue box pal (gold bow, tail+leaf, boots, violet cushion)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-1-perch-20261120-172053/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0 }

-- ramps (dominant pal colours; gvlib recipe supplies the tone steps)
local bodyR  = GV.ramp("#61a1d0", { gloss = "#a8d2e2", dot = "#cfe6f2", rim = "#8cc4e6",
                                    shade = "#3a70b8", deep = "#274489", bounce = "#4a6fbd" })
local bowR   = GV.ramp("gold", { rim = "#eecd63" })
local perchR = GV.ramp("#4f3851", { rim = "#a98aa4" })
local tailR  = GV.ramp("#875330", { rim = "#a8834e", shade = "#5b3620", deep = "#4a2a17" })
local leafR  = GV.ramp("#8fd05a", { gloss = "#c8f08a", dot = "#e2f0ac", rim = "#a5d970",
                                    shade = "#5fae4a", deep = "#3a7a34", bounce = "#77a84e" })
local bootR  = GV.ramp("#8d5f59", { rim = "#ac8f85", shade = "#6a4345", deep = "#4f3851" })

-- shaded build: ramps, crescents, rim, bounce from the library; upper-left light
local bow  = c:ellipse(14.5, 7.5, 3, 2.8):add(c:ellipse(21.5, 7.5, 3, 2.8))
              :add(c:rect(17, 6, 19, 10)):cut(c:rect(17, 3, 19, 7))   -- two puffs, open dip, knot below
local tail  = c:ellipse(27.5, 18.5, 2.5, 2)      -- stump behind the body, right
local leaf  = c:ellipse(28.5, 16.5, 1.5, 1)      -- sprig atop the tail
local perch = c:rrect(6, 26, 29, 30, 2)          -- small violet cushion
local body  = c:rrect(9, 10, 26, 24, 5)          -- the blob: head and body as one
local boots = { c:rrect(10, 23, 14, 26, 1), c:rrect(21, 23, 25, 26, 1) }

local parts = c:build{
  { "perch", perch, perchR },
  { "tail",  tail,  tailR },
  { "leaf",  leaf,  leafR, { gloss = false } },
  { "body",  body,  bodyR },
  { "bow",   bow,   bowR,  { gloss = false } },
  { "bootL", boots[1], bootR, { flat = true } },
  { "bootR", boots[2], bootR, { flat = true } },
}
c:gloss(parts.bow.m, bowR, {13, 6})
c:gloss(parts.body.m, bodyR, {12, 13})

-- face: eyes, glints, cheeks, smile (hand-placed)
local EYE, GLINT = "#2b1c26", "#fff6e0"
for j = 0, 2 do
  c:px(11, 16 + j, EYE); c:px(12, 16 + j, EYE)
  c:px(23, 16 + j, EYE); c:px(24, 16 + j, EYE)
end
c:px(11, 16, GLINT)
c:px(23, 16, GLINT)
c:px(10, 19, "#f5a0b8"); c:px(10, 20, "#f5a0b8")
c:px(25, 19, "#f5a0b8"); c:px(25, 20, "#f5a0b8")
c:px(16, 20, EYE); c:px(19, 20, EYE)            -- smile ends
c:px(17, 21, EYE); c:px(18, 21, EYE)            -- smile bottom

-- accents: gold sparks floating clear of the body/leaf (right side)
c:px(29, 11, "#eecd63"); c:px(28, 12, "#e7ba27"); c:px(29, 12, "#b85914")

-- TEXTURE: hand-placed, subtle, following the form
-- body: 1px dither along the light/shade terminator (shade upward into base, shade between base and deep)
for _, p in ipairs({ {13,22}, {16,22}, {20,22} }) do c:px(p[1], p[2], "#3a70b8") end
for _, p in ipairs({ {14,23}, {18,23}, {22,23} }) do c:px(p[1], p[2], "#3a70b8") end
-- perch: one subtle dither line in the base band above the deep
for _, p in ipairs({ {10,28}, {15,28}, {21,28} }) do c:px(p[1], p[2], "#392b3e") end
-- tail: short wood-grain dashes on the lit side, and one worn base mark in the shade
c:px(28, 18, "#a8834e"); c:px(29, 18, "#a8834e")
c:px(27, 20, "#875330")
-- leaf: 1px midrib
c:px(28, 16, "#3a7a34"); c:px(29, 17, "#3a7a34")
--- boots: single worn sole mark each
c:px(12, 26, "#4f3851"); c:px(23, 26, "#4f3851")

-- DETAIL: one glaze glint on the leaf tip, one on the bow's right puff
c:px(27, 16, "#c8f08a")
c:px(21, 6, "#fff1c8")

-- CRITIQUE fixes: break the bow's full-width deep band, following the curve
c:px(12, 9, "#b8661a"); c:px(16, 10, "#b8661a"); c:px(22, 9, "#b8661a")

local t = c:save(D .. "out/pl-cblo-1-perch.aseprite", D .. "out/pl-cblo-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
