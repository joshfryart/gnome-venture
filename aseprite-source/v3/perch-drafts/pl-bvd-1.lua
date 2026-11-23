-- pl-bvd-1-perch  (36x36 chibi perch sprite)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-1-perch-20261120-170619/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 2, margin = 2 }

-- ramps (from the pal palette)
local bodyR  = GV.ramp("#5e6d5b")   -- grey-green body
local wingR  = GV.ramp("#513752")   -- plum wings
local bellR  = GV.ramp("#dcdbd1")   -- pale cream belly
local woodR  = GV.ramp("#c1793f")   -- perch wood
local mossR  = GV.ramp("#91cf63")   -- moss accent
local footR  = GV.ramp("#d59d66")   -- tan feet/beak

-- BLOCK-IN: flat silhouettes only
local FL = { flat = true, gloss = false, stitch = false }

-- perch (back to front): SMALL under the bird
local perch = c:rrect(9, 27, 28, 31, 1)
local mossL = c:ellipse(11, 27.5, 2.5, 1.5)
local mossRr = c:rrect(23, 26, 27, 28, 1)

-- bird blob: head + hips merged
local body = c:ellipse(17.5, 15, 10, 11)
body:add(c:ellipse(17.5, 22, 8, 5))
local wingL = c:ellipse(8, 19, 2, 5)
local wingRr = c:ellipse(27, 19, 2, 5)
-- cream face + apron (white face like the pal), one appliqué
local cream = c:ellipse(17.5, 14.5, 7, 5.5)
cream:add(c:ellipse(17.5, 20.5, 7.5, 5.5))
local footL = c:rect(14, 26, 15, 29)
local footRr = c:rect(21, 26, 22, 29)
local beak = c:poly({ {17,16}, {18.5,17}, {17,18}, {15.5,17} })

c:build{
  { "perch", perch, woodR, {} },
  { "mossL", mossL, mossR, { cres = 1, gloss = false, stitch = false, contact = false } },
  { "mossR", mossRr, mossR, { cres = 1, gloss = false, stitch = false, contact = false } },
  { "body",  body,  bodyR,  { cres = 1, gloss = false } },
  { "cream", cream, bellR,  { cres = 1, deep = 0, gloss = false, stitch = false } },
  { "wingL", wingL, wingR, { cres = 1, deep = 0, gloss = false, stitch = false, contact = false } },
  { "wingR", wingRr, wingR, { cres = 1, deep = 0, gloss = false, stitch = false, contact = false } },
  { "footL", footL, footR, { flat = true, gloss = false, stitch = false, contour = false, contact = false } },
  { "footR", footRr, footR, { flat = true, gloss = false, stitch = false, contour = false, contact = false } },
}

-- TEXTURE: hand-placed, tone-on-tone, following the form (<=1 shade step)
-- head dome fluff marks (following the curve, lit side / soft darks)
c:px(12, 5, bodyR.bounce); c:px(13, 4, bodyR.bounce); c:px(20, 5, bodyR.bounce)
c:px(15, 6, bodyR.bounce); c:px(19, 6, bodyR.bounce)
c:px(11, 8, bodyR.bounce); c:px(22, 8, bodyR.shade)
c:px(10, 11, bodyR.shade); c:px(23, 11, bodyR.shade)
c:px(9, 15, bodyR.shade); c:px(24, 13, bodyR.shade); c:px(25, 16, bodyR.shade)
-- belly fluff: sparse cream-shade dents along the lower belly curve
c:px(13, 23, bellR.shade); c:px(16, 24, bellR.shade); c:px(20, 24, bellR.shade)
c:px(22, 22, bellR.shade); c:px(12, 20, bellR.shade)
-- wing feather notches (tone-on-tone on the lower wing edge)
c:px(7, 22, wingR.rim); c:px(28, 22, wingR.rim)
-- wood grain on the perch: short dashes along the plank
for _, g in ipairs({ {12,29,15}, {18,28,20}, {23,29,26}, {17,30,19} }) do
  for x = g[1], g[3] do c:px(x, g[2], woodR.bounce) end
end
c:px(11, 29, woodR.shade); c:px(27, 30, woodR.shade); c:px(14, 30, woodR.shade)
-- moss speckles
c:px(9, 28, mossR.shade); c:px(10, 28, mossR.gloss); c:px(26, 27, mossR.shade); c:px(25, 26, mossR.gloss)

-- DETAIL: gloss comma on the head dome (upper-left, following the curve)
c:px(12, 6, bodyR.gloss); c:px(13, 5, bodyR.rim); c:px(14, 5, bodyR.gloss)
c:px(12, 7, bodyR.rim)
-- tiny sprig beside the perch (accent)
c:px(8, 26, mossR.shade); c:px(8, 25, mossR.rim)

-- FACE: bold dark eyes cut-corner 5x5, cream glint
local function eye(x, y)
  for j = 0, 4 do for i = 0, 4 do
    if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then c:px(x + i, y + j, "#2b1c26") end
  end end
  c:px(x + 1, y + 1, "#dcdbd1"); c:px(x + 2, y + 1, "#dcdbd1"); c:px(x + 2, y + 2, "#2a1a10")
end
eye(12, 11); eye(19, 11)
-- cheeks: pink 2x2 under the eyes, shading to coral lower-right
c:px(11, 16, "#f5a0b8"); c:px(12, 16, "#f5a0b8"); c:px(12, 17, "#ff8a8a")
c:px(23, 16, "#f5a0b8"); c:px(24, 16, "#f5a0b8"); c:px(24, 17, "#ff8a8a")
-- beak: tiny brown diamond, lit top, dark under
c:paint({ "aaa", " s " }, 16, 16, { a = "#c1793f", s = "#92402b" })

c:ground(17.5, 32, 14, 1.5, "#92402b")

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-1-perch-20261120-170619/out/pl-bvd-1-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-1-perch-20261120-170619/out/pl-bvd-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
