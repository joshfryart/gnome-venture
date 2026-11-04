-- saffron (final D step, Sonnet high). Slim crocus in three-quarter view: a pale lilac-white tube out of a netted brown
-- corm opens into a tulip cup of six pointed violet tepals (three front, two back showing their pale inner faces, a short
-- lip petal), dark parallel veins converging on a warm gold throat, two flanking yellow anthers and three long crimson
-- stigma threads with flared trumpet tips; two arching grass leaves with a white stripe.
-- Material: per-pixel V-fold light on every petal (6-tone violet), glossy specular on the lip petal, veins, AO and
-- contact shadow where petals overlap and under the drooping thread, paper bracts at the stem foot, corm tunic netting.
-- quirk: the third stigma thread has curled itself into a little ring.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2("saffron")

local VIO  = { "#2b2158", "#45368a", "#6350b2", "#8570d0", "#a794e8", "#cdbff7" }
local INNER = { "#4b3b8e", "#6b57b6", "#8d79d4", "#ae9bec", "#cbbcf7", "#e8defb" }
local LEAF = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local STEM = { "#7d78a8", "#a6a1c8", "#cbc7e2", "#e8e5f3" }
local ANTH = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local THR  = { "#5e1428", "#a02530", "#d8402a", "#f26a38", "#ff9a58", "#ffc98a" }
local CORM = { "#34201f", "#5a382a", "#84552f", "#a87240", "#cc9c5e", "#ecc98e" }
local GLOW = { "#6e4a9c", "#b07fb8", "#e3b8b0", "#ffd98f", "#ffeaa8", "#fff6d8" }
local CUT = { 0.16, 0.32, 0.5, 0.68, 0.85 }
local tok = function(n) return { r = { name = n } } end

-- ---------- leaves (behind everything) ----------
local function leaf(ax, ay, cx, cy, bx, by, w, name, dark)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.45, w * sin(pi * min(1, 0.14 + t * 0.86) ^ 1.05) ^ 0.5)
  end, { fold = 0.5 })
  local tk = tok(name)
  local bias = {}
  if dark then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  G.toneN(c, m, n, LEAF, { bias = bias, tok = tk, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.2 and t > 0.04 and t < 0.94 then c:put(x, y, s <= 0 and "#e6f2c8" or "#a9cf8a", tk) end
  end)
  return m
end
local leafBack = leaf(31, 56, 24, 50, 20, 37, 1.5, "leafB", true)
local leafL = leaf(30, 56, 14, 54, 9, 31, 2.0, "leafL")
local leafR = leaf(34, 56, 52, 54, 55, 33, 2.0, "leafR")

-- ---------- stem tube + paper bracts ----------
local sm, sn, ST = G.tube({ { 32, 53 }, { 32, 48 }, { 32, 43 }, { 32, 36 } }, function(t) return 1.5 - 0.2 * t end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = tok("stem") })
local function bract(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end return max(0.4, 1.7 * sin(pi * min(1, 0.2 + t * 0.8)) ^ 0.6)
  end, { fold = 0.4 })
  G.toneN(c, m, n, { "#9d98c0", "#c4c0dc", "#e2dfee", "#f6f4fa" }, { tok = tok("bract"), cuts = { 0.3, 0.55, 0.8 }, amb = 0.2, wrap = 0.3 })
  return m
end
bract(31, 54, 27, 49, 26, 44)
bract(33, 54, 37, 49, 38, 45)

-- ---------- corm ----------
do
  local m = c:ellipse(32, 55, 6.4, 3.7)
  local n = X.pillow(m, 4)
  local v = X.light(n, { amb = 0.08, wrap = 0.25 })
  local bias = {}
  m:each(function(x, y)
    local d = (x + y) % 4 == 0 or (x - y) % 4 == 0
    if d and G.h(x, y, 3) > 0.12 then bias[K(x, y)] = -1 end
  end)
  X.tone(c, m, v, CORM, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = bias, tok = tok("corm") })
  -- papery neck fringe at the top, pale
  for _, p in ipairs{ { 28, 52, 5 }, { 29, 51, 4 }, { 35, 52, 4 }, { 36, 52, 3 }, { 31, 51, 5 }, { 34, 51, 5 } } do c:px(p[1], p[2], CORM[p[3]]) end
  -- root fibres
  for _, p in ipairs{ { 28, 59, 3 }, { 29, 60, 2 }, { 32, 59, 3 }, { 32, 60, 2 }, { 36, 59, 3 }, { 37, 60, 2 } } do c:px(p[1], p[2], CORM[p[3]]) end
end

-- ---------- petals ----------
local function petal(ax, ay, cx, cy, bx, by, w, fold)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, 0.1 + t * 0.9)) ^ 0.62)
  end, { fold = fold or 0.45 })
  return { m = m, n = n, T = T, S = S }
end
local bl = petal(32, 37, 21, 24, 24, 8, 5.2)
local br = petal(32, 37, 43, 24, 40, 8, 5.2)
local fl = petal(31, 40, 14, 34, 18, 13, 6.2)
local fr = petal(33, 40, 50, 34, 46, 13, 6.2)
local lip = petal(32, 40, 32, 32, 32, 21, 5.4, 0.35)

