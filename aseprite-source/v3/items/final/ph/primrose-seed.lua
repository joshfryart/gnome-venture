-- primrose-seed (D10, Sonnet artist pass). A scatter of tiny angular black-brown primrose seeds on a torn, spoon-shaped
-- primrose leaf scrap: crenate margin, a pale midrib and deeply impressed side veins that pucker the blade between them,
-- V-fold light, cool reflected edge, AO + contact shadow under every seed. One seed has germinated: pale stem, two round
-- seed-leaves and a first crinkled spoon leaf (the same crenate, veined shape in miniature).
-- quirk: a fallen pale-yellow heart-notched petal rests on the leaf, with the orange throat mark at its base.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_3.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("primrose-seed")

local LEAF = { "#1b432b", "#2b6337", "#43853f", "#62a34b", "#86bf58", "#b4dc7e" }
local YL   = { "#265c36", "#397d41", "#55a04f", "#78bf5e", "#a2da7a", "#d2f2a4" }
local COT  = { "#2c6a40", "#40894a", "#5aa656", "#7cc464", "#a4de7c", "#d4f6aa" }
local STEM = { "#5a8a50", "#86b466", "#b2d686", "#e0f2b4" }
local SEED = { "#170f15", "#2e1e27", "#4a3235", "#6a4a44", "#8c6a5c", "#bd9a88" }
local PET  = { "#9c7418", "#cfa22c", "#eec84c", "#f9dd74", "#fdeda0", "#fff8cf" }
local VHI, COOL = "#d2f0a0", "#3a6e74"
local ltok = { r = { name = "leaf" } }

-- seeds: cx, cy, rx, ry, angle (germinated seed is #7)
local seeds = {
  { 15, 51, 2.7, 2.1, -0.4 }, { 21, 47, 2.6, 2.0, 0.5 }, { 21, 54, 2.7, 2.0, 0.2 }, { 27, 50, 2.6, 2.1, -0.7 },
  { 31, 46, 2.5, 1.9, 0.3 }, { 29, 56, 2.5, 1.9, -0.2 }, { 39, 45, 3.0, 2.4, 0.2 },
}
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
local whole = c:rect(0, 0, 63, 63)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, whole, s.m, 1, -1) G.cast(bias, whole, s.m, 1, 2, -1) end

-- leaf scrap: spoon shape (narrow petiole, broad rounded blade), crenate edge
local function spoon(t)
  if t > 0.985 then return -1 end
  local u = min(1, max(0, (t - 0.1) / 0.9))
  return max(1.3, 9.4 * sin(pi * u ^ 1.5) ^ 0.62)
end
local lm, ln, LT, LS, len = D.leaf(c, { 5, 52, 26, 53, 55, 41 }, {
  wfn = spoon, ramp = LEAF, per = 4.4, amp = 0.26, t0 = 0.3, sp = 3.9, slant = 3.4, fold = 0.34,
  bias = bias, tok = ltok, vhi = VHI, cool = COOL })

-- petal (quirk): heart-notched, pale yellow, orange throat, lying on the blade near the tip
local pet = c:poly({ { 43, 44 }, { 44, 41 }, { 46, 40 }, { 48, 42 }, { 50, 40 }, { 52, 41 }, { 53, 44 }, { 51, 48 }, { 48, 50 }, { 45, 48 } })
local pn = X.pillow(pet, 2.4)
pet:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pet:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
G.toneN(c, pet, pn, PET, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.1, wrap = 0.3, tok = { r = { name = "petal" } } })
for _, p in ipairs{ { 48, 48 }, { 47, 47 }, { 49, 47 }, { 48, 46 } } do c:put(p[1], p[2], "#f08a28") end
c:put(48, 49, "#c4601c") c:put(47, 48, "#c4601c") c:put(49, 48, "#c4601c")
D.line(c, { { 48, 45 }, { 46, 42 } }, PET[2]) D.line(c, { { 48, 45 }, { 50, 42 } }, PET[2])
c:put(48, 42, PET[1])                       -- the notch
c:put(45, 42, PET[6]) c:put(46, 41, PET[6])

-- germinated seed's sprout: stem, two round seed-leaves, first spoon leaf
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 39, 44 }, { 38, 39 }, { 40, 34 }, { 40, 29 } }, function(t) return 1.15 end)
G.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local ctok = { r = { name = "cotyledon" } }
local function coty(cx, cy, ang)
  local m, n = G.oval(cx, cy, 4.5, 3.1, ang, 0.9)
  G.toneN(c, m, n, COT, { tok = ctok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.14, wrap = 0.3 })
  -- faint midrib along the long axis
  local ca, sa = cos(ang), sin(ang)
  for i = -3, 3 do c:put(floor(cx + i * ca + 0.5), floor(cy + i * sa + 0.5), i < 0 and COT[6] or COT[3], ctok) end
  return m
end
local cl = coty(33, 31, -0.28)
local cr = coty(47, 30, 0.28)
local tm = D.leaf(c, { 40, 29, 38, 19, 42, 8 }, {
  wfn = function(t) if t > 0.985 then return -1 end
    local u = min(1, max(0, (t - 0.08) / 0.92)) return max(0.9, 4.9 * sin(pi * u ^ 1.4) ^ 0.62) end,
  ramp = YL, per = 3.3, amp = 0.28, t0 = 0.35, sp = 3.1, slant = 2.4, fold = 0.34, tok = ltok, vhi = VHI, cool = COOL })
-- AO where the stem and seed-leaves overlap each other
for _, q in ipairs{ { 38, 30 }, { 41, 30 }, { 39, 31 }, { 41, 31 } } do if cl:has(q[1], q[2]) or cr:has(q[1], q[2]) then c:put(q[1], q[2], COT[1], ctok) end end
c:put(39, 29, STEM[1]) c:put(40, 29, STEM[1]) c:put(41, 29, STEM[2])

-- seeds last: hard dark coat with a bright facet, pale hilum scar, bristle-free angular outline
local n7 = #seeds
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  X.ao(sb, s.m, s.m, 0, 0)
  G.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  -- bright facet upper-left and pale hilum at one end
  local gx, gy = floor(s[1] - 0.9 * ca * 0.6 - 0.6 + 0.5), floor(s[2] - 0.9 + 0.5)
  if s.m:has(gx, gy) then c:put(gx, gy, SEED[6], tok) end
  local hx, hy = floor(s[1] + (s[3] - 0.8) * ca + 0.5), floor(s[2] + (s[3] - 0.8) * sa + 0.5)
  if s.m:has(hx, hy) and i ~= n7 then c:put(hx, hy, SEED[5], tok) end
end
-- germinated seed: coat split open, pale radicle poking out below-left, stem foot overlaps
do
  local s = seeds[n7]
  c:put(38, 44, STEM[2]) c:put(39, 44, STEM[3]) c:put(39, 43, STEM[3]) c:put(40, 44, STEM[2])
  c:put(37, 46, STEM[4]) c:put(36, 47, STEM[3]) c:put(35, 48, STEM[3]) c:put(34, 48, STEM[2])
  c:put(36, 46, SEED[1]) c:put(37, 47, SEED[1])
end
D.save(c, "primrose-seed")
