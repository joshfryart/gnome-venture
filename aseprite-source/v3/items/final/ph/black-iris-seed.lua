-- black-iris-seed (final, Opus single pass). Three flat, D-shaped iris seeds (dusky plum-brown, wrinkled seed coat,
-- a pale hilum notch on the flat side) on a torn strip of glaucous iris leaf (straight strap, parallel veins, waxy
-- blue bloom, both ends ripped, AO + contact shadow under the seeds). The middle seed has germinated as a monocot:
-- a fan of three slim sword leaves rising from one pale sheath, plus a short white root.
-- quirk: a single dewdrop clings to the tip of the tallest sword leaf.
local NAME = "black-iris-seed"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_3.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = R.new(NAME)
local LEAF = { "#16343c", "#1f4e4c", "#2c6c58", "#42895e", "#66a86c", "#9ccb88" }   -- glaucous blue-green
local BLOOM, VEIN, COOL = "#b4d8c8", "#83b884", "#3a5f78"
local SEED = { "#200e1a", "#361a26", "#52282e", "#723a3a", "#965448", "#bd7d62" }
local HILUM = "#e0b88a"
local SHEATH = { "#6a8a5a", "#9ab878", "#c9e0a4", "#ecf6cc" }
local ROOT = { "#b8a890", "#e6dcc4", "#fbf4e0" }
local DROP = { "#3a86b0", "#8fd6e0", "#d8f6f2" }

-- seeds: cx, cy, rx, ry, flat-side angle
local seeds = { { 17, 46, 3.6, 3.0, 0.6 }, { 31, 47, 3.7, 3.1, -1.4 }, { 45, 46, 3.5, 2.9, 2.4 } }
for _, s in ipairs(seeds) do
  local m = c:ellipse(s[1], s[2], s[3], s[4])
  local fx, fy = cos(s[5]), sin(s[5])
  m:each(function(x, y) if (x - s[1]) * fx + (y - s[2]) * fy > s[4] * 0.55 then m.s[K(x, y)] = nil end end)
  s.m = m
end

-- leaf strip: near-straight strap with ripped ends
local lm, ln, LT, LS, len = R.blade(8, 51, 32, 47, 56, 46, function(t) return 5.6 - 0.8 * t end, { fold = 0.22 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local j = ({ 0, 2.5, 1.0, 3.2, 0.4, 2.0, 1.4, 2.8 })[floor((s + 1) * 4.4) % 8 + 1]
  local a = t * len
  if a < 1.0 + j or a > len - 1.0 - (3 - j) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) R.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
R.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.2, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  -- parallel veins along the strap
  for _, vs in ipairs{ -0.55, -0.1, 0.35, 0.75 } do
    if abs(s - vs) < 0.09 then c:put(x, y, s < 0.2 and VEIN or LEAF[2], ltok) return end
  end
  -- waxy bloom specks on the lit half
  if s < 0 and X.hash(x, y, 3) > 0.86 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.62 then c:put(x, y, COOL, ltok) end
  local a = LT[k] * len
  if a < 5 or a > len - 5 then c:put(x, y, "#cfe4b8", ltok) end       -- pale ripped fibres
end)

-- sprout: fan of three sword leaves from a sheath at the middle seed
local stok = { r = { name = "sheath" } }
local function sword(p, w0)
  local m, n, T, S = R.tube(p, function(t) if t > 0.985 then return 0 end return w0 * (1 - t ^ 3 * 0.75) end)
  return m, n, T, S
end
local blades = {
  { { 30, 44 }, { 26, 36 }, { 22, 28 }, { 18, 21 }, w = 1.6 },
  { { 34, 44 }, { 37, 37 }, { 40, 30 }, { 44, 23 }, w = 1.6 },
  { { 32, 44 }, { 32, 34 }, { 31, 22 }, { 30, 11 }, w = 1.9 },
}
local prev = HP.mask()
local tips = {}
for i, b in ipairs(blades) do
  local m, n, T, S = sword(b, b.w)
  local bb = {}
  R.shade(c, m, n, LEAF, { tok = ltok, amb = 0.16, wrap = 0.3, bias = bb })
  -- midvein + bloom on each blade
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
    if T[k] < 0.18 then c:put(x, y, SHEATH[S[k] < 0 and 3 or 2], stok) end      -- pale sheath at the foot
  end)
  -- AO where the outer blades tuck behind the centre blade
  if i == 3 then for _, o in ipairs{ 1, 2 } do end end
  prev:add(m)
  b.m = m
end
-- dark row where the centre blade overlaps the side blades
blades[3].m:grow(1):cut(blades[3].m):each(function(x, y)
  if (blades[1].m:has(x, y) or blades[2].m:has(x, y)) and y > 30 then c:put(x, y, LEAF[1], ltok) end end)
-- root: short white radicle out of the seed's flat side, curling over the leaf edge
local rtok = { r = { name = "root" } }
local rm, rn = R.tube({ { 31, 50 }, { 32, 53 }, { 34, 55 }, { 37, 56 } }, function(t) return 0.9 * (1 - t) + 0.35 end)
R.shade(c, rm, rn, ROOT, { cuts = { 0.4, 0.75 }, tok = rtok })

-- seeds: flat discs, wrinkled coat, hilum notch on the flat side
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  if i == 2 then vis:cut(HP.mask()) end
  local sb = {}
  if i == 2 then X.ao(sb, s.m, prev, 1, -1) end
  local nm = X.pillow(s.m, 2.2)
  local v = X.light(nm, { amb = 0.06, wrap = 0.25 })
  local tok = { r = { name = "seed" .. i } }
  vis:each(function(x, y) local k = K(x, y)
    local ii = 1
    for jj, ct in ipairs{ 0.2, 0.38, 0.55, 0.7, 0.85 } do if v[k] >= ct then ii = jj + 1 end end
    -- wrinkles: short curved creases
    local w = sin((x * 1.3 + y * 0.7) + X.hash(floor(x / 2), floor(y / 2), i) * 2.5)
    if ii >= 3 and w > 0.82 then ii = ii - 2 end
    if sb[k] then ii = ii - 1 end
    c:put(x, y, SEED[max(1, min(6, ii))], tok)
  end)
  local fx, fy = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + fx * (s[4] * 0.55 - 0.2) + .5), floor(s[2] + fy * (s[4] * 0.55 - 0.2) + .5)
  if vis:has(hx, hy) then c:put(hx, hy, HILUM, tok) end
  -- one glint
  local gx, gy = floor(s[1] - 1.4 + .5), floor(s[2] - 1.4 + .5)
  if vis:has(gx, gy) then c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, SEED[6], tok) end
end
-- the sheath sits in front of the sprouting seed's top
for _, b in ipairs(blades) do b.m:each(function(x, y) if y >= 42 and y <= 44 and seeds[2].m:has(x, y) then c:put(x, y, SHEATH[2], stok) end end) end

-- quirk: dewdrop at the tip of the tallest blade (glass: dark rim, pale core, bright glint)
local dx, dy = 29, 9
local dm = c:ellipse(dx, dy, 1.6, 1.6)
local dtok = { r = { name = "drop" } }
dm:each(function(x, y) c:put(x, y, DROP[1], dtok) end)
c:put(dx, dy, DROP[2], dtok) c:put(dx - 1, dy, DROP[2], dtok) c:put(dx, dy + 1, DROP[2], dtok)
c:put(dx - 1, dy - 1, DROP[3], dtok)
R.finish(c)
