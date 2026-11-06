-- nasturtium-seed (final, Opus single pass). Two big corky, deeply wrinkled nasturtium seeds (one dry tan, one fresh
-- green) on a torn, flat-lying fragment of a round nasturtium leaf (blue-green, matte, veins radiating from an
-- off-centre hub, wavy margin, ragged tear on the right). The green seed has sprouted: no seed leaves (they stay in
-- the seed), just a pale stem up to a round shield leaf on a long stalk, plus a small second leaf.
-- quirk: a bead of water sits on the shield leaf (nasturtium leaves shed water like a lotus).
local NAME = "nasturtium-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local LEAF = { "#1d4643", "#2a614f", "#3c7f57", "#5a9f62", "#87bf78", "#bcdfa0" }
local VEIN = { "#9fd18a", "#d9f0bd" }
local STEM = { "#3a6a4a", "#5a8e58", "#86b46e", "#b2d690", "#dcefb8" }
local TAN = { "#45321f", "#6a5233", "#8f7a48", "#b2a062", "#d0c286", "#ede2b2" }
local GRN = { "#2c4428", "#43633a", "#5f8449", "#80a55c", "#a8c679", "#d2e5a6" }
local COOL = "#3f6e80"

local function wavyDisc(cx, cy, rx, ry, waves, amp, ph)
  local m = HP.mask()
  for y = floor(cy - ry - 2), floor(cy + ry + 2) do for x = floor(cx - rx - 2), floor(cx + rx + 2) do
    local dx, dy = (x - cx) / (rx + .4), (y - cy) / (ry + .4)
    local a = atan(dy * ry, dx * rx)
    local lim = 1 + amp * sin(a * waves + (ph or 0))
    if dx * dx + dy * dy <= lim * lim then m:set(x, y) end
  end end
  return m
end
-- radial veins from a hub: returns key->true for vein pixels
local function radial(m, hx, hy, n, rot, sx, sy)
  local v = {}
  m:each(function(x, y)
    local dx, dy = (x - hx) / sx, (y - hy) / sy
    local r = sqrt(dx * dx + dy * dy)
    if r < 0.6 then return end
    local a = atan(dy, dx) - rot
    local f = (a / (2 * pi)) * n
    local d = abs(f - floor(f + 0.5)) * 2 * pi / n * r * sx   -- px distance off the vein line
    if d < 0.55 then v[K(x, y)] = r end
  end)
  return v
end

