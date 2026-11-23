-- pl-cblo-2-perch.lua : perch sprite (36x36) for the pink top-hat pal
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-2-perch-20261120-172054/"
local GV = dofile(D .. "gvlib/gvlib.lua")
-- repoint outline tones to the spec palette (dark plums, not brown)
GV.C.ol1, GV.C.ol2, GV.C.ol3, GV.C.umber = "#563d4b", "#3e3258", "#2b1c26", "#2b1c26"

-- palette ramps (spec palette only)
local pink  = { base = "#dc7f8b", gloss = "#e6b3bb", dot = "#e8dcc9", rim = "#e6b3bb", shade = "#ca557b", deep = "#901f53", bounce = "#ca557b", pale = false }
local hat   = { base = "#3e3258", gloss = "#563d4b", dot = "#9d99a8", rim = "#563d4b", shade = "#2e2242", deep = "#2e2242", bounce = "#2e2242", pale = false }
local stone = { base = "#9d99a8", gloss = "#e8dcc9", dot = "#e8dcc9", rim = "#e8dcc9", shade = "#756470", deep = "#563d4b", bounce = "#756470", pale = false }
local cane  = { base = "#563d4b", gloss = "#9d99a8", dot = "#9d99a8", rim = "#9d99a8", shade = "#2b1c26", deep = "#2b1c26", bounce = "#2b1c26", pale = false }

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1, margin = 2 }

-- shapes
local body = c:ellipse(15.5, 19, 9, 8.5)
local hatM = c:rrect(10, 4, 20, 10, 1):add(c:rrect(8, 10, 23, 12, 1))
local hatBand = c:rect(10, 9, 20, 9)
local plinth = c:rrect(7, 27, 24, 30, 2)
local caneM = c:rrect(25, 12, 27, 14, 1):add(c:rect(26, 14, 27, 29))
local drop = c:poly({ { 5.5, 23 }, { 6.5, 23 }, { 6.5, 25 }, { 5.5, 26 }, { 4.5, 24 } })
local spark1 = c:rect(28, 8, 29, 9)
local spark2 = c:rect(29, 15, 30, 16)
local shadow = c:ellipse(17.5, 31.5, 12, 1)

-- build: plinth under, then body over it (contact shadow), hat, cane, accents
c:part(plinth, stone, { cres = 1, gloss = false, bounce = false })
c:part(body, pink, { cres = 2, deep = 1, gloss = { 9, 14 } })
c:part(hatM, hat, { cres = 1, gloss = { 12, 6 }, bounce = false })
c:fill(hatBand, "#e8dcc9")
c:part(caneM, cane, { flat = true, gloss = false })
c:part(drop, stone, { flat = true, gloss = false })
local spark = { base = "#e8dcc9", rim = "#e8dcc9" }
c:part(spark1, spark, { flat = true, cres = 0, gloss = false, rim = false })
c:part(spark2, spark, { flat = true, cres = 0, gloss = false, rim = false })

-- ground shadow: hand-painted (not a part) so the outline pass leaves it
c:fill(shadow, "#756470")

-- TEXTURE: tone-on-tone marks that follow the form (each <=1 shade step from base)
c:px(19, 7, "#2e2242")  -- felt grain on crown
c:px(13, 4, "#563d4b")  -- felt grain
c:px(17, 6, "#563d4b")
c:px(10, 11, "#563d4b") -- brim join ticks
c:px(21, 12, "#563d4b")
c:px(10, 29, "#756470") -- stone joints on plinth
c:px(16, 30, "#563d4b")
c:px(20, 29, "#756470")
c:px(11, 28, "#756470")
c:px(5, 23, "#756470")  -- drop edge tone
c:px(18, 5, "#3e3258")  -- 1px dither at the crown shade terminator

-- skin pits / dither at the body shade border (following the crescent)
c:px(24, 17, "#dc7f8b"); c:px(24, 20, "#dc7f8b"); c:px(23, 24, "#dc7f8b")
c:px(21, 26, "#901f53") -- pit in the deep at bottom
c:px(12, 27, "#ca557b") -- dither along body/plinth seam

-- face: hand-painted 5x5 eyes (cut-corner cream disc, 3x3 dark pupil, glint), cheeks, tiny mouth
local CRE, PUP = "#e8dcc9", "#2b1c26"
local function eyeball(x, y)
  c:fill(c:rrect(x, y, x + 4, y + 4, 1), CRE)
  c:fill(c:rect(x + 1, y + 1, x + 3, y + 3), PUP)
  c:px(x + 1, y + 1, CRE) -- glint at pupil upper-left
end
eyeball(8, 16)
eyeball(16, 16)
c:paint({ "cccc" }, 14, 22, { c = "#e8dcc9" })
c:px(14, 23, "#901f53"); c:px(15, 23, "#901f53"); c:px(16, 23, "#901f53"); c:px(17, 23, "#901f53")
-- mouth teeth 3px (tiny, like the pal)
c:px(17, 22, "#901f53")
c:px(7, 21, "#ca557b"); c:px(8, 21, "#ca557b")
c:px(22, 21, "#ca557b"); c:px(23, 21, "#ca557b")

-- DETAIL: enamel glints and small accents
c:px(9, 14, "#e6b3bb"); c:px(8, 15, "#e6b3bb") -- body gloss comma, re-set by hand
c:px(26, 13, "#9d99a8")                        -- cane knob glint
c:px(5, 24, "#e8dcc9")                         -- teardrop glint
c:px(11, 5, "#9d99a8")                         -- hat crown glint

-- ground shadow (thin, light from upper-left -> offset right)

local t = c:save(D .. "out/pl-cblo-2-perch.aseprite", D .. "out/pl-cblo-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
