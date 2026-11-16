-- Stitch Crow (mh-stitch-crow), yard 64x64. Haiku first pass, c00. Thornblade, uncommon, Maizehollow.
-- A small violet-black crow wearing a too-big straw hat with an ember band; a gold beak.
-- quirk: a cream measuring tape hangs round its neck (very serious about hats).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-stitch-crow-yard", 64)

c:groundShadow(32, 59, 13, 3)
-- tail, body, wing, head
c:part(c:poly{ { 26, 46 }, { 14, 56 }, { 20, 58 }, { 32, 52 } }, "dusk")
c:part(c:ellipse(32, 44, 14, 12), "dusk")
c:part(c:poly{ { 20, 36 }, { 12, 46 }, { 20, 50 }, { 27, 42 } }, "dusk", { sep = true })
c:part(c:ellipse(32, 30, 10, 9), "dusk")
-- beak with a cream glint
c:part(c:poly{ { 40, 30 }, { 47, 33 }, { 40, 35 } }, "gold")
c:px(41, 32, P.cream)
-- hat: straw crown, brim, ember band
c:part(c:rrect(24, 6, 40, 18, 3), "gold")
c:part(c:ellipse(32, 19, 17, 3), "gold")
c:fillMask(c:rect(24, 15, 40, 15), P.ember.base)
-- face
c:eyeLocked(26, 26)
c:eyeLocked(34, 26)
-- measuring tape (quirk)
c:fillMask(c:line({ { 24, 38 }, { 26, 46 }, { 31, 52 } }, 1), P.cream)
c:px(25, 41, P.ink) c:px(27, 45, P.ink) c:px(29, 49, P.ink)

M.done(c, "mh-stitch-crow-yard")
