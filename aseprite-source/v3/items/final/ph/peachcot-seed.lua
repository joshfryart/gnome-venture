-- peachcot-seed (final pass, Opus aC32_4). One peachcot stone (almond shape, deep wandering furrows with lit ridges,
-- a pale keel along its edge) on a torn peach-leaf scrap (lance leaf, serrated margin, jagged torn base, midrib + veins,
-- cool reflected edge, AO + contact shadow under the stone). The stone has split at its point and a sprout climbs out:
-- reddish stem, two serrated lance leaves and a folded bud (the peachcot leaf in miniature).
-- quirk: a scrap of orange fruit flesh still clings to the stone.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "peachcot-seed"
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local PIT = { "#3a1f22", "#5e3328", "#87502f", "#ad7242", "#cf9a60", "#ecc690" }
local STEM = { "#5a2a32", "#8a4038", "#b8644a", "#dc9068" }
local FLESH = { "#b4422e", "#e0702c", "#f59b38", "#fcc25a" }
local COOL = "#3a6c72"

-- stone geometry
local PX, PY, PRX, PRY, PA = 26, 44, 8.2, 5.4, -0.42
local pm, pn = A.oval(PX, PY, PRX, PRY, PA, 0.7)
-- pointed tip at the upper-right end (where it splits)
local ca, sa = cos(PA), sin(PA)
for i = 1, 2 do pm:set(floor(PX + (PRX + i - 0.3) * ca + .5), floor(PY + (PRX + i - 0.3) * sa + .5)) end

-- leaf scrap: peach leaf on the diagonal, torn base at lower-left
local wfn = function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.6 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.75)
end
local bm, _, BT, BS = A.blade(8, 54, 32, 56, 57, 38, wfn, { fold = 0.38 })
local cut = HP.mask()
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  -- serrated margin: a notch every ~3 px along the outer rim
  if abs(s) > 0.78 and floor(t * 30) % 3 == 0 and t > 0.12 then cut:set(x, y) end
  -- torn base: jagged cut
  if t < 0.05 + 0.07 * X.hash(floor(s * 6), 1, 4) then cut:set(x, y) end
end)
local bias = {}
X.ao(bias, bm, pm, 1, -1) A.cast(bias, bm, pm, 1, 2, -1) A.cast(bias, bm, pm, 2, 3, -1)
local lm, LT, LS = A.leaf(c, 8, 54, 32, 56, 57, 38, 7.6, LEAF, { cut = cut, wfn = wfn, vs = 3.4, fold = 0.38, bias = bias })
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] and LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.88 then c:put(x, y, COOL) end end)

-- sprout: from the split tip up, curving
local tip = { floor(PX + PRX * ca + .5), floor(PY + PRX * sa + .5) }
local sp = { { tip[1] - 1, tip[2] }, { tip[1] + 2, tip[2] - 8 }, { tip[1] - 2, tip[2] - 14 }, { tip[1] + 1, tip[2] - 22 } }
local stok = { r = { name = "stem" } }
local sm = A.stem(c, sp, function(t) return 1.05 - 0.2 * t end, STEM, { tok = stok, cut = pm })
local function bx(t) return A.bez(sp, t) end
local function sleaf(t, ex, ey, cx2, cy2, w)
  local x, y = bx(t) x, y = floor(x + .5), floor(y + .5)
  local m, T, S = A.leaf(c, x, y, x + cx2, y + cy2, x + ex, y + ey, w, LEAF, { cut = sm, vs = 2.6, pw = 0.7 })
  -- serrations
  m:each(function(xx, yy) local k = K(xx, yy)
    if abs(S[k]) > 0.82 and floor(T[k] * 20) % 3 == 0 and T[k] > 0.2 and T[k] < 0.85 then
      local lit = (S[k] < 0)
      c:put(xx, yy, lit and LEAF[5] or LEAF[2]) end end)
  return m
end
local la = sleaf(0.5, -15, -5, -6, -5, 3.0)
local lb = sleaf(0.78, 14, -6, 6, -6, 2.8)
-- folded terminal bud
do local x, y = bx(1) x, y = floor(x + .5), floor(y + .5)
  A.map(c, { ".a.", "abc", "bcd", ".d." }, x - 1, y - 4, { a = LEAF[6], b = LEAF[5], c = LEAF[3], d = LEAF[2] }) end
-- stem contact shadow on leaf scrap is covered by the stone; AO under sprout leaves on the stem
for _, m in ipairs{ la, lb } do m:shift(0, 1):each(function(x, y) if sm:has(x, y) and not m:has(x, y) then c:put(x, y, STEM[1], stok) end end) end

-- stone: furrowed, lit ridges, keel
local ptok = { r = { name = "pit" } }
local v = X.light(pn, { amb = 0.08, wrap = 0.25 })
local idx = {}
pm:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs(A.CUTS) do if (v[k] or 0.45) >= t then i = j + 1 end end
  local dx, dy = x - PX, y - PY
  local u, w = (dx * ca + dy * sa) / PRX, (-dx * sa + dy * ca) / PRY
  local f = sin(u * 4.6 + sin(w * 3.1 + u * 1.7) * 1.6 + w * 1.2)
  if f > 0.72 and abs(u) < 0.9 then i = i - 2 elseif f > 0.35 and f <= 0.72 then i = i + 1 end
  idx[k] = max(1, min(6, i))
end)
for k, i in pairs(idx) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, PIT[i], ptok) end
-- keel: pale ridge along the upper (lit) long edge, dark seam below it
pm:each(function(x, y)
  local dx, dy = x - PX, y - PY
  local u, w = (dx * ca + dy * sa) / PRX, (-dx * sa + dy * ca) / PRY
  if w < -0.62 and w > -0.86 and abs(u) < 0.8 then c:put(x, y, PIT[6], ptok)
  elseif w <= -0.86 and abs(u) < 0.7 then c:put(x, y, PIT[3], ptok) end
end)
-- the split at the tip where the sprout comes out
for _, p in ipairs{ { tip[1] - 2, tip[2] + 1 }, { tip[1] - 1, tip[2] }, { tip[1] - 3, tip[2] + 1 } } do c:put(p[1], p[2], PIT[1], ptok) end
c:put(tip[1], tip[2] - 1, STEM[3], stok)
-- one gloss on the stone
c:put(21, 41, "#fff4d6", ptok)
-- quirk: orange flesh scrap on the lower-right flank
A.map(c, { ".ab", "bcd", "cd." }, 26, 47, { a = FLESH[4], b = FLESH[3], c = FLESH[2], d = FLESH[1] }, { r = { name = "flesh" } })

A.save(c, NAME)
