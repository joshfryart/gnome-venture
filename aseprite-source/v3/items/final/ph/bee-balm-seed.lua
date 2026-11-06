-- bee-balm-seed (final pass, Opus). Bee balm (Monarda): a pinch of tiny oblong nutlets (dark brown, matte, a pale
-- scar at one end) on a torn scrap of the narrow, saw-toothed mint-family leaf (serrate margin, pinnate veins swept
-- to the tip, V fold, cool reflected edge, ragged torn end, AO + contact shadow under each nutlet). One nutlet on the
-- left has sprouted: a SQUARE mint stem (hard lit face / shade face, flushed red at the nodes), a pair of round
-- cotyledons and two tiers of opposite, toothed lanceolate true leaves, so the plant reads at a glance.
-- History: Sonnet draft (_dA14) replaced.
-- quirk: one crimson tubular bee balm floret, lipped and curled, has dropped onto the scrap beside the seeds.
local NAME = "bee-balm-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#183d38", "#235743", "#307449", "#46914f", "#68ad58", "#97c96a" }   -- slightly greyed mint green
local YLEAF = { "#1e4a3c", "#2d6845", "#438a4c", "#61a956", "#88c662", "#b8e082" }
local VEIN, COOL = "#b4d88a", "#3a6c72"
local NUT   = { "#24161a", "#3e2620", "#5c3a28", "#7c5234", "#a06e46", "#c89664" }
local STEM  = { "#3e6e48", "#5f9658", "#8cc06e", "#c4e49a" }
local FLUSH = { "#5e2238", "#8a3046" }
local CRIM  = { "#5a1430", "#8e1c3a", "#bf2a44", "#e24a5a", "#ff8a8c", "#ffc6c0" }

