-- nutmeg-seed (final, C3 Opus single pass). Two nutmegs on a torn scrap of glossy elliptic nutmeg leaf (dark
-- green, pale midrib, pinnate veins, cool reflected edge, AO + contact shadow under each seed). Left: a whole
-- nutmeg still wrapped in its scarlet lacy mace (aril strands over the glossy brown shell). Right: a bare,
-- wrinkle-furrowed nutmeg that has sprouted: pale stem and two glossy pointed-elliptic nutmeg leaves.
-- quirk: one loose strand of mace has slipped off and curls on the leaf like a red ribbon.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "nutmeg-seed"
local c = A.new(NAME)
local LEAF = { "#123a32", "#1b5238", "#286c40", "#3a8a46", "#5aa84e", "#8cc864" }
local VEIN, COOL = "#b4dc84", "#3a6c72"
local SEED = { "#2e1a1e", "#4c2a24", "#6e3e2c", "#93583a", "#b87c52", "#e0a978" }
local MACE = { "#5a1428", "#8c1e2c", "#bc302e", "#e2503a", "#fa7e52", "#ffb48a" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }

-- seeds (cx, cy, rx, ry, angle)
local s1 = { 19, 44, 6.4, 4.6, -0.28 }
local s2 = { 34, 40, 5.4, 4.1, -0.35 }
for _, s in ipairs{ s1, s2 } do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: elliptic blade on the diagonal, its tip torn off in a ragged edge
local lm, ln, LT, LS, len = A.blade(6, 54, 30, 52, 56, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.2 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.55)
end, { fold = 0.34 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local edge = 0.8 + 0.06 * sin(s * 9.0) + 0.05 * (X.hash(floor(s * 6), 0, 5) - 0.5)
  if LT[k] > edge - 0.12 * s then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs{ s1, s2 } do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- pinnate veins arching toward the margin
  local ph = (t * len - abs(s) * 5.5) / 5.2 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.16 and abs(s) < 0.82 and t > 0.06 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- cool reflected edge on the shade side; pale torn fibres on the ragged edge
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.7 and LT[k] > 0.08 then c:put(x, y, COOL, ltok)
  elseif LT[k] > 0.62 and not lm:has(x + 1, y) and not lm:has(x, y - 1) then c:put(x, y, LEAF[6], ltok) end
end)
-- glossy leaf glint
c:put(15, 49, "#d8f0a0", ltok) c:put(16, 49, "#d8f0a0", ltok)
-- petiole stub at the base
for _, q in ipairs{ { 5, 55, 3 }, { 4, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: a loose mace ribbon curling on the leaf (right side)
local rtok = { r = { name = "maceCurl" } }
local rm, rn = A.tube({ { 41, 47 }, { 46, 50 }, { 50, 42 }, { 46, 43 } }, function(t) return 0.85 end)
rm:cut(s2.m)
A.cast({}, lm, rm, 1, 1, -1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not s2.m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
A.shade(c, rm, rn, MACE, { tok = rtok, amb = 0.15, wrap = 0.3 })

-- sprout from the bare nutmeg: stem first (seed covers its foot), then two leaves
local stok = { r = { name = "stem" } }
local sp = { { 35, 38 }, { 34, 30 }, { 37, 24 }, { 36, 15 } }
local sm, sn = A.tube(sp, function(t) return 1.1 - 0.15 * t end)
sm:cut(s2.m)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
local lf1 = A.leaf(c, 36, 19, 28, 15, 20, 16, 3.6, LEAF, { tok = ltok, vs = 3.0, fold = 0.4, pw = 0.9, cut = sm })
local lf2 = A.leaf(c, 37, 17, 44, 11, 52, 12, 3.8, LEAF, { tok = ltok, vs = 3.0, fold = 0.4, pw = 0.9, cut = sm:copy():add(lf1) })
-- terminal bud
for _, q in ipairs{ { 36, 13, 3 }, { 36, 14, 2 }, { 37, 14, 1 } } do c:put(q[1], q[2], STEM[q[3]], stok) end
-- leaf glints (glossy)
c:put(25, 14, LEAF[6], ltok) c:put(44, 11, LEAF[6], ltok)

-- seeds: s2 bare furrowed nutmeg, s1 with mace (front)
local function seed(s, mace, tokname, extraCut)
  local tok = { r = { name = tokname } }
  local vis = s.m:copy()
  if extraCut then vis:cut(extraCut) end
  local sb = {}
  if extraCut then X.ao(sb, s.m, extraCut, 1, -1) end
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.06, wrap = 0.2, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  local ca, sa = cos(s[5]), sin(s[5])
  local mtok = { r = { name = tokname .. "Mace" } }
  local rim = X.rim(s.n)
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local i = idx[k]
    if mace then
      -- lacy aril: flattened strands that branch and rejoin across the shell
      local f1 = abs(sin(v * 4.2 + u * 1.6 + 0.9 * sin(u * 3.3)))
      local f2 = abs(sin(u * 3.0 - v * 1.2 + 1.3))
      if f1 < 0.36 or (f2 < 0.2 and abs(v) < 0.75) then
        c:put(x, y, MACE[max(1, min(6, i + (f1 < 0.15 and 1 or 0)))], mtok) return
      end
      -- shell glimpsed between strands is in the aril's shadow
      c:put(x, y, SEED[max(1, i - 1)], tok)
    else
      -- wrinkle furrows (a fine network of shallow grooves)
      local w1 = abs(sin(u * 5.0 + 1.4 * sin(v * 4.5)))
      local w2 = abs(sin(v * 6.0 + 1.1 * sin(u * 3.7) + 0.5))
      if (w1 < 0.2 or w2 < 0.16) and i > 1 then c:put(x, y, SEED[i - 1], tok)
      elseif rim[k] > 0.65 and i <= 3 then c:put(x, y, "#6c5a7a", tok) end
    end
  end)
  return idx
end
seed(s2, false, "nutmeg2", s1.m)
seed(s1, true, "nutmeg1")
-- specular pops (glossy shell / waxy aril)
c:put(31, 37, SEED[6], { r = { name = "nutmeg2" } }) c:put(32, 37, "#fff4d6", { r = { name = "nutmeg2" } })
c:put(15, 41, MACE[6], { r = { name = "nutmeg1Mace" } })

A.save(c, NAME)
