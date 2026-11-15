-- Bromeliad Bolt (rr-bromeliad-bolt), perch sprite 36x36. Haiku first pass, c01. Spiky crown, rain cup, ember body.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("rr-bromeliad-bolt-perch", 36)
local P = H.P

c:groundShadow(18, 33, 9, 2)
local leaves = {
  { { 12, 22 }, { 2, 12 }, { 6, 10 }, { 15, 19 } },
  { { 15, 18 }, { 10, 3 }, { 15, 4 }, { 19, 17 } },
  { { 19, 17 }, { 25, 3 }, { 30, 6 }, { 24, 18 } },
  { { 23, 20 }, { 33, 11 }, { 33, 15 }, { 25, 23 } },
}
for _, pts in ipairs(leaves) do c:part(c:poly(pts), "moss", { band = 1 }) end
c:part(c:ellipse(18, 24, 11, 8), "ember", { band = 2 })
c:part(c:ellipse(18, 17, 4, 2), "sea", { band = 1 })
c:px(17, 17, P.sky.hi)
c:eyeSmall(13, 23)
c:eyeSmall(21, 23)
c:px(16, 27, P.ink) c:px(17, 27, P.ink) c:px(18, 27, P.ink) c:px(19, 27, P.ink)

H.done(c, "rr-bromeliad-bolt-perch")
