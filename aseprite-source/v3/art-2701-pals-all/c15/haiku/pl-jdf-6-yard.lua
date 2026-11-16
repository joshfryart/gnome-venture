-- Lotus Perch (pl-jdf-6), yard 64x64. Rare, bloomcaller. A pink lotus with a face in its cup.
-- quirk: a jade dragonfly naps on a petal, humming (ink notes rise from it).
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-jdf-6-yard", 64), H.P
c:part(c:line({ {32,52},{32,62} }, 3), "moss")
c:part(c:ellipse(32, 20, 8, 12), "petal", { sep = true })
c:part(c:ellipse(18, 30, 7, 10), "petal", { sep = true })
c:part(c:ellipse(46, 30, 7, 10), "petal", { sep = true })
c:part(c:ellipse(24, 42, 8, 7), "petal", { sep = true })
c:part(c:ellipse(40, 42, 8, 7), "petal", { sep = true })
c:part(c:ellipse(32, 48, 17, 9), "petal", { sep = true })
c:px(30, 14, P.gold.hi) c:px(32, 12, P.gold.hi) c:px(34, 14, P.gold.hi)
c:eyeLocked(24, 45)
c:eyeLocked(35, 45)
c:cheek(20, 51)
c:cheek(42, 51)
for _, p in ipairs({ {30,53},{31,54},{32,54},{33,53} }) do c:px(p[1], p[2], P.ink) end
c:part(c:line({ {40,18},{52,18} }, 2), "moss")
c:part(c:ellipse(45, 15, 3, 2), "sky")
c:part(c:ellipse(49, 14, 3, 2), "sky")
c:part(c:ellipse(53, 18, 2, 2), "moss")
c:fillMask(c:line({ {57,12},{57,6},{60,4} }, 1), P.ink)
H.done(c, "pl-jdf-6-yard")
