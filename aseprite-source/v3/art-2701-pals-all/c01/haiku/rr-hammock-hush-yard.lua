-- Hammock Hush (rr-hammock-hush), yard 64x64. Haiku first pass, c01. Bloomcaller, common, Rainroot.
-- A moss-green pal hanging upside down from a branch, lying in a gold woven hammock.
-- quirk: a thought cloud with three dots, because it calls hanging upside down "thinking".
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("rr-hammock-hush-yard", 64)
local P = H.P

c:groundShadow(32, 60, 14, 2)

-- branch across the top
c:part(c:line({ { 2, 5 }, { 62, 9 } }, 4), "wood")
-- two ropes down to the hammock
c:part(c:line({ { 18, 9 }, { 16, 40 } }, 1), "wood", { noshade = true })
c:part(c:line({ { 46, 9 }, { 48, 40 } }, 1), "wood", { noshade = true })

-- the body, hanging head-down
local body = c:ellipse(32, 36, 15, 17)
c:part(body, "moss", { band = 3 })

-- the gold hammock cradling the belly, woven with a stitch
local ham = c:poly { { 14, 36 }, { 50, 36 }, { 46, 46 }, { 32, 49 }, { 18, 46 } }
c:part(ham, "gold", { band = 2 })
c:stitch({ { 18, 40 }, { 46, 40 } })

-- eyes sit above the hammock, face is upside down
c:eyeLocked(22, 26)
c:eyeLocked(37, 26)
c:cheek(19, 33) c:cheek(43, 33)
for x = 29, 34 do c:px(x, 30, P.ink) end

-- thought cloud with three dots
c:cloud(44, 26, 16, P.sky.hi)
c:px(48, 20, P.ink) c:px(52, 20, P.ink) c:px(56, 20, P.ink)

H.done(c, "rr-hammock-hush-yard")
