-- beach-hibiscus-seed (final pass, Opus). Beach hibiscus (Hibiscus tiliaceus): three dark kidney seeds with a fine
-- velvet of pale hairs, lying on a torn scrap of the broad heart-shaped leaf (cordate sinus + petiole stub on the
-- left, ragged torn edge on the right, palmate veins fanning from the sinus, V fold, cool reflected lower edge,
-- AO + contact shadow under every seed). The right seed has germinated: a pale curving stem, two small round
-- cotyledons and the first true leaf, a heart (cordate) blade with palmate veins, so the plant reads at a glance.
-- Material: seeds per-pixel dome light on a 6-tone ramp, hash velvet, rim hairs, pale hilum; leaf 6-tone ramp.
-- History: Sonnet draft (_dA14) replaced.
-- quirk: one fallen yellow hibiscus petal, maroon at its heel and curling at the edge, rests on the leaf scrap.
local NAME = "beach-hibiscus-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local YLEAF = { "#1f4a38", "#2f6a40", "#468e48", "#64ae52", "#8dcb62", "#c2e586" }
local VEIN, COOL = "#b8dc8a", "#3a6c72"
local SEED  = { "#24161a", "#3c2620", "#5a3a28", "#7c5334", "#a2734a", "#c99a68" }
local STEM  = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local PET   = { "#9a5420", "#cf8420", "#eaa82a", "#f7c83c", "#ffe274", "#fff3b4" }
local MAR   = { "#4a1428", "#7a1f32", "#a8343c" }

