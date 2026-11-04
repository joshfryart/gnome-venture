-- marigold-seed (final, Opus single pass). Three slim marigold achenes (black needle seeds with a straw upper third and
-- a pale bristle tuft) on a torn, saw-toothed marigold leaflet (midrib, pinnate veins, V-fold light, cool shade edge,
-- AO + contact shadow under each seed). The right seed has germinated: pale stem, two strap cotyledons and a first
-- feathery pinnate true leaf that shows the marigold's fern-cut foliage.
-- quirk: a single ruffled orange ray petal has drifted onto the leaf tip.
local NAME = "marigold-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aC22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#14352e", "#1d4c37", "#296640", "#3d8344", "#5fa34c", "#93c766" }
local VEIN, COOL = "#b5dc80", "#386a6c"
local BLK = { "#140f18", "#211824", "#30222e", "#463340", "#6a5052", "#957a68" }
local STR = { "#5a4632", "#80663e", "#a8884e", "#c9aa64", "#e3c987", "#f6e6b0" }
local OR = { "#7a2a1e", "#b2401c", "#de6418", "#f48c1e", "#fdb43c", "#ffd877" }
local STEM = { "#3f7448", "#6fa65c", "#a6d283", "#dcf0b4" }

-- seeds (bezier tubes): base -> tip (tip = straw end with bristles)
local seeds = {
  { { 12, 48 }, { 16, 46 }, { 20, 44 }, { 25, 43 } },
  { { 19, 52 }, { 23, 50 }, { 27, 47 }, { 31, 44 } },
  { { 38, 47 }, { 39, 45 }, { 40, 43 }, { 41, 40 } },     -- sprouting
}
local sm = {}
for i, p in ipairs(seeds) do
  local m, n, T, S = A.tube(p, function(t) return 0.8 + 1.15 * sin(pi * min(1, 0.08 + t * 0.9)) ^ 0.6 end)
  sm[i] = { m = m, n = n, T = T, S = S, p = p }
end

-- leaf scrap: lanceolate leaflet, torn at the base, saw teeth along both margins
local lm, ln, LT, LS, len = A.blade(6, 53, 30, 46, 57, 33, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.6 * sin(pi * min(1, t * 0.92 + 0.1)) ^ 0.75)
end, { fold = 0.4 })
A.tear(lm, LT, LS, 0.05, 0.07, 2)
local PER = 3.4
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0)
  local f = (ph - floor(ph))                         -- saw: ramps then drops
  if t > 0.14 and t < 0.95 and abs(s) > 0.93 - f * 0.28 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(sm) do A.shadow(bias, lm, s.m, 1, 2) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.08 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 6.0 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.72 and t > 0.1 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- quirk: ruffled orange ray petal near the leaf tip
do
  local pm = A.rell(50, 37.5, 0.94, -0.34, 3.6, 2.3)
  local drop = {}
  pm:each(function(x, y) local dx, dy = x - 50, y - 37.5
    local a = dx * 0.94 - dy * 0.34
    if a > 2.2 and ((y + x) % 3 == 0) then drop[#drop + 1] = K(x, y) end end)   -- frilled outer edge
  for _, k in ipairs(drop) do pm.s[k] = nil end
  local ptok = { r = { name = "petal" } }
  local pb = {}
  A.shadow({}, lm, pm, 1, 1)
  pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
  A.toneN(c, pm, X.pillow(pm, 2), OR, { tok = ptok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.15, wrap = 0.3 })
  -- petal veins (two darker streaks along it)
  for _, q in ipairs{ { 48, 38 }, { 50, 38 }, { 52, 37 }, { 49, 36 } } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], OR[3], ptok) end end
end

-- sprout from the third seed's tip
local stok = { r = { name = "stem" } }
local spp = { { 41, 40 }, { 42, 34 }, { 41, 29 }, { 42, 23 } }
local stm, stn = A.tube(spp, function(t) return 1.0 end)
stm:cut(sm[3].m)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.35)
  end, { fold = 0.3 })
  m:cut(stm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS6, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = strap(41, 24, 35, 22, 28, 24, 1.5)
local cr = strap(43, 24, 48, 21, 54, 22, 1.5)
-- pinnate true leaf: rachis + 2 pairs of slim leaflets + terminal, each with a tooth notch
local pet = { { 42, 24 }, { 42, 20 }, { 43, 16 }, { 43, 12 } }
local tl = HP.mask()
for _, q in ipairs{ { 0.4, -1.15, 3.4 }, { 0.42, 1.15, 3.4 }, { 0.72, -1.0, 2.8 }, { 0.74, 1.0, 2.8 } } do
  local x, y = A.bez(pet, q[1]) local ux, uy = A.rot(0, -1, q[2])
  tl:add(A.rell(x + ux * q[3] * 0.55, y + uy * q[3] * 0.55, ux, uy, q[3] * 0.62, 1.05))
end
do local x, y = A.bez(pet, 1) tl:add(A.rell(x, y + 0.2, 0, -1, 2.3, 1.1)) end
tl:cut(cl):cut(cr)
A.toneN(c, tl, X.pillow(tl, 1.5), LEAF, { tok = ltok, cuts = A.CUTS6, amb = 0.14, wrap = 0.25 })
for i = 0, 24 do local x, y = A.bez(pet, i / 24) c:put(floor(x + .5), floor(y + .5), i < 4 and STEM[2] or STEM[3], stok) end

-- seeds last: black achene, straw upper third, ribbed (1 px pale ridge on the lit side), bristle tuft at the tip
for i, s in ipairs(sm) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = 1, #sm do if j ~= i then X.ao(sb, s.m, sm[j].m, 1, -1) end end
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  s.m:each(function(x, y) local k = K(x, y)
    local t, sn = s.T[k], s.S[k]
    local R = t > 0.8 and STR or BLK
    local idx = 1
    for j, q in ipairs(t > 0.8 and A.CUTS6 or { 0.4, 0.6, 0.76, 0.9, 0.97 }) do if v[k] >= q then idx = j + 1 end end
    if sn > -0.55 and sn < -0.15 and t > 0.1 and t < 0.76 and (floor(t * 12) % 2 == 0) then idx = idx + 1 end   -- rib dashes
    if t > 0.78 and t < 0.84 then idx = idx - 2 end                                                       -- collar
    idx = idx + (sb[k] or 0)
    c:put(x, y, R[max(1, min(6, idx))], tok)
  end)
  -- bristle tuft (pappus): two pale 1px spines past the tip
  local p = s.p
  local tx, ty = p[4][1] - p[3][1], p[4][2] - p[3][2]
  local l = math.sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local bx, by = p[4][1] + tx * 1.6, p[4][2] + ty * 1.6
  local b1 = { floor(bx - ty * 0.9 + .5), floor(by + tx * 0.9 + .5) }
  local b2 = { floor(bx + ty * 0.9 + tx + .5), floor(by - tx * 0.9 + ty + .5) }
  if i ~= 3 then
    for _, b in ipairs{ b1, b2 } do if not s.m:has(b[1], b[2]) then c:put(b[1], b[2], STR[6], tok) end end
  end
end
-- one glint on the front seed's straw collar
c:put(22, 50, A.CREAM, { r = { name = "seed2" } })

A.save(c, NAME)
