-- Bromeliad Bolt (rr-bromeliad-bolt), yard 64x64. Haiku first pass, c01. Thornblade, uncommon, Rainroot.
-- An ember-red body crowned with spiky moss leaves and a rain-filled cup in the middle.
-- quirk: the cup of rain in its crown, with one stubby arm held over it so nobody can share.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("rr-bromeliad-bolt-yard", 64)
local P = H.P

c:groundShadow(32, 59, 17, 3)

-- spiky leaves fanning out of the crown (behind the body)
local leaves = {
  { { 24, 36 }, { 4, 20 }, { 10, 17 }, { 28, 30 } },
  { { 27, 31 }, { 17, 6 }, { 24, 8 }, { 33, 28 } },
  { { 33, 28 }, { 39, 6 }, { 47, 8 }, { 39, 31 } },
  { { 40, 36 }, { 60, 20 }, { 60, 25 }, { 44, 40 } },
}
for _, pts in ipairs(leaves) do
  c:part(c:poly(pts), "moss", { band = 2 })
end
-- cream thorn tips
c:px(4, 20, P.cream) c:px(17, 6, P.cream) c:px(39, 6, P.cream) c:px(60, 20, P.cream)

-- the body
local body = c:ellipse(32, 46, 17, 13)
c:part(body, "ember", { band = 3 })

-- the rain cup on top of the body
local cup = c:ellipse(32, 33, 7, 3)
c:part(cup, "sea", { band = 2 })
c:px(29, 33, P.sky.hi) c:px(30, 33, P.sky.hi)
c:px(35, 32, P.cream)

-- a stubby arm over the cup
c:part(c:rrect(37, 30, 41, 35, 2), "ember", { noshade = true })

-- face
c:eyeLocked(23, 45)
c:eyeLocked(36, 45)
c:cheek(19, 51) c:cheek(42, 51)
for x = 29, 33 do c:px(x, 52, P.ink) end

H.done(c, "rr-bromeliad-bolt-yard")