---------------------------------------------------------------- leaf fragment lying flat (foreshortened)
local fm = wavyDisc(30, 49, 22, 8.5, 9, 0.05, 0.4)
-- ragged tear on the right: cut along a slanted jagged line
do local cut = {}
  fm:each(function(x, y)
    local line = 44 + (y - 49) * 0.9 + abs(((y * 0.37) % 1) - 0.5) * 4 + X.hash(x, y, 4) * 1.4
    if x > line then cut[#cut + 1] = K(x, y) end
  end)
  for _, k in ipairs(cut) do fm.s[k] = nil end
  A.clean(fm)
end
local fn = X.pillow(fm, 3, 0.7)
-- seeds
local S1 = { 18, 47, 5.2 }
local S2 = { 34, 46, 5.4 }
for _, s in ipairs{ S1, S2 } do s.m = HP.ellipse(s[1], s[2], s[3], s[3] - 0.6) s.n = X.sphere(s[1], s[2], s[3], s.m) end
local bias = {}
for _, s in ipairs{ S1, S2 } do X.ao(bias, fm, s.m, 1, -1) A.cast(bias, fm, s.m, 2, 1, -1) A.cast(bias, fm, s.m, 1, 2, -1) end
local ftok = A.tok("leaf")
local fidx = A.shade(c, fm, fn, LEAF, { bias = bias, tok = ftok, amb = 0.2, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
local fv = radial(fm, 27, 50, 9, 0.2, 1, 0.38)
for k in pairs(fv) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if not bias[k] then c:put(x, y, y < 49 and VEIN[1] or LEAF[4], ftok) end
end
c:put(27, 50, LEAF[3], ftok) c:put(26, 50, VEIN[2], ftok)          -- hub where the stalk was
fm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and y >= 52 and x > 18 then c:put(x, y, COOL, ftok) end end)

---------------------------------------------------------------- sprout (stalks first, leaves over, seed coat over stalk foot)
local stok = A.tok("stem")
local sp = { { 36, 42 }, { 35, 33 }, { 44, 30 }, { 42, 21 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(S2.m)
A.shade(c, sm, sn, STEM, { amb = 0.12, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
local pp = { { 37, 34 }, { 33, 31 }, { 30, 32 }, { 27, 30 } }
local pm, pn = A.tube(pp, function(t) return 0.75 end)
pm:cut(sm)
A.shade(c, pm, pn, STEM, { amb = 0.12, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })

local function shield(cx, cy, rx, ry, hx, hy, nv, tok, waves)
  local m = wavyDisc(cx, cy, rx, ry, waves, 0.045, 1.1)
  local np = X.pillow(m, 2.5, 0.8)
  local ns = X.sphere(cx, cy, max(rx, ry) + 2, m)
  local n = {}
  for k, a in pairs(np) do local b = ns[k] n[k] = { A.norm(a[1] * 0.6 + b[1] * 0.5, a[2] * 0.6 + b[2] * 0.5, a[3] * 0.6 + b[3] * 0.5) } end
  local b = {}
  local idx = A.shade(c, m, n, LEAF, { tok = tok, bias = b, amb = 0.14, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  local vv = radial(m, hx, hy, nv, 0.35, 1, 1)
  for k, r in pairs(vv) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local i = idx[k] or 3
    c:put(x, y, i >= 4 and VEIN[2] or VEIN[1], tok)
  end
  c:put(hx, hy, VEIN[2], tok)
  -- darker rim on the shade side (the margin curls under)
  m:edge():each(function(x, y) if (x - cx) / rx + (y - cy) / ry > 0.7 then c:put(x, y, LEAF[2], tok) end end)
  return m, idx
end
local L2, L2i = shield(26, 27, 5.2, 4.4, 26, 28, 7, A.tok("leaf2"), 7)
local L1, L1i = shield(41, 15, 10.5, 8, 42, 16, 9, A.tok("leaf1"), 9)

-- quirk: water bead on the big leaf, with its contact shadow
do local tok = A.tok("leaf1")
  for _, p in ipairs{ { 36, 14 }, { 37, 14 }, { 37, 13 } } do c:put(p[1] + 1, p[2] + 1, LEAF[2], tok) end
  local W = { { 35, 12, "#3f8f92" }, { 36, 12, "#3f8f92" }, { 34, 13, "#3f8f92" }, { 35, 13, "#fff4d6" }, { 36, 13, "#a8e6e0" },
              { 37, 13, "#7cc9c8" }, { 34, 14, "#5aa8a8" }, { 35, 14, "#b8eee6" }, { 36, 14, "#d8faf2" }, { 37, 14, "#e8fff8" },
              { 35, 15, "#c8f4ec" }, { 36, 15, "#e8fff8" } }
  for _, p in ipairs(W) do c:put(p[1], p[2], p[3], A.tok("bead")) end
end

---------------------------------------------------------------- seeds: corky, deeply wrinkled
local function seed(s, ramp, i, other)
  local tok = A.tok("seed" .. i)
  local v = X.light(s.n, { amb = 0.15, wrap = 0.3 })
  local sb = {}
  if other then X.ao(sb, s.m, other.m, 1, -1) end
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local r = sqrt(dx * dx + dy * dy) / s[3]
    local a = atan(dy, dx)
    local i = floor(v[k] * 6) + 1
    local g = sin(a * 3 + r * 5.5 + i * 0.0)
    if r > 0.25 and abs(g) < 0.24 then i = i - 2 elseif g > 0.82 then i = i + 1 end
    if r < 0.3 and dx >= 0 and dy >= 0 then i = i - 1 end          -- crown dimple
    if sb[k] then i = i + sb[k] end
    c:put(x, y, ramp[max(1, min(6, i))], tok)
  end)
  return tok
end
seed(S1, TAN, 1)
local t2 = seed(S2, GRN, 2)
-- coat split where the stalk leaves the green seed
c:put(35, 42, GRN[1], t2) c:put(36, 42, STEM[3], stok) c:put(37, 42, GRN[1], t2) c:put(36, 43, GRN[1], t2)
-- one glint each
c:put(15, 44, TAN[6]) c:put(16, 44, TAN[6]) c:put(31, 43, GRN[6])

A.save(c, NAME)
