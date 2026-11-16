-- Ash Wreath (pl-cwy-5), yard sprite 64x64. Haiku first pass.
-- Uncommon, rootwarden. "A hollow wreath of cool grey ash that still hopes for a fire."
-- A grey ring of ash with a hollow middle, a little ember glowing deep inside the hole.
-- quirk: the unlit ember at the top of the hollow.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-cwy-5-yard" }

c:groundShadow(32, 57, 15, 2)
local ring = c:ellipse(32, 33, 20, 19):cut(c:ellipse(32, 33, 12, 11))
c:part(ring, "stone", { band = 3 })
for _, p in ipairs({ {16,33},{48,33},{24,20},{40,20},{24,46},{40,46} }) do
  c:part(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "stone", { band = 1, noshade = true, nopop = true })
end
c:part(c:rect(31, 23, 33, 24), "ember", { band = 1, noshade = true, nopop = true })   -- the hopeful ember
c:eyeLocked(26, 30)
c:eyeLocked(36, 30)
c:fillMask(c:rect(30, 38, 34, 38), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-5-yard.aseprite", png = out .. "pl-cwy-5-yard.png", scale = 1 }
