-- Snorkel Snip (cs-snorkel-snip), yard sprite 64x64. Haiku pass, c08.
-- Common, seedkeeper. A round pink reef-blob with a snorkel up the side and a clam shell in each hand.
-- quirk: the snorkel tube, and the shells held up as if it is about to swap them.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-snorkel-snip-yard", 64)

c:groundShadow(32, 56, 14, 2.5)
c:part(c:ellipse(24, 52, 5, 3), "petal")
c:part(c:ellipse(40, 52, 5, 3), "petal")
c:part(c:line({ { 18, 42 }, { 10, 34 } }, 3), "petal")
c:part(c:line({ { 46, 42 }, { 54, 34 } }, 3), "petal")
c:part(c:ellipse(8, 29, 5, 4), "gold")
c:part(c:ellipse(56, 29, 5, 4), "gold")
c:part(c:ellipse(32, 38, 15, 13), "petal")
c:part(c:line({ { 40, 27 }, { 46, 10 }, { 48, 6 } }, 2), "sea")
c:fillMask(c:line({ { 45, 6 }, { 50, 6 } }, 1), P.sea.deep)
c:eyeLocked(24, 31)
c:eyeLocked(36, 31)
c:cheek(19, 38)
c:cheek(42, 38)
c:fillMask(c:line({ { 29, 42 }, { 32, 44 }, { 35, 42 } }, 1), P.ink)

H.done(c, "cs-snorkel-snip-yard")
