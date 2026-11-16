-- Skerry Seal (mm-skerry-seal), yard 64x64. Haiku first pass, c01. Wayfinder, common, Mistmoor.
-- A grey seal with its head up, lying on a rock by the sea, with a lighthouse behind.
-- quirk: a bark mark beside the open mouth and a lighthouse beam it keeps waiting under.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("mm-skerry-seal-yard", 64)
local P = H.P

-- lighthouse behind (drawn first)
c:part(c:poly { { 45, 44 }, { 48, 14 }, { 53, 14 }, { 56, 44 } }, "sky", { band = 2 })
c:part(c:rect(47, 22, 54, 26), "ember", { noshade = true })
c:part(c:rect(46, 10, 55, 14), "gold", { band = 1 })
c:px(50, 12, P.gold.hi)
c:part(c:poly { { 55, 12 }, { 63, 6 }, { 63, 16 } }, "gold", { noshade = true })

-- the rock
c:part(c:ellipse(30, 53, 26, 7), "stone", { band = 3 })

-- seal body, lying on the rock
local body = c:ellipse(28, 44, 20, 10)
c:part(body, "stone", { band = 3 })

-- head raised at the front
local head = c:ellipse(12, 36, 9, 9)
c:part(head, "stone", { band = 3 })

-- belly lighter patch
c:part(c:ellipse(30, 47, 13, 4), "sky", { noshade = true })

-- face on the head
c:eyeLocked(8, 33)
c:eyeLocked(15, 33)
c:cheek(5, 40)
-- open barking mouth
c:fillMask(c:rect(6, 39, 11, 41), P.ink)
c:px(9, 40, P.petal.base) c:px(10, 40, P.petal.base)
-- bark marks
c:px(2, 37, P.ink) c:px(1, 39, P.ink) c:px(3, 42, P.ink)

-- flippers
c:part(c:poly { { 26, 50 }, { 36, 52 }, { 30, 56 }, { 22, 54 } }, "stone", { band = 1 })

H.done(c, "mm-skerry-seal-yard")
