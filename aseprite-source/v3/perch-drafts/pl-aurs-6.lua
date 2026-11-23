-- pl-aurs-6-perch.lua : chibi pink-dress bear on a wood stump perch, 36x36
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurs-6-perch-20261120-165043/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 1, deep = 2 }

-- ---- ramps (from the pal) ----
local fur   = GV.ramp("#b07a50", { gloss = "#d89a68", dot = "#e8b078", rim = "#c08452",
                                   shade = "#8a5a3a", deep = "#5b3a2c", bounce = "#a06a48" })
local skirt = GV.ramp("#e8688c", { gloss = "#ffd0e0", dot = "#fff0f6", rim = "#ff9ab8",
                                   shade = "#b8487a", deep = "#6e3a7a", bounce = "#c85a92" })
local mintB = GV.ramp("#3fa896", { gloss = "#c8f8e8", rim = "#c8f8e8", dot = "#e8fff4",
                                   shade = "#358a78", deep = "#2a6a60", bounce = "#4aa890" })
local muzz  = GV.ramp("#f0d8b0", { gloss = "#f7e8cc", dot = "#fffbe8", rim = "#e8d0a8",
                                   shade = "#d8bc8e", deep = "#b89068", bounce = "#e8d0a8", pale = true })
local wood  = GV.ramp("#c08858", { gloss = "#e8c090", dot = "#f4d8b0", rim = "#dba974",
                                   shade = "#9a6437", deep = "#6e4326", bounce = "#a8743f", pale = false })
local woodT = { base = "#d9a660", rim = "#ecc58a", gloss = "#ecc58a", dot = "#f8e6b8",
                shade = "#c08a50", deep = "#a86a40", bounce = "#d9a660", pale = false }

-- ---- ground shadow (hand, 2-tone, excluded from outline silhouette) ----
c:fill(c:ellipse(17.5, 30, 12, 1.4):clip(c:rect(0, 0, 35, 29)), "#bfa0a2")
c:fill(c:ellipse(17.5, 30, 12, 1.4):clip(c:rect(0, 30, 35, 35)), "#796183")

-- ---- perch: wood stump ----
local side = c:rrect(8, 26, 27, 28, 2)                            -- side
         :add(c:ellipse(17.5, 27, 9.5, 1.5))
c:part(side, wood, { gloss = false, cres = 2 })
local top  = c:ellipse(17.5, 25.6, 9.5, 1.7)                       -- top face
c:part(top, woodT, { bounce = false, gloss = false, rim = false,
                     light = top:copy():add(side) })
c:fill(top, "#d9a660")                                             -- lit top face
c:ellipse(17.5, 25.6, 9.5, 1.7):edge():each(function(x, y)          -- far rim arc (upper-left)
  if x + y <= 26.5 then c:px(x, y, "#ecc58a") end end)

-- ---- bear ----
local tier1 = c:rrect(12, 18, 23, 21, 2)
local tier2 = c:rrect(11, 22, 24, 24, 2)
local dress = tier1:copy():add(tier2)
c:part(tier1, skirt, { gloss = false, light = dress, cres = 2, deep = 1, contour = false })  -- skirt tier 1
c:part(c:rect(11, 21, 24, 21), mintB, { flat = true, rim = false, contact = false })         -- mint hem
c:part(tier2, skirt, { gloss = false, light = dress, cres = 2, deep = 1, contour = false })  -- skirt tier 2
c:part(c:line({ { 13, 24.5 }, { 13, 25.8 } }, 2), fur, { flat = true })  -- left leg
c:part(c:line({ { 21, 24.5 }, { 21, 25.8 } }, 2), fur, { flat = true })  -- right leg
c:px(13, 26, "#5b3a2c"); c:px(14, 26, "#5b3a2c")                      -- feet
c:px(21, 26, "#5b3a2c"); c:px(22, 26, "#5b3a2c")
c:part(c:ellipse(11.5, 6.5, 2.5, 2.5), fur, { gloss = false })        -- left ear
c:fill(c:ellipse(11, 6, 1.3, 1.2), "#f8cfe0")                         -- inner
c:px(10, 5, "#f0c4cc")                                                -- inner tone
c:part(c:ellipse(23.5, 6.5, 2.5, 2.5), fur, { gloss = false })        -- right ear
c:fill(c:ellipse(23, 6, 1.3, 1.2), "#f8cfe0")                         -- inner
c:px(24, 6, "#f0c4cc")                                                -- inner tone
c:part(c:ellipse(17.5, 12.5, 8, 6.9), fur, { gloss = false, cres = 2, contour = false }) -- head
c:part(c:ellipse(17.5, 15.3, 3.0, 1.7), muzz, { bounce = false, gloss = false,
                                                contour = false, cres = 1, deep = 1 })  -- muzzle
