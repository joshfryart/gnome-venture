-- brussels-sprouts-seed (final, Opus aB13_1 single pass). Three tiny round brassica seeds (glossy red-brown beads,
-- one bright spec each, AO between) on a torn scrap of blue-green brussels leaf (pale midrib and fan veins, waxy bloom,
-- ragged torn end, cool reflected edge, contact shadow under each seed). The fourth seed has germinated: pale stem,
-- two notched heart cotyledons and a first wavy-edged true leaf that shows the brassica leaf.
-- quirk: the split seed coat is still stuck on the tip of the left cotyledon like a little cap.
local NAME = "brussels-sprouts-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1a3a40", "#25554e", "#33725a", "#4c9068", "#74b07c", "#a6d0a0" }
local VEIN, BLOOM, COOL = "#d2eac4", "#a4cfc0", "#3a6e7a"
local SEED = { "#2a1420", "#4a2026", "#6e3028", "#94462e", "#b86a42", "#e0a070" }
local STEM = { "#4e7f56", "#86b674", "#b8da98", "#e0f0bc" }
local COT = { "#1f4d38", "#2e6e40", "#46924a", "#6cb556", "#9cd36c", "#cfec98" }

-- seeds (cx, cy, r); the last one sprouts
local seeds = { { 16, 50, 2.7 }, { 23.5, 50.5, 2.6 }, { 30, 47, 2.6 }, { 41, 44, 2.8 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3] * 0.92, 0, 1) end

-- leaf scrap: broad brassica blade lying almost flat, the far end torn off ragged
local lm, ln, LT, LS, len = A.blade(6, 53, 30, 39, 58, 47, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 9.2 * sin(pi * min(1, t * 0.85 + 0.08)) ^ 0.6)
end, { fold = 0.6 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  -- torn end: jagged line across the blade near t ~ 0.8
  local j = 0.8 + 0.05 * sin(LS[k] * 9.0) + 0.03 * (X.hash(x, y, 3) - 0.5)
  if LT[k] > j then cut[#cut + 1] = k end
  -- gentle wavy margin elsewhere
  if abs(LS[k]) > 0.9 - 0.08 * sin(LT[k] * len * 0.9) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 }, amb = 0.12, wrap = 0.2 })
local ledge = lm:edge()
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  -- fan veins from the midrib toward the margin
  local d = (t * len - abs(s) * 6.5) % 6.2
  if d < 0.85 and abs(s) > 0.15 and abs(s) < 0.78 and t < 0.76 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) return end
  if lidx[k] and lidx[k] >= 4 and X.hash(x, y, 7) > 0.93 then c:put(x, y, BLOOM, ltok) end
  if ledge:has(x, y) and s > 0.55 and t < 0.78 then c:put(x, y, COOL, ltok) end
end)
-- torn end gets a paler raw edge
ledge:each(function(x, y) local k = K(x, y) if LT[k] > 0.74 and abs(LS[k]) < 0.8 and not bias[k] then c:put(x, y, LEAF[6], ltok) end end)
-- petiole stub
for _, qq in ipairs{ { 5, 51, 4 }, { 4, 52, 3 }, { 3, 52, 3 } } do c:put(qq[1], qq[2], LEAF[qq[3]], ltok) end

