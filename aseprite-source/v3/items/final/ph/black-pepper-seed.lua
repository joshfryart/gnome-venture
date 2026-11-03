-- black-pepper-seed (aR20_4, Opus single pass). Three wrinkled peppercorns on a torn scrap of glossy piper leaf
-- (torn ragged base, midrib + curved veins running base-to-tip, glossy streak, cool reflected edge, AO and cast
-- shadow under each corn). The left corn has sprouted: pale radicle, thin stem, two oval cotyledons and a first
-- heart-shaped true leaf with curved piper veins.
-- quirk: one of the corns is still fresh and red, not yet dried black.
local NAME = "black-pepper-seed"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = R.new2(NAME)
local LEAF = { "#13352e", "#1c4f37", "#296b3f", "#3d8a46", "#5fa84f", "#93c96a" }
local VEINL, COOL, GLOSS = "#b4dc86", "#356a74", "#d4ee9e"
local PEP = { "#140d14", "#22161c", "#33232a", "#4a3534", "#6a5046", "#93785e" }
local RED = { "#4e1222", "#7e1a26", "#b02a2c", "#d6452f", "#f0743f", "#ffb27a" }
local STEM = { "#4c8452", "#7fb468", "#b2d88e", "#e0f0b8" }
local ROOT = { "#c9b48e", "#efe2bf" }

-- corns: cx, cy, r
local corns = { { 19, 46, 3.9 }, { 30, 48, 3.9 }, { 41, 44, 3.9 } }
for _, s in ipairs(corns) do s.m = c:ellipse(s[1], s[2], s[3], s[3]) end

-- leaf scrap: ovate piper leaf tip piece, ragged torn base on the left
local lm, ln, LT, LS, len = R.blade(8, 49, 32, 53, 57, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.6 * sin(pi * (0.22 + 0.78 * t)) ^ 0.7)
end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local band = floor((LS[k] + 1) * 5)
  local lim = 0.03 + 0.09 * X.hash(band, 0, 11) + 0.02 * X.hash(x, y, 5)
  if LT[k] < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(corns) do X.ao(bias, lm, s.m, 1, -1) R.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
R.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 and t < 0.94 then c:put(x, y, s <= 0 and VEINL or LEAF[3], ltok) return end
  -- acrodromous veins: curves converging to the tip
  for _, vv in ipairs{ 0.48, 0.8 } do
    local target = vv * (1 - t ^ 1.6)
    if abs(abs(s) - target) < 0.1 and t > 0.03 and t < 0.86 then c:put(x, y, s < 0 and VEINL or LEAF[4], ltok) end
  end
  -- gloss streak on the lit half
  if s < -0.25 and s > -0.42 and t > 0.45 and t < 0.68 then c:put(x, y, GLOSS, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: paler raw edge on the ragged base
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] < 0.16 and abs(LS[k]) < 0.85 and X.hash(x, y, 2) > 0.35 then c:put(x, y, LEAF[5], ltok) end end)

-- radicle: pale root from the sprouting corn, curling onto the leaf
local rtok = { r = { name = "root" } }
for i, q in ipairs{ { 15, 48 }, { 14, 49 }, { 13, 50 }, { 13, 51 }, { 14, 52 } } do
  c:put(q[1], q[2], i < 3 and ROOT[2] or ROOT[1], rtok)
  if lm:has(q[1] + 1, q[2] + 1) and not corns[1].m:has(q[1] + 1, q[2] + 1) then c:put(q[1] + 1, q[2] + 1, LEAF[1], ltok) end
end

