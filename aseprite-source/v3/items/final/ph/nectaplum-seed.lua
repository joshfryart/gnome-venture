-- nectaplum-seed (final, Opus single pass). Two nectaplum stones on a torn plum-leaf scrap (serrated margin,
-- reddish midrib, veins, jagged torn end). The big stone lies flat: almond shape, a raised keel along the top with
-- a lit lip, pitted woody shell. The small stone has cracked open at its tip and sprouts: a ruddy stem, two elliptic
-- serrated plum leaves with midribs and veins, and a curled bud between them.
-- Material: per-pixel ellipsoid light (6-tone wood shell), pitting + keel groove, leaf V-fold light with veins, cool
-- reflected edge, AO + contact shadow under each stone.
-- quirk: a last coral sliver of fruit flesh still clings to the big stone.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "nectaplum-seed"
local c = A.new(NAME)
local OLD  = { "#173a34", "#1f5440", "#2c6e46", "#41894a", "#62a652", "#92c46a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SHELL = { "#3a2220", "#5e3828", "#865232", "#ac7444", "#cf9c62", "#f0c88e" }
local RUDDY = { "#5e2236", "#8c3a42", "#b8604e" }
local FLESH = { "#b23a58", "#e2624e", "#f8a06a" }
local COOL = "#3a6c72"

local big   = { 23, 45, 7.2, 4.4, -0.32 }
local small = { 41, 42, 4.8, 3.1, -0.75 }
for _, s in ipairs{ big, small } do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 54, 57, 41, function(t)
  if t > 0.985 then return -1 end
  local w = max(0.5, 9 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.65)
  if t > 0.1 and floor(t * 70) % 3 == 0 then w = w - 0.7 end         -- fine serration
  return w
end, { fold = 0.35 })
-- torn end: jagged tear across the tip side
lm:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.8 + 0.06 * sin(LS[k] * 9) + (X.hash(x, y, 5) - 0.5) * 0.04 then lm.s[k] = nil end end)
-- a nibble out of the upper edge
lm:cut(c:ellipse(15, 45, 2.2, 2))
local bias = {}
for _, s in ipairs{ big, small } do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "scrap" } }
local lidx = A.toneN(c, lm, ln, OLD, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 then c:put(x, y, s <= 0 and RUDDY[3] or RUDDY[2], ltok) return end
  local d = (t * len - abs(s) * 6) % 4.6
  if d < 0.8 and abs(s) < 0.78 then c:put(x, y, s < 0 and OLD[min(6, lidx[k] + 1)] or OLD[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] < 0.75 then c:put(x, y, COOL, ltok) end
  if LT[k] > 0.74 then c:put(x, y, OLD[2], ltok) end                -- torn fibres darker
end)
for _, q in ipairs{ { 6, 53, 2 }, { 5, 54, 2 }, { 4, 55, 1 } } do c:put(q[1], q[2], RUDDY[q[3]], ltok) end

-- sprout (behind the small stone)
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 43, 40 }, { 44, 33 }, { 41, 27 }, { 41, 21 } }, function(t) return 1.1 - 0.15 * t end, { RUDDY[1], RUDDY[2], RUDDY[3], "#e0907a" }, { tok = stok })
local l1 = A.leaf(c, 40, 22, 31, 22, 25, 15, 3.6, LEAF, { serr = true, pw = 0.85, cut = sm })
local l2 = A.leaf(c, 42, 22, 50, 20, 56, 13, 3.4, LEAF, { serr = true, pw = 0.85, cut = sm:copy():add(l1) })
-- curled bud between them
local bud = c:ellipse(41, 18, 1.2, 2.2)
bud:cut(l1):cut(l2)
A.shade(c, bud, X.sphere(40.5, 17.5, 2.4, bud), { LEAF[2], LEAF[3], LEAF[4], LEAF[5], LEAF[6], "#c8e890" }, { tok = stok })
c:put(41, 15, RUDDY[2], stok)

-- stones
for i, s in ipairs{ big, small } do
  local vis = s.m:copy()
  if i == 1 then vis:cut(small.m) end
  local tok = { r = { name = "stone" .. i } }
  local sb = {}
  if i == 2 then vis:cut(HP.mask()) end
  local idx = A.shade(c, vis, s.n, SHELL, { bias = sb, tok = tok, amb = 0.06, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / s[3], (-dx * sa + dy * ca) / s[4]
    -- keel: groove along the long axis, lit lip above it
    if abs(v + 0.15) < 0.16 and abs(u) < 0.8 then c:put(x, y, SHELL[max(1, idx[k] - 2)], tok)
    elseif v < -0.15 and v > -0.5 and abs(u) < 0.7 then c:put(x, y, SHELL[min(6, idx[k] + 1)], tok)
    elseif X.hash(x, y, 13 + i) > 0.8 and idx[k] >= 3 and abs(u) < 0.85 then c:put(x, y, SHELL[idx[k] - 1], tok) end   -- pitting
  end)
  -- pointed tip pixel on the long axis
  local tx, ty = floor(s[1] + ca * (s[3] + 1) + .5), floor(s[2] + sa * (s[3] + 1) + .5)
  if not lm:has(tx, ty) or true then c:put(tx, ty, SHELL[3], tok) end
end
-- crack at the small stone's top where the stem exits
for _, q in ipairs{ { 43, 39 }, { 42, 40 }, { 44, 40 }, { 41, 41 } } do c:put(q[1], q[2], SHELL[1]) end
c:put(43, 40, RUDDY[2], stok)
-- glint on the big stone
c:put(19, 42, SHELL[6]) c:put(20, 42, "#fff1cf")

-- quirk: coral flesh sliver clinging to the lower-right of the big stone
A.map(c, { "..ab", ".abc", "abc." }, 25, 46, { a = FLESH[3], b = FLESH[2], c = FLESH[1] }, { r = { name = "flesh" } })
A.save(c, NAME)
