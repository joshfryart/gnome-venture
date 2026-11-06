-- nav-arranging (final, Opus single pass). A slim glazed bud vase (teal glaze: rounded belly, narrow neck, flared lip
-- with a dark mouth, specular streak, cool reflected rim, a pale painted band, unglazed foot ring) holding a small
-- arrangement at three heights: a tall pink cosmos, a red tulip cup, a low blue five-petal flower, and two veined leaves.
-- Ground shadow under the vase.
-- quirk: one pink cosmos petal has dropped and lies by the foot of the vase.
local NAME = "nav-arranging"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local SEA = { "#1f3560", "#285384", "#357ba6", "#4fa4bf", "#86d0d2", "#cff1e8" }
local CLAY = { "#6a4636", "#9a6c50", "#c49672", "#e2be94" }
local STEM = { "#24544a", "#2f7350", "#4b9a56", "#7cc35a", "#b2dc84" }
local LEAF = { "#1d4a40", "#27644a", "#3a8650", "#5aa85a", "#8ccb6c", "#c4e690" }
local PET = { "#6c2350", "#a3386d", "#d0598c", "#ef7f9e", "#ffacc2", "#ffd6e0" }
local TUL = { "#6b1f36", "#a22a3a", "#d23e3a", "#ee6440", "#fb9858", "#ffc888" }
local BLU = { "#2b2a6a", "#3f4296", "#5a62c4", "#7d8ce0", "#aab8f2", "#d6e0ff" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(32, 56, 10, 1)

---------------------------------------------------------------- stems (behind everything)
local stok = A.tok("stems")
local function stem(p, w)
  local m, n = A.tube(p, function(t) return w end)
  A.shade(c, m, n, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.22, 0.42, 0.62, 0.82 } })
  return m
end
local st1 = stem({ { 31, 36 }, { 30, 27 }, { 26, 21 }, { 25, 15 } }, 0.8)
local st2 = stem({ { 33, 36 }, { 35, 29 }, { 41, 27 }, { 42, 22 } }, 0.8)
local st3 = stem({ { 30, 37 }, { 27, 33 }, { 22, 31 }, { 18, 30 } }, 0.7)

---------------------------------------------------------------- leaves
local function leaf(ax, ay, cx, cy, bx, by, W, name)
  local tok = A.tok(name)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end return max(0.4, W * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7) end, { fold = 0.4 })
  A.clean(m)
  A.toneN(c, m, n, LEAF, { tok = tok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.05 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[2], tok) end end)
  return m
end
leaf(34, 36, 42, 38, 49, 32, 2.6, "leafR")
leaf(29, 26, 31, 21, 35, 18, 1.9, "leafL")

---------------------------------------------------------------- vase
local VX = 32
local function hw(y)
  if y <= 34 then return 4.2 end                     -- lip
  if y <= 40 then return 2.4 + (y - 35) * 0.08 end   -- neck
  if y <= 45 then local t = (y - 40) / 5 return 2.8 + 4.6 * sin(t * pi / 2) end  -- shoulder
  if y <= 51 then return 7.4 + 0.2 * sin((y - 45) / 6 * pi) end                  -- belly
  local t = (y - 51) / 4 return 7.4 - 2.2 * t * t - 0.4 * t                       -- base
end
local vm, vn = HP.mask(), {}
for y = 33, 55 do
  local w = hw(y)
  local dw = (hw(y + 1) - hw(y - 1)) / 2
  for x = floor(VX - w + 0.5), floor(VX + w + 0.5) do
    local s = (x - VX) / (w + 0.6)
    if abs(s) <= 1 then
      vm:set(x, y)
      s = max(-0.96, min(0.96, s))
      local nz = sqrt(1 - s * s)
      vn[K(x, y)] = { A.norm(s, -dw * nz * 0.8, nz) }
    end
  end
end
local vtok = A.tok("vase")
local vb = {}
for y = 33, 55 do for x = 20, 44 do local k = K(x, y)
  if vm:has(x, y) then
    if y == 35 then vb[k] = -2 end                     -- shadow under the lip
    if y == 36 then vb[k] = -1 end
    if y >= 54 then vb[k] = (vb[k] or 0) end
  end end end
local vidx = A.shade(c, vm, vn, SEA, { tok = vtok, bias = vb, amb = 0.12, wrap = 0.3, cuts = { 0.12, 0.28, 0.45, 0.62, 0.8 } })
-- mouth: dark opening at the top of the lip
for x = VX - 3, VX + 3 do c:put(x, 33, x < VX + 2 and SEA[1] or SEA[2], vtok) end
c:put(VX - 4, 33, SEA[5], vtok) c:put(VX + 4, 33, SEA[3], vtok)
-- stems enter the mouth: ambient dark where they meet
for _, p in ipairs{ { 31, 33 }, { 33, 33 }, { 30, 33 } } do c:put(p[1], p[2], "#16244a", vtok) end
-- unglazed foot ring
for x = VX - 6, VX + 6 do if vm:has(x, 55) then c:put(x, 55, CLAY[x < VX - 1 and 3 or (x < VX + 3 and 2 or 1)], vtok) end end
-- painted cream band with dots on the belly
for x = VX - 7, VX + 7 do if vm:has(x, 47) then
  local i = vidx[K(x, 47)] or 3
  c:put(x, 47, i >= 4 and "#f6ecc8" or (i >= 2 and "#c8c2b0" or "#8a8aa0"), vtok)
  if (x - VX) % 3 == 0 and vm:has(x, 49) then c:put(x, 49, i >= 4 and "#f6ecc8" or "#a8a6a8", vtok) end