-- ---------------------------------------------------------------- leaf scrap (broad cordate blade, torn)
local LCX, LCY, LANG = 33, 48, -0.2
local ca, sa = cos(LANG), sin(LANG)
local lm = A.rell(LCX, LCY, ca, sa, 23.5, 8.6)
local ax, ay = 16.0, 51.6                        -- sinus apex (veins fan from here)
lm:cut(c:poly{ { 6, 49.0 }, { ax + 0.6, ay - 0.2 }, { 8, 57.5 } })   -- cordate sinus
-- torn right edge: ragged teeth + one bite out of the upper margin
local LU, LV = {}, {}
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - LCX, y - LCY
  local u, v = (dx * ca + dy * sa) / 24, (-dx * sa + dy * ca) / 9
  LU[k], LV[k] = u, v
  local rag = 0.6 + 0.07 * X.hash(floor(v * 6 + 0.5), 3, 11) + 0.05 * abs(sin(v * 9))
  if u > rag then cut[#cut + 1] = k end
  if (x - 45) ^ 2 / 9 + (y - 38.3) ^ 2 / 4 < 1 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local seeds = { { 25, 45, 4.1, 2.8, -0.45, 1 }, { 32, 52, 4.0, 2.7, 0.1, -1 }, { 42, 46, 3.7, 2.7, -0.6, 1 } }
for _, s in ipairs(seeds) do s.m, s.hx, s.hy = A.kidney(s[1], s[2], s[3], s[4], s[5], s[6]) end

-- normals: pillow + V fold across the midrib
local np = X.pillow(lm, 4)
local ln = {}
local px, py = -sa, ca
for k, n in pairs(np) do
  local f = (LV[k] < 0 and -0.32 or 0.38)
  ln[k] = { A.norm(n[1] + px * f, n[2] + py * f, n[3]) }
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
-- palmate veins fanning from the sinus apex (explicit bowed polylines, lit-side pale / shade-side dark)
local function vein(phi, L, bow, main)
  local pts = {}
  for i = 0, 6 do local t = i / 6 local a = phi + bow * t
    pts[#pts + 1] = { ax + cos(a) * L * t, ay + sin(a) * L * t } end
  for j = 1, #pts - 1 do
    A.pl({ pts[j], pts[j + 1] }):each(function(x, y) local k = K(x, y)
      if lm:has(x, y) and (x - ax) ^ 2 + (y - ay) ^ 2 > 3 then
        if main then c:put(x, y, VEIN, ltok) else c:put(x, y, LV[k] < 0 and VEIN or LEAF[2], ltok) end
      end end)
  end
end
vein(LANG, 38, 0.02, true)
vein(LANG - 0.62, 20, 0.28) vein(LANG + 0.62, 20, -0.3)
vein(LANG - 1.25, 11, 0.45) vein(LANG + 1.2, 10, -0.45)
-- midrib shade side
A.pl({ { ax + 2, ay + 0.6 }, { ax + 2 + cos(LANG) * 33, ay + 0.6 + sin(LANG) * 33 } }):each(function(x, y)
  local k = K(x, y) if lm:has(x, y) and not bias[k] and c:get(x, y) ~= VEIN:lower() then c:put(x, y, LEAF[3], ltok) end end)
-- cool reflected light on the lower rim; pale lit rim on the upper edge
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LV[k] > 0.55 and LU[k] > -0.75 and LU[k] < 0.55 then c:put(x, y, COOL, ltok)
  elseif LV[k] < -0.6 and LU[k] > -0.6 and LU[k] < 0.3 and (x + y) % 3 ~= 0 then c:put(x, y, LEAF[6], ltok) end
end)
-- petiole stub out of the sinus
for i, q in ipairs{ { 15, 52, 4 }, { 14, 52, 5 }, { 13, 53, 4 }, { 12, 53, 4 }, { 11, 54, 3 }, { 10, 54, 3 }, { 9, 55, 2 },
  { 14, 53, 2 }, { 12, 54, 2 }, { 10, 55, 1 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- ---------------------------------------------------------------- quirk: fallen yellow petal on the scrap
local pm = A.rell(50.0, 47.5, cos(0.45), sin(0.45), 6.0, 3.8)
pm:cut(A.rell(55.6, 47.4, cos(0.45), sin(0.45), 1.5, 1.3))   -- wavy rim notch
local ptok = { r = { name = "petal" } }
X.ao(bias, lm, pm, 1, -1)
pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local pidx = A.shade(c, pm, A.dome(pm, 49.5, 46.5, 5.5, 2, 0.5), PET, { tok = ptok, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 } })
pm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - 50.0, y - 47.5
  local u = dx * cos(0.45) + dy * sin(0.45)
  local v = -dx * sin(0.45) + dy * cos(0.45)
  if u < -3.4 then c:put(x, y, (u < -4.8) and MAR[1] or MAR[2], ptok)        -- maroon heel
  elseif u < -2.3 and abs(v) < 1.8 then c:put(x, y, MAR[3], ptok)
  elseif (floor(v * 1.6 + u * 0.15) % 2 == 0) and u > -1 and u < 3.6 then A.step(c, pidx, PET, x, y, -1, ptok) end  -- fine radial ribs
end)
-- curled lit edge on the upper rim
for _, q in ipairs{ { 47, 43 }, { 48, 43 }, { 49, 44 }, { 50, 44 }, { 51, 45 } } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], PET[6], ptok) end end

