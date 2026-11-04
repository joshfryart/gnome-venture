-- pickled-kale (C34, Opus single pass). Tall slim swing-top jar (glass dome lid, orange rubber gasket, steel wire
-- bail and lever) packed with curly blue-green kale leaves in pale green brine, a few red chili flakes and a garlic clove.
-- Material: per-pixel lathe glass (6-tone, bright left band, pale core, dark right band, cool bounce), frilly leaves as
-- clusters of sphere-lit bumps with pale ribs and veins, AO where leaves stack, steel wire with a bright edge.
-- quirk: one curly leaf has escaped under the gasket and flops over the outside of the jar.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("pickled-kale")

local KALE = { "#10302e", "#1a4a3e", "#276646", "#3a864c", "#5ea858", "#98cc6a" }
local RIB = { "#6a9a5a", "#a8cc8a", "#d8ecb8" }
local BRINE = { "#3e7a5a", "#6aa46a", "#9cc884", "#c4e0a4", "#e0f0c4", "#f4fbe4" }
local GASK = { "#6e2a1c", "#b0461e", "#e26a26", "#f8a050", "#ffd08a" }
local CHILI = { "#7a1a26", "#c42a2a", "#f05a3a" }
local GARLIC = { "#9a8070", "#d8c8b0", "#f4ecdc", "#fffaf0" }

c:groundShadow(32, 53, 13, 2)

-- jar: neck 14..17, shoulder, tall straight body, rounded heel
local function hw(y)
  if y < 14 then return nil end
  if y <= 17 then return 8 end
  if y <= 21 then return 8 + (y - 17) * .75 end
  if y <= 49 then return 11 end
  return 11 - (y - 49) * .7
end
local J = A.jar(c, 32, 14, 52, hw, 22, BRINE)

-- kale leaves packed inside (bottom-up, back to front)
local occ = HP.mask()
local leaves = {
  { { { 26, 51 }, { 24, 46 }, { 25, 42 }, { 28, 36 } }, 5.5 },
  { { { 38, 51 }, { 41, 46 }, { 39, 42 }, { 36, 37 } }, 5.5 },
  { { { 31, 48 }, { 34, 42 }, { 30, 35 }, { 33, 27 } }, 6 },
  { { { 25, 40 }, { 23, 33 }, { 26, 26 }, { 27, 19 } }, 5 },
  { { { 40, 41 }, { 42, 34 }, { 38, 27 }, { 37, 19 } }, 5 },
  { { { 33, 32 }, { 30, 26 }, { 33, 22 }, { 31, 17 } }, 4.5 },
}
local ribs = {}
for i, L in ipairs(leaves) do
  local m, n = A.frill(L[1], L[2], 9, .5)
  m:clip(J.inner)
  local nn = {} m:each(function(x, y) nn[K(x, y)] = n[K(x, y)] end)
  A.piece(c, m, nn, KALE, occ, { amb = .1, wrap = .25 })
  -- pale rib + side veins
  for s = 0, 40 do local t = s / 40 * .9
    local x, y = A.bez(L[1], t) local xi, yi = floor(x + .5), floor(y + .5)
    if m:has(xi, yi) then c:put(xi, yi, t < .5 and RIB[2] or RIB[1]) if t < .35 and m:has(xi + 1, yi) then c:put(xi + 1, yi, RIB[1]) end end
  end
  for _, t in ipairs{ .3, .55, .75 } do
    local x, y = A.bez(L[1], t)
    for _, s in ipairs{ -1, 1 } do
      for d = 1, 2 do local xi, yi = floor(x + s * d + .5), floor(y - d * .6 + .5)
        if m:has(xi, yi) then c:put(xi, yi, KALE[2]) end end
    end
  end
  local x, y = A.bez(L[1], .2) c:put(floor(x) - 1, floor(y), RIB[3])
end
-- chili flakes and a garlic clove
for _, p in ipairs{ { 29, 45 }, { 36, 30 }, { 27, 31 }, { 39, 47 }, { 33, 49 } } do
  c:put(p[1], p[2], CHILI[2]) c:put(p[1] + 1, p[2], CHILI[1]) c:put(p[1], p[2] - 1, CHILI[3])
