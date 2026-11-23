-- pl-flfm-5-perch : 36x36 chibi perch (hat traveler pal), gvlib

-- gvlib does the ramp shading; this file is hand-tuned per phase.

local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-5-perch-20261120-183931/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- ramps (bases straight from the pal/spec palette)
local bodyHex = GV.ramp("#c4975f")
local glowR = GV.ramp("#f4d98a")
local tieR = GV.ramp("#56cdc3")
local bootR = GV.ramp("#6b626c")

-- ================= PERSPECTIVE: proportions, overlap, ground contact =================
-- back to front
c:part(c:rect(27, 10, 28, 29), "wood", { flat = true, gloss = false })               -- pole (thin, stands on ground)
c:part(c:rrect(22, 6, 27, 11, 1), glowR, { gloss = false })                          -- lantern sits on pole top
c:part(c:rrect(9, 25, 26, 29, 2), "wood", { gloss = false, stitch = false })         -- stump perch
c:part(c:rrect(10, 27, 14, 29, 1), bootR, { flat = true, gloss = false })            -- boot L
c:part(c:rrect(21, 27, 25, 29, 1), bootR, { flat = true, gloss = false })            -- boot R
c:part(c:ellipse(17.5, 21.5, 8, 6), bodyHex, { gloss = false })                      -- round head/body
c:part(c:poly({ { 17.5, 5 }, { 9, 14 }, { 26, 14 } }):add(c:ellipse(17.5, 14, 9.5, 2.5)),
  "gold", { gloss = false })                                                        -- conical hat
c:fill(c:ascii({ "v", "vvv" }, 4, 6), "#af7a31")                                     -- sparkle diamond

-- face (chibi: head 0.44*h, big eyes, tiny mouth)
c:eye(12, 20, true); c:eye(21, 20, true)
c:fill(c:rect(15, 24, 20, 24), "#411928")                                            -- mustache band
c:fill(c:rect(10, 23, 11, 24), GV.ramp("petal").base)                                -- cheek L
c:fill(c:rect(24, 23, 25, 24), GV.ramp("petal").base)                                -- cheek R
c:fill(c:rrect(14, 26, 21, 27, 1), tieR.base)                                        -- bowtie knot band

-- ================= SHADE: crescents (auto) + hand shading by form =================
local woodShade, woodDeep = GV.ramp("wood").shade, GV.ramp("wood").deep
local bodyShade = bodyHex.shade
local goldBase, goldS = "#d0a24a", GV.ramp("gold").shade

-- lantern: gold frame, warm cream glow core
c:fill(c:rrect(22, 6, 27, 11, 1), goldBase)                                          -- frame
c:fill(c:rrect(23, 7, 26, 10, 1), "#f4d98a")                                         -- glow
c:fill(c:rect(24, 7, 25, 9), "#fff6c0")                                              -- hot core
c:px(26, 10, goldS); c:px(27, 10, goldS)                                             -- frame shade lower-right
c:px(23, 10, goldS)

-- pole roundness: 1 px shade on its right column
for y = 12, 29 do c:px(28, y, woodShade) end
c:px(28, 29, woodDeep)

-- under-brim shadow on the body (row below the brim), soft ends: no hard band
for x = 12, 23 do c:px(x, 17, bodyShade) end
c:px(11, 17, bodyShade)
c:px(24, 17, bodyShade)
c:px(13, 18, bodyShade); c:px(14, 18, bodyShade)
c:px(21, 18, bodyShade); c:px(22, 18, bodyShade)

-- hat auto-crescent covers the cone's right slope; no extra band needed

-- ================= TEXTURE: hand-placed, subtle, follows the form =================
local goldRing = GV.ramp("gold").shade             -- #b8661a, 1 step from gold base
local goldLit  = GV.ramp("gold").bounce            -- #d0862a
local bodyRim  = bodyHex.rim                       -- #cfba7c

-- straw rings on the cone: 1 px lines, ends easing 1 px up with the form
-- cone edges: x = 17.5 +/- 0.944*(y-5)
for x = 17, 19 do c:px(x, 7, goldRing) end; c:px(18, 6, goldRing)
for x = 14, 21 do c:px(x, 9, goldRing) end
for x = 12, 23 do c:px(x, 11, goldRing) end; c:px(13, 10, goldRing); c:px(22, 10, goldRing)
for x = 10, 25 do c:px(x, 13, goldRing) end
c:px(11, 12, goldRing); c:px(24, 12, goldRing)
-- lit left slope of the cone: a few 1px weave marks toward the light
c:px(16, 8, goldLit); c:px(15, 10, goldLit); c:px(16, 12, goldLit)

-- under-brim band: dither the ends back to base so it is not a hard band
c:px(11, 17, "#c4975f"); c:px(24, 17, "#c4975f")

-- body felt: sparse tone-on-tone marks following the round lit side
c:px(11, 20, bodyRim); c:px(10, 22, bodyRim); c:px(12, 19, bodyRim)
c:px(23, 25, bodyHex.shade); c:px(22, 23, bodyRim)

-- lantern: 1 px thread-gold glint on the frame's lit corner
c:px(22, 6, GV.C.gold)

-- ================= DETAIL: gloss, glints, small accents =================
-- eye glints (upper-left of each pupil)
c:px(13, 21, "#fffbe8"); c:px(22, 21, "#fffbe8")
-- sparkle: cream-hot centre
c:px(5, 7, "#fffbe8")
-- lantern frame glint on its lit corner
c:px(23, 7, "#f5cf6a")
-- mustache tip accents: 1 px darker ends following the beard curve
c:fill(c:rect(14, 24, 15, 24), "#411928"); c:fill(c:rect(20, 24, 21, 24), "#411928")

-- ================= CRITIQUE fixes =================
-- 1. hat gloss by hand on the lit upper-left slope (auto ring misplaced it)
local goldGloss, goldDot = GV.ramp("gold").gloss, GV.ramp("gold").dot
c:px(16, 7, goldGloss); c:px(17, 7, goldGloss); c:px(18, 8, goldGloss)
c:px(17, 8, goldDot)
-- 2. bowtie knot shade (two-wing read)
local tieShade = tieR.shade
c:px(18, 26, tieShade); c:px(19, 27, tieShade)
-- 3. stump face grain, tone-on-tone on the lit left / centre
c:px(10, 28, "#b07a45"); c:px(17, 29, "#b07a45"); c:px(20, 29, "#b07a45")

-- ground contact
c:ground(17.5, 30.5, 11, 1.2)

local t = c:save(D .. "out/pl-flfm-5-perch.aseprite",
                 D .. "out/pl-flfm-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 2)
