-- lime-seed (Opus artist pass). Two pale ivory lime pips (plump teardrops, one pointed end, fine lengthwise ridges)
-- on a torn scrap of glossy citrus leaf (dark waxy green, pale midrib, looping veins, winged petiole at the base,
-- jagged torn tip, cool reflected edge, AO + contact shadow under each pip). The right pip has germinated: pale
-- stem, two fleshy round cotyledons and the first true leaf, an ovate pointed citrus leaf on a little winged stalk.
-- quirk: a tiny green thorn already pokes out of the sprout's stem.
local NAME = "lime-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_4.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = D.new(NAME)
local LEAF = { "#123a2a", "#1a5234", "#24703c", "#348f42", "#55ad4c", "#8fd066" }
local VEIN, COOL = "#b6e07e", "#2f6668"
local PIP  = { "#6a5a3c", "#937e52", "#bba576", "#d9c894", "#efe3b8", "#fff6d8" }
local STEM = { "#5a8e4a", "#8cbc66", "#bcdc90", "#e2f2bc" }
local ltok = D.tok("leaf")

-- pips (seed coat): teardrops, blunt end + pointed end
local seeds = { { 18, 50, 5.2, 2.9, -0.25 }, { 29, 46, 5.2, 2.9, 0.35 }, { 41, 42, 4.6, 2.8, -1.25 } }
for _, s in ipairs(seeds) do
  local m, n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8)
  -- pinch the +u end into a point
  local ca, sa = cos(s[5]), sin(s[5])
  local cut = {}
  m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if u > 0.2 and abs(v) > 1 - (u - 0.2) * 0.2 - (u > 0.55 and (u - 0.55) * 1.6 or 0) then cut[#cut + 1] = K(x, y) end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  s.m, s.n = m, n
end

-- leaf scrap: glossy citrus leaf on the diagonal, torn at the far end
local lm, ln, LT, LS, len = G.blade(10, 55, 30, 50, 55, 37, function(t)
  if t > 0.93 then return -1 end
  return max(0.6, 7.6 * sin(pi * min(1, t * 0.82 + 0.1)) ^ 0.75)
end, { fold = 0.32 })
-- torn edge: jagged bite across the tip
do local cut = {}
  lm:each(function(x, y) local k = K(x, y)
    local z = (LS[k] + 1) * 2.2
    local j = 0.06 * abs((z % 2) - 1)
    if LT[k] > 0.8 - j - LS[k] * 0.05 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- looping secondary veins (citrus: veins arc and join near the margin)
  local ph = (t * len - abs(s) * 5.0) / 6.5
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.72 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  if abs(abs(s) - 0.76) < 0.05 and t > 0.1 and s < 0 then c:put(x, y, LEAF[5], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 then c:put(x, y, COOL, ltok) end end)
-- waxy gloss streak on the lit half
for _, p in ipairs{ { 21, 47 }, { 22, 47 }, { 23, 46 } } do if lm:has(p[1], p[2]) and not bias[K(p[1], p[2])] then c:put(p[1], p[2], "#c8ec98", ltok) end end
-- winged petiole at the base (citrus cue): small heart wing + stalk
local wing = G.rell(8, 57, -0.8, 0.6, 2.6, 1.6)
wing:cut(lm)
D.tone(c, wing, X.pillow(wing, 1.5), LEAF, { amb = 0.15, tok = ltok })
c:put(5, 59, LEAF[2], ltok) c:put(6, 59, LEAF[3], ltok)

-- sprout from the right pip: stem, cotyledons, true leaf
local stok = D.tok("stem")
local sp = { { 41, 40 }, { 39, 35 }, { 40, 29 }, { 40, 21 } }
local sm, sn = G.tube(sp, function(t) return 1.1 - 0.15 * t end)
sm:cut(seeds[3].m)
D.tone(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
-- quirk: thorn on the stem
c:put(42, 32, STEM[2], stok) c:put(43, 31, STEM[1], stok)
-- cotyledons: fleshy, rounded, slightly cupped
local function coty(cx, cy, ux, uy)
  local m = G.rell(cx, cy, ux, uy, 4.2, 2.4)
  m:cut(sm)
  local n = X.sphere(cx - 0.8, cy - 0.8, 4.2, m)
  D.tone(c, m, n, D.LEAF, { amb = 0.14, wrap = 0.3, tok = ltok })
  return m
end
local cl = coty(35, 28, -0.9, -0.42)
local cr = coty(45.5, 28, 0.9, -0.42)
-- dark seam where cotyledons meet the stem
c:put(39, 29, D.LEAF[1], ltok) c:put(42, 29, D.LEAF[1], ltok)
-- true leaf: ovate pointed blade on a winged stalk
local tm, tn, TT, TS = G.blade(40, 22, 38, 16, 43, 8, function(t)
  if t > 0.97 then return -1 end
  return max(0.4, 3.4 * sin(pi * min(1, t * 0.95 + 0.08)) ^ 0.8)
end, { fold = 0.35 })
tm:cut(cl):cut(cr)
D.tone(c, tm, tn, LEAF, { amb = 0.16, wrap = 0.3, tok = ltok })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.18 and TT[k] > 0.15 and TT[k] < 0.88 then c:put(x, y, TS[k] <= 0 and VEIN or LEAF[3], ltok) end end)
c:put(39, 23, D.LEAF[5], ltok) c:put(41, 23, D.LEAF[4], ltok)          -- tiny petiole wings
c:put(39, 14, "#d6f4a8", ltok)                                         -- gloss glint

-- pips last: ridged ivory coat, AO between neighbours, pale glint
for i, s in ipairs(seeds) do
  local tok = D.tok("pip" .. i)
  local sb = {}
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local idx = D.tone(c, s.m, s.n, PIP, { amb = 0.1, wrap = 0.3, bias = sb, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local k = K(x, y) local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(v) < 0.12 and u > -0.75 and u < 0.6 then c:put(x, y, PIP[max(1, (idx[k] or 3) - 1)], tok) end   -- raphe ridge
  end)
  -- hilum: dark dot at the pointed tip
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + 0.5), floor(s[2] + sa * (s[3] - 0.6) + 0.5)
  if s.m:has(hx, hy) then c:put(hx, hy, PIP[1], tok) end
  local gx, gy = floor(s[1] - ca * 2 - 1 + 0.5), floor(s[2] - sa * 2 - 1 + 0.5)
  if s.m:has(gx, gy) then c:put(gx, gy, PIP[6], tok) end
end
-- root tip peeking from the sprouting pip, over the leaf
c:put(45, 45, STEM[3], stok) c:put(46, 46, STEM[2], stok) c:put(47, 47, STEM[1], stok)
D.save(c, NAME)