end
do
  local g = A.rell(36.5, 45.5, .5, -.85, 3, 1.8)
  g:clip(J.inner)
  local gn = X.pillow(g, 1.5)
  A.piece(c, g, gn, { GARLIC[1], GARLIC[1], GARLIC[2], GARLIC[3], GARLIC[3], GARLIC[4] }, occ, { amb = .2, wrap = .35 })
  c:put(37, 43, "#b8a890")
end

-- glass over contents
A.glass(c, J.body, J.inner, J.n, J.NX, { ys = 15 })
-- thick glass base: pale heel line
for x = 24, 39 do if J.body:has(x, 51) then c:put(x, 51, x < 30 and A.GLASS[5] or A.GLASS[3]) end end
c:put(25, 30, A.SPEC) c:put(25, 31, "#f4fbff")

-- gasket (orange rubber) and glass dome lid
local gk = c:rect(23, 12, 40, 13)
local gn = {} gk:each(function(x, y) local s = (x + .5 - 32) / 9.5 gn[K(x, y)] = { A.norm(s, y == 12 and -.6 or .2, sqrt(max(.05, 1 - s * s))) } end)
A.tone(c, gk, gn, GASK, { amb = .1, wrap = .3, cuts = { .2, .4, .62, .82 } })
c:put(24, 12, GASK[5]) c:put(41, 12, GASK[2]) c:put(41, 13, GASK[1])
gk:add(c:rect(41, 12, 41, 13))
local lid, ln = A.lathe(32, 6, 11, function(y)
  if y == 6 then return 5.5 elseif y == 7 then return 7.5 elseif y == 8 then return 8.5 end return 9 end)
A.tone(c, lid, ln, A.GLASS, { amb = .25, wrap = .4 })
for x = 25, 30 do if lid:has(x, 7) then c:put(x, 7, A.GLASS[6]) end end
c:put(26, 8, A.SPEC) c:put(27, 8, A.GLASS[6])
for x = 24, 40 do c:put(x, 11, x < 31 and A.GLASS[4] or A.GLASS[2]) end

-- steel wire bail over the lid and lever wires down to the shoulder
local W = { "#3a3c58", "#74758c", "#c4c6d4", "#f2f2f8" }
local bail = { { 22, 13 }, { 22, 10 }, { 23, 7 }, { 25, 5 }, { 28, 4 }, { 32, 4 }, { 36, 4 }, { 39, 5 }, { 41, 7 }, { 42, 10 }, { 42, 13 } }
for i = 1, #bail - 1 do A.ln(c, bail[i][1], bail[i][2], bail[i + 1][1], bail[i + 1][2], i < 5 and W[2] or W[1]) end
c:put(28, 4, W[4]) c:put(29, 4, W[4])
-- hinge loops on each side of the neck + levers
for _, s in ipairs{ -1, 1 } do
  local x = 32 + s * 10
  c:put(x, 14, W[2]) c:put(x, 15, W[1]) c:put(x - s, 15, W[2])
  A.ln(c, x, 16, x + s * 0, 19, s < 0 and W[3] or W[1])
  c:put(x - s, 19, W[2])
end
c:put(22, 14, W[4])

-- quirk: an escaped kale leaf flopping over the right shoulder
do
  local p = { { 40, 13 }, { 46, 14 }, { 48, 19 }, { 47, 25 } }
  local m, n = A.frill(p, 4, 7, .55)
  local occ2 = J.body:copy():add(gk)
  A.piece(c, m, n, KALE, occ2, { amb = .12, wrap = .3, sep = 1 })
  for s = 0, 24 do local t = s / 24 * .85 local x, y = A.bez(p, t) c:put(floor(x + .5), floor(y + .5), RIB[2]) end
  c:put(44, 14, RIB[3]) c:put(45, 14, RIB[3])
  c:put(41, 13, KALE[2])
end

A.fin(c, "pickled-kale")