-- serrate: notch the margin of a blade (teeth lean toward the tip)
local function serrate(m, T, S, len, per, depth, t0, t1)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if t > t0 and t < t1 then
      local ph = (t * len / per + (s > 0 and 0.5 or 0)) % 1        -- 0..1 saw phase
      local lim = 1 - depth * ph ^ 1.6
      if abs(s) > lim then cut[#cut + 1] = k end
    end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m
end

-- ---------------------------------------------------------------- leaf scrap (narrow toothed blade, torn end)
local lm, ln, LT, LS, len = A.blade(9, 56, 31, 55, 57, 44, function(t)
  if t > 0.995 then return -1 end
  return max(0.6, 5.8 * sin(pi * min(1, t * 0.66 + 0.06)) ^ 0.75)
end, { fold = 0.4 })
serrate(lm, LT, LS, len, 4.8, 0.3, 0.1, 0.88)
-- ragged torn upper end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d = (1 - LT[k]) * len
  local rag = 1.2 + 1.4 * X.hash(floor(LS[k] * 3 + 0.5), 5, 3)
  if d < rag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local SX = 23                      -- stem left column; 3 px wide (lit face 2 px, shade face 1 px)
local nuts = { { 31, 50.5, 2.3, 1.35, 0.5 }, { 36, 53, 2.3, 1.35, -0.3 }, { 37.8, 48.6, 2.2, 1.3, 0.9 },
               { 42.5, 51.0, 2.3, 1.35, 0.1 }, { 46, 47.2, 2.1, 1.25, -0.6 }, { SX + 1, 51.3, 2.1, 1.3, -0.2 } }
for _, s in ipairs(nuts) do s.m = A.rell(s[1], s[2], cos(s[5]), sin(s[5]), s[3] + 0.4, s[4] + 0.4) end

local bias = {}
for _, s in ipairs(nuts) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.1, 0.24, 0.4, 0.57, 0.76 }, amb = 0.2, wrap = 0.35 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- pinnate veins: one into every second tooth, swept toward the tip
  local ph = (t * len - abs(s) * 5.5) / 6.4 + (s > 0 and 0.5 or 0)
  local f = ph % 1
  if f < 0.13 and abs(s) > 0.16 and abs(s) < 0.78 and t > 0.06 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.08 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 8, 57, 4 }, { 7, 57, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- ---------------------------------------------------------------- quirk: crimson tubular floret on the scrap
local fp = { { 50.5, 49.5 }, { 52, 46 }, { 50, 42.5 }, { 46.5, 42.3 } }
local fm, fn, FT, FS = A.tube(fp, function(t) return 0.7 + 1.05 * t end)
-- two-lipped mouth: upper lip hood + lower lip flare at the open end
local lipU = A.rell(45.4, 41.2, cos(-0.5), sin(-0.5), 1.9, 1.0)
local lipL = A.rell(45.6, 44.0, cos(0.5), sin(0.5), 1.6, 0.9)
fm:add(lipU):add(lipL)
X.ao(bias, lm, fm, 1, -1)
fm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not fm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local ftok = { r = { name = "floret" } }
local fnn = X.pillow(fm, 1.4)
for k, n in pairs(fn) do if fnn[k] then fnn[k] = { A.norm(n[1] + fnn[k][1], n[2] + fnn[k][2], n[3] + fnn[k][3]) } end end
local fidx = A.shade(c, fm, fnn, CRIM, { tok = ftok, amb = 0.1, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- throat (dark) and a pale lip edge, glossy glint on the tube
c:put(46, 42, CRIM[1], ftok) c:put(46, 43, CRIM[2], ftok)
c:put(44, 41, CRIM[5], ftok) c:put(45, 40, CRIM[5], ftok)
c:put(51, 45, CRIM[6], ftok)
-- pale calyx stub at the closed end
c:put(50, 49, "#86b86c", ftok) c:put(51, 50, "#4f8a55", ftok) c:put(50, 50, "#5f9658", ftok)

-- ---------------------------------------------------------------- sprout: square stem, opposite leaves
local stok = { r = { name = "stem" } }
local ytop, ybot = 21, 50
local sm = c:rect(SX, ytop, SX + 2, ybot)
for y = ytop, ybot do
  c:put(SX, y, (y % 5 == 0 and y < 40) and STEM[4] or STEM[3], stok) c:put(SX + 1, y, STEM[3], stok) c:put(SX + 2, y, STEM[1], stok)
end
local function node(y) c:put(SX, y, STEM[2], stok) c:put(SX + 1, y, FLUSH[2], stok) c:put(SX + 2, y, FLUSH[1], stok) end

local function tleaf(bx, by, cx, cy, tx, ty, w, ramp, teeth)
  local m, n, T, S, L = A.blade(bx, by, cx, cy, tx, ty, function(t)
    if t > 0.98 then return -1 end
    return max(0.45, w * sin(pi * min(1, (t * 0.82 + 0.08) ^ 0.75)) ^ 0.7)
  end, { fold = 0.38 })
  if teeth then serrate(m, T, S, L, 2.6, 0.5, 0.2, 0.86) end
  m:cut(sm)
  local b = {}
  X.ao(b, m, sm, 1, -1)
  A.shade(c, m, n, ramp, { tok = ltok, amb = 0.1, wrap = 0.28, bias = b, cuts = { 0.18, 0.34, 0.5, 0.67, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.12 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], ltok) end
    if teeth then
      local ph = (T[k] * L - abs(S[k]) * 3) / 3.4 % 1
      if ph < 0.18 and abs(S[k]) > 0.2 and abs(S[k]) < 0.7 and T[k] > 0.2 and T[k] < 0.8 then c:put(x, y, S[k] < 0 and ramp[6] or ramp[2], ltok) end
    end
  end)
  return m
end
-- cotyledons (round, low)
tleaf(SX, 44, SX - 3, 42, SX - 7, 40, 2.2, YLEAF, false)
tleaf(SX + 2, 44, SX + 5, 42.5, SX + 9, 40.5, 2.2, YLEAF, false)
-- first true pair (larger, toothed), second pair (smaller), terminal bud
tleaf(SX, 34, SX - 5, 31, SX - 12, 23, 4.0, YLEAF, true)
tleaf(SX + 2, 34, SX + 7, 31, SX + 14, 23.5, 4.0, YLEAF, true)
tleaf(SX, 25, SX - 2, 22, SX - 5, 18, 1.6, YLEAF, false)
tleaf(SX + 2, 25, SX + 4, 22, SX + 7, 18.5, 1.6, YLEAF, false)
for _, y in ipairs{ 44, 34, 25 } do node(y) end
-- terminal bud: two folded baby leaves
for _, q in ipairs{ { SX, 20, 5 }, { SX + 1, 20, 4 }, { SX + 2, 20, 3 }, { SX, 19, 6 }, { SX + 1, 19, 5 }, { SX + 2, 19, 2 },
  { SX + 1, 18, 4 }, { SX - 1, 20, 4 }, { SX + 3, 20, 2 } } do c:put(q[1], q[2], YLEAF[q[3]], ltok) end

-- ---------------------------------------------------------------- nutlets last
for i, s in ipairs(nuts) do
  local vis = s.m:copy()
  if i == 6 then vis:cut(sm) end
  local tok = { r = { name = "nut" .. i } }
  local n = X.sphere(s[1] - 0.4, s[2] - 0.5, s[3] + 0.5, vis)
  local idx = A.shade(c, vis, n, NUT, { tok = tok, amb = 0.06, wrap = 0.22, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
  -- pale attachment scar at the lower-right end, one dull glint upper-left
  local ex, ey = floor(s[1] + cos(s[5]) * (s[3] - 0.2) + 0.5), floor(s[2] + sin(s[5]) * (s[3] - 0.2) + 0.5)
  if vis:has(ex, ey) then c:put(ex, ey, NUT[5], tok) end
  local gx, gy = floor(s[1] - 0.8 + 0.5), floor(s[2] - 0.6)
  if vis:has(gx, gy) then c:put(gx, gy, "#d8b48a", tok) end
  vis:edge():each(function(x, y) if not vis:has(x - 1, y - 1) and (idx[K(x, y)] or 1) >= 3 and not (x == gx and y == gy) then c:put(x, y, NUT[5], tok) end end)
end
-- sprouting nutlet: split coat around the stem foot + a white root hair below
c:put(SX, 51, NUT[1]) c:put(SX + 2, 51, NUT[1]) c:put(SX + 1, 51, STEM[3], stok)

A.save(c, NAME)
