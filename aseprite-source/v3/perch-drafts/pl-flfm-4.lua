-- pl-flfm-4-perch.lua : 36x36 perch for the rose grass-crown pal
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-4-perch-20261120-183541/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local rose  = GV.ramp("#c85f81", { shade = "#99285f", gloss = "#f5b8c0" })
local blush = GV.ramp("#e6bcc3", { gloss = "#fff3c8", rim = "#fbe9c9" })
local green = GV.ramp("#617765", { gloss = "#a1d889", shade = "#49454d" })
local cork  = GV.ramp("#8f5833", { deep = "#49211a" })
local cream = GV.ramp("#fbe9c9")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 2, margin = 2 }

-- parts (back to front) -- CRITIQUE fixes: mound up 1 (margin 2), quieter dome, feet as nubs
local mound = c:ellipse(17.5, 28, 8.5, 2.2)
mound:add(c:ellipse(17.5, 24.8, 5.5, 1.5))  -- wide bump fills the valley under the blob
mound:add(c:ellipse(11, 26.6, 2, 1))
mound:add(c:ellipse(23.5, 26.6, 2, 1))
local tail  = c:rrect(28, 17, 30, 22, 1)
local feetL = c:rrect(10, 23, 14, 25, 1)
local feetR = c:rrect(21, 23, 25, 25, 1)
local blob  = c:rrect(7, 8, 28, 23, 5)
local face  = c:ellipse(17.5, 15, 6.5, 4.2)

local leafL = c:ellipse(12.5, 6.5, 2, 1.3)
local leafC = c:ellipse(18, 5.8, 2.2, 2.3)
local leafR = c:ellipse(23.5, 6.5, 2, 1.3)
local crown = leafL
crown:add(leafC):add(leafR)
local spark = c:ascii({ ".s.", "sss", ".s." }, 5, 6)

c:build{
  { "mound",  mound,  green, { cres = 1, deep = 0, bounce = false, gloss = false, contour = false } },
  { "tail",   tail,   cork,  { flat = true, contour = false } },
  { "feetL",  feetL,  green, { flat = true, contour = false } },
  { "feetR",  feetR,  green, { flat = true, contour = false } },
  { "blob",   blob,   rose,  { gloss = false, bounce = false } },
  { "face",   face,   blush, { contour = false } },
  { "crown",  crown,  green, { cres = 1, deep = 1, gloss = false } },
}
c:part(spark, cream, { flat = true, rim = false })

-- green collar band + lit strip
c:fill(c:rect(8, 8, 27, 9):clip(blob), green.base)
c:fill(c:line({ { 8, 8 }, { 16, 8.5 } }, 2), "#a1d889")
c:px(27, 9, "#49454d"); c:px(26, 9, green.shade)
c:px(17, 5, "#fa9db8")

-- eyes, mouth, cheeks
for _, ex in ipairs({ 12, 21 }) do
  c:fill(c:rect(ex, 14, ex + 2, 15), "#2b1c26")
end
c:px(12, 14, "#fbe9c9"); c:px(21, 14, "#fbe9c9")
c:px(16, 17, "#2b1c26"); c:px(17, 18, "#2b1c26"); c:px(18, 18, "#2b1c26"); c:px(19, 17, "#2b1c26")
c:fill(c:rect(11, 17, 12, 17), "#fa9db8"); c:fill(c:rect(23, 17, 24, 17), "#fa9db8")

-- gold stitch seam with green diamonds
c:seam({ { 9, 21 }, { 26, 21 } }, { gap = "#99285f" })
for _, dx in ipairs({ 11, 17, 23 }) do
  c:px(dx, 21, "#a1d889"); c:px(dx, 22, "#617765")
end

-- TEXTURE: hand-placed, tone-on-tone, following the form
-- rose body: sparse shade flecks lower-right + 1px dither on the shade border
c:px(19, 20, "#99285f"); c:px(24, 19, "#99285f"); c:px(25, 21, "#99285f"); c:px(20, 16, "#c9959f")
c:px(24, 22, "#99285f"); c:px(27, 21, "#99285f")                         -- shade flecks
-- 1px bounce return on the lower-right body edge, broken (no band)
c:px(26, 22, "#b43e60"); c:px(24, 23, "#b43e60")
-- face edge light (rim) and a dot below the gloss comma are library-made
-- feet: 1px edge marks so the nubs read apart from the dome
c:px(14, 24, "#49454d"); c:px(25, 24, "#49454d")
-- dome: moss texture, light tips upper area, quiet 1px shade arc lower-right
c:px(13, 26, "#a1d889"); c:px(21, 24, "#a1d889"); c:px(25, 27, "#3f5240")
c:px(22, 29, "#323e39"); c:px(16, 30, "#49454d"); c:px(10, 28, "#323e39")
c:px(22, 26, "#506252"); c:px(25, 25, "#506252")
-- contact shadow under the feet stays library-made; 1px grey only at the dome's dark point
-- leaves: light tips + a shade notch per tuft
c:px(18, 4, "#a1d889"); c:px(19, 5, "#a1d889"); c:px(13, 6, "#506252"); c:px(24, 6, "#506252")
-- tail: cork grain, lit top, deep end
c:px(29, 17, "#c1a351"); c:px(30, 20, "#5e3620"); c:px(29, 22, "#5e3620")
c:px(30, 18, "#7a5230")

c:ground(17.5, 30.5, 10.5, 0.8, "#49454d")

local t = c:save(D .. "out/pl-flfm-4-perch.aseprite", D .. "out/pl-flfm-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
