-- coffee-seed (final, Opus single pass). Two grey-green unroasted coffee seeds (flat face up, S crease) and one
-- sprouting seed in its pale parchment husk, on a torn scrap of glossy coffee leaf (looped lateral veins, pale torn
-- tissue on the ripped edge, cool reflected rim, contact shadows). The sprout carries the first pair of opposite,
-- elliptic, drip-tipped coffee leaves with sunken veins; a pale root curls over the scrap edge.
-- quirk: the seedling still wears its parchment husk on top like a little hat (the "soldier" stage).
local NAME = "coffee-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#14362f", "#1d4f3e", "#286a46", "#3c884d", "#5fa656", "#94ca70" }
local TORN, COOL = "#c6e09a", "#3a6a74"
local GB = { "#3c4a3e", "#5a6c52", "#7a8c64", "#9cab7a", "#bdc896", "#dfe4b8" }
local PAR = { "#6e5640", "#937658", "#b59870", "#d2ba8c", "#e9d8ac", "#f8eecc" }
local STEM = { "#3e6a40", "#5e9050", "#88b866", "#bcdc8c" }
local ROOT = { "#9a8a6e", "#c8b894", "#ece0bc" }

-- seed masks first (for AO on the scrap)
local seeds = {
  { 18, 47, 5.0, 3.3, -0.25, GB },
  { 28, 51, 4.8, 3.2, 0.3, GB },
  { 41, 46, 4.6, 3.3, -0.5, PAR },
}
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap
local ltok = { r = { name = "leaf" } }
local lm, ln, LT, LS, len = A.blade(6, 53, 30, 56, 58, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 9.2 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.6)
end, { fold = 0.35 })
-- ripped right end (zigzag tear)
local tear = c:poly{ { 47, 28 }, { 64, 28 }, { 64, 64 }, { 44, 64 }, { 46, 59 }, { 44, 56 }, { 48, 52 }, { 46, 49 }, { 50, 46 }, { 48, 42 }, { 51, 38 } }
lm:cut(tear)
-- wavy margin: small bites along the lower edge
lm:each(function(x, y) local k = K(x, y) if LS[k] > 0.8 and (floor(LT[k] * len) % 7) == 3 then lm.s[k] = nil end end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and TORN or LEAF[3], ltok) return end
  -- lateral veins arching toward the tip, looping near the margin
  local ph = (t * len - abs(s) * 5.5) / 6.5
  local f = ph - floor(ph)
  if f < 0.14 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.05 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- torn edge: pale exposed tissue on the ripped boundary
lm:edge():each(function(x, y) local k = K(x, y)
  if tear:grow(1):has(x, y) and not bias[k] then c:put(x, y, TORN, ltok)
  elseif LS[k] > 0.6 and not bias[k] then c:put(x, y, COOL, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 5, 53, 3 }, { 4, 54, 3 }, { 3, 54, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- root out of the sprouting seed, curling over the lower edge of the scrap
local rtok = { r = { name = "root" } }
local rm = A.stem(c, { { 44, 49 }, { 46, 53 }, { 45, 57 }, { 48, 59 } }, function(t) return 0.95 * (1 - t) + 0.35 end, ROOT, { cut = seeds[3].m, tok = rtok, cuts = { 0.4, 0.75 } })
A.cast({}, lm, rm, 1, 1, -1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout stem
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 40, 44 }, { 37, 36 }, { 35, 28 }, { 36, 21 } }, function(t) return 1.1 - t * 0.25 end, STEM, { tok = stok })
-- first pair of true leaves: opposite, elliptic, drip tip, sunken veins
local function cleaf(ax, ay, cx, cy, bx, by)
  return A.leaf(c, ax, ay, cx, cy, bx, by, 3.7, LEAF, { pw = 0.62, fold = 0.5, vs = 3.0, cut = sm, wfn = function(t)
    if t > 0.985 then return -1 end
    local w = 3.7 * sin(pi * min(1, t * 0.96 + 0.04)) ^ 0.62
    if t > 0.82 then w = w * 0.6 end   -- drip tip
    return max(0.35, w)
  end })
end
local l1 = cleaf(35, 22, 28, 16, 17, 19)
local l2 = cleaf(37, 22, 45, 15, 55, 17)
-- wavy margins: one notch on each leaf's upper edge
c:put(25, 16, LEAF[2], ltok) c:put(47, 14, LEAF[2], ltok)

-- seeds: AO between them, crease, specular
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local vis = s.m:copy()
  if i == 3 then vis:cut(sm) end
  local idx = A.shade(c, vis, s.n, s[6], { amb = 0.08, wrap = 0.22, bias = sb, tok = tok })
  local F = A.frame(s[1], s[2], s[3], s[4], s[5])
  vis:each(function(x, y) local k = K(x, y)
    local u, v = F(x, y)
    local d = v - 0.22 * sin(pi * u)
    if abs(u) < 0.75 and abs(d) < 0.16 then c:put(x, y, s[6][i == 3 and 2 or 1], tok)
    elseif abs(u) < 0.7 and d >= 0.16 and d < 0.42 then c:put(x, y, s[6][min(6, (idx[k] or 3) + 1)], tok) end
  end)
  -- split husk on the sprouting seed: stem emerges through a dark slit
  if i == 3 then c:put(40, 45, PAR[1], tok) c:put(39, 46, PAR[2], tok) end
end
c:put(15, 45, A.CREAM) c:put(16, 45, GB[6])

-- quirk: parchment husk cap on the seedling top
local hm, hn = A.oval(36, 18, 2.6, 1.9, -0.3, 0.8)
local htok = { r = { name = "husk" } }
A.shade(c, hm, hn, PAR, { amb = 0.08, wrap = 0.22, tok = htok })
c:put(35, 19, PAR[2], htok) c:put(36, 19, PAR[1], htok) c:put(35, 17, PAR[6], htok)

A.save(c, NAME)
