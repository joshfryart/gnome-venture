-- Anemone Nudge (cs-anemone-nudge), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: a little clownfish at its side, being nudged.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-anemone-nudge-perch", 36)

c:groundShadow(18, 33, 8, 1.5)
c:part(c:poly{ { 6, 29 }, { 2, 26 }, { 2, 32 } }, "ember")
c:part(c:ellipse(7, 29, 3, 2), "ember")
c:fillMask(c:line({ { 5, 27 }, { 5, 31 } }, 1), P.cream)
local fr = c:line({ { 12, 24 }, { 11, 30 } }, 1)
for _, x in ipairs({ 15, 18, 21, 24 }) do
  fr:add(c:line({ { x, 24 }, { x + (x % 2 == 0 and -1 or 1), 30 } }, 1))
end
c:part(fr, "petal", { band = 1 })
c:part(c:line({ { 25, 25 }, { 20, 28 }, { 12, 29 } }, 2), "petal")
c:part(c:ellipse(18, 20, 8, 6), "petal")
c:px(14, 15, P.cream) c:px(21, 13, P.cream)
c:eyeSmall(14, 17)
c:eyeSmall(20, 17)
c:fillMask(c:line({ { 15, 22 }, { 18, 23 }, { 21, 22 } }, 1), P.ink)

H.done(c, "cs-anemone-nudge-perch")
