-- bitter-melon-seed (final, Opus aR20_2). Three flat, oblong bitter-melon seeds (cream-tan, crenate notched rims,
-- engraved ridges, AO + contact shadow) on a torn scrap of a palmate melon leaf lying flat (five lobes, toothed
-- margin, palmate veins from the petiole, jagged torn base, cool reflected edge). The left seed has germinated: a pale
-- stem, two round cotyledons and a first deeply five-lobed true leaf showing the melon's foliage.
-- quirk: one seed is still wrapped in its sticky scarlet aril.
local NAME = "bitter-melon-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#b8de86", "#3a6c72"
local SEED = { "#4a3226", "#7a5638", "#a8804e", "#c9a46a", "#e2c78e", "#f6e6b8" }
local ARIL = { "#5e1426", "#962034", "#cc3040", "#ec5a52", "#ff8e78", "#ffc8b0" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }

-- palmate leaf lying flat (squashed in y), middle lobe pointing right; base torn away on the left
local LCX, LCY, LR, SQ = 13, 47, 41, 0.42
local lm = HP.mask()
local LA, LF = {}, {}
for y = 30, 62 do for x = 4, 60 do
  local dx, dy = x - LCX, (y - LCY) / SQ
  local r = sqrt(dx*dx + dy*dy)
  local a = math.atan(dy, dx) - 0.06
  local spread = 1.25
  if abs(a) <= spread then
    local ph = (a / spread * 0.5 + 0.5) * 5
    local f = abs((ph - floor(ph)) - 0.5) * 2
    local rr = LR * (1 - 0.34 * f ^ 1.5) * (1 - 0.3 * (abs(a) / spread) ^ 2)
    -- toothed margin
    rr = rr - (X.hash(floor(r / 2.2), floor(ph * 3), 5) > 0.55 and 1.2 or 0)
    if r <= rr and r > 6 then lm:set(x, y) LA[K(x, y)], LF[K(x, y)] = ph, f end
  end
