-- Highland Ring (rr-highland-ring), yard 64x64. Haiku first pass, c01. Rootwarden, uncommon, Rainroot.
-- A cloud-cold stone hoop with a snow cap on top and a sky-blue hole showing the sky.
-- quirk: a little summit flag on a wood pole, planted on top of the hoop.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("rr-highland-ring-yard", 64)
local P = H.P

c:groundShadow(32, 60, 19, 3)

-- summit pole and flag (behind the hoop top)
c:part(c:rect(31, 2, 32, 16), "wood", { noshade = true })
c:part(c:poly { { 32, 3 }, { 42, 6 }, { 32, 10 } }, "ember", { noshade = true })
c:px(33, 5, P.ember.hi)

-- the hoop
local outer = c:ellipse(32, 38, 21, 21)
local hole = c:ellipse(32, 36, 9, 7)
local hoop = outer:copy():cut(hole)
c:part(hoop, "stone", { band = 3 })

-- snow cap on the top arc
local snow = hoop:copy():clip(c:rect(0, 0, 63, 23))
c:fillMask(snow, P.cream)

-- the sky in the hole
c:part(hole, "sky", { band = 2, pop = { x = 27, y = 33, horizontal = true } })
c:sparkle(36, 34)

-- face on the lower band
c:eyeLocked(20, 46)
c:eyeLocked(38, 46)
c:cheek(16, 53) c:cheek(44, 53)
for x = 29, 34 do c:px(x, 51, P.ink) end

H.done(c, "rr-highland-ring-yard")
