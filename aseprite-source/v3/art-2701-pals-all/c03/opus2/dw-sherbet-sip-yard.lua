-- Sherbet Sip (dw-sherbet-sip), yard sprite 64x64. Opus second pass (art-2701-pals-all/c03/opus2), built on the
-- Haiku first pass. Common, brewroot, Dunewhisper. "Pours mint tea from very high up and hopes nobody spills."
-- A sherbet-peach Moroccan teapot: pear belly with gold bands and a scalloped engraved trim, foot ring, a domed lid
-- with a stacked finial and a mint sprig, a looped handle. Its long spout swoops up above its own head and a
-- 2 px stream of mint tea falls the whole height into a gold-rimmed tea glass (the first pass had an arm and a
-- 1 px hair of a stream). quirk: one drop has hopped out of the glass, mid-air: it hopes nobody saw.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-sherbet-sip-yard", 64)

local PCH  = { "#7a3434", "#b85a48", "#e08060", "#f4a67a", "#fac69c", "#fee6cc" }
local GOLD = { "#6a3e12", "#a0701c", "#d4a032", "#f0cc5a", "#fbe8a0" }
local MINT = { "#24563a", "#3e8a48", "#6cbc5a", "#a8e07a" }
local TEA  = { "#6a6a1e", "#a8a83a", "#dcd878" }
local GLS  = { "#4a6a7a", "#8ab4be", "#cde6e6" }

c:groundShadow(34, 58, 22, 2.5)

-- looped handle
local hnd = c:ellipse(12, 42, 4.5, 6.5)
hnd:cut(c:ellipse(12, 42, 2, 4))
O.shade(c, hnd, GOLD, { R = 1, amb = .3, cuts = { .25, .5, .72, .9 }, rim = true })

-- foot ring
O.shade(c, c:poly{ { 19, 52 }, { 33, 52 }, { 35, 56 }, { 17, 56 } }, GOLD, { R = 1, amb = .3, cuts = { .25, .5, .72, .9 }, sep = GOLD[1] })
-- belly
local body = c:ellipse(26, 43, 12, 9.5)
body:add(c:ellipse(26, 35, 8, 4))
local bI, bT = O.shade(c, body, PCH, { sphere = { 22, 38, 15 }, amb = .2, wrap = .4, sep = PCH[1], rim = true, bounce = "#9a7ab8", bmax = 2 })
-- gold band with an engraved scallop trim
for x = 14, 38 do
  if body:has(x, 47) then c:put(x, 47, GOLD[3], bT) end
  if body:has(x, 48) then c:put(x, 48, GOLD[2], bT) end
  if body:has(x, 49) and x % 3 == 0 then c:put(x, 49, GOLD[3], bT) end
end
for x = 18, 34 do if body:has(x, 35) then c:put(x, 35, GOLD[3], bT) end end

-- domed lid, stacked finial, mint sprig
O.shade(c, c:ellipse(26, 30, 6.5, 3.5):add(c:rect(20, 30, 32, 32)), GOLD, { R = 2, amb = .3, cuts = { .25, .5, .72, .9 }, sep = GOLD[1], rim = true })
O.shade(c, c:ellipse(26, 24.5, 2, 2), GOLD, { R = 1, amb = .35, cuts = { .25, .5, .72, .9 }, sep = GOLD[1] })
O.flat(c, c:rect(26, 20, 26, 22), GOLD[3], "spire") O.dot(c, 26, 19, GOLD[5])
for _, L in ipairs({ { 29, 25, 1 }, { 30, 22, 1 } }) do
  local lf = c:poly{ { L[1], L[2] }, { L[1] + 3, L[2] - 2 }, { L[1] + 5, L[2] - 1 }, { L[1] + 2, L[2] + 1 } }
  O.shade(c, lf, MINT, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = MINT[1] })
end
O.dots(c, { { 28, 26 }, { 29, 24 } }, MINT[1])

-- long swooping spout, tip high above its head
local sp, sn = O.tube({ { 36, 45 }, { 48, 44 }, { 41, 18 }, { 51, 14 } }, function(t) return 2.4 - t * 1.2 end)
O.shadeN(c, sp, sn, PCH, { amb = .3, wrap = .4, sep = PCH[1], rim = true })
O.dots(c, { { 51, 13 }, { 52, 14 }, { 52, 15 } }, GOLD[4]) O.dot(c, 51, 15, GOLD[2]) -- gold spout tip, turned down

-- face
c:eyeLocked(18, 38) c:eyeLocked(28, 38)
c:cheek(16, 44) c:cheek(32, 44)
O.dots(c, { { 23, 44 }, { 24, 45 }, { 25, 45 }, { 26, 44 } }, P.ink) -- small hopeful smile

-- tea glass with gold rim and painted band
local gl = c:poly{ { 47, 48 }, { 56, 48 }, { 55, 56 }, { 48, 56 } }
O.shade(c, gl, GLS, { R = 1, amb = .4, cuts = { .35, .7 }, sep = GLS[1] })
O.dots(c, { { 48, 50 }, { 49, 50 }, { 50, 50 }, { 51, 50 }, { 52, 50 }, { 53, 50 }, { 54, 50 }, { 55, 50 } }, TEA[2])
O.dots(c, { { 48, 51 }, { 49, 52 }, { 50, 51 }, { 51, 52 }, { 52, 51 }, { 53, 52 }, { 54, 51 } }, GOLD[3])
for y = 53, 55 do for x = 49, 54 do if gl:has(x, y) then c:put(x, y, (x + y) % 2 == 0 and TEA[1] or TEA[2]) end end end
O.dots(c, { { 47, 48 }, { 48, 48 }, { 49, 48 }, { 50, 48 }, { 51, 48 }, { 52, 48 }, { 53, 48 }, { 54, 48 }, { 55, 48 }, { 56, 48 } }, GOLD[4])
O.dots(c, { { 49, 49 }, { 51, 49 }, { 52, 49 }, { 53, 49 } }, TEA[3])

O.shift(c, 0, -2)
O.done(c, "dw-sherbet-sip-yard", function(c)
  -- (drawn after the -2 px shift) the long pour: a 2 px stream, lit left, shaded right, straight down into the glass
  for y = 15, 45 do c:put(51, y, TEA[3]) c:put(52, y, TEA[2]) end
  c:put(50, 45, TEA[3]) c:put(53, 45, TEA[2])
  -- quirk: one hopping drop above the rim
  c:put(58, 42, P.ink) c:put(57, 43, P.ink) c:put(59, 43, P.ink) c:put(58, 44, P.ink) c:put(58, 43, TEA[3])
  c:put(56, 44, TEA[2]) c:put(59, 45, TEA[2])
end)
