-- pl-ana-2-perch : 36x36 perch sprite (phase 7 CRITIQUE)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ana-2-perch-20261120-162753/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

local wood   = GV.ramp("#d19667")     -- light-tan stool, distinct from the pal's tan
local tanR   = GV.ramp("#b57f4f")
local magR   = GV.ramp("#9c2e54")
local berryR = GV.ramp("#d8382b")

local shadow = c:ellipse(17.5, 27.5, 8.5, 1.2)
local stool  = c:rrect(13, 24, 23, 28, 2)
local body   = c:ellipse(17.5, 21.5, 6.2, 4.8):cut(c:rrect(11, 24, 25, 29, 0))
local belly  = c:ellipse(17.5, 22.5, 5.9, 3.1):clip(body)
local head   = c:ellipse(17.5, 12, 8.5, 6.3)
local sproutL = c:mask():ellipse(14.6, 5.2, 1.9, 1.1)
local sproutR = c:mask():ellipse(20.2, 5.2, 1.6, 1.0)

local p = c:build{
  { "shadow",  shadow,  "#5e2f1e", { flat = true, gloss = false, outline = false, rim = false } },
  { "stool",   stool,   wood,      { flat = true } },
  { "body",    body,    "#b57f4f", { contact = false, gloss = false } },
  { "belly",   belly,   "#9c2e54", { gloss = false } },
  { "head",    head,    "#b57f4f", { contact = false, gloss = { 13, 8 } } },
  { "sproutL", sproutL, "#73bc51", { flat = true, outline = false, contact = true, contour = false } },
  { "sproutR", sproutR, "#73bc51", { flat = true, outline = false, contact = false, contour = false } },
}

-- face
c:eye(11, 11); c:eye(19, 11)
c:fill(c:rect(10, 15, 11, 15), "#9c2e54")
c:fill(c:rect(24, 15, 25, 15), "#9c2e54")

-- hand-placed seat contact (weight under the pal), not a full dark row
c:px(15, 24, wood.shade); c:px(16, 24, wood.shade); c:px(17, 24, wood.shade)
c:px(18, 24, wood.shade); c:px(19, 24, wood.shade)

-- texture
c:px(22, 14, tanR.base); c:px(23, 13, tanR.base)
c:px(21, 17, tanR.shade); c:px(20, 18, tanR.shade)
c:px(24, 11, tanR.shade)
c:px(21, 19, tanR.base); c:px(22, 18, tanR.base)
c:px(20, 21, tanR.shade)
c:px(13, 21, magR.shade); c:px(14, 20, magR.shade)
c:px(21, 22, magR.base); c:px(22, 23, magR.base)
c:px(17, 26, wood.shade); c:px(18, 26, wood.shade)
c:px(16, 27, wood.shade); c:px(20, 27, wood.shade)
c:px(14, 5, "#2a3a2a"); c:px(20, 5, "#2a3a2a")
c:px(9, 28, GV.C.umber); c:px(26, 28, GV.C.umber)

-- accents: berry (red, from the pal), restrained 2-accent glaze
c:fill(c:rect(8, 25, 9, 27), berryR.base)
c:px(8, 25, berryR.rim); c:px(9, 27, berryR.shade)
-- belly glaze comma
c:px(14, 22, magR.gloss); c:px(13, 22, magR.dot)

local t = c:save(D .. "out/pl-ana-2-perch.aseprite", D .. "out/pl-ana-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
