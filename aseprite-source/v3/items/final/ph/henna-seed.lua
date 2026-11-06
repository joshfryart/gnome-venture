-- henna-seed (final, Opus single pass). A round dry henna capsule (tan globe, style spike on top, starry calyx below,
-- one crack showing seeds inside) and four tiny angular pyramid seeds (faceted: lit face, mid face, dark face) on a
-- torn scrap of a slim elliptic henna leaf laid the other way, upper-left to lower-right (midrib, swept veins, ragged
-- torn base, cool edge, AO + contact shadows). One seed has sprouted a slim stem with two pairs of small opposite
-- elliptic leaves, the true henna leaf.
-- quirk: someone has practised a tiny henna dot-motif on the leaf in rust-orange paste.
local NAME = "henna-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1e3a2c", "#2c5436", "#3e703e", "#588e48", "#7cae58", "#acce7c" }
local VEIN, COOL, TORN = "#d4e8a0", "#4a7c78", "#e2eeb4"
local CAP = { "#3e2a1a", "#624226", "#8a6034", "#b08244", "#d2a862", "#f0d496" }
local CALYX = { "#4a4a2a", "#76703c", "#a49a58" }
local SEED = { "#2e1a14", "#5a3020", "#8a4e2c", "#c07a44" }
local HENNA = { "#8a2e14", "#c04e1c", "#e0702a" }
local STEM = { "#4e7c40", "#86b060", "#bcd88c" }
local SPR = { "#183e2c", "#245a36", "#357640", "#4c944a", "#72b25a", "#a8d47e" }

-- leaf scrap: slim, upper-left to lower-right, torn at the right base
local lm, ln, LT, LS, len = A.blade(6, 39, 29, 41, 57, 55, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 7.4 * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.65)
end, { fold = 0.36 })
local torn = A.tear(lm, LT, LS, 0.88, 0.05, 41, 0.08)

-- capsule (globe), calyx, angular seeds
local CX, CY = 25, 39
local cm, cn = A.oval(CX, CY, 4.4, 4.2, 0, 1)
local calyx = HP.mask()
for _, q in ipairs{ {20,43},{21,44},{22,44},{23,45},{24,45},{25,45},{26,45},{27,45},{28,44},{29,44},{30,43} } do calyx:set(q[1], q[2]) end
calyx:cut(cm)
local seeds = { { 33, 45 }, { 37, 49 }, { 29, 49 }, { 46, 51 } }
local sdm = HP.mask()
for _, s in ipairs(seeds) do for dy = 0, 2 do for dx = 0, 2 do if not (dy == 0 and dx ~= 1) then sdm:set(s[1] + dx, s[2] + dy) end end end end
local sp = { { 47, 50 }, { 46, 40 }, { 43, 28 }, { 45, 12 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return t < 0.4 and 1.1 or 0.9 end)

local bias = {}
local caps = cm:copy():add(calyx)
X.ao(bias, lm, caps, 1, -1) A.cast(bias, lm, caps, 1, 2, -1) A.cast(bias, lm, caps, 2, 3, -1)
A.cast(bias, lm, sdm, 1, 1, -1)
A.cast(bias, lm, sm, 1, 1, -1)
local ltok = A.tok("leaf")
A.leaf(c, lm, ln, LT, LS, len, LEAF, { bias = bias, tok = ltok, vein = VEIN, per = 6, sweep = 3.2, cool = COOL })
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)

-- quirk: henna dot motif (diamond of dots round a bold centre, trailing dots) on the left of the leaf
local htok = A.tok("henna")
local motif = { {11,37,2},{9,39,2},{13,39,2},{11,41,2},{11,39,1},{12,39,3},{10,38,3},{14,41,3},{16,42,2},{8,41,3} }
for _, q in ipairs(motif) do if lm:has(q[1], q[2]) then c:put(q[1], q[2], HENNA[q[3]], htok) end end

-- angular seeds: three-faced pyramids
local stok = A.tok("seeds")
for i, s in ipairs(seeds) do local x, y = s[1], s[2]
  c:put(x + 1, y, SEED[4], stok)
  c:put(x, y + 1, SEED[3], stok) c:put(x + 1, y + 1, (i % 2 == 0) and SEED[3] or SEED[4], stok) c:put(x + 2, y + 1, SEED[2], stok)
  c:put(x, y + 2, SEED[2], stok) c:put(x + 1, y + 2, SEED[2], stok) c:put(x + 2, y + 2, SEED[1], stok)
end

-- sprout from the last seed: slim stem, two opposite leaf pairs, tip
local ttok = A.tok("stem")
sm:each(function(x, y) local k = K(x, y) c:put(x, y, STEM[SS[k] < -0.3 and 3 or (SS[k] < 0.4 and 2 or 1)], ttok) end)
local gtok = A.tok("sprout-leaves")
local function pair(t, L, W, up)
  local x, y = A.bez(sp, t)
  x, y = floor(x + .5), floor(y + .5)
  local a = A.sprleaf(c, x - 1, y, x - L * 0.5, y - up - 1, x - L, y - up, W, SPR, gtok, { pow = 0.6, cut = sm })
  A.sprleaf(c, x + 1, y, x + L * 0.5, y - up - 1, x + L, y - up, W, SPR, gtok, { pow = 0.6, cut = sm:copy():add(a) })
  c:put(x - 1, y + 1, SPR[1], gtok) c:put(x + 1, y + 1, SPR[1], gtok)
end
pair(0.52, 8, 2.3, 3)
pair(0.93, 7, 2.1, 4)
local tx, ty = A.bez(sp, 1)
tx, ty = floor(tx + .5), floor(ty + .5)
c:put(tx, ty - 1, SPR[5], gtok) c:put(tx, ty - 2, SPR[6], gtok) c:put(tx + 1, ty - 1, SPR[3], gtok)
-- seed coat still on the stem foot
c:put(46, 51, SEED[3], stok) c:put(48, 51, SEED[1], stok)

-- calyx: star of dry sepals under the capsule
local ktok = A.tok("calyx")
calyx:each(function(x, y) local i = (x < CX) and 3 or 2 if y >= 45 then i = i - 1 end c:put(x, y, CALYX[max(1, i)], ktok) end)
-- capsule globe
local ptok = A.tok("capsule")
local cidx = A.shade(c, cm, cn, CAP, { tok = ptok, amb = 0.1 })
-- faint meridian lines (dry skin)
cm:each(function(x, y) local k = K(x, y) if (x == CX + 2 and y > CY - 3) and cidx[k] then c:put(x, y, CAP[max(1, cidx[k] - 1)], ptok) end end)
-- crack on the shade side with a seed peeking out
for _, q in ipairs{ {27,38,1},{28,39,1},{27,40,1},{28,40,2},{27,39,2} } do c:put(q[1], q[2], q[3] == 1 and CAP[1] or SEED[4], ptok) end
-- style spike on top
c:put(CX, CY - 5, CAP[3], ptok) c:put(CX, CY - 6, CAP[4], ptok) c:put(CX + 1, CY - 7, CAP[2], ptok)
-- specular
c:put(CX - 2, CY - 2, CAP[6], ptok) c:put(CX - 1, CY - 3, A.CREAM, ptok)

A.save(c, NAME)
