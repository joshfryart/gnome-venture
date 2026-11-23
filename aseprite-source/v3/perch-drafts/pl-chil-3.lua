-- pl-chil-3-perch.lua — 36x36 chibi perch of the mossy pot pal
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-chil-3-perch-20261120-173149/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- ramps (spec palette)
local Rbody = GV.ramp("#9c94a4")   -- grey pot body
local Rmoss = GV.ramp("#3f8a4a")   -- moss / sprouts
local Rwood = GV.ramp("#9a7a52")   -- perch pot + broom handle
local Rgold = GV.ramp("#cfc787")   -- broom bristles / sparkle
local Rpink = GV.ramp("#985b5d")   -- broom band / heart / blooms
local Rdusk = GV.ramp("#372b43")   -- deep accents
local Rshadow = GV.ramp("#55465e") -- soft ground shadow

local ball = c:ellipse(17.5, 18, 9.5, 9)
local perch = c:rrect(9, 26, 26, 29, 2)
local shadow = c:ellipse(17.5, 29.5, 9.5, 1)
local handle = c:line({ {27, 4}, {25, 21} }, 2)
local bristles = c:rrect(22, 23, 30, 27, 1)
local band = c:rrect(22, 23, 30, 25, 1)
local crown = c:rrect(10, 8, 25, 10, 3)
local sproutL = c:poly({ {12.5, 8}, {14, 4}, {15.5, 8} })
local sproutR = c:poly({ {19.5, 8}, {21.5, 4}, {23.5, 8} })
local armL = c:rrect(4, 11, 10, 13, 1)
local armR = c:rrect(22, 14, 28, 17, 2)
local heart = c:ascii({ ".u.u", "uuuu", ".uu.", "..u." }, 4, 8, "u")

local p = c:build{
  { "shadow",   shadow,   "#55465e", { flat = true, rim = false } },
  { "handle",   handle,   Rwood },
  { "bristles", bristles, Rgold },
  { "band",     band:clip(bristles),   Rpink },
  { "perch",    perch,    Rwood, { cres = 1 } },
  { "ball",     ball,     Rbody },
  { "crown",    crown,    Rmoss },
  { "sproutL",  sproutL,  Rmoss, { flat = true } },
  { "sproutR",  sproutR,  Rmoss, { flat = true } },
  { "armL",     armL,     Rbody },
  { "armR",     armR,     Rbody },
  { "heart",    heart,    Rpink, { flat = true } },
}

-- face on the ball (open eye left, wink right, tiny open mouth) — matches the pal
local eyeRing, eyeWhite, mouthPale = "#2b1c26", "#fff6e0", "#fff6e0"
-- open eye: oval ring (corners cut), cream core, lavender glint
c:px(13, 14, eyeRing); c:px(14, 14, eyeRing); c:px(15, 14, eyeRing)
c:px(12, 15, eyeRing); c:px(16, 15, eyeRing)
c:px(12, 16, eyeRing); c:px(16, 16, eyeRing)
c:px(12, 17, eyeRing); c:px(16, 17, eyeRing)
c:px(13, 18, eyeRing); c:px(14, 18, eyeRing); c:px(15, 18, eyeRing)
c:px(13, 15, eyeWhite); c:px(14, 15, eyeWhite); c:px(15, 15, eyeWhite)
c:px(13, 16, eyeWhite); c:px(14, 16, eyeWhite); c:px(15, 16, eyeWhite)
c:px(13, 17, eyeWhite); c:px(14, 17, eyeWhite); c:px(15, 17, eyeWhite)
c:px(13, 15, "#d8c8f0")  -- glint, upper-left like the pal
-- wink: happy closed arc on the right
c:px(20, 16, eyeRing); c:px(21, 17, eyeRing); c:px(22, 16, eyeRing)
-- mouth: dark line + open pale mouth
c:px(16, 21, eyeRing); c:px(17, 21, eyeRing)
c:px(16, 22, mouthPale); c:px(17, 22, mouthPale)

-- texture (all <=1 shade step from base, following the form)
local ballShade = Rbody.shade          -- #736f81 family
local woodShade = Rwood.shade          -- #75543e
-- brown body patches (pal's dirty spots), away from the crescent
c:px(9, 22, Rwood.base); c:px(10, 22, Rwood.base); c:px(9, 23, woodShade)
c:px(19, 23, Rwood.base); c:px(19, 24, Rwood.base); c:px(18, 23, woodShade)
c:px(14, 26, woodShade)
-- 1px dither straddling the ball's light/shade terminator
c:px(23, 17, ballShade); c:px(24, 20, ballShade); c:px(23, 22, ballShade)
-- wood grain on the perch: sparse darker marks along the form
c:px(12, 27, woodShade); c:px(12, 28, Rwood.base)
c:px(18, 28, woodShade); c:px(23, 27, woodShade)
-- perch lip: light 1px row along the pot rim, plus 1px wear notch
c:px(10, 26, Rwood.rim); c:px(11, 26, Rwood.rim); c:px(24, 26, Rwood.rim)
c:px(20, 26, Rwood.rim)
-- moss: tone-on-tone speckle on the crown, lit sprout edge
c:px(11, 9, Rmoss.shade); c:px(24, 9, Rmoss.shade); c:px(17, 9, Rmoss.shade)
c:px(12, 9, Rmoss.base); c:px(23, 9, Rmoss.base)
c:px(14, 5, Rmoss.gloss); c:px(21, 5, Rmoss.gloss)
-- bristle texture in the gold: a few darker strands
c:px(25, 27, Rgold.shade); c:px(27, 26, Rgold.shade); c:px(29, 27, Rgold.shade)
-- edge wear: 1px nick on the broom handle lit side
c:px(26, 7, Rwood.base)

-- detail: gloss dot on the heart, gold sparkle accent above the crown (from the pal)
c:px(5, 10, Rpink.gloss)
c:px(8, 4, Rgold.base); c:px(7, 5, Rgold.base); c:px(8, 6, Rgold.base); c:px(9, 5, Rgold.base)

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-chil-3-perch-20261120-173149/out/pl-chil-3-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-chil-3-perch-20261120-173149/out/pl-chil-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
