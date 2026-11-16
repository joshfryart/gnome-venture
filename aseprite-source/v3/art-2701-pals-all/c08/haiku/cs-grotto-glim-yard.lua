-- Grotto Glim (cs-grotto-glim), yard sprite 64x64. Haiku pass, c08.
-- Uncommon, seedkeeper. A segmented cave glowworm in dusk-violet, glowing gold, with a round "ooh" mouth.
-- quirk: its glow spots and the little "ooh" mouth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-grotto-glim-yard", 64)

c:groundShadow(32, 58, 14, 2)
-- antennae with glowing tips
c:part(c:line({ { 26, 18 }, { 22, 8 } }, 1), "dusk")
c:part(c:line({ { 38, 18 }, { 42, 8 } }, 1), "dusk")
c:px(22, 7, P.gold.hi)
c:px(42, 7, P.gold.hi)
-- segments, tail to head
c:part(c:ellipse(32, 46, 14, 8), "dusk")
c:part(c:ellipse(32, 36, 11, 7), "dusk", { sep = true })
c:part(c:ellipse(32, 26, 11, 8), "dusk", { sep = true })
-- glow spots
c:px(24, 46, P.gold.hi)
c:px(40, 40, P.gold.hi)
c:px(28, 52, P.gold.base)
c:sparkle(18, 42)
c:sparkle(46, 34)
c:px(38, 30, P.gold.base)
c:eyeLocked(24, 21)
c:eyeLocked(36, 21)
c:fillMask(c:ellipse(32, 30, 2, 2), P.ink)
c:fillMask(c:ellipse(32, 31, 1, 1), P.gold.base)

H.done(c, "cs-grotto-glim-yard")