end end
A.tear(lm, 15, 62, 19, 30, 1.6, 11)
local ln = X.pillow(lm, 2.2)
-- gentle curl: the far (upper) half tilts toward the light
for k, n in pairs(ln) do local y = k // 1024 - 256 local t = (y - LCY) * 0.06 ln[k] = { A.norm(n[1], n[2] + t, n[3]) } end

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 47, 4.4, 2.4, -0.25 }, { 31, 46, 4.6, 2.5, 0.12 }, { 43, 51, 4.6, 2.5, -0.35 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7)
  -- crenate rim: knock out notches along the long edges
  local cut = {}
  s.m:edge():each(function(x, y) local ca, sa = cos(s[5]), sin(s[5])
    local u = ((x - s[1]) * ca + (y - s[2]) * sa)
    if abs(u) < s[3] - 1 and floor(u + 10) % 3 == 0 then cut[#cut + 1] = K(x, y) end end)
  for _, k in ipairs(cut) do s.m.s[k] = nil end
end
local aril = seeds[2]
aril.am = aril.m:grow(1)
local bias = {}
for i, s in ipairs(seeds) do local cm = i == 2 and aril.am or s.m X.ao(bias, lm, cm, 1, -1) A.cast(bias, lm, cm, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.tone(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- palmate veins: a ray to each lobe tip, plus faint side veins
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local f = LF[k]
  local dx, dy = x - LCX, (y - LCY) / SQ
  local r = sqrt(dx*dx + dy*dy)
  if f > 0.93 and r < LR * 0.85 then c:put(x, y, lidx[k] >= 4 and VEIN or LEAF[3], ltok)
  elseif f > 0.55 and f < 0.62 and floor(r) % 5 == 0 then c:put(x, y, LEAF[(lidx[k] or 3) >= 4 and 6 or 2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and y > LCY + 3 and (lidx[k] or 0) <= 3 then c:put(x, y, COOL, ltok) end end)

-- sprout from the left seed: stem, cotyledons, palmate true leaf
local stok = { r = { name = "stem" } }
local sp = { { 18, 45 }, { 16, 39 }, { 20, 33 }, { 21, 26 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[1].m)
local sidx = A.tone(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local ctok = { r = { name = "coty" } }
local function coty(cx, cy, ang)
  local m, n = A.oval(cx, cy, 4.2, 2.3, ang, 0.8)
  m:cut(sm)
  A.tone(c, m, n, LEAF, { tok = ctok, amb = 0.14, wrap = 0.3 })
  -- midrib
  for u = -2, 2 do local x, y = floor(cx + u * cos(ang) + .5), floor(cy + u * sin(ang) + .5) if m:has(x, y) then c:put(x, y, LEAF[u < 0 and 3 or 2], ctok) end end
  return m
end
local cl = coty(16, 27, 0.4)
local cr = coty(27, 26, -0.35)
-- true leaf: deep five-lobed, pointing up
local tm = A.palm(21, 19, 11, 5, -pi / 2, 0.5, 1.75)
tm:cut(c:rect(0, 21, 63, 63))
tm:add(c:ellipse(21, 19, 1, 1))
tm:cut(cl):cut(cr)
local tb = {}
X.ao(tb, tm, cl:copy():add(cr), 1, -1)
local tidx = A.tone(c, tm, X.pillow(tm, 1.6), LEAF, { tok = ltok, bias = tb, amb = 0.15, wrap = 0.3 })
-- veins to the five lobe tips
for i = 0, 4 do local a = -pi / 2 + (i - 2) * (2 * 1.75 / 5)
  for r = 2, 8 do local x, y = floor(21 + cos(a) * r + .5), floor(19 + sin(a) * r + .5)
    if tm:has(x, y) then c:put(x, y, (tidx[K(x, y)] or 3) >= 4 and VEIN or LEAF[3], ltok) end end end
for i = 0, 4 do c:put(21, 20 + i, STEM[2 + (i % 2)], stok) end

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 1 then X.ao(sb, s.m, sm, 1, -1) end
  local ca, sa = cos(s[5]), sin(s[5])
  local idx = A.tone(c, s.m, s.n, SEED, { tok = tok, bias = sb, amb = 0.1, wrap = 0.3 })
  -- engraved ridges: two dark grooves along the seed, pale crest between
  s.m:each(function(x, y) local k = K(x, y)
    local u = ((x - s[1]) * ca + (y - s[2]) * sa) / (s[3] + .45)
    local v = (-(x - s[1]) * sa + (y - s[2]) * ca) / (s[4] + .45)
    if abs(u) < 0.72 and abs(abs(v) - 0.38) < 0.14 then c:put(x, y, SEED[max(1, idx[k] - 2)], tok) end
    if abs(u) < 0.6 and abs(v) < 0.18 and v < 0.1 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end
  end)
  if i == 2 then
    -- quirk: scarlet aril wrapped around this seed, the seed's ridges showing through near the top
    local am = aril.am:copy()
    local ab = {}
    local an = X.pillow(am, 1.8)
    local aidx = A.tone(c, am, an, ARIL, { tok = { r = { name = "aril" } }, amb = 0.08, wrap = 0.3, bias = ab })
    -- wet shine + pulpy wrinkles
    am:each(function(x, y) local k = K(x, y) if X.hash(x, y, 9) > 0.86 and aidx[k] and aidx[k] >= 3 then c:put(x, y, ARIL[aidx[k] - 1]) end end)
    c:put(floor(s[1] - 2), floor(s[2] - 2), A.CREAM) c:put(floor(s[1] - 1), floor(s[2] - 2), ARIL[6])
    -- a torn gap in the aril shows the seed coat
    for _, d in ipairs{ { 1, 0 }, { 2, 0 }, { 3, 1 }, { 2, 1 } } do c:put(floor(s[1]) + d[1], floor(s[2]) + d[2], SEED[d[2] == 0 and 5 or 3]) end
  end
end
A.fin(c, NAME)
