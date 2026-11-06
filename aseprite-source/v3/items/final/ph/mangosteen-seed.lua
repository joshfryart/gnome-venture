-- mangosteen-seed (final, Opus single pass). Two flat, kidney-oval mangosteen seeds (fibrous tan-brown coat with
-- darker fibre streaks) on a torn scrap of a thick, glossy mangosteen leaf (dark green, pale midrib, many fine
-- parallel side veins, ragged tear at the tip end, petiole stub). The right seed has sprouted: a rosy young stem,
-- a pair of opposite elliptic glossy leaves with midribs, and a bronze-red terminal bud (new mangosteen growth is red).
-- quirk: the left seed still wears a cap of snowy, sticky aril pulp.
local NAME = "mangosteen-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)

local LEAF = { "#132f28", "#1c4a34", "#276338", "#3a8044", "#5a9f4f", "#8cc464" }
local VEIN, COOL = "#a8d47e", "#2f6468"
local YL = { "#1d4a30", "#2b6a3a", "#3f8a44", "#5ea852", "#86c460", "#bfe286" }
local SEED = { "#3a2220", "#5a3626", "#7d5230", "#a0703c", "#c4975a", "#e6c48a" }
local ROSE = { "#5e2a32", "#8a3c40", "#b45a4e", "#d88468" }
local BUD = { "#5a1e2a", "#8e2e30", "#c04a3a", "#e8805a" }
local ARIL = { "#b8aab0", "#dcd2d2", "#f2ebe4", "#fff6ea" }

-- seeds: cx, cy, rx, ry, ang
local seeds = { { 21, 47, 5.2, 3.2, 0.25 }, { 37, 42, 5.0, 3.0, -0.35 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end
local sdm = HP.mask() for _, s in ipairs(seeds) do sdm:add(s.m) end

-- leaf scrap: thick elliptic blade on the diagonal, torn off ragged at the upper-right end
local lm, ln, LT, LS, len = A.blade(8, 55, 30, 52, 56, 38, function(t)
  local u = min(1, t * 0.8 + 0.06)
  return max(0.6, 9.4 * sin(pi * u) ^ 0.6)
end, { fold = 0.32 })
-- ragged tear: zig-zag cut across the blade near the end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  local lim = 0.80 + 0.045 * sin(s * 13.0) + 0.03 * (X.hash(floor(s * 6 + 9), 1, 3) - 0.5) + 0.04 * s
  if t > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end

-- sprout masks first (for AO on the leaf)
local stem = { { 38, 41 }, { 37, 34 }, { 38.5, 27 }, { 38, 21 } }
local stm, stn, STT = A.tube(stem, function(t) return 1.15 - t * 0.2 end)
stm:cut(seeds[2].m)
local radp = { { 41, 44 }, { 43, 48 }, { 44, 52 }, { 47, 56 } }
local rdm, rdn = A.tube(radp, function(t) return 1.1 * (1 - t) + 0.35 end)
rdm:cut(seeds[2].m)
X.ao(bias, lm, rdm, 1, -1) A.cast(bias, lm, rdm, 1, 1, -1)

local ltok = { r = { name = "leaf" } }
local lidx = A.tone(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 }, amb = 0.16, wrap = 0.3 })
-- midrib + fine parallel side veins (mangosteen: many, close, almost straight)
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 2.2) / 3.0
  local f = ph - floor(ph)
  if f < 0.2 and abs(s) > 0.2 and abs(s) < 0.82 and t > 0.05 then
    c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 3) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok)
  end
end)
-- cool reflected edge on the shade side; pale torn fibre edge
local le = lm:edge()
le:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] > 0.74 then c:put(x, y, (X.hash(x, y, 5) > 0.5) and "#b8d890" or LEAF[5], ltok)
  elseif LS[k] > 0.7 and LT[k] > 0.08 then c:put(x, y, COOL, ltok) end
end)
-- glossy leaf glint
c:put(15, 49, LEAF[6], ltok) c:put(16, 49, "#d4eca0", ltok)
-- petiole stub
for _, q in ipairs{ { 7, 56, 3 }, { 6, 57, 4 }, { 5, 58, 3 }, { 6, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- radicle (root tip over the leaf edge), creamy
local rtok = { r = { name = "radicle" } }
A.tone(c, rdm, rdn, { "#8a6a4a", "#b89670", "#dcc39a", "#f2e2bc" }, { tok = rtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1 })

-- young stem, rosy
local stok = { r = { name = "stem" } }
A.tone(c, stm, stn, ROSE, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.12, wrap = 0.3 })

-- opposite pair of elliptic leaves
local function yleaf(ax, ay, cxx, cyy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cxx, cyy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.62)
  end, { fold = 0.4 })
  m:cut(stm)
  local idx = A.tone(c, m, n, YL, { tok = ltok, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.06 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and YL[6] or YL[2], ltok)
    else
      local ph = T[k] * 5.5 - abs(S[k]) * 0.9
      if ph - floor(ph) < 0.16 and abs(S[k]) > 0.25 and abs(S[k]) < 0.75 and T[k] > 0.12 and T[k] < 0.85 then
        A.step(c, idx, YL, x, y, S[k] < 0 and 1 or -1, ltok) end
    end
  end)
  return m
end
local L1 = yleaf(37, 22, 30, 17, 21, 19, 3.4)
local L2 = yleaf(39, 22, 46, 16, 54, 18, 3.4)
-- terminal bud between the pair: bronze-red, pointed
local btok = { r = { name = "bud" } }
local bm, bn = A.oval(38, 18.5, 1.6, 2.8, 0, 0.8)
bm:cut(L1):cut(L2)
A.tone(c, bm, bn, BUD, { tok = btok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1 })
c:put(38, 15, BUD[2], btok)

-- seeds: flat kidney ovals, fibre streaks along the long axis, AO under each
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.tone(c, s.m, s.n, SEED, { tok = tok, amb = 0.06, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y)
    local u = ((x - s[1]) * ca + (y - s[2]) * sa) / s[3]
    local v = (-(x - s[1]) * sa + (y - s[2]) * ca) / s[4]
    -- fibres: two wavy dark streaks + one pale
    local w = v + 0.12 * sin(u * 4)
    if abs(w - 0.25) < 0.14 or abs(w + 0.45) < 0.12 then A.step(c, idx, SEED, x, y, -1, tok)
    elseif abs(w + 0.1) < 0.1 and u < 0.4 then A.step(c, idx, SEED, x, y, 1, tok) end
    -- hilum notch: dark dimple at one end
    if u > 0.72 and abs(v) < 0.35 then c:put(x, y, SEED[2], tok) end
  end)
end
-- seed glint
c:put(34, 40, SEED[6], nil) c:put(35, 40, A.CREAM)
-- stem foot over the seed coat (it bursts from the hilum)
c:put(38, 39, ROSE[3]) c:put(37, 39, ROSE[2])

-- quirk: sticky aril pulp still clinging to the left seed (lumpy cream blob over its top half)
local am = HP.ellipse(19.5, 45.4, 3.4, 2.0):add(HP.ellipse(23, 45.6, 2.2, 1.6))
am:clip(seeds[1].m:grow(1))
local an = X.pillow(am, 2)
local atok = { r = { name = "aril" } }
local aidx = A.tone(c, am, an, ARIL, { tok = atok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15 })
-- a drip of pulp on the seed flank
c:put(22, 48, ARIL[3], atok) c:put(22, 49, ARIL[2], atok)
c:put(18, 44, A.CREAM, atok)

A.fin(c, NAME)
