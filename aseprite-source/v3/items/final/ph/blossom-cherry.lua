-- blossom-cherry (final, Opus single pass). A slim cherry sprig: red-brown bark with pale horizontal lenticels,
-- a side twig, four open five-petal blossoms (notched petal tips, cupped per-petal light, pink veins, crimson eye,
-- gold stamens), two closed buds and two young leaves. AO + contact shadow where blossoms sit on the wood.
-- quirk: one loose petal drifting off to the lower right.
local NAME = "blossom-cherry"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local BARK = { "#3a2026", "#552d2c", "#764032", "#975a3d", "#b87a52", "#d79e70" }
local PINK = { "#7a2850", "#a83e6a", "#d4628c", "#ef93b0", "#fbbcd0", "#ffe3ea" }
local BUD = { "#6e2038", "#a3304f", "#d24f72", "#f07c98", "#ffaec0" }
local LEAF = { "#24544a", "#2f7046", "#48924c", "#6fb45a", "#a2d374" }
local EYE, STAM, ANTH, ANTH2 = "#b8264f", "#e66a8e", "#f5b82e", "#ffe38a"

-- branch + twig
local bp = { { 13, 56 }, { 20, 45 }, { 32, 31 }, { 48, 15 } }
local bm, bn, BT, BS = A.tube(bp, function(t) return 2.3 - 1.35 * t end)
local tp = { { 31, 33 }, { 37, 33 }, { 42, 35 }, { 47, 38 } }
local tm, tn, TT, TS = A.tube(tp, function(t) return 1.35 - 0.55 * t end)
tm:cut(bm)

-- blossoms: cx, cy, rotation, scale
local fl = { { 19, 34, 0.3, 1.0 }, { 35, 21, -0.2, 1.05 }, { 50, 38, 0.9, 0.95 }, { 48, 14, 0.55, 0.85 } }
local fmasks = {}
for i, f in ipairs(fl) do
  local m = HP.mask()
  f.petals = {}
  for j = 0, 4 do
    local a = f[3] + j * 2 * pi / 5
    local ux, uy = cos(a), sin(a)
    local pm = A.rell(f[1] + ux * 3.3 * f[4], f[2] + uy * 3.3 * f[4], ux, uy, 3.4 * f[4], 2.75 * f[4])
    -- notch at the petal tip
    local tx, ty = floor(f[1] + ux * 6.2 * f[4] + 0.5), floor(f[2] + uy * 6.2 * f[4] + 0.5)
    pm.s[K(tx, ty)] = nil
    f.petals[#f.petals + 1] = { m = pm, ux = ux, uy = uy }
    m:add(pm)
  end
  fmasks[i] = m
end
-- AO + cast shadow on the wood from blossoms
local bb, tb = {}, {}
for _, m in ipairs(fmasks) do
  X.ao(bb, bm, m, 1, -1) A.cast(bb, bm, m, 1, 2, -1)
  X.ao(tb, tm, m, 1, -1) A.cast(tb, tm, m, 1, 2, -1)
end
X.ao(tb, tm, bm, 1, -1)
local btok, ttok = { r = { name = "bark" } }, { r = { name = "twig" } }
local bidx = A.shade(c, bm, bn, BARK, { bias = bb, tok = btok, amb = 0.1 })
local tidx = A.shade(c, tm, tn, BARK, { bias = tb, tok = ttok, amb = 0.1 })
-- lenticels: short pale dashes across the bark on the lit half
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  local ph = (t * 52) % 6.5
  if ph < 1 and s > -0.75 and s < 0.25 and t > 0.05 and t < 0.8 and not bb[k] then c:put(x, y, BARK[min(6, bidx[k] + 2)], btok) end
  if ph >= 1 and ph < 2 and s > -0.6 and s < 0.3 and t > 0.05 and t < 0.8 and not bb[k] then c:put(x, y, BARK[max(1, bidx[k] - 1)], btok) end
end)
-- snapped end of the branch at the base: pale end grain
c:put(12, 56, BARK[6], btok) c:put(13, 57, BARK[5], btok) c:put(14, 57, BARK[5], btok)

-- young leaves at the twig fork and below the top blossom
local ltok = { r = { name = "leaf" } }
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end return max(0.3, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.7) end, { fold = 0.45 })
  m:cut(bm):cut(tm)
  for _, fm in ipairs(fmasks) do m:cut(fm) end
  A.shade(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.4, 0.6, 0.8 } })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[5] or LEAF[2], ltok) end end)
  return m
end
local L1 = leaf(28, 37, 24, 44, 21, 50, 2.6)
local L2 = leaf(42, 20, 44, 25, 42, 28, 1.9)

