-- Lotus Lump (mt-lotus-lump), yard 64x64. Haiku first pass, c07. Bloomcaller, common, Monsoontangle.
-- A pink petal lump asleep on a notched lotus pad, lids down.
-- quirk: rain drops land on it and it sleeps through them (sea dots around it).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-lotus-lump-yard", 64)

-- lotus pad with a notch
local pad = c:ellipse(32, 52, 24, 6)
pad:cut(c:poly{ { 32, 52 }, { 40, 46 }, { 40, 58 } })
c:part(pad, "moss", { band = 2 })
-- petals (behind the lump)
c:part(c:poly{ { 22, 28 }, { 17, 18 }, { 27, 24 } }, "petal")
c:part(c:poly{ { 32, 25 }, { 32, 12 }, { 38, 25 } }, "petal")
c:part(c:poly{ { 42, 28 }, { 47, 18 }, { 37, 24 } }, "petal")
-- lump body
c:part(c:ellipse(32, 36, 14, 12), "petal", { band = 3 })
-- sleeping eyes: locked eyes with the top rows covered by the lid
c:eyeLocked(25, 35)
c:eyeLocked(35, 35)
c:fillMask(c:rect(25, 35, 29, 36), P.petal.deep)
c:fillMask(c:rect(35, 35, 39, 36), P.petal.deep)
c:cheek(21, 42) c:cheek(40, 42)
c:px(31, 43, P.ink) c:px(32, 43, P.ink)
-- rain drops (quirk)
c:px(8, 12, P.sea.base) c:px(56, 10, P.sea.base) c:px(52, 24, P.sea.base) c:px(12, 26, P.sea.base)

M.done(c, "mt-lotus-lump-yard")
