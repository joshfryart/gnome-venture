-- pl-flfm-2-perch : 36x36 chibi perch sprite (TEXTURE: marks + ramps)
local GV = dofile("C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-2-perch-20261120-183031/gvlib/gvlib.lua")
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-2-perch-20261120-183031/"
local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- ramps from the spec palette
local teal  = GV.ramp("#48cdac")            -- head + body
local padT  = GV.ramp("#37859a")            -- droplet / water family
local sage  = GV.ramp("#c3d5b3")            -- sage cushion
local green = GV.ramp("#5fae4a")            -- sprout / lily pad
local wood  = GV.ramp("#b98350", { gloss = "#e5b57e", dot = "#f6dcae", rim = "#d5a468" }) -- wood family
local gold  = GV.ramp("#f0b159")            -- belly gem
local lav   = GV.ramp("#666684")            -- limbs
local cream = GV.ramp("#eae1cd")            -- head bumps

c:ground(17.5, 30.5, 10.5, 1.1, "#666684")

-- perch: small stump + sage pad
c:part(c:rrect(11, 24, 24, 30, 2), wood, { deep = 1 })
c:part(c:ellipse(17.5, 25.4, 7.5, 2), sage, { gloss = false })

-- pal: tiny body under the big head, planted on the pad
c:part(c:ellipse(17.5, 21.5, 7, 3.5), teal, { gloss = false })
c:part(c:ellipse(17.5, 14, 10, 8), teal, { gloss = { 10, 10 } })

-- cream bumps + sprout
c:part(c:ellipse(12.5, 8, 2.6, 2), cream, {})
c:part(c:ellipse(22.5, 8, 2.6, 2), cream, {})
c:part(c:line({ { 17, 10 }, { 17, 6.5 } }, 2), green, { gloss = false })
c:part(c:ellipse(19.8, 6.2, 1.9, 1.1), green, {})

-- feet on the pad
c:part(c:rect(14, 22, 15, 23), wood, { flat = true })
c:part(c:rect(20, 22, 21, 23), wood, { flat = true })

-- gold gem on the belly, hand gloss
c:part(c:ascii({ "..Y..", ".YYY.", ".YYY.", "..Y.." }, 15, 21), gold, { gloss = false, cres = 1, deep = 1, contour = false })
c:px(16, 22, gold.gloss); c:px(17, 22, gold.dot)

-- arms
c:part(c:line({ { 12, 21 }, { 10, 22 } }, 2), lav, { flat = true })
c:part(c:line({ { 23, 21 }, { 25, 20 } }, 2), lav, { flat = true })

-- droplet on the ground left of the stump; lily pad floats right
c:part(c:ellipse(6, 27, 2.1, 2.4), padT, { gloss = false })
c:part(c:ellipse(27, 28.5, 2.3, 1.2), green, { gloss = false })
c:px(5, 26, padT.gloss); c:px(26, 28, green.gloss)

-- face
c:eye(12, 11); c:eye(20, 11)
c:px(16, 18, "#2a1a10"); c:px(18, 18, "#2a1a10"); c:px(17, 19, "#2a1a10")

-- details
c:px(12, 24, wood.gloss)            -- gloss nick on the stump's lit top edge

-- texture: teal spots on the head, dither at the light/shade border, bark knots
c:px(24, 10, "#37859a"); c:px(26, 12, "#37859a"); c:px(11, 23, "#2da59c")
c:px(24, 16, teal.base); c:px(23, 17, teal.shade)
c:px(13, 29, wood.deep); c:px(22, 28, wood.deep)
c:px(12, 25, wood.rim); c:px(23, 25, wood.rim)

local t = c:save(D .. "out/pl-flfm-2-perch.aseprite", D .. "out/pl-flfm-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
