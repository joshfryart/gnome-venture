-- pack-kit PASS B (polish over A). 32x32 pack header icon (step 3 "Everyday kit"): a small leather satchel with a
-- steel trowel poking out top-left and a teal watering-can spout + rose poking out top-right.
-- B: satchel re-cut (rounder bottom, flap with a central tongue, darker side gusset, narrow front strap) so it no
-- longer reads as a chest; stitched hem follows the flap and tongue; 3 px tube spout and a bigger rose with holes,
-- kept inside the margin; trowel blade enlarged with a centre ridge and specular; bigger falling drop.
-- quirk: one drop of water falling from the rose.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local X = dofile(DIR .. "/../lib/hpx.lua").init(HP)
local K = X.K
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "pack-kit.pB"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
local ink = "#2b1c26"

local LEATH = { "#4a2420", "#6e3328", "#93472f", "#b8653a", "#d68a50", "#f0b478" }
local FLAP  = { "#3e1e1e", "#5c2a26", "#7e3a2c", "#a0503a", "#c26c48", "#e09466" }
local STEEL = { "#444663", "#5d607a", "#74758c", "#aaa9b8", "#d0d0da", "#eeeef4" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local TEAL  = { "#1f4a5a", "#2a6a78", "#3a8f96", "#5fc4c8", "#9ae4dc" }
local BRASS = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- trowel: 3 px wooden handle into the bag, steel leaf blade pointing up-left with a centre ridge
local hm, hn = X.cyl(9.5, 17, 7, 11, function() return 1.5 end)
X.tone(c, hm, X.light(hn, { amb = 0.2 }), WOOD)
local blade = c:poly{ {2, 2}, {8, 3}, {10, 6}, {9, 10}, {5, 11}, {2, 7} }
X.tone(c, blade, X.light(X.pillow(blade, 2), { amb = 0.25 }), STEEL)
for _, p in ipairs{ {3,3},{4,3},{5,4},{6,5},{7,6},{7,7} } do c:px(p[1], p[2], STEEL[4]) end   -- ridge
for _, p in ipairs{ {4,4},{5,5},{6,6} } do c:px(p[1], p[2], STEEL[3]) end                      -- ridge shade side
c:px(3, 4, STEEL[6]) c:px(3, 5, STEEL[6]) c:px(4, 6, STEEL[5])                                -- specular
c:px(6, 11, STEEL[2]) c:px(7, 11, STEEL[3]) c:px(8, 11, STEEL[2])                             -- ferrule

-- spout: 3 px teal tube up-right, rose disc with holes at the tip
local sm, sn = X.cyl(20, 18, 25.5, 9, function() return 1.5 end)
X.tone(c, sm, X.light(sn, { amb = 0.2 }), TEAL)
local rose = c:ellipse(26.5, 5.5, 3, 3)
X.tone(c, rose, X.light(X.sphere(26.5, 5.5, 3, rose), { amb = 0.25 }), TEAL)
c:ellipse(26.5, 5.5, 3, 3):cut(c:ellipse(26.5, 5.5, 2, 2)):each(function(x, y)   -- rolled rim of the rose
  c:put(x, y, (x + y <= 31) and TEAL[5] or TEAL[2]) end)
c:paint({ ".a.", "a.a", ".a." }, 25, 4, { a = TEAL[1] })                          -- holes
-- drop (quirk)
c:paint({ ".s.", "sAs", "sas", ".s." }, 27, 11, { s = "sea.shade", A = "#e4fbff", a = "sea.base" })

-- satchel body with a darker side gusset on the right
local bag = c:rrect(4, 15, 24, 29, 5)
X.tone(c, bag, X.light(X.pillow(bag, 3), { amb = 0.35 }), LEATH)
for y = 18, 26 do c:put(23, y, LEATH[2]) c:put(24, y, LEATH[1]) end
-- flap: band + central tongue
local flap = c:rrect(4, 15, 24, 21, 3):add(c:rrect(11, 15, 17, 25, 2))
X.tone(c, flap, X.light(X.pillow(flap, 2), { amb = 0.1 }), FLAP)
for x = 6, 22 do if not flap:has(x, 22) then c:put(x, 22, LEATH[2]) end end    -- shadow under the flap band
for y = 22, 26 do c:put(10, y, LEATH[2]) c:put(18, y, LEATH[2]) end            -- shadow beside the tongue
c:px(6, 16, FLAP[6]) c:px(7, 16, FLAP[6])                                       -- pop
c:stitch{ {6, 19}, {11, 19}, {11, 23}, {16, 23}, {16, 19}, {22, 19} }
-- front strap and buckle
for y = 25, 28 do c:put(13, y, FLAP[2]) c:put(14, y, FLAP[4]) c:put(15, y, FLAP[3]) end
c:paint({ "BBBBb", "B.p.b", "B.p.b", "bbbbb" }, 12, 22, { b = BRASS[1], B = BRASS[3], p = BRASS[2] })
c:px(12, 22, BRASS[4])
-- worn lighter scuff on the bag front
c:px(7, 25, LEATH[5]) c:px(8, 25, LEATH[5]) c:px(20, 26, LEATH[4])
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
