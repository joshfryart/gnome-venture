-- adzuki-seed (final pass, Opus). A torn adzuki leaflet lying almost flat (ovate, drawn-out tip, pinnate veins
-- with a pale midrib, V-fold light, cool reflected edge, torn base with pale broken tissue). Two glossy maroon adzuki
-- beans on it (6-tone, white hilum ridge, specular, AO + contact shadow). The middle bean has germinated: its coat
-- has split to show the cream cotyledon, a pale root curls down onto the leaf and a slim stem rises to the first
-- trifoliate leaf (three ovate pointed leaflets, midribs, little stipules at the joint) that shows the adzuki plant.
-- quirk: a round dew drop rests near the leaf tip.
local NAME = "adzuki-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#173d37", "#215741", "#2d7449", "#44934f", "#68b257", "#9ccd6c" }
local VEIN, COOL, TORN = "#c4e48e", "#3a6a74", "#b8d98c"
local BEAN = { "#2c0914", "#4a1020", "#6e1a2a", "#952634", "#bd3f42", "#e2705f" }
local BCUT = { 0.12, 0.28, 0.45, 0.62, 0.8 }
local COT  = { "#b59e66", "#e2d09a", "#fbf0cc" }
local STEM = { "#3f7a4c", "#6fa85e", "#a6d184", "#d8efb0" }
local ROOT = { "#8e8270", "#b8ab90", "#ddd3ba", "#f6efdc" }
local SPEC, BOUNCE, HIL, HILD = "#ffd2c2", "#7d4a72", "#f4ead4", "#b9a48c"
local DROP = { "#3f7fae", "#7fbde4", "#bfe8f8", "#effaff" }

-- leaf scrap: ovate leaflet, torn across the base (left), tip to the right
local lm, ln, LT, LS, len = A.blade(7, 52, 28, 44, 57, 36, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.0 * sin(pi * min(1, t ^ 0.72)) ^ 0.75)
end, { fold = 0.3 })
A.tear(lm, LT, 0.03, 0.1, 7)

-- beans: masks first
local beans = {
  { 17, 49, 4.4, 2.9, -0.3, hil = 0.45 },
  { 29, 45, 4.3, 3.0, -0.1, sprout = true },
  { 39, 43, 4.1, 2.8, -0.5, hil = 0.5 },
}
local allB = HP.mask()
for _, b in ipairs(beans) do b.m, b.n = A.ovalM(b[1], b[2], b[3], b[4], b[5], 0.85) allB:add(b.m) end

-- root (quirk-free, real): pale radicle out of the sprouting bean, curling down over the leaf
local rm, rn, RT, RS = A.tube({ { 26, 47 }, { 23, 49 }, { 23, 52 }, { 26, 53 } }, function(t) return 0.95 * (1 - t) ^ 0.7 + 0.3 end)
rm:cut(allB)

-- dew drop
local dcx, dcy, dr = 47.5, 38.5, 2.4
local drop = c:ellipse(dcx, dcy, dr, dr)

-- leaf tone: AO + contact shadow from beans, root and drop
local bias = {}
X.ao(bias, lm, allB, 1, -1) A.cast(bias, lm, allB, 1, 2, -1) A.cast(bias, lm, allB, 2, 2, -1)
X.ao(bias, lm, rm, 1, -1) A.cast(bias, lm, rm, 1, 1, -1)
A.cast(bias, lm, drop, 1, 1, -1)
local ltok = A.tok("leaf")
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.06, wrap = 0.2 })
A.veins(c, lm, LT, LS, len, LEAF, VEIN, { tok = ltok, skip = bias, per = 6.2, sweep = 4.2, t0 = 0.05, t1 = 0.93, hiV = 4 })
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] < 0.16 then c:put(x, y, TORN, ltok)                       -- broken tissue on the torn base
  elseif LS[k] > 0.62 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- root: rounded, faint rings, root hair
local rtok = A.tok("root")
A.shade(c, rm, rn, ROOT, { tok = rtok, cuts = { 0.25, 0.5, 0.75 }, amb = 0.15, wrap = 0.3 })
c:put(22, 50, ROOT[2], rtok)

