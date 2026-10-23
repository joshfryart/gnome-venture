-- scenes/home-cottage : 480x270, drawn 240x135 written 2x. Warm back wall, window upper-left, hearth right, counter strip bottom-left (hides the bust cut, y 215..270).
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 240, h = 135, mode = "scene", out = 2, ol = 1, olx = 1 }
local W = 240
local WOOD = GV.ramp("#b07a45", { shade = "#8a4f2a", deep = "#8a4f2a", bounce = "#8a4f2a", rim = "#d9a660" })
local STONE = GV.ramp("#8b8f96", { shade = "#5b6470", deep = "#5b6470", bounce = "#5b6470", rim = "#c9c5bc" })
-- back wall: warm plaster, five hard bands (lit from the window side), plank seams every 24 px
c:bands(c:rect(0, 0, W - 1, 99), { "#f1d9a0", "#ecce90", "#e6c383", "#dfb877", "#d9ad6b" }, { dir = "h" })
for x = 12, W - 1, 24 do c:fill(c:rect(x, 8, x, 99), "#c9a96e") end
-- ceiling beam and floor
c:fill(c:rect(0, 0, W - 1, 6), "#8a4f2a"); c:fill(c:rect(0, 7, W - 1, 7), "#5e2f1e")
c:fill(c:rect(0, 100, W - 1, 134), "#a8582f")
for y = 106, 134, 7 do c:fill(c:rect(0, y, W - 1, y), "#8a4f2a") end                    -- floorboard lines
c:fill(c:rect(0, 100, W - 1, 100), "#d9a660")                                           -- skirting rim
-- window upper-left: frame, sky pane, cross bars, sill; flat light patch on the wall below
c:fill(c:rect(18, 22, 51, 24), "#2a1a10")                                              -- drop shadow row above
c:part(c:rect(18, 14, 50, 52), WOOD, { gloss = false, cres = 3 })
c:fill(c:rect(21, 17, 47, 49), "#a9d6ea"); c:fill(c:rect(21, 17, 47, 24), "#c8ecdc")
c:fill(c:rect(33, 17, 34, 49), "#b07a45"); c:fill(c:rect(21, 32, 47, 33), "#b07a45")
c:part(c:rect(15, 52, 53, 55), WOOD, { gloss = false, flat = true })                   -- sill
c:fill(c:poly({ { 52, 60 }, { 74, 60 }, { 92, 98 }, { 62, 98 } }), "#f5cf6a")           -- light patch (lit plaster)
-- hearth right: stone block, dark opening, flame, pot on a hook
c:part(c:rect(168, 34, 224, 100), STONE, { gloss = false, cres = 4 })
c:fill(c:rect(180, 62, 212, 100), "#35161f")
c:fill(c:ellipse(196, 96, 8, 6), "#f08a24"); c:fill(c:ellipse(196, 97, 4, 4), "#f5cf6a")
c:part(c:rect(160, 28, 232, 36), WOOD, { gloss = false, cres = 2 })                     -- mantel
c:part(c:ellipse(196, 80, 9, 6), GV.ramp("#5b6470"), { gloss = false, flat = true })    -- cauldron
-- shelf with jars (mid-right), kept clear of the left-centre villager slot
c:part(c:rect(118, 44, 156, 46), WOOD, { gloss = false, flat = true })
for i, col in ipairs({ "#d6322b", "#7ab55c", "#f5cf6a" }) do c:part(c:rrect(120 + (i - 1) * 12, 34, 128 + (i - 1) * 12, 43, 1), col, { gloss = false, flat = true }) end
-- rug on the floor (stitched felt edge)
c:fill(c:ellipse(150, 120, 34, 7), "#ae2a2a"); c:fill(c:ellipse(150, 120, 30, 5), "#d6322b")
for x = 118, 182 do if x % 3 < 2 then c:px(x, 114 + math.floor(0.3 * math.abs(x - 150) / 6), "#f5cf6a") end end
-- counter bottom-left: raised, outlined, hides the bust cut (native y 107..134, x 0..118)
c:part(c:rect(-2, 108, 118, 136), WOOD, { cres = 5, deep = 2 })
c:part(c:rect(-2, 104, 120, 109), GV.ramp("#d9a660", { shade = "#b07a45", deep = "#b07a45", bounce = "#b07a45" }), { gloss = false, cres = 2 })
c:fill(c:rect(0, 116, 116, 116), "#8a4f2a")                                             -- plank seam
c:fill(c:ellipse(30, 101, 6, 3), "#f5cf6a"); c:fill(c:ellipse(86, 101, 5, 3), "#7ab55c")  -- bowl of grain, bundle of herbs
H.done(c, "home-cottage", "scenes/home-cottage.png", 32, true)
