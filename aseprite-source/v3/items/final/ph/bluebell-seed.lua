-- bluebell-seed (final, Opus single pass). Hyacinthoides: five round, jet-black, glossy seeds (blue-violet sheen,
-- one bright specular each, cool reflected rim) lined up on a torn strap of bluebell leaf (channelled keel, parallel
-- monocot veins, glossy streak, both ends torn, AO + contact shadows). The middle seed has germinated into the
-- bluebell seedling's single grass-like strap leaf, with a younger blade beside it.
-- quirk: the arching blade still wears its empty black seed coat on the tip like a little hat.
local NAME = "bluebell-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local norm = A.norm
local LEAF = { "#12352c", "#1b5034", "#266c3c", "#3a8a44", "#5eaa50", "#94cc6a" }
local GLOSS, COOL, TORN = "#c8ec96", "#2f5f6c", "#cfe8a8"
local SPR = { "#174632", "#21633a", "#2f8243", "#47a24e", "#70c05c", "#a8de82" }
local SB = { "#110f1d", "#1c1a2e", "#2b2846", "#3f3c64", "#5f5e96", "#a6aee2" }
local RIM, SPEC = "#3c5786", "#e2e7ff"

-- strap leaf scrap, sagging slightly, torn at both ends
local lm, ln, LT, LS = A.blade(8, 51, 32, 57, 56, 47, function(t) return 5.2 + 0.6 * sin(t * 5) end, { fold = 0.5 })
A.tear(lm, function(x, y) return LT[K(x, y)] end, 0.035, false, 0.06, 2)
A.tear(lm, function(x, y) return LT[K(x, y)] end, 0.97, true, 0.05, 9)

-- seeds along the strap
local SEEDS = { { 12, 50.5, 2.8 }, { 20, 52.5, 2.6 }, { 28.5, 52.5, 2.9 }, { 37.5, 52, 2.6 }, { 45.5, 50, 2.8 } }
local sm = HP.mask()
for _, s in ipairs(SEEDS) do
  for y = floor(s[2] - s[3]) - 1, floor(s[2] + s[3]) + 1 do for x = floor(s[1] - s[3]) - 1, floor(s[1] + s[3]) + 1 do
    if ((x - s[1]) / (s[3] + .45))^2 + ((y - s[2]) / (s[3] + .45))^2 <= 1 then sm:set(x, y) end end end
end

-- sprout blades (tubes flattened into straps)
local function strap(p, w0, w1)
  local m, n, T, S = A.tube(p, function(t) if t > 0.985 then return -1 end return w0 + (w1 - w0) * t end)
  -- flatten: blade faces the viewer, slight fold at the keel
  for k, nn in pairs(n) do local s = S[k] n[k] = { norm(nn[1] * 0.45 + (s < 0 and -0.12 or 0.12), nn[2] * 0.45, 1) } end
  return m, n, T, S
end
local b1, n1, T1, S1 = strap({ { 29, 50 }, { 30, 30 }, { 38, 14 }, { 48, 21 } }, 2.0, 0.9)
local b2, n2, T2, S2 = strap({ { 27, 50 }, { 25, 42 }, { 20, 36 }, { 17, 28 } }, 1.7, 0.6)
b1:cut(sm) b2:cut(sm)
-- seed coat hat on b1's tip
local tx, ty = A.bez({ { 29, 50 }, { 30, 30 }, { 38, 14 }, { 48, 21 } }, 1)
local hat = A.rell(tx + 0.6, ty + 1.6, 0.55, 0.83, 2.6, 2.1)

-- leaf light with AO under seeds and blade feet
local bias = {}
X.ao(bias, lm, sm, 1, -1) A.cast(bias, lm, sm, 1, 2, -1) A.cast(bias, lm, sm, 2, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 then A.step(c, lidx, LEAF, x, y, -2, ltok) return end                 -- channel
  if abs(s) > 0.1 and abs(s) < 0.22 and s < 0 then c:put(x, y, LEAF[6], ltok) return end -- lit keel lip
  for _, vs in ipairs{ 0.45, 0.72 } do if abs(abs(s) - vs) < 0.07 then A.step(c, lidx, LEAF, x, y, -1, ltok) return end end
  if s > -0.66 and s < -0.52 and ((t > 0.12 and t < 0.3) or (t > 0.62 and t < 0.74)) then c:put(x, y, GLOSS, ltok) end
end)
for _, p in ipairs(A.border(lm)) do local k = K(p[1], p[2])
  if LT[k] < 0.07 and p[3] < 0 or LT[k] > 0.93 and p[3] > 0 then c:put(p[1], p[2], TORN, ltok)
  elseif not bias[k] and LS[k] > 0.7 then c:put(p[1], p[2], COOL, ltok) end end

-- blades
local stok = { r = { name = "sprout" } }
local function paintBlade(m, n, T, S, ramp)
  local idx = A.shade(c, m, n, ramp, { tok = stok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.92 then A.step(c, idx, ramp, x, y, S[k] <= 0 and 2 or -1, stok) end end)
  return idx
end
paintBlade(b2, n2, T2, S2, SPR)
paintBlade(b1, n1, T1, S1, SPR)
-- base sheath where blades leave the seed: ambient dark
for _, q in ipairs{ { 28, 49 }, { 29, 49 }, { 27, 49 } } do if b1:has(q[1], q[2]) or b2:has(q[1], q[2]) then c:put(q[1], q[2], SPR[1], stok) end end

-- seeds
for i, s in ipairs(SEEDS) do
  local tok = { r = { name = "seed" .. i } }
  local b = {}
  if i == 3 then X.ao(b, sm, b1:copy():add(b2), 1, -1) end
  A.bead(c, s[1], s[2], s[3], s[3], SB, { tok = tok, rim = RIM, spec = SPEC, bias = b })
  local hx, hy = floor(s[1] - s[3] * 0.45 + 0.5), floor(s[2] - s[3] * 0.45 + 0.5)
  c:put(hx + 1, hy, SB[6], tok)
end
-- the sprouting seed is split open where the blade leaves it
c:put(28, 50, SB[1], { r = { name = "seed3" } }) c:put(29, 50, SB[2], { r = { name = "seed3" } })

-- quirk: seed-coat hat on the blade tip
local htok = { r = { name = "hat" } }
local hn = {}
local hcx, hcy = tx + 0.6, ty + 1.6
hat:each(function(x, y) local a, b = (x - hcx) / 3.0, (y - hcy) / 2.6 hn[K(x, y)] = { norm(a, b, sqrt(max(0.05, 1 - a*a - b*b))) } end)
A.shade(c, hat, hn, SB, { tok = htok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.04, wrap = 0.2 })
-- open mouth of the coat where the blade goes in (upper-left side): dark rim
local hx0, hy0 = hat:bbox()
for _, p in ipairs(A.border(hat, b1)) do c:put(p[1], p[2], SB[1], htok) end
local bx, by = A.specAt(hat, hn, 30) if bx then c:put(bx, by, SPEC, htok) end

A.save(c, NAME)