local function paintPetal(p, ramp, bias, name, veins)
  local tk = tok(name)
  G.toneN(c, p.m, p.n, ramp, { bias = bias, tok = tk, cuts = CUT, amb = 0.12, wrap = 0.3 })
  if veins then
    p.m:each(function(x, y) local k = K(x, y) local s, t = p.S[k], p.T[k]
      if bias[k] and bias[k] < 0 then return end
      if t > 0.1 and t < 0.9 then
        for _, sv in ipairs{ -0.52, 0.0, 0.52 } do
          if abs(s - sv) < 0.085 then c:put(x, y, s < 0 and ramp[2] or ramp[1], tk) end
        end
      end
    end)
  end
end
-- back petals: inner (pale) faces; AO from the front petals + cast shadow
local back = HP.mask() back:add(bl.m):add(br.m)
local front = HP.mask() front:add(fl.m):add(fr.m):add(lip.m)
local bb = {}
X.ao(bb, back, front, 1, -1)
G.cast(bb, back, front, 0, -1, -1)
paintPetal(bl, INNER, bb, "backL", true)
paintPetal(br, INNER, bb, "backR", true)
-- throat glow
do
  local gm = c:ellipse(32, 30, 4.2, 5.4)
  gm:cut(front)
  local gn = X.sphere(32, 30, 5, gm)
  X.tone(c, gm, X.light(gn, { amb = 0.3, wrap = 0.5 }), GLOW, { cuts = { 0.4, 0.55, 0.7, 0.82, 0.92 }, tok = tok("glow") })
end

-- anthers: two flanking lances
local function anther(ax, ay, bx, by)
  local m, n, T, S = G.tube({ { ax, ay }, { ax, ay - 2 }, { bx, by + 2 }, { bx, by } }, function(t) return 1.15 - 0.45 * t end)
  X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), ANTH, { cuts = { 0.3, 0.55, 0.8 }, tok = tok("anther") })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, ANTH[1], tok("anther")) end end)
  return m
end
local an1 = anther(28, 33, 27, 22)
local an2 = anther(36, 33, 37, 22)

-- stigma threads (painted before the front petals, droop parts re-painted after)
local threads = {}
local function thread(p, w0)
  local m, n, T, S = G.tube(p, function(t) return w0 + 1.0 * max(0, (t - 0.8) / 0.2) end)
  local idx = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.3 }), THR, { cuts = { 0.22, 0.4, 0.58, 0.74, 0.9 }, tok = tok("thread") })
  threads[#threads + 1] = { m = m, T = T, idx = idx }
  return m
end
thread({ { 33, 28 }, { 33, 11 }, { 47, 8 }, { 50, 24 } }, 0.55)
thread({ { 31, 28 }, { 31, 12 }, { 17, 9 }, { 14, 24 } }, 0.55)
thread({ { 32, 28 }, { 32, 8 }, { 22, 12 }, { 27, 18 } }, 0.55)  -- curls into a ring (quirk)

-- front petals (cover the thread bases), lip first as it sits in front
local fb = {}
G.cast(fb, fl.m, lip.m, 1, 0, -1) G.cast(fb, fr.m, lip.m, -1, 0, -1)
X.ao(fb, fl.m, lip.m, 1, -1) X.ao(fb, fr.m, lip.m, 1, -1)
fl.m:cut(lip.m) fr.m:cut(lip.m)
paintPetal(fl, VIO, fb, "frontL", true)
paintPetal(fr, VIO, fb, "frontR", true)
local lb = {}
paintPetal(lip, VIO, lb, "lip", true)
-- cool reflected edge on the lower-right rims
for _, p in ipairs{ fr, lip } do
  local rim = X.rim(p.n)
  p.m:edge():each(function(x, y) if rim[K(x, y)] > 0.55 and y > 26 then c:px(x, y, "#7a82e0") end end)
end
-- thread drooping parts over the petals: contact shadow then the thread itself
local petalsAll = HP.mask() petalsAll:add(fl.m):add(fr.m):add(lip.m):add(bl.m):add(br.m)
for _, th in ipairs(threads) do
  th.m:shift(1, 1):each(function(x, y)
    if petalsAll:has(x, y) and not th.m:has(x, y) then c:put(x, y, VIO[1], tok("shadow")) end
  end)
end
for _, th in ipairs(threads) do
  th.m:each(function(x, y) local k = K(x, y)
    if th.T[k] > 0.5 and th.idx[k] then c:put(x, y, THR[th.idx[k]], tok("thread")) end
  end)
  -- bright trumpet lip
end
-- glossy specular on the lip petal + one on the left front petal
c:px(30, 28, "#fff4d6") c:px(31, 28, "#fff4d6") c:px(30, 29, VIO[6])
c:px(17, 24, VIO[6]) c:px(17, 25, VIO[6])
-- stem foot shadow where bracts meet corm
for _, p in ipairs{ { 30, 52 }, { 31, 52 }, { 33, 52 }, { 34, 52 } } do c:px(p[1], p[2], CORM[2]) end

G.save2(c, "saffron")
