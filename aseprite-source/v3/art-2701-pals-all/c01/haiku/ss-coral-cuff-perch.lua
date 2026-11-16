-- Coral Cuff (ss-coral-cuff), perch sprite 36x36. Haiku first pass, c01. Four reefs, one cuff band, pill eyes.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("ss-coral-cuff-perch", 36)
local P = H.P

c:groundShadow(18, 33, 11, 2)
for _, x in ipairs({ 6, 13, 21, 28 }) do
  c:part(c:rect(x, 9, x + 1, 17), "ember", { band = 1 })
  c:part(c:ellipse(x + .5, 8, 2, 2), "ember", { band = 1 })
end
c:part(c:rrect(3, 15, 32, 27, 6), "petal", { band = 2 })
c:stitch({ { 6, 23 }, { 29, 23 } })
c:eyeSmall(11, 18)
c:eyeSmall(23, 18)
c:px(16, 23, P.ink) c:px(17, 23, P.ink) c:px(18, 23, P.ink) c:px(19, 23, P.ink)

H.done(c, "ss-coral-cuff-perch")
