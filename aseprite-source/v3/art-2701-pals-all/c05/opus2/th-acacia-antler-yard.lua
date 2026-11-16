-- Acacia Antler (th-acacia-antler), yard sprite 64x64. Opus second pass (art-2701-pals-all/c05/opus2) over the Haiku pass.
-- Rootwarden, uncommon, Thornacre. "Grows antler-like twigs and hangs weaver nests from every one."
-- A round acacia-bush critter: a ball of fine olive leaflets (feathery texture, rim light, cool bounce) with two
-- leaf ears, a little bark nose and stubby bark legs. Out of its crown grow two branching twig antlers with pale
-- acacia thorns, and from the twig tips hang woven straw weaver nests on short fibres, each with a
-- downward entrance spout.
-- Fixes vs Haiku: antlers branch (three tips each) and carry thorns, nests are woven pouches that hang instead
-- of gold balls stuck on the ends, body has leaflet texture instead of a flat green disc, ears give it a
-- deer read.
-- quirk: a tiny yellow weaver bird peeks out of one nest's spout.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-acacia-antler-yard", 64)

local LEAF  = { "#1f3a2a", "#2f5a35", "#4a7d3c", "#6fa047", "#9cc25a", "#c8e080" }
local BARK  = { "#2e1f1f", "#4d3326", "#704a32", "#946a45", "#b88c5c", "#d6ae7c" }
local STRAW = { "#5a3e1a", "#8a6428", "#b88f3a", "#dcb85a", "#f2dc8a" }
local BIRD  = { "#8a6a12", "#e0b820", "#f8e060" }
local THORN = "#efe4c8"
local BNC   = "#4f6a7a"

c:groundShadow(32, 58, 14, 2.5)
for _, lx in ipairs({ 26, 38 }) do
  O.shade(c, c:rrect(lx - 2, 50, lx + 2, 56, 1), BARK, { R = 1, amb = .3, sep = BARK[1], rim = true })
  O.mark(c, { { lx - 2, 56 }, { lx - 1, 56 }, { lx, 56 }, { lx + 1, 56 }, { lx + 2, 56 } }, BARK[1]) -- hooves
end

-- antlers: trunk + two tines each (drawn before the body so the body overlaps the roots)
local branches = {
  { { 28, 36 }, { 25, 27 }, { 20, 19 }, { 17, 8 } },
  { { 23, 24 }, { 26, 20 }, { 28, 17 }, { 29, 12 } },
  { { 20, 19 }, { 16, 18 }, { 12, 17 }, { 8, 14 } },
  { { 36, 36 }, { 39, 27 }, { 44, 19 }, { 47, 8 } },
  { { 41, 24 }, { 38, 20 }, { 36, 17 }, { 35, 12 } },
  { { 44, 19 }, { 48, 18 }, { 52, 17 }, { 56, 14 } },
}
for i, b in ipairs(branches) do
  local m, n = O.tube(b, function(t) return (i % 3 == 1) and (1.6 - t * .7) or (1.1 - t * .4) end)
  O.shadeN(c, m, n, BARK, { amb = .25, wrap = .35, sep = BARK[1], rim = true })
end
-- thorns: pale paired spikes
O.dots(c, { { 23, 28 }, { 19, 13 }, { 15, 16 }, { 29, 18 }, { 41, 28 }, { 45, 13 }, { 49, 16 }, { 35, 18 } }, THORN)

-- nests hanging from the tips: fibre, woven pouch, spout
local nests = { { 8, 14, 8, 20 }, { 29, 12, 30, 17 }, { 56, 14, 56, 20 }, { 17, 8, 14, 12 }, { 35, 12, 34, 17 }, { 47, 8, 50, 12 } }
local spouts = {}
for i, n in ipairs(nests) do
  local tx, ty, cx, cy = n[1], n[2], n[3], n[4]
  local big = (i == 1 or i == 3)
  local ry = big and 3 or 2
  for y = ty + 1, math.floor(cy - ry) do O.dot(c, tx + (cx - tx) * (y - ty) // math.max(1, math.floor(cy - ry) - ty), y, STRAW[2]) end
  local m = c:ellipse(cx, cy, big and 2.5 or 1.5, ry)
  local nI, nT = O.shade(c, m, STRAW, { R = 1, amb = .3, wrap = .4, cuts = { .22, .42, .62, .82 }, sep = STRAW[1], rim = true })
  -- weave: alternating dark ticks
  O.tex(c, nI, nT, STRAW, function(x, y, k) if (x + y * 2) % 3 == 0 and k >= 2 then return -1 end end)
  -- entrance spout under the pouch
  local sy = math.floor(cy + ry) + 1
  O.flat(c, c:rect(cx, sy, cx, sy + 1), STRAW[3], "spout")
  O.dot(c, cx, sy + 1, STRAW[1])
  spouts[i] = { cx, sy }
end

-- body: ball of leaflets
local body = c:ellipse(32, 43, 12.5, 10)
local bI, bT = O.shade(c, body, LEAF, { sphere = { 29, 37, 14 }, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, LEAF, function(x, y, i)
  local face = x > 22 and x < 42 and y > 34 and y < 47
  if face then return nil end
  if (x * 2 + y) % 5 == 0 and y % 2 == 0 and i <= 5 then return 1 end   -- lit leaflet tips
  if (x * 2 + y) % 5 == 2 and y % 2 == 1 and i >= 2 then return -1 end -- leaflet gaps
end)
-- leaf ears
for _, e in ipairs({ { { 23, 36 }, { 18, 33 }, { 15, 33 }, { 19, 38 }, { 22, 39 } }, { { 41, 36 }, { 46, 33 }, { 49, 33 }, { 45, 38 }, { 42, 39 } } }) do
  local m = c:poly(e)
  O.shade(c, m, LEAF, { R = 1, amb = .35, wrap = .4, sep = LEAF[1], rim = true })
end
O.mark(c, { { 17, 34 }, { 18, 35 } }, LEAF[2]) O.mark(c, { { 47, 34 }, { 46, 35 } }, LEAF[2]) -- midribs

-- face
c:eyeLocked(24, 36) c:eyeLocked(35, 36)
O.shade(c, c:ellipse(32, 43, 2, 1.5), BARK, { R = 1, amb = .45, sep = BARK[1] }) -- bark nose
O.dot(c, 31, 42, BARK[6])
O.mark(c, { { 30, 46 }, { 31, 47 }, { 32, 47 }, { 33, 47 }, { 34, 46 } }, P.ink)
c:cheek(22, 43) c:cheek(40, 43)

-- quirk: a yellow weaver bird peeking out of the right big nest's spout
local sx, sy = spouts[3][1], spouts[3][2]
O.flat(c, c:rect(sx - 1, sy + 2, sx + 1, sy + 3), BIRD[2], "bird")
O.dot(c, sx - 1, sy + 2, BIRD[3]) O.dot(c, sx + 1, sy + 3, BIRD[1])
O.dot(c, sx, sy + 2, P.ink) O.dot(c, sx + 2, sy + 3, "#c86a2a") -- eye, beak

O.done(c, "th-acacia-antler-yard")
