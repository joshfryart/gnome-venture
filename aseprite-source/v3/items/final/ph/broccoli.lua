-- broccoli (final, Opus single pass). A slim pale stalk forking into three branchlets under a domed crown of
-- ten bumpy florets (back row high and small, front row low and large). Florets: sphere light blended with the
-- dome, bud granulation, contact shadow on each floret a front one overlaps, cool bounce on the lower right.
-- Stalk: cylinder light, fibre striations, a healed side-shoot scar, a dark ambient band under the crown.
-- One small glaucous leaf peels off the stalk (midrib + veins).
-- quirk: one back floret has bolted and opened three tiny yellow flowers.
local NAME = "broccoli"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local FL = { "#132f2e", "#1c4936", "#28663c", "#398545", "#5aa84f", "#93cb64" }
local STK = { "#2a4f39", "#477a48", "#6ba05a", "#90c06c", "#b8d98a", "#e0eeb2" }
local LEAF = { "#1b3a3e", "#275650", "#377262", "#509076", "#78b28e", "#b0d4ae" }
local COOL = "#3a6e74"

-- branchlets (behind the stalk top, covered mostly by florets)
local stok = { r = { name = "stalk" } }
local brs = {
  { { 31, 40 }, { 28, 36 }, { 25, 32 }, { 21, 28 } },
  { { 32, 39 }, { 32, 35 }, { 32, 31 }, { 32, 26 } },
  { { 33, 40 }, { 36, 36 }, { 39, 32 }, { 43, 28 } },
}
local bm = HP.mask()
for _, p in ipairs(brs) do
  local m, n = A.tube(p, function(t) return 1.9 - t * 0.6 end)
  A.shade(c, m, n, STK, { tok = stok, amb = 0.1 })
  bm:add(m)
end
-- stalk
local sp = { { 32, 55 }, { 32, 50 }, { 31, 45 }, { 32, 39 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 3.1 - t * 0.5 + (t > 0.85 and (t - 0.85) * 9 or 0) end)
local sb = {}
sm:each(function(x, y) local k = K(x, y)
  if ST[k] > 0.86 then sb[k] = -2 elseif ST[k] > 0.8 then sb[k] = -1 end
  if ST[k] < 0.03 then sb[k] = (sb[k] or 0) - 1 end
end)
local sidx = A.shade(c, sm, sn, STK, { tok = stok, bias = sb, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- fibre striations: broken lines along the stalk
sm:each(function(x, y) local k = K(x, y)
  local s, t = SS[k], ST[k]
  if t > 0.05 and t < 0.8 and ((abs(s + 0.42) < 0.12) or (abs(s - 0.25) < 0.1)) and A.hash(x, floor(y / 3), 7) > 0.3 then
    A.step(c, sidx, STK, x, y, -1, stok) end
end)
-- healed side-shoot scar on the left
c:put(29, 47, STK[2], stok) c:put(30, 47, STK[3], stok) c:put(29, 48, STK[4], stok) c:put(30, 46, STK[5], stok)
-- cut base: pale vascular dots
c:put(31, 55, STK[5], stok) c:put(33, 55, STK[4], stok)

-- small leaf peeling off the stalk to the right
local ltok = { r = { name = "leaf" } }
local lm, ln, LT, LS = A.blade(34, 47, 40, 46, 47, 40, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 2.7 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7)
end, { fold = 0.4 })
lm:cut(sm)
local lb = {}
lm:each(function(x, y) if LT[K(x, y)] < 0.12 then lb[K(x, y)] = -1 end end)
A.shade(c, lm, ln, LEAF, { tok = ltok, bias = lb, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if abs(LS[k]) < 0.18 and LT[k] > 0.1 and LT[k] < 0.88 then c:put(x, y, LEAF[6], ltok) end
end)
c:put(41, 43, LEAF[5], ltok) c:put(44, 42, LEAF[3], ltok)
-- stalk AO where the leaf leaves it
c:put(35, 47, STK[2], stok) c:put(35, 48, STK[2], stok)

-- florets, back to front
local flo = {
  { 23, 17, 5.0 }, { 32, 13, 5.6 }, { 41, 16, 5.2 },
  { 16, 25, 4.8 }, { 26, 22, 5.8 }, { 37, 21, 5.8 }, { 48, 25, 4.8 },
  { 21, 32, 5.2 }, { 32, 31, 6.2 }, { 43, 32, 5.2 },
}
local CX, CY, CR = 32, 24, 21
local all = HP.mask()
local fidx = {}
local ftok = { r = { name = "floret" } }
for i, f in ipairs(flo) do
  local fx, fy, r = f[1], f[2], f[3]
  local m = HP.ellipse(fx, fy, r, r - 0.4)
  -- bumpy rim: bud clusters around the edge
  for a = 0, 7 do
    local ang = a * pi / 4 + i * 0.4
    m:add(HP.ellipse(fx + math.cos(ang) * (r - 0.6), fy + math.sin(ang) * (r - 0.9), 1.6, 1.6))
  end
  -- contact shadow on the florets already painted, around this one (heavier lower-right)
  local ring = m:grow(1):cut(m)
  ring:each(function(x, y) local k = K(x, y)
    if all:has(x, y) and fidx[k] then
      local d = (x >= fx or y >= fy) and -2 or -1
      local ni = max(1, fidx[k] + d) fidx[k] = ni c:put(x, y, FL[ni], ftok)
    end
  end)
  local ns = X.sphere(fx, fy, r, m)
  local nd = X.sphere(CX, CY, CR, m)
  local n = {}
  for k, a in pairs(ns) do local b = nd[k]
    n[k] = { A.norm(a[1] * 0.6 + b[1] * 0.4, a[2] * 0.6 + b[2] * 0.4, a[3] * 0.6 + b[3] * 0.4) } end
  local v = X.light(n, { amb = 0.06, wrap = 0.2 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local h = A.hash(x, y, 3)
    if h > 0.74 then bias[k] = -1 elseif h < 0.1 and v[k] > 0.55 then bias[k] = 1 end
    if i >= 8 and y > fy + r * 0.45 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local idx = X.tone(c, m, v, FL, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, bias = bias, tok = ftok })
  for k, ii in pairs(idx) do fidx[k] = ii end
  -- cool bounce on the lower-right rim
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.62 and fidx[k] and fidx[k] >= 2 and fidx[k] <= 3 then c:put(x, y, COOL, ftok) end end)
  all:add(m)
end
-- top glint on the crown
c:put(29, 10, "#d4ec98", ftok) c:put(30, 10, "#d4ec98", ftok) c:put(28, 11, FL[6], ftok)
-- ambient band where the stalk enters the crown
for x = 28, 36 do if sm:has(x, 39) and not all:has(x, 39) then c:put(x, 39, STK[1], stok) end end
for x = 29, 35 do if sm:has(x, 40) and not all:has(x, 40) then c:put(x, 40, STK[2], stok) end end

-- quirk: a bolted floret with three tiny yellow flowers
local YL = { "#d98322", "#f5c431", "#ffe98a" }
local function flower(x, y)
  c:put(x, y, YL[1], ftok) c:put(x - 1, y, YL[2], ftok) c:put(x + 1, y, YL[2], ftok)
  c:put(x, y - 1, YL[3], ftok) c:put(x, y + 1, YL[2], ftok)
end
flower(43, 12) flower(46, 15) c:put(40, 11, YL[2], ftok) c:put(40, 10, YL[3], ftok)
A.save(c, NAME)
