-- hyacinth-seed (final, Opus single pass aC12_5). Three glossy, near-black hyacinth seeds (round, violet-black with a
-- bright specular each) lying in the channel of a torn length of hyacinth leaf (long fleshy strap, V-channelled,
-- parallel monocot veins, ragged pale tissue at both torn ends, cool reflected lower edge, AO + contact shadow under
-- each seed). The right seed has germinated: its black coat split, a pale root foot and three fleshy, channelled,
-- blunt-tipped strap leaves rising in a fan, the hyacinth's own leaf shape.
-- quirk: a single fallen purple hyacinth floret (a six-pointed starry bell) rests on the left end of the leaf.
local NAME = "hyacinth-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local COOL, TORN = "#3a6c72", "#b4d690"
local SEED = { "#140e1a", "#261a30", "#3a2a4a", "#56426c", "#7e6898", "#b8a4d8" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local FL = { "#35295f", "#5a459e", "#8a6fd0", "#b49af0", "#dccbff" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "sprout" } }

-- strap leaf scrap: long, gently arched, both ends torn
local lm, ln, LT, LS, len = A.blade(6, 52, 32, 46, 58, 51, function(t) return 5.2 - 0.8 * t end, { fold = 0.55 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t = LT[k]
  local jag = 0.03 * X.hash(0, floor(LS[k] * 6), 5) + 0.012 * sin(LS[k] * 9)
  if t < 0.02 + jag or t > 0.975 - jag then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local seeds = { { 17, 47.5, 2.6, 2.3 }, { 26, 46, 2.6, 2.3 }, { 39, 46, 2.7, 2.4 } }
local smask = {}
for i, s in ipairs(seeds) do
  local m = HP.mask()
  for y = floor(s[2] - 4), floor(s[2] + 4) do for x = floor(s[1] - 4), floor(s[1] + 4) do
    local u, v = (x + 0.5 - s[1]) / (s[3] + 0.3), (y + 0.5 - s[2]) / (s[4] + 0.3)
    if u * u + v * v <= 1 then m:set(x, y) end end end
  smask[i] = m
end
local bias = {}
for _, m in ipairs(smask) do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) end
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = bias, amb = 0.16, wrap = 0.3, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 } })
-- parallel veins + channel crease
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  if abs(s) < 0.1 then c:put(x, y, LEAF[2], ltok)
  elseif abs(abs(s) - 0.5) < 0.09 and (x + floor(LT[k] * 40)) % 5 ~= 0 then
    c:put(x, y, LEAF[max(1, min(6, (lidx[k] or 3) + (s < 0 and 1 or -1)))], ltok) end
end)
-- torn ends pale, cool reflected lower edge
lm:edge():each(function(x, y) local k = K(x, y)
  local t = LT[k]
  if t < 0.07 or t > 0.93 then c:put(x, y, TORN, ltok)
  elseif LS[k] > 0.6 and not bias[k] then c:put(x, y, COOL, ltok) end end)

-- sprout: three fleshy strap leaves from the right seed
local BX, BY = 39, 44
local function strap(p, w, tip)
  local m, n, T, S = A.tube(p, function(t) return t > 0.93 and w * (1 - (t - 0.93) / 0.07) ^ 0.5 + 0.2 or w end)
  return m, n, T, S
end
local leaves = {
  { { BX - 1, BY }, { 34, 36 }, { 28, 30 }, { 22, 24 } }, -- left, arching out
  { { BX + 1, BY }, { 44, 37 }, { 48, 31 }, { 50, 25 } }, -- right
  { { BX, BY }, { 39, 33 }, { 37, 22 }, { 38, 12 } },     -- centre, tallest
}
local done = {}
for i, p in ipairs(leaves) do
  local m, n, T, S = strap(p, i == 3 and 2.3 or 2.0)
  -- channel: fold the normal across the midline
  for k, v in pairs(n) do local s = S[k] local f = (s < 0 and -0.35 or 0.35) n[k] = { A.norm(v[1] + f * 0.6, v[2] - f * 0.3, v[3]) } end
  local b = {}
  for _, d in ipairs(done) do X.ao(b, m, d, 1, -1) end
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.12 then b[k] = (b[k] or 0) - 1 end end)
  local idx = A.shade(c, m, n, LEAF, { tok = ltok, bias = b, amb = 0.14, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.15 and T[k] < 0.9 then c:put(x, y, LEAF[max(1, (idx[k] or 3) - 1)], ltok) end   -- channel crease
    if S[k] < -0.55 and T[k] > 0.3 and T[k] < 0.8 and (idx[k] or 1) >= 4 then c:put(x, y, LEAF[6], ltok) end         -- glossy lit lip
  end)
  done[#done + 1] = m
end
-- pale stem foot over the seed
for _, q in ipairs{ { 38, 44, 3 }, { 39, 44, 4 }, { 40, 44, 2 }, { 38, 43, 2 }, { 39, 43, 3 }, { 40, 43, 2 } } do c:put(q[1], q[2], STEM[q[3]], stok) end

-- seeds: glossy violet-black spheres
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local m, idx = A.ball(c, s[1], s[2], s[3], s[4], SEED, tok, { amb = 0.03, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
  -- tiny wrinkle pits, specular + bounce
  c:put(floor(s[1]) + 1, floor(s[2]) + 1, SEED[2], tok)
  c:put(floor(s[1] - 1), floor(s[2] - 1), "#d8ccff", tok)
  c:put(floor(s[1] + 1), floor(s[2] + 2), "#3e5a72", tok)
end
-- sprouting seed: coat split open around the stem foot
c:put(38, 45, STEM[2], stok) c:put(39, 45, STEM[3], stok) c:put(40, 45, SEED[1], {})
c:put(39, 46, STEM[1], stok)

-- quirk: fallen purple floret (six-pointed starry bell) on the left end
local ftok = { r = { name = "floret" } }
A.paint(c, {
  "..a.b..",
  ".abbbc.",
  "abbdbcc",
  ".bdeec.",
  "cbbecc.",
  ".cc.cd.",
  "..c....",
}, 7, 41, { a = FL[5], b = FL[4], c = FL[3], d = FL[2], e = FL[1] }, ftok)
for _, q in ipairs{ { 12, 47 }, { 13, 46 }, { 10, 48 } } do if lm:has(q[1], q[2]) then c:put(q[1], q[2], LEAF[1], ltok) end end
A.save(c, NAME)
