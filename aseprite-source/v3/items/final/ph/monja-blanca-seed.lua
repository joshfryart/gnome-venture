-- monja-blanca-seed (final, Opus single pass): a torn scrap of pleated (plicate) orchid leaf lying low, its parallel
-- pleats running lengthwise, ragged at both ends. Three spindle orchid seeds (pale coat, dark embryo) with dust grains
-- rest on it. The seedling is a ribbed green pseudobulb in a papery sheath, from which one broad pleated lance leaf
-- arches up and right, and a slim stalk lifts a white nun bloom: three broad cream sepals, a hooded lip.
-- quirk: a single dewdrop sits on the arching leaf.
local NAME = "monja-blanca-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1a3f3a", "#245a44", "#337a4c", "#4c9852", "#74b85c", "#a6d474" }
local BULB = { "#24483a", "#356a44", "#4e8a4a", "#70a854", "#9cc866", "#cce496" }
local SHEA = { "#5e4630", "#8a6a44", "#b8965e", "#e0c68c" }
local WHT  = { "#6e6a8e", "#9c98b6", "#c8c4d8", "#e8e2e6", "#fbf2e2", "#fffaee" }
local SEED = { "#5e3a26", "#a8804c", "#d8b878", "#f2dca6" }
local COOL = "#3a6c72"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- pleat shading: alternate one tone up/down in lengthwise bands (ridges lit, furrows dark)
local function pleats(m, S, T, idx, ramp, tok, nb, skip)
  m:each(function(x, y) local k = K(x, y)
    if skip and skip[k] then return end
    local s = S[k]
    local ph = (s + 1) * nb
    local f = ph - floor(ph)
    local i = idx[k]
    if f < 0.28 then i = i - 1 elseif f > 0.72 then i = i + 1 end
    c:put(x, y, ramp[max(1, min(#ramp, i))], tok)
  end)
end

-- ---- leaf scrap (torn at both ends) ----
local seeds = { { 36, 51, -0.35 }, { 43, 50, 0.25 }, { 48, 53, -0.15 } }
local smask = HP.mask()
local sm = {}
for i, s in ipairs(seeds) do local m, n = G.oval(s[1], s[2], 2.6, 1.1, s[3], 0.7) sm[i] = { m = m, n = n } smask:add(m) end
local la, lc_, lb = { 9, 47 }, { 32, 54 }, { 57, 51 }
local lwfn = function(t) return 5.6 - 0.6 * t end
local lm, ln, LT, LS, len = G.blade(la[1], la[2], lc_[1], lc_[2], lb[1], lb[2], lwfn, { fold = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  local tl = 1.4 + 3.0 * X.hash(floor((LS[k] + 1) * 3), 3)
  local tr = 1.2 + 3.4 * X.hash(floor((LS[k] + 1) * 3.4), 11)
  if LT[k] * len < tl or (1 - LT[k]) * len < tr then lm.s[k] = nil end
end)
-- bulb mask first (AO + contact shadow on the scrap)
local bulb, bn = G.oval(22, 41, 4.2, 6.2, 0.12, 1)
local lbias = {}
X.ao(lbias, lm, bulb, 1, -1) G.cast(lbias, lm, bulb, 2, 1, -1)
X.ao(lbias, lm, smask, 1, -1) G.cast(lbias, lm, smask, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = lbias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
pleats(lm, LS, LT, lidx, LEAF, ltok, 2.5, lbias)
lm:edge():each(function(x, y) local k = K(x, y)
  if not lbias[k] and LS[k] > 0.7 then c:put(x, y, COOL, ltok) end
  if LS[k] < -0.7 and (x % 3 ~= 0) then c:put(x, y, LEAF[6], ltok) end end)

-- ---- arching pleated leaf (behind the bulb) ----
local ab = G.blade(23, 37, 36, 18, 54, 16, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 5.0 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.8)
end, { fold = 0.45 })
local am, an, AT, AS = G.blade(23, 37, 36, 18, 54, 16, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 5.0 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.8)
end, { fold = 0.45 })
am:cut(bulb)
local atok = { r = { name = "blade" } }
local aidx = G.toneN(c, am, an, LEAF, { tok = atok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
pleats(am, AS, AT, aidx, LEAF, atok, 2.0)
am:each(function(x, y) local k = K(x, y) if abs(AS[k]) < 0.1 and AT[k] > 0.05 and AT[k] < 0.9 then c:put(x, y, AS[k] <= 0 and LEAF[6] or LEAF[3], atok) end end)

-- ---- flower stalk (thin, arching left) ----
local stk = { { 20, 37 }, { 17, 30 }, { 13, 24 }, { 15, 17 } }
local fstok = { r = { name = "stalk" } }
for i = 0, 40 do local x, y = G.bez(stk, i / 40) c:put(floor(x + .5), floor(y + .5), i < 20 and BULB[3] or BULB[4], fstok)
  if i % 4 == 0 then c:put(floor(x + .5) + 1, floor(y + .5), BULB[2], fstok) end end

-- ---- pseudobulb in a papery sheath ----
local btok = { r = { name = "bulb" } }
local bidx = A.shade(c, bulb, bn, BULB, { tok = btok, amb = 0.08, wrap = 0.25 })
bulb:each(function(x, y) local k = K(x, y)
  local i = bidx[k]
  local u = x - 22 - (y - 41) * 0.12
  if abs(u + 1.5) < 0.5 or abs(u - 1.5) < 0.5 then i = i - 1 end     -- ribs (grooves)
  if y >= 45 then                                                   -- dry sheath wrapping the base
    local si = (i >= 5 and 4) or (i >= 3 and 3) or (i >= 2 and 2) or 1
    if (x + y) % 3 == 0 then si = max(1, si - 1) end
    if y == 45 then si = 1 end
    c:put(x, y, SHEA[si], btok) return
  end
  c:put(x, y, BULB[max(1, min(6, i))], btok)
end)
c:put(20, 37, BULB[6], btok) c:put(20, 38, BULB[6], btok)  -- bulb specular

-- ---- seeds ----
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, sm[i].m, sm[i].n, SEED, { tok = tok, cuts = { 0.25, 0.5, 0.75 }, amb = 0.15, wrap = 0.3 })
  c:put(s[1], s[2], SEED[1], tok) -- dark embryo in the middle
  c:put(s[1] - 1, s[2] - 1 + (s[3] < 0 and 0 or 0), SEED[4], tok)
end
local dtok = { r = { name = "dust" } }
for _, p in ipairs{ { 40, 53 }, { 45, 48 }, { 32, 50 }, { 51, 50 } } do c:put(p[1], p[2], SEED[3], dtok) end

-- ---- the white nun bloom ----
local fx, fy = 15, 14
local ftok = { r = { name = "bloom" } }
local top = G.oval(fx + 0.5, fy - 4, 2.0, 3.2, 0.15, 1)
local sl  = G.oval(fx - 4, fy + 2.5, 3.2, 2.0, -0.55, 1)
local sr  = G.oval(fx + 4.5, fy + 2.5, 3.2, 2.0, 0.55, 1)
local sep = top:copy():add(sl):add(sr)
local sidx = A.shade(c, sep, X.pillow(sep, 1.8), WHT, { tok = ftok, amb = 0.3, wrap = 0.4, cuts = { 0.12, 0.26, 0.42, 0.6, 0.8 } })
-- vein lines along each sepal (one step down on the axis)
for _, q in ipairs{ { 0, -1, 4 }, { -1, 0.6, 4 }, { 1, 0.6, 4 } } do
  for d = 2, q[3] + 1 do local x, y = floor(fx + 0.5 + q[1] * d * 0.95 + .5), floor(fy + q[2] * d * 0.95 + .5)
    if sep:has(x, y) then local k = K(x, y) c:put(x, y, WHT[max(1, sidx[k] - 1)], ftok) end end end
-- hooded lip (the nun's coif) in the centre
local lip = G.oval(fx + 0.5, fy + 1, 1.8, 1.8, 0, 1)
local lb = {}
X.ao(lb, lip, HP.mask(), 1, 0)
A.shade(c, lip, X.sphere(fx, fy + 0.5, 2, lip), WHT, { tok = ftok, cuts = { 0.3, 0.45, 0.6, 0.75, 0.9 } })
c:put(fx, fy + 2, WHT[1], ftok) c:put(fx + 1, fy + 2, WHT[2], ftok)  -- throat shadow
c:put(fx, fy, "#f5c64a", ftok)                                       -- pollen cap

-- ---- quirk: a dewdrop on the arching leaf ----
local dx, dy = 40, 20
local drop = c:ellipse(dx, dy, 1.5, 1.5)
local dtk = { r = { name = "dew" } }
drop:each(function(x, y)
  local i = (x - dx) + (y - dy)
  c:put(x, y, i <= -1 and "#5f9ad0" or i >= 1 and "#e4f6ff" or "#b9e2f5", dtk) end)
c:put(dx - 1, dy - 1, "#fff4d6", dtk)
for _, p in ipairs{ { dx + 1, dy + 2 }, { dx + 2, dy + 1 } } do if am:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], atok) end end

A.save(c, NAME)