-- sprout stem from the 4th seed
local stok = { r = { name = "stem" } }
local SPT = { { 41, 43 }, { 40, 37 }, { 41, 31 }, { 40, 24 } }
local sm, sn = A.tube(SPT, function(t) return 1.05 end)
sm:cut(seeds[4].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- root hair out of the seed, down over the leaf
do local rt = { { 42, 46 }, { 44, 48 }, { 45, 50 }, { 47, 51 } }
  for _, p in ipairs(rt) do c:put(p[1], p[2], STEM[3], stok) end
  c:put(46, 50, STEM[2], stok) end

-- cotyledons: notched hearts on short petioles
local ctok = { r = { name = "cot" } }
local function heart(px, py, dir)
  -- lobe centre out along dir, two overlapping discs leave a notch at the outer end
  local cx, cy = px + dir * 6.0, py - 2.2
  local m = HP.mask()
  for y = floor(cy) - 6, floor(cy) + 6 do for x = floor(cx) - 8, floor(cx) + 8 do
    local u, v = (x - cx) * dir, y - cy
    local a = ((u + 0.8) / 4.6) ^ 2 + ((v + 1.5) / 3.0) ^ 2 <= 1 and u > -4.6
    local b = ((u + 0.8) / 4.6) ^ 2 + ((v - 1.4) / 3.0) ^ 2 <= 1 and u > -4.6
    local notch = u > 2.4 and abs(v + 0.1) < 0.9
    if (a or b) and not notch then m:set(x, y) end
  end end
  -- petiole
  for i = 0, 4 do m:set(floor(px + dir * i + 0.5), floor(py - i * 0.3 + 0.5)) end
  return m, cx, cy
end
local hl, hlx, hly = heart(39, 25, -1)
local hr, hrx, hry = heart(41, 25, 1)
for _, h in ipairs{ { hl, hlx, hly, -1 }, { hr, hrx, hry, 1 } } do
  local m, cx, cy, dir = h[1], h[2], h[3], h[4]
  local n = A.body(m, cx, cy, 5, 2, 0.4)
  local idx = A.shade(c, m, n, COT, { amb = 0.12, wrap = 0.28, tok = ctok })
  -- midrib to the notch
  for i = -3, 3 do local x, y = floor(cx + i * dir + 0.5), floor(cy + 0.5)
    if m:has(x, y) then c:put(x, y, (idx[K(x, y)] or 3) >= 4 and COT[6] or COT[3], ctok) end end
  local sx, sy = A.specAt(m, n, 30)
  if sx then c:put(sx, sy, COT[6], ctok) end
end
-- first true leaf: small ovate, wavy margin, petiole from the stem top
local tl = HP.mask()
for y = 9, 22 do for x = 34, 48 do
  local u, v = (x - 41.5) / 3.6, (y - 15.0) / 5.4
  local wav = 0.08 * sin(y * 1.9)
  if u * u + v * v <= 1 + wav and not (y > 19 and abs(x - 41) > 1) then tl:set(x, y) end
end end
tl:cut(hl):cut(hr)
local tidx = A.shade(c, tl, A.body(tl, 41, 14, 5, 2, 0.5), COT, { amb = 0.12, wrap = 0.28, tok = ctok })
tl:each(function(x, y) local k = K(x, y)
  if x == 41 and y > 10 and y < 21 then c:put(x, y, COT[(tidx[k] or 3) >= 4 and 6 or 3], ctok)
  elseif (y - abs(x - 41) * 0.8) % 3 < 0.6 and y > 11 and y < 19 and abs(x - 41) >= 2 and abs(x - 41) <= 3 then
    c:put(x, y, x < 41 and COT[6] or COT[2], ctok) end
end)
-- stem top joining the leaves
for y = 22, 25 do c:put(40, y, STEM[3], stok) c:put(41, y, STEM[2], stok) end

-- quirk: split seed coat cap on the left cotyledon's outer tip
do local x0, y0 = floor(hlx - 4.6 + 0.5), floor(hly + 0.5)
  local cap = { { -1, -1, 4 }, { 0, -1, 5 }, { -2, 0, 3 }, { -1, 0, 4 }, { -2, 1, 2 }, { -1, 1, 3 }, { -1, 2, 2 } }
  for _, p in ipairs(cap) do c:put(x0 + p[1], y0 + p[2], SEED[p[3]], ctok) end
end

-- seeds last: glossy beads
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local idx = A.shade(c, s.m, s.n, SEED, { amb = 0.06, wrap = 0.2, bias = sb, tok = tok })
  -- hilum: a tiny pale scar on the shade side
  c:put(floor(s[1] + 1.5), floor(s[2] + 0.5), SEED[3], tok)
  local sx, sy = A.specAt(s.m, s.n, 40)
  if sx then c:put(sx, sy, i == 2 and A.CREAM or SEED[6], tok) end
end
-- cool bounce on the front seed's lower right
c:put(26, 51, "#6a4a5a")

A.save(c, NAME)