end end
-- specular streak + cool reflected rim
for _, p in ipairs{ { 28, 43 }, { 27, 44 }, { 27, 45 }, { 27, 46 }, { 27, 48 }, { 27, 50 }, { 28, 51 } } do c:put(p[1], p[2], SEA[6], vtok) end
c:put(30, 37, SEA[6], vtok)
for y = 44, 52 do local w = hw(y) local x = floor(VX + w + 0.5) if vm:has(x, y) then c:put(x - 1, y, SEA[3], vtok) end end

---------------------------------------------------------------- flowers
-- pink cosmos: 8 petals with seams, gold disc
do local tok = A.tok("cosmos")
  local cx, cy = 25, 13
  local m = HP.mask()
  for i = 0, 7 do local a = i * pi / 4 + 0.2
    m:add(A.rell(cx + cos(a) * 3.6, cy + sin(a) * 3.3, cos(a), sin(a), 3.0, 1.75)) end
  local n = X.pillow(m, 2.2, 0.9)
  local idx = A.shade(c, m, n, PET, { tok = tok, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local a = atan(y - cy, x - cx) - 0.2
    local f = (a / (pi / 4)) f = abs(f - floor(f) - 0.5)
    local r = sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
    if f > 0.4 and r > 2 then c:put(x, y, PET[max(1, (idx[k] or 3) - 2)], tok)        -- seam between petals
    elseif f < 0.08 and r > 2.5 and r < 5 and (idx[k] or 3) >= 3 then c:put(x, y, PET[min(6, idx[k] + 1)], tok) end -- petal vein
  end)
  local d = HP.ellipse(cx, cy, 1.6, 1.6)
  d:each(function(x, y) local i = (x + y < cx + cy) and 4 or ((x + y == cx + cy) and 3 or 2) c:put(x, y, GOLD[i], tok) end)
  d:grow(1):cut(d):each(function(x, y) if (x - cx) + (y - cy) > 0 then c:put(x, y, PET[1], tok) end end)
end
-- red tulip: three cupped petals
do local tok = A.tok("tulip")
  local parts = { { 41, 18, 2.3, 4.1, -0.25 }, { 45, 18, 2.3, 4.1, 0.25 }, { 43, 17, 2.5, 4.6, 0 } }
  local all = HP.mask()
  for _, p in ipairs(parts) do p.m = A.rell(p[1], p[2], -sin(p[5]), cos(p[5]), p[4], p[3]) all:add(p.m) end
  -- flat-ish base of the cup
  all:cut(HP.rect(38, 22, 48, 26)):add(HP.ellipse(43, 20.5, 3.2, 1.4))
  local n = X.sphere(43, 18, 5.5, all)
  local np = X.pillow(all, 2)
  for k, a in pairs(n) do local b = np[k] n[k] = { A.norm(a[1] + b[1] * 0.5, a[2] + b[2] * 0.5, a[3] + b[3] * 0.5) } end
  local idx = A.shade(c, all, n, TUL, { tok = tok, amb = 0.12, wrap = 0.3 })
  -- centre petal overlaps the side ones: seam lines
  parts[3].m:copy():grow(1):cut(parts[3].m):clip(all):each(function(x, y)
    if y < 21 then c:put(x, y, TUL[max(1, (idx[K(x, y)] or 3) - 2)], tok) end end)
  c:put(42, 14, TUL[6], tok) c:put(42, 15, TUL[6], tok)                      -- gloss
end
-- blue five-petal flower, low left
do local tok = A.tok("blue")
  local cx, cy = 16, 29
  local m = HP.mask()
  for i = 0, 4 do local a = i * 2 * pi / 5 - pi / 2
    m:add(A.rell(cx + cos(a) * 2.6, cy + sin(a) * 2.6, cos(a), sin(a), 2.1, 1.7)) end
  local n = X.pillow(m, 1.8)
  local idx = A.shade(c, m, n, BLU, { tok = tok, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local a = atan(y - cy, x - cx) + pi / 2
    local f = (a / (2 * pi / 5)) f = abs(f - floor(f) - 0.5)
    if f > 0.4 and (x - cx) ^ 2 + (y - cy) ^ 2 > 2.5 then c:put(x, y, BLU[max(1, (idx[k] or 3) - 2)], tok) end
  end)
  c:put(cx, cy, GOLD[3], tok) c:put(cx - 1, cy, GOLD[4], tok) c:put(cx, cy + 1, GOLD[2], tok)
end

---------------------------------------------------------------- quirk: a fallen cosmos petal by the foot
do local tok = A.tok("petal")
  for _, p in ipairs{ { 43, 55, 4 }, { 44, 55, 5 }, { 45, 55, 4 }, { 44, 54, 6 }, { 45, 54, 5 }, { 46, 55, 3 }, { 44, 56, 2 }, { 45, 56, 2 } } do
    c:put(p[1], p[2], PET[p[3]], tok) end
end

A.save(c, NAME)