-- face: closed happy arcs, cheeks, mouth
c:px(11, 10, "#452e3b"); c:px(12, 11, "#452e3b"); c:px(13, 11, "#452e3b"); c:px(14, 10, "#452e3b")
c:px(21, 10, "#452e3b"); c:px(22, 11, "#452e3b"); c:px(23, 11, "#452e3b"); c:px(24, 10, "#452e3b")
c:px(16, 16, "#7a4e32"); c:px(17, 16, "#5b3a2c"); c:px(18, 16, "#7a4e32")  -- tiny mouth
c:px(10, 15, "#f8cfe0"); c:px(11, 15, "#f8cfe0")                      -- left cheek
c:px(25, 15, "#f8cfe0"); c:px(24, 15, "#f8cfe0")                      -- right cheek

-- ---- texture: hand-placed, following the form ----
-- fur flecks (tone-on-tone, following the head curve)
c:px(13, 7, "#c08452"); c:px(20, 6, "#c08452"); c:px(25, 11, "#a06a48")
c:px(9, 14, "#a06a48"); c:px(11, 18, "#8a5a3a")
-- dither at the head light/shade turn (upper left of the muzzle)
-- skirt: weave marks along the tiers, dither at deep border
c:px(13, 20, "#f9c0d8"); c:px(20, 19, "#f9c0d8"); c:px(15, 23, "#f080a0")
c:px(22, 23, "#f080a0"); c:px(12, 24, "#c85a92"); c:px(23, 24, "#c85a92")
-- mint hem weave
c:px(13, 21, "#5cc0aa"); c:px(22, 21, "#5cc0aa")
-- stump: bark ticks on the shaded right side, following the cylinder
c:px(22, 26, "#9a6437"); c:px(23, 27, "#9a6437"); c:px(24, 27, "#9a6437")
c:px(14, 28, "#9a6437")
-- stump top: growth ring (tone-on-tone)
c:ellipse(17.5, 25.6, 6.2, 1.0):edge():each(function(x, y)
  if top:has(x, y) then c:px(x, y, "#c08a50") end end)
c:px(12, 24, "#ecc58a"); c:px(21, 26, "#c08a50")

-- ---- detail: gloss, highlights, small accents ----
c:gloss(c:rrect(14, 18, 21, 21, 1), skirt, { 15, 19 })   -- tier 1 sheen
c:gloss(c:ellipse(17.5, 12.5, 8, 6.9), fur, { 13, 8 })   -- head sheen
-- gold sparkles beside the pal (from the pal's sparkle marks)
c:px(6, 8, "#ffe98a"); c:px(5, 9, "#ffe98a"); c:px(7, 9, "#ffe98a"); c:px(6, 10, "#ffe98a")
c:px(6, 9, "#fffbe8")
c:px(28, 4, "#ffe98a"); c:px(29, 5, "#ffe98a"); c:px(30, 5, "#ffe98a"); c:px(29, 6, "#ffe98a")
c:px(29, 5, "#fffbe8")

local t = c:save(D .. "out/pl-aurs-6-perch.aseprite", D .. "out/pl-aurs-6-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 2)
