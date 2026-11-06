-- fenugreek (B31, Opus single pass). A fenugreek sprig on the diagonal: slim jointed stem, three trifoliate leaves
-- (obovate leaflets with a lit midrib, toothed tips and a V-fold), and one long sickle pod with its beak, seed bumps
-- along it and a dark suture line, AO where the pod's stalk meets the stem.
-- quirk: the pod has split along its suture and two little amber seeds peek out of the gap.
local NAME = "fenugreek"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new(NAME)

local LEAF = { "#1d4434", "#2b6446", "#40854e", "#62a65a", "#92c86c", "#c6e590" }
local STEM = { "#2c5a40", "#4f8a50", "#7cb466", "#b2d88a" }
local POD = { "#4c3a26", "#7a6234", "#a68e46", "#c9b25c", "#e3d184", "#f6ecb6" }
local SEED = { "#5e3218", "#9a5a26", "#d2923a", "#f4cc72" }

-- main stem: lower-left to upper-right
local stem = { { 17, 52 }, { 22, 42 }, { 32, 26 }, { 42, 13 } }
local SM, SN, ST, SS = G.tube(stem, function(t) return 1.25 - 0.45 * t end)
G.shade(c, SM, SN, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.12, wrap = 0.3 })

-- trifoliate leaf: petiole from node to centre, three obovate leaflets
local LMall = HP.mask()
local function leaflet(x0, y0, ux, uy, L, W)
  local bx, by = x0 + ux * L, y0 + uy * L
  local m, n, T, S = G.blade(x0, y0, (x0 + bx) / 2 + uy * 0.4, (y0 + by) / 2 - ux * 0.4, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.3, W * (0.25 + 0.75 * sin(pi * 0.5 * min(1, t / 0.68)) ) * (t > 0.8 and sqrt(max(0, 1 - ((t - 0.8) / 0.2) ^ 2)) or 1))
  end, { fold = 0.35 })
  -- toothed tip: notch every other pixel along the far rim
  local cut = HP.mask()
  m:edge():each(function(x, y) local k = K(x, y) if T[k] > 0.72 and (x + y) % 3 == 0 then cut:set(x, y) end end)
  m:cut(cut)
  m:cut(LMall)
  local idx = G.shade(c, m, n, LEAF, { amb = 0.1, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if n[k] and abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end end)
  LMall:add(m)
  return m
end
local function trifol(nx, ny, cx, cy, L, W, spread)
  G.pline(c, { { nx, ny }, { cx, cy } }, STEM[3])
  local dx, dy = cx - nx, cy - ny local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
  for _, a in ipairs{ 0, -spread, spread } do
    local ux, uy = G.rot(dx, dy, a)
    leaflet(cx + ux * 0.6, cy + uy * 0.6, ux, uy, a == 0 and L or L - 1, a == 0 and W or W - 0.3)
  end
end
trifol(42, 13, 44, 11, 7.5, 3.0, 1.15)           -- terminal leaf
trifol(26, 36, 18, 31, 6.8, 2.8, 1.1)            -- left leaf
trifol(35, 22, 43, 23, 6.6, 2.7, 1.1)            -- right leaf
-- AO: stem pixels under leaflets
G.touch(SM, LMall):each(function(x, y) if not LMall:has(x, y) then c:put(x, y, STEM[1]) end end)
-- node bumps
for _, q in ipairs{ { 26, 36 }, { 35, 22 }, { 22, 43 } } do c:put(q[1], q[2], STEM[4]) end

-- pod: hangs from the lower node, sickle curve down-right ending in a long beak
local pp = { { 23, 44 }, { 33, 44 }, { 44, 46 }, { 52, 38 } }
local PM, PN, PT, PS = G.tube(pp, function(t)
  if t < 0.06 then return 0.7 end
  if t > 0.82 then return max(0.45, 2.2 * (1 - (t - 0.82) / 0.18)) end
  return min(2.3, 0.9 + (t - 0.06) * 14)
end, 160)
PM:cut(SM)
local pv = X.light(PN, { amb = 0.12, wrap = 0.3 })
local pbias = {}
PM:each(function(x, y) local k = K(x, y)
  local t = PT[k]
  if t > 0.15 and t < 0.8 then
    local ph = (t - 0.15) / 0.65 * 7
    local f = abs(ph - floor(ph) - 0.5) * 2   -- 1 at bump centre, 0 between seeds
    if f < 0.25 then pbias[k] = -1 end
  end
end)
local pidx = X.tone(c, PM, pv, POD, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = pbias })
-- suture: dark line along the upper (lit) edge, one in from the rim
PM:each(function(x, y) local k = K(x, y)
  if PT[k] > 0.12 and PT[k] < 0.85 and PS[k] < -0.35 and PS[k] > -0.62 then c:put(x, y, POD[max(1, pidx[k] - 2)]) end end)
-- waxy bloom flecks + one glint
for _, q in ipairs{ { 33, 43 }, { 37, 43 } } do if PM:has(q[1], q[2]) then c:put(q[1], q[2], POD[6]) end end
c:put(29, 43, "#fff4d6") c:put(30, 43, "#fff4d6")
-- quirk: split along the suture showing two amber seeds
local gap = HP.mask()
PM:each(function(x, y) local k = K(x, y) if PT[k] > 0.46 and PT[k] < 0.7 and PS[k] < 0.4 and PS[k] > -0.85 - 0.0 then
  local e = abs(PT[k] - 0.58) / 0.12  -- lens shape: narrower toward the ends
  if PS[k] < 0.4 - e * 0.9 then gap:set(x, y) end end end)
gap:each(function(x, y) c:put(x, y, POD[1]) end)
-- lit lip on the far edge of the split
gap:each(function(x, y) if PM:has(x + 1, y + 1) and not gap:has(x + 1, y + 1) then c:put(x + 1, y + 1, POD[5]) end end)
local sx, sy = G.bez(pp, 0.55) local tx, ty = G.bez(pp, 0.62)
for _, s in ipairs{ { floor(sx + .5), floor(sy - .5) }, { floor(tx + .5), floor(ty - .5) } } do
  for _, d in ipairs{ { 0, 0, 3 }, { -1, 0, 4 }, { 0, 1, 2 }, { -1, 1, 3 }, { 1, 0, 2 } } do
    local x, y = s[1] + d[1], s[2] + d[2]
    if gap:has(x, y) then c:put(x, y, SEED[d[3]]) end
  end
end
-- AO where pod stalk meets the stem
G.touch(PM, SM):each(function(x, y) c:put(x, y, POD[1]) end)
-- cool reflected light on the pod belly
PM:edge():each(function(x, y) local k = K(x, y) if PS[k] > 0.7 and PT[k] > 0.2 and PT[k] < 0.75 and not gap:has(x, y) then c:put(x, y, "#8a8a6a") end end)

G.save(c, NAME)