-- ---------------------------------------------------------------- sprout from the right seed
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 42, 45 }, { 43, 39 }, { 37, 32 }, { 39, 21 } }, function(t) return 1.05 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- round cotyledons on short stalks
local function coty(cx, cy, ang, ra, rb)
  local m = A.rell(cx, cy, cos(ang), sin(ang), ra, rb)
  m:cut(sm)
  local n = A.dome(m, cx - 0.6, cy - 0.6, ra + 0.5, 1.6, 0.55)
  A.shade(c, m, n, YLEAF, { tok = ltok, amb = 0.08, wrap = 0.25, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  for t = -ra + 1, ra - 1.2, 0.5 do local x, y = floor(cx + cos(ang) * t + 0.5), floor(cy + sin(ang) * t + 0.5)
    if m:has(x, y) then c:put(x, y, YLEAF[t < 0 and 6 or 3], ltok) end end
  return m
end
local c1 = coty(33.6, 32.2, 0.35, 3.8, 2.3)
local c2 = coty(45.0, 31.6, -0.3, 3.8, 2.3)
for _, q in ipairs{ { 37, 33, 3 }, { 41, 32, 2 } } do c:put(q[1], q[2], STEM[q[3]], stok) end
-- first true leaf: heart blade (two round basal lobes, deep sinus at the stalk, pointed tip up-right)
local tm = A.rell(35.4, 18.6, 0.7, 0.7, 4.0, 4.0):add(A.rell(42.6, 18.2, 0.7, 0.7, 4.0, 4.0))
tm:add(c:poly{ { 32.4, 17.4 }, { 45.8, 16.4 }, { 41.6, 6.6 } })
tm:cut(c:poly{ { 37.0, 23.4 }, { 39.1, 18.2 }, { 41.3, 23.4 } })
-- normals: pillow + V fold about the midrib (attach -> tip)
local mx0, my0, mx1, my1 = 39.1, 19.0, 41.6, 7.2
local tnn = X.pillow(tm, 2.4)
local TS = {}
for k, n in pairs(tnn) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local cr = ((mx1 - mx0) * (y + 0.5 - my0) - (my1 - my0) * (x + 0.5 - mx0)) / 12
  TS[k] = cr
  local f = cr < 0 and -0.35 or 0.35
  tnn[k] = { A.norm(n[1] - f * 0.9, n[2] - f * 0.25, n[3]) }
end
local tb = {}
A.shade(c, tm, tnn, YLEAF, { tok = ltok, amb = 0.08, wrap = 0.25, bias = tb, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
-- palmate veins on the true leaf from the attach point
for i, v in ipairs{ { { 39, 18 }, { 40, 14 }, { 41, 9 } }, { { 39, 18 }, { 36, 16 }, { 34, 15 } },
  { { 39, 18 }, { 42, 16 }, { 44, 15 } }, { { 38, 19 }, { 36, 20 }, { 33, 20 } }, { { 40, 19 }, { 42, 20 }, { 45, 20 } } } do
  A.pl(v):each(function(x, y) if tm:has(x, y) then
    local k = K(x, y)
    c:put(x, y, (TS[k] or 0) < 0 and YLEAF[6] or YLEAF[3], ltok) end end)
end
for _, q in ipairs{ { 39, 19, 2 }, { 39, 20, 2 } } do c:put(q[1], q[2], STEM[q[3]], stok) end
-- small glint on the true leaf
c:put(37, 14, YLEAF[6], ltok) c:put(38, 14, YLEAF[6], ltok)

-- ---------------------------------------------------------------- seeds last (velvet, rim hairs, hilum, glint)
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local n = A.dome(s.m, s[1] - 0.5, s[2] - 0.6, s[3] + 0.3, 1.8, 0.6)
  local idx = A.shade(c, vis, n, SEED, { tok = tok, bias = sb, amb = 0.06, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  vis:each(function(x, y)                                     -- velvet: sparse pale hairs on the body
    local h = X.hash(x, y, 40 + i)
    if h > 0.86 and (idx[K(x, y)] or 1) >= 2 then A.step(c, idx, SEED, x, y, 1, tok) end
  end)
  -- hilum: pale scar in the notch
  c:put(floor(s.hx + 0.5), floor(s.hy + 0.5), SEED[6], tok)
  -- rim hairs on the lit side
  local ca2, sa2 = cos(s[5]), sin(s[5])
  for _, u in ipairs{ -0.4, 0.35 } do
    local hx, hy = floor(s[1] + ca2 * u * s[3] + sa2 * (s[4] + 1.2) + 0.5), floor(s[2] + sa2 * u * s[3] - ca2 * (s[4] + 1.2) + 0.5)
    if not s.m:has(hx, hy) and not sm:has(hx, hy) then c:put(hx, hy, SEED[4], tok) end
  end
  -- one glint
  local gx, gy = floor(s[1] - 1.4 + 0.5), floor(s[2] - 1.2 + 0.5)
  if vis:has(gx, gy) then c:put(gx, gy, "#f6e4c2", tok) end
end
-- germination split on the sprouting seed
c:put(42, 44, STEM[2], stok) c:put(43, 44, SEED[1])

A.save(c, NAME)
