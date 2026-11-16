-- Tide Tuck (ss-tide-tuck), yard 64x64. Haiku first pass, c00. Brewroot, common, Sunsprinkle.
-- A sand-gold dome tucked into the beach, with a sea-blue wave curling up behind it.
-- quirk: a foam curl on the wave's crest (it tucks in just before the wave lands).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("ss-tide-tuck-yard", 64)

-- the wave, drawn first
c:part(c:poly{ { 2, 60 }, { 2, 46 }, { 10, 36 }, { 20, 30 }, { 32, 34 }, { 44, 26 }, { 56, 30 }, { 62, 42 }, { 62, 60 } }, "sea")
-- foam curl on the crest (quirk)
c:fillMask(c:line({ { 24, 30 }, { 28, 26 }, { 34, 27 } }, 2), P.cream)
-- sand dome, tucked in
local sand = c:ellipse(32, 46, 19, 14)
sand:cut(c:rect(0, 56, 63, 63))
c:part(sand, "gold", { band = 3 })
for _, p in ipairs({ { 20, 50 }, { 26, 54 }, { 40, 52 }, { 44, 48 } }) do c:px(p[1], p[2], P.gold.shade) end
-- face
c:eyeLocked(24, 42)
c:eyeLocked(36, 42)
c:cheek(19, 47) c:cheek(42, 47)
c:px(31, 45, P.gold.hi) c:px(32, 45, P.gold.hi)
c:px(31, 46, P.gold.deep) c:px(32, 46, P.gold.deep)
for _, p in ipairs({ { 29, 49 }, { 30, 50 }, { 31, 50 }, { 32, 50 }, { 33, 49 } }) do c:px(p[1], p[2], P.ink) end

M.done(c, "ss-tide-tuck-yard")
