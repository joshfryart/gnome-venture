-- pineapple-seed (batch2, single pass, Opus). Two hard, glossy, chestnut pineapple seeds (small wedge-ovals with a
-- pointed hilum end, sharp specular, cool rim, contact shadow) lying in the trough of a torn scrap of pineapple leaf
-- (glaucous strap with a V-trough cross-section, pale bloom stripe, fine parallel striations, little hooked spines
-- along both edges, ragged torn ends). A third seed has germinated: a pale root tip and a miniature pineapple-crown
-- rosette of stiff, V-folded sword blades. Draft by Sonnet replaced.
-- quirk: the split seed coat is still stuck on the tip of the tallest blade like a little hat.
local NAME = "pineapple-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../batch1/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min

local LEAF  = { "#1c2f3e", "#2a4a58", "#3a6668", "#55857a", "#7ea592", "#afcab2" }
local SPR   = { "#1b4636", "#276446", "#3a8450", "#57a45a", "#84c270", "#b8e08e" }
local SEED  = { "#24121a", "#3c1e1e", "#5a3022", "#7c4428", "#a05e32", "#c8864a" }
local BLOOM, SPINE, ROOT = "#c4dccc", "#c9a86a", "#efe2c4"
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }

------------------------------------------------------------------ seeds (masks first: they cast on the leaf)
local seeds = {   -- cx, cy, rx, ry, angle, pointed end (+1/-1 along the axis)
  { 17, 49.5, 3.7, 2.3, -0.25, -1 }, { 46, 39.3, 3.6, 2.2, -0.55, 1 }, { 31.5, 45, 3.5, 2.2, -0.35, 1 },
}
local seedAll = HP.mask()
for _, s in ipairs(seeds) do
  local m, n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.9)
  -- pointed hilum end: trim the two corner pixels beside the tip
  local ca, sa = math.cos(s[5]) * s[6], math.sin(s[5]) * s[6]
  m:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local a, b = dx * ca + dy * sa, -dx * sa + dy * ca
    if a > s[3] - 1.4 and abs(b) > 0.9 then m.s[K(x, y)] = nil end
  end)
  s.m, s.n = m, n
  seedAll:add(m)
end

------------------------------------------------------------------ leaf scrap
local lm, ln, LT, LS, len = G.blade(8, 52, 30, 48, 56, 35, function(t) return 4.3 end, { fold = -0.4 })  -- trough
-- torn ends: ragged, hashed per row across the strap
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local r0 = 0.012 + X.hash(floor((s + 1) * 4), 1, 5) * 0.05
  local r1 = 0.95 - X.hash(floor((s + 1) * 4), 2, 5) * 0.06
  if LT[k] < r0 or LT[k] > r1 then lm.s[k] = nil end
end)
-- hooked spines: 1 px teeth just outside both edges, every ~5 px, pointing toward the tip
local spines = HP.mask()
local edge = lm:edge()
edge:each(function(x, y) local k = K(x, y)
  local u = LT[k] * len
  if LT[k] > 0.06 and LT[k] < 0.92 and abs(LS[k]) > 0.8 and floor(u) % 6 == (LS[k] < 0 and 0 or 3) then
    local oy = LS[k] < 0 and -1 or 1
    if not lm:has(x + 1, y + oy) then spines:set(x + 1, y + oy) end
  end
end)
local bias = {}
X.ao(bias, lm, seedAll, 1, -1)
G.cast(bias, lm, seedAll, 1, 1, -1) G.cast(bias, lm, seedAll, 1, 2, -1)
-- fine parallel striations along the strap
lm:each(function(x, y) local k = K(x, y)
  local sv = LS[k] * 6
  if abs(sv - floor(sv + 0.5)) < 0.18 and floor(sv + 0.5) % 2 == 1 and abs(LS[k]) < 0.75 and not bias[k] then bias[k] = -1 end
end)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { tok = ltok, bias = bias, amb = 0.14, wrap = 0.3, cuts = CUTS })
-- bloom stripe on the lit inner wall of the trough (lower half faces the upper-left light)
lm:each(function(x, y) local k = K(x, y)
  if LS[k] > 0.3 and LS[k] < 0.55 and LT[k] > 0.1 and LT[k] < 0.88 and not bias[k] then c:put(x, y, BLOOM, ltok) end
end)
-- upper rim catches light as a thin bright edge
edge:each(function(x, y) local k = K(x, y) if LS[k] < -0.8 and LT[k] > 0.05 and LT[k] < 0.92 then c:put(x, y, LEAF[5], ltok) end end)
spines:each(function(x, y) c:put(x, y, SPINE, ltok) end)

