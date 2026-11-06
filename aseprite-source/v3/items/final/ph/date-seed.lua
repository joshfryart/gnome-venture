-- date-seed (final, Opus single pass). Two long date pits on a torn date-palm leaflet scrap (parallel veins, ragged
-- tear at both ends, V-fold light, cool reflected edge, AO + contact shadow). Back pit lies groove-up (deep lengthwise
-- slit with pale lips); front pit shows its smooth back with the dark germ pore. The front-right pit has germinated:
-- a pale cotyledon stalk and the first strap-shaped, pleated palm leaf plus a younger folded spear.
-- quirk: a papery curl of seed skin peeling off the back pit.
local NAME = "date-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1b3a38", "#26564b", "#367158", "#4f8e62", "#78ad72", "#abcf90" }
local VEIN, COOL = "#c6e2a2", "#3b6c74"
local SEED = { "#3a2220", "#5a3626", "#7d5232", "#a3743f", "#c79a5c", "#e6c48a" }
local STEM = { "#6f8a52", "#a6c27a", "#d2e4a6", "#eef5c8" }
local CUTS = A.CUTS

-- pits: cx, cy, rx, ry, angle
local pits = { { 19, 47, 7.4, 2.8, -0.3 }, { 31, 50, 7.4, 2.9, -0.06 } }
for _, s in ipairs(pits) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.75) end

-- sprout stalk + leaves (masks first, for AO on the scrap)
local stalk = { { 38, 49 }, { 41, 46 }, { 40, 40 }, { 39, 35 } }
local sm, sn = A.tube(stalk, function(t) return 1.15 end)
sm:cut(pits[2].m)
local la, lan, LAT, LAS = A.blade(39, 36, 36, 22, 28, 14, function(t)
  if t > 0.99 then return -1 end
  return max(0.45, 2.7 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.55)
end, { fold = 0.6 })
local lb, lbn, LBT, LBS = A.blade(40, 36, 45, 28, 47, 22, function(t)
  if t > 0.99 then return -1 end
  return max(0.4, 1.7 * (1 - t) ^ 0.6)
end, { fold = 0.7 })
la:cut(sm) lb:cut(sm) lb:cut(la)

-- scrap: date-palm leaflet, torn both ends
local lm, ln, LT, LS, len = A.scrap(7, 50, 30, 57, 57, 47, { w = 6.4, tornA = 0.05, tornB = 0.93, seed = 3, fold = 0.4,
  shape = function(t) return 0.75 + 0.25 * sin(pi * t) end })
local bias = {}
for _, s in ipairs(pits) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, sm, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- parallel veins (monocot) + midrib, cool edge on the shade rim
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local q = abs(s)
  if (q > 0.38 and q < 0.46) or (q > 0.7 and q < 0.77) then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

-- stalk
local stok = { r = { name = "stalk" } }
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- leaves: pleated strap (alternating light/dark folds along the length)
local ftok = { r = { name = "frond" } }
local function pleat(m, n, T, S, nP)
  local bb = {}
  m:each(function(x, y) local k = K(x, y)
    local p = (S[k] + 1) * nP / 2
    local f = p - floor(p)
    if f < 0.3 then bb[k] = -1 elseif f > 0.75 then bb[k] = 1 end
  end)
  A.toneN(c, m, n, LEAF, { bias = bb, tok = ftok, cuts = CUTS, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.12 and T[k] > 0.05 and T[k] < 0.8 then
    c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[4], ftok) end end)
end
local lbias = {} X.ao(lbias, lb, la, 1, -1)
pleat(lb, lbn, LBT, LBS, 2)
lb:each(function(x, y) if lbias[K(x, y)] then c:put(x, y, LEAF[2], ftok) end end)
pleat(la, lan, LAT, LAS, 3)
-- leaf foot ambient where it leaves the stalk
c:put(39, 36, LEAF[2], ftok) c:put(40, 36, LEAF[1], ftok)

-- pits
for i, s in ipairs(pits) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #pits do vis:cut(pits[j].m) X.ao(sb, s.m, pits[j].m, 1, -1) end
  if i == 2 then X.ao(sb, s.m, sm, 1, 0) end
  local tok = { r = { name = "pit" .. i } }
  local idx = A.toneN(c, vis, s.n, SEED, { bias = sb, tok = tok, cuts = CUTS, amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if i == 1 then
      -- groove-up pit: dark slit along the middle, pale lit lip just above it
      if abs(v) < 0.18 and abs(u) < 0.8 then c:put(x, y, SEED[1], tok)
      elseif v > -0.55 and v < -0.18 and abs(u) < 0.7 then c:put(x, y, SEED[min(6, (idx[k] or 4) + 1)], tok) end
    else
      -- faint lengthwise grain lines on the back
      if abs(v + 0.45) < 0.12 and u > -0.6 and u < 0.5 and X.hash(x, y, 5) > 0.4 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
end
-- germ pore on the front pit's back, specular on the back pit
c:put(32, 49, SEED[1], { r = { name = "pit2" } })
c:put(26, 48, SEED[2], { r = { name = "pit2" } })
c:put(14, 47, SEED[6], { r = { name = "pit1" } }) c:put(15, 47, SEED[6], { r = { name = "pit1" } })
c:put(27, 48, A.CREAM, { r = { name = "pit2" } })

-- quirk: papery skin curl peeling off the back pit (upper edge, lifts into the air)
local ptok = { r = { name = "skin" } }
for _, q in ipairs{ { 22, 43, "#f3dcae" }, { 23, 42, "#f3dcae" }, { 24, 42, "#d8b884" }, { 25, 43, "#b8935e" }, { 24, 43, "#e9cf9c" } } do
  c:put(q[1], q[2], q[3], ptok) end

A.save(c, NAME)
