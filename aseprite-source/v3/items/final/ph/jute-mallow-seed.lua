-- jute-mallow-seed (final pass, Opus single pass). Five tiny angular jute seeds (grey-green wedges with flat lit,
-- mid and shade facets and a pale ridge) scattered on a torn scrap of jute-mallow leaf (yellow-green, finely saw-
-- toothed margin, three veins from the base, cool rim, AO + contact shadow under each seed), torn across the base.
-- One seed has germinated: slim reddish stem, two round cotyledons and a first serrated lance leaf with the pair
-- of thread-like basal tails that marks jute mallow. quirk: a glossy bead of the plant's famous slime clings to
-- the sprouting seed, trailing a thin strand onto the leaf.
local NAME = "jute-mallow-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1d3324", "#2a5228", "#3e702e", "#5c9236", "#84b244", "#b6d46c" }
local COOL, VEIN, TISSUE = "#3d6a64", "#d6eb98", "#e2efb4"
local SEED = { "#14161c", "#252b2e", "#3a423f", "#5a6352", "#7d8a6c", "#c4cca8" }
local STEM = { "#6a3a3a", "#9a5a48", "#c98a66", "#ecc49a" }
local SPR = { "#24452a", "#356632", "#4f8a3a", "#74ac4a", "#a2cc66", "#d2ea9a" }
local SLIME = { "#9fbf9a", "#cfe4c0", "#f3f8e4" }

-- leaf scrap: jute leaf rising to the right, torn across the base on the left
local lm, ln, LT, LS, len = A.blade(5, 50, 30, 50, 58, 36, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.9 + 0.1) ^ 1.25) ^ 0.7)
end, { fold = 0.32 })
A.frill(lm, LT, LS, len, 2.6, function(t) return 0.14 end, 0.18, 0.97)          -- fine saw teeth
local torn = A.tear(lm, LT, LS, 0.13, { 0.03, -0.03, 0.04, -0.01, 0.05, -0.04, 0.02, 0 }, true)

-- seeds: small faceted wedges (char maps: a lit facet, b mid, c shade, h ridge)
local SEEDS = {
  { 14, 46, { ".hab.", "aabbc", ".bbcc", "..cc." } },
  { 21, 49, { "..hb", ".aabc", "aabcc", ".bcc." } },
  { 26, 43, { ".ha.", "aabc", "abbc", ".cc." } },
  { 44, 41, { "hab..", "aabbc", ".abcc", "..cc." } },
  { 33, 46, { ".hab.", "aabbc", "abbcc", ".bcc." } },   -- sprouting seed
}
local seedM = HP.mask()
for _, s in ipairs(SEEDS) do s.m = HP.mask()
  for j, row in ipairs(s[3]) do for i = 1, #row do if row:sub(i, i) ~= "." then s.m:set(s[1] + i - 1, s[2] + j - 1) end end end
  seedM:add(s.m)
end
local bias = {}
for _, s in ipairs(SEEDS) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = VEIN, cool = COOL, per = 6, sweep = 4, len = len,
  torn = torn, tissue = TISSUE, tok = ltok, bias = bias, t0 = 0.13 })
-- three-vein base: two strong laterals fanning from the base
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if (bias[k] or 0) < 0 then return end
  if t > 0.15 and t < 0.5 then
    local target = (t - 0.15) * 1.6
    if abs(abs(s) - target) < 0.09 and abs(s) < 0.8 then c:put(x, y, s < 0 and VEIN or LEAF[2], ltok) end
  end
end)

-- sprout
local stok = { r = { name = "stem" } }
local sp = { { 35, 45 }, { 36, 37 }, { 33, 30 }, { 34, 22 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
local ctok = { r = { name = "coty" } }
local function blob(cx, cy, ux, uy, ra, rb)
  local m = A.rell(cx, cy, ux, uy, ra, rb)
  return m, X.pillow(m, 1.8)
end
local cl, cln = blob(29, 21, -1, 0.15, 4.2, 2.9)
local cr, crn = blob(39, 21.5, 1, 0.2, 4.2, 2.9)
local cb = {}
X.ao(cb, cl, sm, 1, -1) X.ao(cb, cr, sm, 1, -1)
A.shade(c, cl, cln, SPR, { tok = ctok, bias = cb, amb = 0.1, wrap = 0.3 })
A.shade(c, cr, crn, SPR, { tok = ctok, bias = cb, amb = 0.1, wrap = 0.3 })
for i = 0, 2 do c:put(28 + i, 21, SPR[6], ctok) c:put(37 + i, 22, SPR[3], ctok) end
-- first true leaf: serrated lance leaf leaning right, with two thread tails at its base
local tm, tn, TT, TS, tlen = A.blade(34, 20, 36, 13, 42, 7, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 3.0 * sin(pi * min(1, t * 0.85 + 0.15) ^ 1.3) ^ 0.7)
end, { fold = 0.4 })
A.frill(tm, TT, TS, tlen, 2.2, function(t) return 0.3 end, 0.2, 0.95)
tm:cut(cl):cut(cr)
A.shade(c, tm, tn, SPR, { tok = ctok, amb = 0.12, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.16 and TT[k] > 0.1 and TT[k] < 0.85 then c:put(x, y, SPR[6], ctok) end end)
for _, q in ipairs{ { 32, 18 }, { 31, 17 }, { 30, 17 }, { 36, 18 }, { 37, 17 }, { 38, 17 } } do
  if not tm:has(q[1], q[2]) then c:put(q[1], q[2], SPR[2], ctok) end end

-- seeds (faceted, painted from the maps; AO on facets touching the stem)
local ch2i = { a = 4, b = 2, c = 1, h = 6 }
for _, s in ipairs(SEEDS) do
  local tok = { r = { name = "seed" } }
  for j, row in ipairs(s[3]) do for i = 1, #row do local ch = row:sub(i, i)
    if ch2i[ch] then local x, y = s[1] + i - 1, s[2] + j - 1
      local ii = ch2i[ch]
      if sm:has(x, y + 1) or sm:has(x - 1, y) then ii = max(1, ii - 1) end
      c:put(x, y, SEED[ii], tok) end end end
end
c:put(35, 45, STEM[2], stok) c:put(35, 44, STEM[3], stok)

-- quirk: slime bead on the sprouting seed, thin strand down onto the leaf
local qtok = { r = { name = "slime" } }
for _, q in ipairs{ { 38, 47, 2 }, { 39, 47, 2 }, { 38, 48, 2 }, { 39, 48, 1 }, { 38, 46, 3 }, { 37, 47, 2 } } do
  c:put(q[1], q[2], SLIME[q[3]], qtok) end
for _, q in ipairs{ { 40, 49 }, { 40, 50 }, { 41, 51 } } do c:put(q[1], q[2], SLIME[2], qtok) end
c:put(41, 52, SLIME[3], qtok)
c:put(40, 49 + 3, LEAF[2], ltok)

A.save(c, NAME)