-- sprout stem
local stok = { r = { name = "stem" } }
local sp = { { 19, 43 }, { 17, 36 }, { 22, 29 }, { 25, 23 } }
local sm, sn = R.tube(sp, function(t) return 0.95 end)
sm:cut(corns[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: two small ovals at mid stem
local cots = {}
for _, q in ipairs{ { 13.5, 33, -0.5 }, { 23.5, 35.5, 0.35 } } do
  local m, n = R.oval(q[1], q[2], 3.4, 1.6, q[3], 0.7)
  m:cut(sm)
  R.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.15, wrap = 0.3 })
  cots[#cots + 1] = m
end
-- first true leaf: heart-shaped (implicit heart curve), notched base on the stem tip, tip pointing up-right
local BX, BY = 26, 22
local dx, dy = 0.55, -0.835          -- base -> tip
local px, py = -dy, dx               -- across (+ = lower-right side)
local SC = 6.2
local hm = HP.mask()
local HA, HB = {}, {}
for y = BY - 20, BY + 6 do for x = BX - 10, BX + 20 do
  local rx, ry = x - BX, y - BY
  local a, b = rx * dx + ry * dy, rx * px + ry * py
  local hx, hy = b / SC, 1 - a / SC
  if (hx * hx + hy * hy - 1) ^ 3 - hx * hx * hy ^ 3 <= 0 then
    hm:set(x, y) HA[K(x, y)], HB[K(x, y)] = a, b end
end end
local hn = X.pillow(hm, 2.6)
for k, nn in pairs(hn) do local sg = HB[k] < 0 and -1 or 1
  hn[k] = { R.norm(nn[1] + px * sg * 0.32, nn[2] + py * sg * 0.32, nn[3]) } end
local hb = {}
R.cast(hb, hm, sm, 1, 1, -1)
R.toneN(c, hm, hn, LEAF, { tok = ltok, bias = hb, cuts = { 0.14, 0.3, 0.47, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
local L = 2 * SC
local function hv(pts, lit)
  for i = 1, #pts - 1 do
    local a0, b0, a1, b1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    for j = 0, 8 do local t = j / 8
      local a, b = a0 + (a1 - a0) * t, b0 + (b1 - b0) * t
      local x, y = floor(BX + a * dx + b * px + .5), floor(BY + a * dy + b * py + .5)
      if hm:has(x, y) and not hm:edge():has(x, y) then c:put(x, y, lit and LEAF[5] or LEAF[2], ltok) end
    end
  end
end
hv({ { 1, -0.4 }, { 0.45 * L, -0.38 * SC }, { 0.82 * L, -0.12 * SC } }, true)
hv({ { 1, 0.4 }, { 0.45 * L, 0.38 * SC }, { 0.82 * L, 0.12 * SC } }, false)
for j = 0, 24 do local a = 0.5 + j / 24 * (0.85 * L)
  local x, y = floor(BX + a * dx + .5), floor(BY + a * dy + .5)
  if hm:has(x, y) then c:put(x, y, VEINL, ltok) end end
hm:edge():each(function(x, y) local k = K(x, y) if HB[k] > 0.5 * SC and HA[k] > 2 then c:put(x, y, COOL, ltok) end end)
do local bx, by = R.specAt(hm, hn, 40) if bx then c:put(bx, by, GLOSS, ltok) c:put(bx + 1, by, GLOSS, ltok) end end

-- corns: wrinkled spheres (raised net of ridges, dark pits), AO between neighbours
for i, s in ipairs(corns) do
  local ramp = (i == 3) and RED or PEP
  local tok = { r = { name = "corn" .. i } }
  local m = s.m
  local n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3], m)
  local v = X.light(n, { amb = 0.05, wrap = 0.2 })
  local idx = X.tone(c, m, v, ramp, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, tok = tok })
  m:each(function(x, y) local k = K(x, y)
    local h = X.hash(x * 3 + i, y * 5, 9)
    local ii = idx[k]
    local net = (x + 2 * y + i) % 3 == 0
    if net and h > 0.3 and ii > 1 then ii = ii - 1 elseif not net and h > 0.82 and ii < 5 then ii = ii + 1 end
    c:put(x, y, ramp[ii], tok)
  end)
  local bx, by = R.specAt(m, n, 30)
  c:put(bx, by, i == 3 and "#ffe0b0" or "#e2d2bc", tok)
  -- dried stalk scar on the black corns
  if i ~= 3 then c:put(s[1] + 1, s[2] - 2, ramp[2], tok) end
end
-- shadow from the leaf under the corns' lower-right rims is handled by bias; contact dark row under corns
for _, s in ipairs(corns) do
  for dx = -2, 3 do local x, y = s[1] + dx, s[2] + 5
    if lm:has(x, y) and not s.m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end
end

R.save2(c, NAME)