-- beans
for i, b in ipairs(beans) do
  local bt = A.tok("bean" .. i)
  local bb = {}
  local m = b.m:copy()
  for j, o in ipairs(beans) do if j ~= i and j > i then m:cut(o.m) end end
  if b.sprout then A.cast(bb, m, rm, 0, 0, 0) end
  A.shade(c, m, b.n, BEAN, { tok = bt, amb = 0.04, wrap = 0.16, cuts = BCUT, bias = bb })
  A.bounce(c, m, b.n, BOUNCE, 0.62, bt)
  local ca, sa = cos(b[5]), sin(b[5])
  if b.hil then
    for u = -1.6, 1.6, 0.5 do
      local v = b.hil * b[4]
      local x, y = floor(b[1] + u * ca - v * sa + .5), floor(b[2] + u * sa + v * ca + .5)
      if m:has(x, y) then c:put(x, y, abs(u) > 1.4 and HILD or HIL, bt) end
      local x2, y2 = floor(b[1] + u * ca - (v + 1) * sa + .5), floor(b[2] + u * sa + (v + 1) * ca + .5)
      if m:has(x2, y2) and not (x2 == x and y2 == y) and abs(u) < 1.2 then c:put(x2, y2, BEAN[2], bt) end
    end
  end
  if b.sprout then
    -- split coat along the top: cream cotyledon in the gap, dark lips
    m:each(function(x, y)
      local dx, dy = x - b[1], y - b[2]
      local u, v = (dx * ca + dy * sa) / (b[3] + .45), (-dx * sa + dy * ca) / (b[4] + .45)
      if v < -0.05 and v > -0.62 and abs(u + 0.1) < 0.55 - (v + 0.33) ^ 2 then
        c:put(x, y, v < -0.4 and COT[3] or (u > 0.2 and COT[1] or COT[2]), bt)
      end
    end)
  end
  local sx, sy = A.specAt(m, b.n, 30)
  if b.sprout then sx, sy = sx - 1, sy + 1 end
  if m:has(sx, sy) then c:put(sx, sy, SPEC, bt) end
  if m:has(sx + 1, sy) then c:put(sx + 1, sy, BEAN[6], bt) end
end

-- stem out of the split coat
local stok = A.tok("stem")
local SP = { { 29, 43 }, { 28, 35 }, { 31, 28 }, { 31, 22 } }
local sm, sn = A.tube(SP, function(t) return 0.95 + 0.2 * (1 - t) end)
sm:cut(beans[2].m:copy():cut(c:rect(0, 0, 63, 42)))
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.28, 0.52, 0.76 }, amb = 0.15, wrap = 0.3 })

-- trifoliate leaf
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.12 then return 0.6 end                                 -- petiolule
    local u = (t - 0.12) / 0.88
    return max(0.4, w * sin(pi * min(1, u ^ 0.7)) ^ 0.7)
  end, { fold = 0.36 })
  return { m = m, n = n, T = T, S = S, L = L }
end
local lfs = {
  leaflet(30, 22, 24, 21, 17, 15, 3.2),
  leaflet(32, 22, 38, 21, 45, 16, 3.2),
  leaflet(31, 21, 30, 15, 32, 7, 3.4),
}
local taken = HP.mask()
for i = #lfs, 1, -1 do local f = lfs[i] f.m:cut(taken):cut(sm) taken:add(f.m) end
for i, f in ipairs(lfs) do
  local fb = {}
  if i < 3 then X.ao(fb, f.m, lfs[3].m, 1, -1) end
  A.toneN(c, f.m, f.n, LEAF, { tok = ltok, bias = fb, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  f.m:each(function(x, y) local k = K(x, y)
    if abs(f.S[k]) < 0.15 and f.T[k] > 0.1 and f.T[k] < 0.86 then c:put(x, y, f.S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
    local ph = (f.T[k] * f.L - abs(f.S[k]) * 2.2) / 3.6
    if f.T[k] > 0.3 and f.T[k] < 0.8 and ph % 1 < 0.2 and abs(f.S[k]) > 0.3 and abs(f.S[k]) < 0.7 and not fb[k] then
      c:put(x, y, f.S[k] < 0 and LEAF[5] or LEAF[2], ltok) end
  end)
end
-- joint: stipules
c:put(30, 23, STEM[4], stok) c:put(32, 23, STEM[2], stok) c:put(31, 22, STEM[3], stok)

-- dew drop: dark refracted rim top-left, bright caustic lower-right, sharp glint
local dtok = A.tok("drop")
drop:each(function(x, y)
  local dx, dy = (x - dcx) / (dr + .5), (y - dcy) / (dr + .5)
  local col = DROP[2]
  if dx + dy < -0.55 then col = DROP[1] elseif dx + dy > 0.45 then col = DROP[3] end
  c:put(x, y, col, dtok)
end)
c:put(floor(dcx - 0.5), floor(dcy - 0.5), DROP[4], dtok)

A.save(c, NAME)
