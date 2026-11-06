-- fava-bean-seed (final, Opus single pass). Two dried fava seeds (broad flat kidney ovals, buff-tan with fine
-- wrinkles, a black hilum stripe on the top end with a pale lip) lying on a torn glaucous fava leaflet scrap (entire
-- margin, midrib + looping veins, V-fold light, jagged tear on the right, cool reflected edge, AO + contact shadows).
-- The right seed has germinated: split seed coat, a thick pale stem rising into two pairs of oval blue-green
-- leaflets (the fava paired leaf) and a folded bud; a white radicle curls down over the scrap.
-- Draft by Sonnet replaced.
-- quirk: a tiny ladybird is climbing the right lower leaflet (favas are an aphid buffet).
local NAME = "fava-bean-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1b3a3f", "#265348", "#346e52", "#4b8b60", "#71a978", "#a2ca98" }
local SPR  = { "#1f4a3e", "#2c6648", "#3f8550", "#5ea35c", "#86c06e", "#b6dc92" }
local STEM = { "#3d7050", "#64a066", "#9acb86", "#d4ecb6" }
local SEED = { "#4a2c22", "#6e4630", "#93663e", "#b88a54", "#d6ae72", "#eed29c" }
local ROOT = { "#a89c84", "#d2c8ae", "#f0ead2" }
local COOL, HIL, LIP = "#4c7c8a", "#2b1c26", "#f2e2b4"

-- leaf scrap: a leaflet lying on the diagonal, natural tip at the left, torn at the right
local tear = HP.mask()
local JAG = { 0, 2, -1, 1, 3, 0, -2, 1, 2, -1, 1, 3 }
for y = 30, 64 do for x = 49 + JAG[y % 12 + 1], 64 do tear:set(x, y) end end
local seeds = { { 20, 47, 5.2, 3.8, -0.28 }, { 37, 45, 5.0, 3.7, 0.42 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end
local lbias = {}
local lm0 = A.blade(6, 50, 30, 56, 60, 42, function(t) if t > 0.985 then return -1 end
  return max(0.4, 8.2 * sin(pi * min(1, t * 0.82 + 0.03)) ^ 0.62) end, { fold = 0.4 })
lm0:cut(tear)
for _, s in ipairs(seeds) do X.ao(lbias, lm0, s.m, 1, -1) A.cast(lbias, lm0, s.m, 1, 2, -1) end
local lm, LT, LS, lidx = A.leaf(c, 6, 50, 30, 56, 60, 42, 8.2, LEAF,
  { cut = tear, bias = lbias, vs = 4.2, fold = 0.4,
    wfn = function(t) if t > 0.985 then return -1 end return max(0.4, 8.2 * sin(pi * min(1, t * 0.82 + 0.03)) ^ 0.62) end })
local ltok = { r = { name = "leaf" } }
lm:edge():each(function(x, y) local k = K(x, y)
  if not lbias[k] and LS[k] > 0.7 and LT[k] > 0.12 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale broken tissue along the tear
lm:each(function(x, y) if tear:has(x + 1, y) and not lbias[K(x, y)] then c:put(x, y, LEAF[6], ltok) end end)

-- radicle: white root curling off the sprouting seed over the scrap
local rm, rn = A.tube({ { 40, 48 }, { 43, 52 }, { 47, 53 }, { 49, 51 } }, function(t) return 1.3 * (1 - t) + 0.45 end)
rm:cut(seeds[2].m)
A.cast({}, lm, rm, 1, 1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[2].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
A.shade(c, rm, rn, ROOT, { amb = 0.2, wrap = 0.3, cuts = { 0.4, 0.7 } })

-- sprout stem (thick, pale at the foot)
local stok = { r = { name = "stem" } }
local sp = { { 38, 42 }, { 36, 34 }, { 40, 26 }, { 38, 13 } }
local sm, sn, ST = A.tube(sp, function(t) return 1.45 - t * 0.35 end)
sm:cut(seeds[2].m)
local sidx = A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- paired leaflets: two leaves of two ovals each, plus a folded bud on top
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m = A.leaf(c, ax, ay, cx, cy, bx, by, w, SPR, { cut = sm, vs = 2.6, fold = 0.35,
    wfn = function(t) if t > 0.97 then return -1 end return max(0.4, w * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.55) end })
  return m
end
local L1 = leaflet(37, 29, 31, 25, 23, 25, 3.5)
local L2 = leaflet(39, 29, 45, 26, 53, 27, 3.5)
local L3 = leaflet(38, 18, 34, 13, 28, 11, 3.0)
local L4 = leaflet(39, 18, 43, 13, 49, 12, 3.0)
-- AO on the stem where leaf stalks join
for _, y in ipairs{ 29, 30, 18, 19 } do
  for x = 35, 41 do if sm:has(x, y) and not (L1:has(x, y) or L2:has(x, y) or L3:has(x, y) or L4:has(x, y)) then c:put(x, y, STEM[1], stok) end end
end
-- folded bud at the tip
local bm, bn = A.oval(38.2, 10.5, 1.6, 2.6, -0.3, 1)
bm:cut(L3):cut(L4)
A.shade(c, bm, bn, SPR, { amb = 0.15, wrap = 0.3 })

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local idx = A.shade(c, s.m, s.n, SEED, { amb = 0.08, wrap = 0.25, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  -- wrinkles: short wavy creases across the seed (one tone darker, a lit pixel above each)
  s.m:shrink(1):each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    local w = sin(u * 1.25 + sin(v * 0.9) * 1.4 + i)
    if w > 0.93 and X.hash(x, y, 5) > 0.35 then c:put(x, y, SEED[max(1, idx[k] - 1)], tok)
    elseif w < -0.96 and idx[k] >= 3 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end
  end)
  -- hilum: black stripe across the top end with a pale lip
  for j = -1, 1 do
    local hx = floor(s[1] + 4.2 * ca - j * 1.4 * (-sa) + 0.5)
    local hy = floor(s[2] + 4.2 * sa - j * 1.4 * ca + 0.5)
    hx = floor(s[1] + (s[3] - 0.9) * ca - j * sa + 0.5)
    hy = floor(s[2] + (s[3] - 0.9) * sa + j * ca + 0.5)
    if s.m:has(hx, hy) then c:put(hx, hy, HIL, tok) end
    local lx, ly = floor(hx - ca + 0.5), floor(hy - sa + 0.5)
    if s.m:has(lx, ly) and j <= 0 then c:put(lx, ly, LIP, tok) end
  end
  local gx, gy = A.specAt(s.m, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, SEED[6], tok) end
end
-- split seed coat where the stem leaves seed 2
c:put(37, 42, SEED[2]) c:put(39, 42, SEED[2]) c:put(38, 42, STEM[3])

-- quirk: ladybird on the right lower leaflet (red shell, ink head, two spots, cream glint)
local lx, ly = 47, 25
for _, q in ipairs{ { 0, 0, "#e8493b" }, { 1, 0, "#e8493b" }, { 2, 0, "#c8323a" }, { 0, 1, "#d63c38" }, { 1, 1, "#b52e3f" },
  { 2, 1, "#8e2236" }, { 3, 0, HIL }, { 3, 1, HIL }, { 1, -1, "#ff8a5c" }, { 2, -1, "#e8493b" } } do
  c:put(lx + q[1], ly + q[2], q[3])
end
c:put(lx, ly, "#fff4d6") c:put(lx + 1, ly + 1, HIL)
A.save(c, NAME)
