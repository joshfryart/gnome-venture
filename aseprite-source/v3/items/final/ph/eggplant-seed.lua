-- eggplant-seed (Opus single pass, aB25_3). Four small flat kidney-shaped buff seeds (hilum notch, lit rim,
-- pale face) on a torn eggplant-leaf scrap (broad oval blade, wavy margin, purple-tinged midrib, pinnate veins,
-- pale fibres along the tear, cool reflected edge, AO + contact shadows). One seed has sprouted: purple
-- hypocotyl, two oval cotyledons and a first true leaf (broad, wavy, purple midrib) that shows the eggplant leaf.
-- quirk: the empty seed coat still sits on the tip of the left cotyledon like a little hat.
local NAME = "eggplant-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = G.new2(NAME)
local LEAF = { "#1b3638", "#284f45", "#3a6c4f", "#548a57", "#7aa866", "#aacb86" }
local VEIN, MID, COOL, FIB = "#c4dc98", "#8a6a8e", "#3e6a76", "#d8e8b0"
local SEED = { "#4a3020", "#7a5532", "#a8834e", "#cfae6c", "#e9d08e", "#fbeab8" }
local PUR = { "#2f1a3e", "#4e2a62", "#704088", "#9560ac", "#b98ccc", "#dcbce6" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- leaf scrap: broad blade lying across the bottom, tip torn off on the right
local lm, ln, LT, LS, len = G.blade(6, 52, 30, 42, 58, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.4 * sin(pi * min(1, t * 0.86 + 0.06)) ^ 0.75)
end, { fold = 0.36 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local lim = 0.95 + 0.06 * sin(t * len * 0.75 + (s > 0 and 1.3 or 0))       -- wavy margin
  local tear = 0.8 + 0.035 * ((x * 7 + y * 3) % 5 - 2)                          -- jagged tear
  if abs(s) > lim or t > tear then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: cx, cy, rx, ry, ang
local seeds = { { 15, 49, 3.4, 2.5, 0.25 }, { 23, 51, 3.3, 2.4, -0.2 }, { 33, 46, 3.4, 2.5, 0.1 }, { 45, 47, 3.3, 2.4, -0.5 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end

-- sprout masks first (for AO on the leaf)
local stok, ltok = { r = { name = "stem" } }, { r = { name = "leaf" } }
local sp = { { 33, 44 }, { 32, 37 }, { 34, 31 }, { 33, 25 } }
local sm, sn = G.tube(sp, function(t) return 1.0 + 0.25 * (1 - t) end)
sm:cut(seeds[3].m)
G.cast(bias, lm, sm, 1, 1, -1)

G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.78 then c:put(x, y, s <= 0 and MID or PUR[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / 6.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.78 and t > 0.05 and t < 0.76 then c:put(x, y, s < 0 and VEIN or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] > 0.72 then c:put(x, y, FIB, ltok)                                       -- torn fibres
  elseif LS[k] > 0.62 and LT[k] > 0.08 then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 5, 53, 3 }, { 4, 54, 2 } } do c:put(q[1], q[2], PUR[q[3]], ltok) end      -- petiole stub

-- true leaf: broad oval, wavy edge, purple midrib (drawn before the cotyledons)
local tm, tn, TT, TS = G.blade(33, 26, 31, 16, 37, 7, function(t)
  if t > 0.97 then return -1 end
  return max(0.5, 5.2 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.8)
end, { fold = 0.4 })
do local cc = {}
  tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) > 0.92 + 0.08 * sin(TT[k] * 16) then cc[#cc + 1] = k end end)
  for _, k in ipairs(cc) do tm.s[k] = nil end end
-- cotyledons
local function coty(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, 2.4 * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.6)
  end, { fold = 0.3 })
  return { m = m, n = n, T = T, S = S }
end
local cl = coty(33, 26, 28, 26, 21, 22)
local cr = coty(34, 26, 39, 25, 45, 21)
local tb = {}
X.ao(tb, tm, cl.m, 1, -1) X.ao(tb, tm, cr.m, 1, -1)
tm:cut(cl.m):cut(cr.m)
G.toneN(c, tm, tn, LEAF, { bias = tb, tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y) local s, t = TS[k], TT[k]
  if tb[k] then return end
  if abs(s) < 0.14 and t < 0.86 then c:put(x, y, s <= 0 and MID or PUR[3], ltok) return end
  local ph = (t * 18 - abs(s) * 3.5) / 4.5
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.85 and abs(s) > 0.2 and abs(s) < 0.75 and t < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
for _, q in ipairs{ cl, cr } do
  q.m:cut(sm)
  G.toneN(c, q.m, q.n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  q.m:each(function(x, y) local k = K(x, y) if abs(q.S[k]) < 0.15 and q.T[k] > 0.12 and q.T[k] < 0.8 then c:put(x, y, q.S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
end
-- purple hypocotyl
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), PUR, { cuts = { 0.25, 0.45, 0.62, 0.8, 0.95 }, tok = stok })

-- quirk: seed-coat hat on the left cotyledon tip
do local hm, hn = G.oval(21, 21, 2.3, 1.6, -0.5, 0.6)
  local hb = {}
  G.toneN(c, hm, hn, SEED, { tok = { r = { name = "hat" } }, cuts = CUTS, amb = 0.15 })
  c:put(20, 20, SEED[6], { r = { name = "hat" } })
  c:put(23, 22, SEED[2], { r = { name = "hat" } })                                  -- open split
end

-- seeds: kidney shape (notch), lit rim, pale face, AO between neighbours
for i, s in ipairs(seeds) do
  local ca, sa = cos(s[5]), sin(s[5])
  -- hilum notch on the lower long side
  local nx, ny = floor(s[1] - sa * (s[4] + 0.3) + 0.5), floor(s[2] + ca * (s[4] + 0.3) + 0.5)
  s.m.s[K(nx, ny)] = nil
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.12, wrap = 0.3 }), SEED, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = sb, tok = tok })
  -- raised rim: edge pixels one step darker on the shade side, one lighter on the lit side
  vis:edge():each(function(x, y) local k = K(x, y)
    local lit = (x - s[1]) + (y - s[2]) < 0
    c:put(x, y, SEED[max(1, min(6, (idx[k] or 3) + (lit and 1 or -1)))], tok) end)
  c:put(nx, ny - (ca > 0 and 1 or 0), SEED[2], tok)                                -- notch shadow
end
-- seed 3 split open where the stem leaves it
c:put(33, 44, SEED[2], { r = { name = "seed3" } }) c:put(32, 44, SEED[6], { r = { name = "seed3" } })
-- glint on the front seed
c:put(22, 50, "#fff4d6", { r = { name = "seed2" } }) c:put(23, 50, SEED[6], { r = { name = "seed2" } })

G.save2(c, NAME)
