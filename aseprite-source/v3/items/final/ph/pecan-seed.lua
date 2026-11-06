-- pecan-seed (final, Opus single pass). One in-shell pecan lying on a torn pecan leaflet (long, sickle-curved
-- lanceolate blade on the diagonal, midrib + close side veins, fibrous torn base). The nut has split at its stem end:
-- a pale root curls down over the leaf edge and a slim shoot rises carrying the first pecan leaf, pinnate,
-- with five small pointed leaflets on a rachis.
-- Material: per-pixel tube light on the shell (6-tone warm brown), dark lengthwise streaks, glossy 2x1 specular,
-- cool reflected edge, cracked suture gaping at the split, AO + contact shadow under the nut and at the shoot base.
-- quirk: one quarter of the dark green-black husk still clings to the nut's tip, curled back like a peeled petal.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("pecan-seed")

local LEAF  = { "#183428", "#224e34", "#326a3c", "#4e8a44", "#76aa50", "#aacb66" }
local SHELL = { "#36201f", "#5a2e22", "#82442a", "#a8622f", "#c98848", "#e8b070" }
local HUSK  = { "#1c221c", "#2a3426", "#3c4a30", "#56663a", "#788a48" }
local STEM  = { "#5a7a44", "#8aac5e", "#b8d282", "#e0eeb0" }
local ROOT  = { "#9a7e66", "#c4a88a", "#e4d0b2", "#f6ecd6" }
local STREAK, STREAK2 = "#2a1a1e", "#4a2a24"
local TORN, COOL, SPEC = "#d6e2a0", "#3c6670", "#fff2d8"
local ltok, ntok, stok, htok, rtok = { r = { name = "leaf" } }, { r = { name = "nut" } }, { r = { name = "stem" } }, { r = { name = "husk" } }, { r = { name = "root" } }

-- nut: lying left-right, stem end (split) at the left, pointed tip at the right
local np = { { 18, 44 }, { 25, 42 }, { 36, 40 }, { 46, 37 } }
local nm, nn, NT, NS = A.tube(np, function(t)
  local w = 5.6 * sin(pi * (0.05 + 0.93 * t)) ^ 0.55
  if t > 0.82 then w = w * (1 - (t - 0.82) * 1.8) end
  return w + 0.35
end)
local pl = X.pillow(nm, 3.5)
for k, a in pairs(nn) do local b = pl[k] if b then nn[k] = { A.norm(a[1] * 0.75 + b[1] * 0.25, a[2] * 0.75 + b[2] * 0.25, a[3] * 0.75 + b[3] * 0.25) } end end

-- root: from the split end, curls down-left over the leaf edge
local rp = { { 18, 45 }, { 14, 49 }, { 13, 54 }, { 17, 57 } }
local rm, rn, RT = A.tube(rp, function(t) return 1.5 * (1 - t) ^ 0.8 + 0.35 end)
rm:cut(nm)

-- leaf scrap: long falcate leaflet, base torn at lower-left
local tear = HP.mask()
for y = 40, 64 do for x = 0, 30 do
  local j = 1.4 * sin(x * 2.1) + (X.hash(x, 0, 6) - 0.5) * 2.2
  if y > 58 - (x - 8) * 0.25 + j and x < 22 then tear:set(x, y) end
  if x < 9 + j then tear:set(x, y) end
