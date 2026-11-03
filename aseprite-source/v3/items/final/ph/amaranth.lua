-- amaranth (final, Opus). Love-lies-bleeding: a slim red-striped green stem that arches at the top into a long,
-- drooping crimson tassel, with a shorter second tassel hanging from a side branch and three ovate leaves on red
-- petioles (midrib + curving pinnate veins, red-tinted margins). Tassels are chenille ropes of tiny packed flowers:
-- per-pixel tube light, a diagonal twisted bead pattern, granular speckle, a knobbly edge and a waxy pale bloom on
-- the lit side; AO where the tassels leave the stem and where the leaves meet it.
-- quirk: three golden seeds are dropping off the tip of the big tassel.
local NAME = "amaranth"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CRIM = { "#3c0e2e", "#62163e", "#8e2046", "#b8304c", "#dc5060", "#f6847e" }
local BLOOM = "#ffb4a4"
local STEM = { "#24402e", "#36583a", "#4e7840", "#6c9648", "#92b85e", "#c0d88a" }
local RED = "#8a2a42"
local LEAF = { "#1b3a30", "#265638", "#367640", "#4f9648", "#76b65a", "#aad27a" }
local GOLD = { "#8f5a1f", "#d0942c", "#f2c450", "#fff0b0" }

local function plen(sm) local L = 0 for i = 2, #sm do L = L + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end return L end

-- stem
local stok = { r = { name = "stem" } }
local SP = { { 26, 56 }, { 27, 46 }, { 29, 30 }, { 30, 17 } }
local sm, sn, ST, SS = A.tube(SP, function(t) return 1.45 - 0.35 * t end)
local leaves = HP.mask()

-- leaves (drawn first so the stem sits over the petiole joints)
local ltok = { r = { name = "leaf" } }
local function leaf(px0, py0, ax, ay, cx, cy, bx, by, w)
  -- petiole
  local pm, pn = A.tube({ { px0, py0 }, { (px0 + ax) / 2, (py0 + ay) / 2 - 0.5 }, { (px0 + ax) / 2, (py0 + ay) / 2 }, { ax, ay } }, function() return 0.6 end)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = t ^ 0.8
    return max(0.5, w * sin(pi * min(1, u * 0.95 + 0.04)) ^ 0.6)
  end, { fold = 0.35 })
  pm:cut(m)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    local as = abs(s)
    if as < 0.13 and t < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[2], ltok) return end
    local ph = (t * len - as * 3.6) / 3.4 + (s > 0 and 0.5 or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and as > 0.18 and as < 0.75 and t > 0.1 and t < 0.85 then
      c:put(x, y, s < 0 and LEAF[min(6, idx[k] + 2)] or LEAF[max(1, idx[k] - 1)], ltok) end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.55 and T[k] > 0.2 then c:put(x, y, RED, ltok) end end)
  A.shade(c, pm, pn, { "#4a1a32", "#6e2440", "#9a3a50", "#c86068" }, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, tok = ltok })
  leaves:add(m):add(pm)
  return m
end
leaf(27, 47, 23, 46, 15, 45, 8, 39, 4.2)
leaf(28, 37, 24, 35, 18, 31, 12, 25, 3.6)
leaf(27, 53, 31, 54, 37, 55, 43, 52, 3.2)

-- tassels: big one from the stem top arching right and hanging down; short one from a side branch
local ttok = { r = { name = "tassel" } }
local function tassel(P, wfn, seed, under)
  local m, n, T, S, samp = A.tube(P, wfn, 200)
  local L = plen(samp)
  -- knobbly silhouette: nibble edge pixels
  local nib = {}
  m:edge():each(function(x, y) if X.hash(x, y, seed) > 0.74 then nib[#nib + 1] = K(x, y) end end)
  for _, k in ipairs(nib) do m.s[k] = nil end
  if under then m:cut(under) end
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local ph = T[k] * L / 2.1 + S[k] * 1.1         -- twisted diagonal bead rows
    local b = sin(ph * 2 * pi)
    local bb = 0
    if b < -0.45 then bb = -1 elseif b > 0.75 then bb = 1 end
    if X.hash(x, y, seed + 9) > 0.86 then bb = bb - 1 end
    if bb ~= 0 then bias[k] = bb end
  end)
  local idx, v = A.shade(c, m, n, CRIM, { bias = bias, tok = ttok, cuts = { 0.12, 0.28, 0.44, 0.6, 0.78 }, amb = 0.06, wrap = 0.3 })
  -- waxy bloom specks on the lit crest
  m:each(function(x, y) local k = K(x, y)
    if idx[k] == 6 and X.hash(x, y, seed + 4) > 0.72 then c:put(x, y, BLOOM, ttok) end end)
  return m, T, S
end
local big = tassel({ { 30, 18 }, { 31, 8 }, { 47, 6 }, { 47, 24 } }, function(t) return 3.1 - 0.2 * t end, 3)
local big2 = tassel({ { 47, 23 }, { 48, 31 }, { 46, 37 }, { 47, 44 } }, function(t) return 3.0 - 1.7 * t ^ 1.6 end, 5, big)
-- side branch + short tassel
local bm, bn = A.tube({ { 29, 30 }, { 32, 28 }, { 34, 27 }, { 36, 27 } }, function() return 0.7 end)
local small = tassel({ { 36, 27 }, { 39, 27 }, { 40, 33 }, { 39, 41 } }, function(t) return 2.4 - 1.3 * t ^ 1.4 end, 8)
bm:cut(small)

-- stem over leaves, with red stripes; AO at the tassel and leaf joints
local sb = {}
X.ao(sb, sm, big, 2, -1)
X.ao(sb, sm, leaves, 1, -1)
sm:cut(big)
local sidx = A.shade(c, sm, sn, STEM, { bias = sb, tok = stok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.12, wrap = 0.3 })
sm:each(function(x, y) local k = K(x, y) if SS[k] > 0.1 and SS[k] < 0.5 and ST[k] > 0.1 then c:put(x, y, RED, stok) end end)
A.shade(c, bm, bn, STEM, { tok = stok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.15 })

-- quirk: golden seeds dropping from the big tassel tip
for _, p in ipairs{ { 47, 47, 2 }, { 46, 50, 3 }, { 48, 53, 2 } } do
  c:put(p[1], p[2], GOLD[p[3]]) c:put(p[1] + 1, p[2], GOLD[p[3] - 1]) c:put(p[1], p[2] - 1, GOLD[4])
end
A.save(c, NAME)
