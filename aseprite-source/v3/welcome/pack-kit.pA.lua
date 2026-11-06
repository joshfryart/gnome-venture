-- pack-kit PASS A. 32x32 pack header icon (step 3 "Everyday kit"): a small leather satchel, a steel trowel
-- poking out top-left and a teal watering-can spout with its rose poking out top-right.
-- Leather: pillow light snapped to 6 tones, flap with a stitched hem, brass buckle. Steel: bevel, bright edge,
-- specular streak. Painted spout: cylinder light, rose with dark holes.
-- quirk: one drop of water falling from the rose.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local X = dofile(DIR .. "/../lib/hpx.lua").init(HP)
local K = X.K
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "pack-kit.pA"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
local ink = "#2b1c26"

local LEATH = { "#4a2420", "#6e3328", "#93472f", "#b8653a", "#d68a50", "#f0b478" }
local FLAP  = { "#3e1e1e", "#5c2a26", "#7e3a2c", "#a0503a", "#c26c48", "#e09466" }
local STEEL = { "#444663", "#5d607a", "#74758c", "#aaa9b8", "#d0d0da", "#eeeef4" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local TEAL  = { "#1f4a5a", "#2a6a78", "#3a8f96", "#5fc4c8", "#9ae4dc" }
local BRASS = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- trowel: wooden handle into the bag, steel leaf blade pointing up-left
local hm, hn = X.cyl(10, 16, 7.5, 10.5, function() return 1.2 end)
X.tone(c, hm, X.light(hn, { amb = 0.2 }), WOOD)
local blade = c:poly{ {2, 1}, {7, 3}, {9, 7}, {8, 10}, {5, 10}, {2, 6} }
local bn = X.pillow(blade, 2)
X.tone(c, blade, X.light(bn, { amb = 0.25 }), STEEL)
c:px(3, 3, STEEL[6]) c:px(4, 4, STEEL[6]) c:px(5, 5, STEEL[5])   -- specular streak
c:px(6, 10, STEEL[2]) c:px(7, 10, STEEL[2])                    -- ferrule

-- spout: teal tube from inside the bag up-right, rose at the tip
local sm, sn = X.cyl(21, 20, 27, 7, function() return 1.2 end)
X.tone(c, sm, X.light(sn, { amb = 0.2 }), TEAL)
local rose = c:ellipse(27.5, 5.5, 2.5, 2.5)
X.tone(c, rose, X.light(X.sphere(27.5, 5.5, 2.5, rose), { amb = 0.2 }), TEAL)
c:px(27, 4, TEAL[1]) c:px(29, 5, TEAL[1]) c:px(28, 7, TEAL[1])
-- drop (quirk)
c:paint({ ".s.", "sAs", "sas" }, 28, 10, { s = "sea.shade", A = "sea.hi", a = "sea.base" })

-- satchel body
local bag = c:rrect(3, 14, 26, 29, 3)
X.tone(c, bag, X.light(X.pillow(bag, 3), { amb = 0.2 }), LEATH)
-- flap with rounded bottom
local flap = c:rrect(3, 14, 26, 22, 3)
local fb = X.light(X.pillow(flap, 2), { amb = 0.2 })
X.tone(c, flap, fb, FLAP)
for x = 5, 24 do c:put(x, 23, LEATH[1]) end          -- shadow under the flap
c:stitch{ {5, 20}, {24, 20} }
-- strap + buckle
for y = 19, 26 do c:put(13, y, FLAP[2]) c:put(14, y, FLAP[3]) c:put(15, y, FLAP[3]) c:put(16, y, FLAP[2]) end
c:paint({ "bBBBb", "B...b", "Bpp.b", "Bp..b", "bbbbb" }, 12, 21, { b = BRASS[2], B = BRASS[4], p = FLAP[1] })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