end end
local lbias = {}
local wf = function(t) if t > 0.985 then return -1 end return max(0.5, 7.6 * sin(pi * min(1, t * 0.86 + 0.02)) ^ 0.7) end
local lm0 = A.blade(7, 55, 30, 53, 57, 35, wf)
lm0:cut(tear)
X.ao(lbias, lm0, nm, 1, -1) A.cast(lbias, lm0, nm, 1, 2, -1) A.cast(lbias, lm0, nm, 2, 3, -1)
X.ao(lbias, lm0, rm, 1, -1)
local occ = nm:copy():add(rm)
local lm, LT, LS, lidx = A.leaf(c, 7, 55, 30, 53, 57, 35, 7.6, LEAF, { cut = tear:copy():add(occ), bias = lbias, tok = ltok, vs = 2.8, fold = 0.42, wfn = wf })
for k in pairs(lbias) do if lm.s[k] and lidx[k] then c:put(k % 1024 - 256, k // 1024 - 256, LEAF[lidx[k]], ltok) end end
tear:grow(1):each(function(x, y) if lm:has(x, y) and not tear:has(x, y) then c:put(x, y, (x % 3 == 0) and LEAF[5] or TORN, ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y) if not lbias[k] and LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- root shading + ring hairs
A.shade(c, rm, rn, ROOT, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = rtok })
c:put(13, 52, ROOT[3], rtok) c:put(11, 51, ROOT[2], rtok)

-- shoot: from the split end, up and slightly right, then the pinnate leaf
local sh = { { 20, 41 }, { 21, 33 }, { 19, 28 }, { 22, 21 } }
local smk = A.stem(c, sh, function(t) return 1.1 - t * 0.3 end, STEM, { cut = nm, tok = stok })
-- rachis continues up-right
local rach = { { 22, 21 }, { 25, 17 }, { 30, 14 }, { 36, 12 } }
local rk = A.stem(c, rach, function(t) return 0.6 end, STEM, { tok = stok })
local function lf(ax, ay, bx, by, w)
  local cx, cy = (ax + bx) / 2 + (by - ay) * 0.12, (ay + by) / 2 - (bx - ax) * 0.12
  return A.leaf(c, ax, ay, cx, cy, bx, by, w, LEAF, { tok = ltok, pw = 0.8, vs = 2.6, cut = rk:copy():add(smk) })
end
lf(23, 20, 17, 14, 2.2)   -- lower left leaflet
lf(25, 17, 26, 9, 2.1)    -- upper
lf(29, 15, 34, 7, 2.0)
lf(28, 15, 33, 20, 2.0)   -- lower right
lf(36, 12, 44, 10, 2.3)     -- terminal
c:put(20, 40, STEM[1], stok) c:put(21, 40, STEM[1], stok)

-- nut
local nb = {}
local idx = A.shade(c, nm, nn, SHELL, { amb = 0.08, wrap = 0.26, tok = ntok, bias = nb })
nm:each(function(x, y) local k = K(x, y)
  local s, t = NS[k], NT[k]
  local band = floor((s + 1) * 3.6)
  local wob = sin(t * 19 + band * 2.3) * 0.5 + X.hash(band, floor(t * 12), 3) - 0.45
  if wob > 0.45 and abs(s) < 0.84 and t > 0.1 and t < 0.92 then c:put(x, y, (idx[k] or 3) >= 4 and STREAK2 or STREAK, ntok)
  elseif X.hash(x, y, 13) > 0.94 and (idx[k] or 1) >= 3 then c:put(x, y, STREAK2, ntok) end
end)
local rim = X.rim(nn)
nm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.6 and NT[k] > 0.12 and NT[k] < 0.85 then c:put(x, y, "#8a7aa8", ntok) end end)
-- split suture gaping at the stem end
for _, p in ipairs{ { 17, 43 }, { 18, 43 }, { 19, 43 }, { 20, 42 }, { 21, 42 } } do c:put(p[1], p[2], STREAK, ntok) end
c:put(18, 42, SHELL[6], ntok) c:put(20, 41, SHELL[5], ntok)
-- specular
c:put(30, 38, SPEC, ntok) c:put(31, 38, SHELL[6], ntok)

-- quirk: husk quarter clinging at the tip, curled back
local hm = HP.mask()
for y = 30, 40 do for x = 41, 52 do
  local dx, dy = x - 46.5, y - 35.5
  local u = (dx * 0.86 - dy * 0.5) / 4.6
  local v = (dx * 0.5 + dy * 0.86) / 2.3
  if u * u + v * v <= 1 and dy < 1.2 then hm:set(x, y) end
end end
for _, p in ipairs{ { 50, 30 }, { 51, 30 }, { 51, 29 }, { 52, 29 } } do hm:set(p[1], p[2]) end
local hidx = A.shade(c, hm, X.pillow(hm, 2), HUSK, { amb = 0.08, wrap = 0.3, tok = htok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
-- husk's pale inner face on the curled lip
c:put(51, 29, "#c4b07a", htok) c:put(52, 29, "#a8925e", htok) c:put(50, 30, "#a8925e", htok)
-- AO on the nut under the husk
nm:each(function(x, y) if hm:shift(0, 1):has(x, y) and not hm:has(x, y) then c:put(x, y, SHELL[1], ntok) end end)

A.save(c, "pecan-seed")