-- buds on short stalks
local budtok = { r = { name = "bud" } }
local buds = { { 25, 47, 2.4, 1.7, -2.3, 22, 42 }, { 41, 11, 2.2, 1.6, -1.0, 44, 16 } }
local budm = HP.mask()
for _, b in ipairs(buds) do
  -- stalk
  local sx, sy = b[6], b[7]
  for i = 0, 6 do local f = i / 6 local x, y = floor(sx + (b[1] - sx) * f + 0.5), floor(sy + (b[2] - sy) * f + 0.5)
    if not bm:has(x, y) then c:put(x, y, i < 3 and LEAF[3] or LEAF[4], ltok) end end
  local m, n = A.oval(b[1], b[2], b[3], b[4], b[5], 0.8)
  local bidx2 = A.shade(c, m, n, BUD, { tok = budtok, cuts = { 0.2, 0.4, 0.6, 0.8 } })
  -- green calyx cup at the stalk end
  m:each(function(x, y) local dx, dy = x - b[1], y - b[2]
    local d = dx * cos(b[5]) + dy * sin(b[5])
    if d < -b[3] * 0.45 then c:put(x, y, d < -b[3] * 0.75 and LEAF[2] or LEAF[3], budtok) end end)
  budm:add(m)
end

-- blossoms
local painted = HP.mask():add(bm):add(tm):add(L1):add(L2):add(budm)
for i, f in ipairs(fl) do
  local ftok = { r = { name = "blossom" .. i } }
  local done = HP.mask()
  for j, p in ipairs(f.petals) do
    local m = p.m:copy():cut(done)
    -- cupped petal: normal tilts inward near the eye, rounded at the rim
    local n = {}
    m:each(function(x, y)
      local dx, dy = x - f[1], y - f[2]
      local r = sqrt(dx * dx + dy * dy) / (6.3 * f[4])
      local rr = max(0, min(1, r))
      local cup = -0.45 * (1 - rr) + 0.55 * rr ^ 3
      local q = dx * (-p.uy) + dy * p.ux             -- across-petal offset
      local qn = q / (2.9 * f[4])
      n[K(x, y)] = { A.norm(p.ux * cup + (-p.uy) * qn * 0.6, p.uy * cup + p.ux * qn * 0.6, 1) }
    end)
    local bias = {}
    if i == 3 then X.ao(bias, m, tm, 1, -1) end
    local idx = A.shade(c, m, n, PINK, { tok = ftok, cuts = { 0.12, 0.3, 0.5, 0.68, 0.86 }, amb = 0.25, wrap = 0.35, bias = bias })
    -- vein: centre line of the petal, one tone darker
    m:each(function(x, y) local dx, dy = x - f[1], y - f[2]
      local q = dx * (-p.uy) + dy * p.ux local a = dx * p.ux + dy * p.uy
      if abs(q) < 0.5 and a > 2.2 * f[4] and a < 5 * f[4] then A.step(c, idx, PINK, x, y, -1, ftok) end end)
    -- separation from earlier petals and from wood/leaves underneath
    if j > 1 then A.sep(c, m, done, PINK[2], ftok) end
    A.sep(c, m, painted, PINK[1], ftok)
    done:add(m)
  end
  -- eye: crimson star + stamens with gold anthers
  local cx, cy = f[1], f[2]
  for dx = -1, 1 do for dy = -1, 1 do if abs(dx) + abs(dy) < 2 then c:put(cx + dx, cy + dy, EYE, ftok) end end end
  for j = 0, 4 do
    local a = f[3] + pi / 5 + j * 2 * pi / 5
    local x1, y1 = floor(cx + cos(a) * 1.7 + 0.5), floor(cy + sin(a) * 1.7 + 0.5)
    local x2, y2 = floor(cx + cos(a) * 2.9 + 0.5), floor(cy + sin(a) * 2.9 + 0.5)
    c:put(x1, y1, STAM, ftok)
    c:put(x2, y2, (x2 - cx) + (y2 - cy) < 0 and ANTH2 or ANTH, ftok)
  end
  painted:add(done)
end
-- one sparkle-ish pop on the front blossom petal
c:put(31, 17, PINK[6], { r = { name = "pop" } }) c:put(32, 17, PINK[6], { r = { name = "pop" } })

-- quirk: a loose petal drifting away, lower right
local qtok = { r = { name = "drift" } }
local qm, qn = A.oval(51, 52, 2.6, 1.8, 0.7, 0.6)
qm.s[K(53, 54)] = nil
local qidx = A.shade(c, qm, qn, PINK, { tok = qtok, cuts = { 0.12, 0.3, 0.5, 0.68, 0.86 }, amb = 0.25, wrap = 0.35 })
c:put(52, 53, PINK[3], qtok)

A.save(c, NAME)
