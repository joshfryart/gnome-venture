-- Anemone Nudge (cs-anemone-nudge), yard sprite 64x64. Haiku pass, c08.
-- Common, seedkeeper. A pink anemone dome with a fringe of tentacles, nudging a clownfish home with one arm.
-- quirk: the clownfish, being nudged along the reef.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-anemone-nudge-yard", 64)

c:groundShadow(32, 59, 18, 2.5)
-- clownfish being nudged
c:part(c:poly{ { 8, 52 }, { 2, 47 }, { 2, 57 } }, "ember")
c:part(c:ellipse(15, 52, 7, 4.5), "ember")
c:fillMask(c:line({ { 11, 48 }, { 11, 56 } }, 1), P.cream)
c:fillMask(c:line({ { 18, 48 }, { 18, 56 } }, 1), P.cream)
c:px(20, 50, P.ink)
-- fringe of tentacles
local fr = c:line({ { 22, 42 }, { 20, 50 } }, 2)
for _, x in ipairs({ 27, 32, 37, 42 }) do
  fr:add(c:line({ { x, 42 }, { x + (x % 2 == 0 and -2 or 2), 50 } }, 2))
end
c:part(fr, "petal", { band = 1 })
-- the nudging arm
c:part(c:line({ { 44, 44 }, { 36, 50 }, { 24, 52 } }, 3), "petal")
-- dome
c:part(c:ellipse(32, 30, 17, 13), "petal")
c:px(24, 22, P.cream) c:px(31, 17, P.cream) c:px(39, 22, P.cream)
c:eyeLocked(23, 26)
c:eyeLocked(36, 26)
c:cheek(19, 33)
c:cheek(42, 33)
c:fillMask(c:line({ { 28, 37 }, { 32, 39 }, { 36, 37 } }, 1), P.ink)

H.done(c, "cs-anemone-nudge-yard")
