-- pl-ffy-2-perch: chibi perch sprite, 36x36
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ffy-2-perch-20261120-181836/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "scene", bleed = "" }

local bodyRamp  = GV.ramp("#b0564a")
local beretRamp = GV.ramp("#6bceca")
local woodRamp  = GV.ramp("#c08a48")
local poleRamp  = GV.ramp("#96684a")
local bootRamp  = GV.ramp("#8a5c44")
local gold      = GV.R.gold
local DK        = "#2b1c26"

-- soft ground shadow (no outline: it is a shadow, not an object)
local shadow = c:ellipse(16, 29.5, 11, 1.6)
c:fill(shadow, "#543b4c")

local p = c:build{
  { "stumpRim", c:ellipse(15.5, 27, 8.5, 2.9), woodRamp,             { outline = false, cres = 1, deep = 1 } },
  { "stumpTop", c:ellipse(15.5, 25.5, 7.5, 2.3), GV.ramp("#dcb277"), { outline = false, cres = 0, deep = 1, gloss = false } },
  { "pole",     c:rrect(27, 11, 28, 28, 1), poleRamp,                { outline = false, cres = 1, deep = 1, gloss = false } },
  { "lamp",     c:rrect(24, 5, 30, 10, 1), gold,                     { outline = false, cres = 1, deep = 1, gloss = false } },
  { "bootL",    c:rrect(9, 26, 12, 28, 1), bootRamp,                 { outline = false, cres = 1, deep = 1, gloss = false } },
  { "bootR",    c:rrect(17, 26, 20, 28, 1), bootRamp,                { outline = false, cres = 1, deep = 1, gloss = false } },
  { "body",     c:ellipse(16, 17.5, 9.8, 9.8), bodyRamp,             { outline = false, cres = 3, deep = 1, gloss = { 8, 11 } } },
  { "beret",    c:ellipse(15.5, 9.8, 9.2, 4.3), beretRamp,           { outline = false, cres = 3, deep = 1, contour = false, gloss = { 9, 7 } } },
}

local function tex(x, y, hex, only)
  local cur = c:get(x, y)
  if only and cur ~= only then return end
  if not only and (cur == nil or cur == DK) then return end
  c:px(x, y, hex)
end

-- lamp glow: cream lantern window inside the gold frame
c:fill(c:rect(26, 6, 28, 8), "#f2e4c0")
c:px(26, 6, "#fffbe8"); c:px(29, 9, GV.R.gold.deep); c:px(28, 10, GV.R.gold.deep)

-- small lit wedge upper-left of the body, tucked beside the left eye
tex(7, 15, "#db985a"); tex(8, 15, "#e7b5b6"); tex(7, 16, "#db985a")

-- bounce light following the body's bottom curve (1px, curved)
tex(12, 27, bodyRamp.bounce); tex(13, 27, bodyRamp.bounce); tex(14, 27, bodyRamp.bounce)
tex(15, 27, bodyRamp.bounce); tex(16, 27, bodyRamp.bounce); tex(17, 27, bodyRamp.bounce)
tex(11, 26, bodyRamp.bounce); tex(18, 27, bodyRamp.bounce)

-- pale speckles on the body, like the 64px pal's freckles (tone-on-tone)
tex(12, 23, bodyRamp.rim); tex(20, 22, bodyRamp.rim); tex(9, 21, bodyRamp.rim)

-- 1px dither where the body's lit area meets the crescent shade
tex(20, 17, bodyRamp.shade); tex(19, 21, bodyRamp.shade); tex(17, 24, bodyRamp.shade)
tex(8, 18, bodyRamp.gloss); tex(12, 15, bodyRamp.rim)

-- dither on the beret's crescent boundary (base tone into shade, 1px steps)
tex(21, 10, beretRamp.base, beretRamp.shade); tex(19, 12, beretRamp.base, beretRamp.shade)
tex(24, 7, beretRamp.shade, beretRamp.base); tex(22, 6, beretRamp.shade, beretRamp.base)

-- stump grain: two short horizontal wood dashes on the lit side only
tex(11, 28, woodRamp.shade, woodRamp.base); tex(14, 29, woodRamp.shade)

-- boot wear: 1px lit scuffs on the boot toes
tex(10, 26, bootRamp.rim, bootRamp.base); tex(19, 26, bootRamp.rim, bootRamp.base)

-- gold spectacles: 1px rims arched over each eye with a bridge (the pal's signature)
local gg, gs, gl3 = GV.C.gold, GV.C.goldS, "#fff1c8"
c:fill(c:rect(9, 15, 15, 15), gg); c:fill(c:rect(18, 15, 24, 15), gg)
c:px(8, 16, gg); c:px(8, 17, gs)                 -- left temple
c:px(25, 16, gg); c:px(25, 17, gs)               -- right temple
c:px(16, 16, gg); c:px(17, 16, gg)               -- bridge
c:px(9, 15, gl3); c:px(10, 15, gl3)              -- glint on the lit rim
c:px(24, 15, gs)                                 -- rim shade lower-right
c:px(11, 21, gs); c:px(12, 21, gs)               -- bottom rim hints (round lenses)
c:px(21, 21, gs); c:px(22, 21, gs)

-- lantern top handle
c:part(c:line({ { 26, 4.6 }, { 27, 3.6 }, { 28, 4.6 } }, 1), GV.R.gold, { flat = true, outline = false, gloss = false, contact = false })

-- floating gold sparkle accent, taken from the 64px pal
local spark = c:line({ { 3.6, 11 }, { 4.6, 11 } }, 1)
spark:add(c:line({ { 4, 10 }, { 4, 12 } }, 1))
c:part(spark, GV.C.gold, { flat = true, outline = false, gloss = false, contact = false })
c:px(4, 11, "#f3e4aa")

-- glints
tex(15, 25, "#fffbe8", GV.C.gold)                -- bell glint

-- face
c:eye(10, 16); c:eye(19, 16)
c:px(15, 22, DK); c:px(16, 22, DK)                                   -- tiny mouth
c:paint({ "uu", "uu" }, 7, 19, { u = "#e7b5b6" })                    -- cheeks
c:paint({ "uu", "uu" }, 23, 19, { u = "#e7b5b6" })
c:paint({ "..G..", ".GGG.", "GGGs" }, 14, 24, { G = GV.C.gold, g = GV.C.goldS, s = GV.C.goldS }) -- bell

-- one 1px selective outline in the pal's dark plum, like the finished perch examples
local rim = c.sil:grow(1)
rim:each(function(x, y)
  if c:inside(x, y) and not c.sil:has(x, y) then c:px(x, y, DK) end
end)

local t = c:save(D .. "out/pl-ffy-2-perch.aseprite", D .. "out/pl-ffy-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