------------------------------------------------------------------ sprout: miniature crown rosette
local drawn = HP.mask()
local function blade(ax, ay, cx, cy, bx, by, w, dark)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.45, w * (1 - t) ^ 0.7 * min(1, 0.6 + t * 4))
  end, { fold = 0.5 })
  local tok = { r = { name = "sprout" } }
  local b = {}
  if dark then m:each(function(x, y) b[K(x, y)] = -1 end) end
  G.toneN(c, m, n, SPR, { tok = tok, bias = b, amb = 0.12, wrap = 0.25, cuts = CUTS })
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.25 and S[k] > -0.6 and T[k] > 0.15 and T[k] < 0.7 then c:put(x, y, dark and SPR[5] or SPR[6], tok) end
  end)
  m:grow(1):cut(m):each(function(x, y) if drawn:has(x, y) then c:put(x, y, SPR[1], { r = { name = "sprout" } }) end end)
  drawn:add(m)
  return m
end
-- stem: short pale hypocotyl out of the seed
local stem = c:rect(31, 38, 32, 43)
G.toneN(c, stem, (function() local n = {} stem:each(function(x, y) n[K(x, y)] = { x == 31 and -0.5 or 0.5, 0, 0.8 } end) return n end)(),
  { "#5f8a52", "#86ac68", "#a9c886", "#cfe2a8" }, { cuts = { 0.4, 0.6, 0.8 }, tok = { r = { name = "stem" } } })
drawn:add(stem)
blade(31, 38, 26, 31, 19, 28, 1.6, true)
blade(32, 38, 38, 31, 45, 27, 1.6, true)
blade(31, 38, 27, 26, 22, 14, 1.9)
blade(32, 38, 37, 26, 42, 13, 1.9)
blade(31, 38, 31, 24, 32, 9, 2.1)
-- quirk: split seed coat stuck on the tip of the tallest blade
local ctok = { r = { name = "cap" } }
for _, p in ipairs{ {31, 7, 5}, {32, 7, 6}, {33, 7, 4}, {30, 8, 4}, {31, 8, 3}, {32, 8, 3}, {33, 8, 2}, {34, 8, 2}, {30, 9, 1}, {34, 9, 1} } do
  c:put(p[1], p[2], SEED[p[3]], ctok)
end

------------------------------------------------------------------ seeds on top
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 3 then X.ao(sb, s.m, stem, 1, -1) end
  G.toneN(c, s.m, s.n, SEED, { tok = tok, bias = sb, amb = 0.05, wrap = 0.15, cuts = { 0.28, 0.44, 0.58, 0.72, 0.85 } })
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if rim[K(x, y)] > 0.75 then c:put(x, y, "#5e4a62", tok) end end)
  local bx, by = G.specAt(s.m, s.n, 50)
  c:put(bx, by, "#fff0e0", tok) c:put(bx + 1, by, SEED[6], tok)
end
-- germinated seed: split seam and a pale root tip curling out of its lower end
c:px(31, 44, SEED[1]) c:px(32, 44, SEED[1])
for _, p in ipairs{ {35, 46}, {36, 47}, {37, 47}, {38, 46} } do c:put(p[1], p[2], ROOT, { r = { name = "root" } }) end

G.save(c, NAME)
