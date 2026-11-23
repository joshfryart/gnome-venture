-- pl-cblo-5-perch.lua : chibi perch sprite, 36x36
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-5-perch-20261120-172155/gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

local body  = GV.ramp("#33996e")
local sprout = GV.ramp("#acbb6e")
local gold  = GV.ramp("#efd17d")
local mound = GV.R.moss

-- perch mound
local moundM = c:ellipse(17.5, 26.5, 8, 2.6):clip(c:rect(0, 24, 35, 30))
c:part(moundM, mound, { gloss = false })

-- body ball (head+body one chibi unit)
local bodyM = c:ellipse(17, 15.5, 9.5, 8.5)
c:part(bodyM, body, { gloss = {14, 11}, contour = false })

-- sprout stems
c:part(c:line({{13,8},{12,6}}, 2), sprout, { flat = true, gloss = false, contact = false })
c:part(c:line({{17,7},{17,6}}, 2), sprout, { flat = true, gloss = false, contact = false })
c:part(c:line({{21,8},{22,6}}, 2), sprout, { flat = true, gloss = false, contact = false })
-- club tips
c:part(c:rrect(10, 3, 12, 5, 1), gold, { flat = true, gloss = false, contact = false })
c:part(c:rrect(16, 3, 18, 5, 1), gold, { flat = true, gloss = false, contact = false })
c:part(c:rrect(21, 3, 23, 5, 1), gold, { flat = true, gloss = false, contact = false })

c:ground(17.5, 30, 8.5, 1.2)

-- texture (hand-placed, <=1 tone step from base)
-- 1px dither along the body crescent border (light/shade seam)
c:px(22, 11, body.shade); c:px(21, 12, body.shade); c:px(22, 14, body.shade)
c:px(9, 15, body.rim); c:px(10, 18, body.rim)
-- moss tufts and tone variation on the mound
c:px(11, 26, mound.rim); c:px(23, 27, mound.shade); c:px(12, 28, mound.deep)
c:px(24, 26, mound.rim); c:px(14, 29, mound.shade)
-- stems: rim tick at the upper-left
c:px(12, 7, sprout.rim); c:px(21, 8, sprout.shade)

-- face: locked 3x3 eyes, pink cheeks, tiny mouth
c:eye(12, 13, true); c:eye(20, 13, true)
c:px(10, 16, "#c497b7"); c:px(24, 16, "#c497b7")
c:px(16, 17, "#2b1c26"); c:px(17, 17, "#2b1c26")

-- accent: tiny gold sprout beside the mound, stem seated on the mound edge
c:px(27, 25, gold.rim); c:px(27, 26, gold.base); c:px(28, 26, gold.base); c:px(28, 27, gold.shade)
c:px(26, 27, "#2b1c26") -- stem tick, touches the mound surface
local t = c:save("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-5-perch-20261120-172155/out/pl-cblo-5-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-5-perch-20261120-172155/out/pl-cblo-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
