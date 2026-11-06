-- meadowsweet (final pass, Opus, replaces Sonnet draft). A slim cut sprig: one red-purple stem (6-tone, lit
-- per pixel, node rings) forking into three thin pedicels, each carrying a frothy cyme of tiny cream florets.
-- Florets are lit twice (cluster dome + own tiny dome), so the froth reads as bumps over deep shaded gaps; a few
-- pink-tinged buds on the rims and butter-yellow stamen specks on the lit florets. Below, a pinnate leaf: serrated
-- leaflets with midribs, a big three-lobed end leaflet and tiny leaflets between the pairs; AO where the stalks join.
-- quirk: one floret has come loose and drifts off to the right.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "meadowsweet"
local c = A.new(NAME)

local STEM = { "#3e1a28", "#5f2433", "#84323d", "#a8474a", "#c8665c", "#e08c78" }
local CRM  = { "#6a5258", "#998276", "#c3b092", "#e0d3b0", "#f2e9cc", "#fffae8" }
local LEAF = { "#163a35", "#1f553f", "#2b7246", "#42904c", "#68ae56", "#9acb6c" }
local STAMEN, BUD = "#f2d27a", "#efc9c0"
local stok, ltok, ftok = { r = { name = "stem" } }, { r = { name = "leaf" } }, { r = { name = "floret" } }

-- leaves first (behind the stem)
local function leaflet(x0, y0, ux, uy, L, W, tok, lobed)
  local m = A.rell(x0 + ux * L / 2, y0 + uy * L / 2, ux, uy, L / 2, W)
  if lobed then
    local px, py = -uy, ux
    m:add(A.rell(x0 + ux * L * 0.45 + px * W * 0.9, y0 + uy * L * 0.45 + py * W * 0.9, ux, uy, L * 0.28, W * 0.55))
    m:add(A.rell(x0 + ux * L * 0.45 - px * W * 0.9, y0 + uy * L * 0.45 - py * W * 0.9, ux, uy, L * 0.28, W * 0.55))
  end
  -- serrate: nibble every third edge pixel
  local nib = {}
  m:edge():each(function(x, y) if (x * 2 + y) % 3 == 0 then nib[#nib + 1] = { x, y } end end)
  for _, p in ipairs(nib) do m.s[K(p[1], p[2])] = nil end
  local n = X.pillow(m, 1.6)
  A.shade(c, m, n, LEAF, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.3 })
  -- midrib
  for i = 1, floor(L * 0.85) do
    local x, y = floor(x0 + ux * i + 0.5), floor(y0 + uy * i + 0.5)
    if m:has(x, y) then c:put(x, y, i < L * 0.5 and LEAF[5] or LEAF[4], tok) end
  end
  return m
end
local leafM = HP.mask()
local function pinnate(ax, ay, bx, by, size)
  local dx, dy = bx - ax, by - ay
  local L = sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local px, py = -uy, ux
  -- pairs
  for i, t in ipairs{ 0.32, 0.64 } do
    local x, y = ax + dx * t, ay + dy * t
    for _, sd in ipairs{ -1, 1 } do
      local vx, vy = A.rot(ux, uy, sd * 0.95)
      leafM:add(leaflet(x, y, vx, vy, 6.5 * size, 2.0 * size, ltok))
    end
    -- tiny interstitial leaflets
    local tx, ty = ax + dx * (t - 0.14), ay + dy * (t - 0.14)
    for _, sd in ipairs{ -1, 1 } do
      local qx, qy = floor(tx + px * sd * 1.6 + 0.5), floor(ty + py * sd * 1.6 + 0.5)
      c:put(qx, qy, LEAF[4], ltok) leafM:set(qx, qy)
    end
  end
  leafM:add(leaflet(bx - ux, by - uy, ux, uy, 7.5 * size, 2.3 * size, ltok, true))
  -- rachis
  local rm, rn = A.tube({ { ax, ay }, { ax + dx * 0.33, ay + dy * 0.33 }, { ax + dx * 0.66, ay + dy * 0.66 }, { bx, by } }, function() return 0.6 end)
  A.shade(c, rm, rn, { STEM[3], STEM[4], STEM[5] }, { tok = stok, cuts = { 0.4, 0.7 } })
  leafM:add(rm)
end
pinnate(30, 45, 13, 39, 1.0)
pinnate(32, 50, 45, 45, 0.8)

-- main stem + three pedicels
local stemM = HP.mask()
local function stalk(p, w0, w1)
  local m, n, T = A.tube(p, function(t) return w0 + (w1 - w0) * t end)
  local bias = {}
  local idx = A.shade(c, m, n, STEM, { tok = stok, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 }, bias = bias })
  stemM:add(m)
  return m, T, idx
end
local sm, ST, sidx = stalk({ { 31, 55 }, { 30, 47 }, { 32, 38 }, { 31, 29 } }, 1.5, 1.15)
-- node rings (darker band) on the main stem
sm:each(function(x, y) if y == 44 or y == 50 then c:put(x, y, STEM[max(1, (sidx[K(x, y)] or 3) - 2)], stok) end end)
-- cut end at the bottom: pale pith
c:put(30, 55, STEM[6], stok) c:put(31, 55, STEM[5], stok)
stalk({ { 31, 31 }, { 27, 27 }, { 23, 24 }, { 20, 20 } }, 0.85, 0.6)
stalk({ { 31, 31 }, { 32, 26 }, { 32, 21 }, { 32, 15 } }, 0.85, 0.6)
stalk({ { 31, 31 }, { 36, 28 }, { 40, 25 }, { 43, 21 } }, 0.85, 0.6)
-- AO where the leaves meet the stem
stemM:grow(1):each(function(x, y) if leafM:has(x, y) and not stemM:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- florets: cymes of tiny domes over a shaded bed
local function cyme(ccx, ccy, crx, cry, seed)
  local bed = A.ell(ccx, ccy, crx - 1, cry - 1)
  local cn = A.ellN(ccx, ccy, crx, cry, bed, 0.9)
  local cv = X.light(cn, { amb = 0.05, wrap = 0.2 })
  bed:each(function(x, y) local val = cv[K(x, y)] c:put(x, y, val > 0.55 and CRM[3] or CRM[2], ftok) end)
  -- jittered floret centres
  local fl = {}
  for j = -4, 4 do for i = -5, 5 do
    local fx = ccx + i * 2.6 + (j % 2) * 1.3 + (X.hash(i, j, seed) - 0.5) * 1.2
    local fy = ccy + j * 2.3 + (X.hash(i, j, seed + 5) - 0.5) * 1.0
    local a, b = (fx - ccx) / crx, (fy - ccy) / cry
    if a * a + b * b <= 1.0 then fl[#fl + 1] = { fx, fy, X.hash(i, j, seed + 11) } end
  end end
  table.sort(fl, function(p, q) return p[2] < q[2] end)
  local L = X.L
  for _, f in ipairs(fl) do
    local fx, fy = floor(f[1] + 0.5), floor(f[2] + 0.5)
    local a, b = (fx - ccx) / (crx + 0.5), (fy - ccy) / (cry + 0.5)
    local q = max(0.05, 1 - a * a - b * b)
    local base = max(0, a * L[1] + b * L[2] + sqrt(q) * L[3])
    local rim = (a * a + b * b) > 0.6
    for _, o in ipairs{ { 0, 0, 0.2 }, { -1, 0, 0.12 }, { 1, 0, -0.12 }, { 0, -1, 0.15 }, { 0, 1, -0.18 } } do
      local val = base * 0.75 + 0.18 + o[3]
      local i = 1
      for jj, t in ipairs{ 0.25, 0.42, 0.58, 0.72, 0.86 } do if val >= t then i = jj + 1 end end
      local col = CRM[max(1, min(6, i))]
      if rim and f[3] > 0.72 and o[1] == 0 and o[2] == 0 then col = BUD end
      c:put(fx + o[1], fy + o[2], col, ftok)
    end
    if base > 0.7 and f[3] < 0.3 then c:put(fx, fy, STAMEN, ftok) end
  end
end
cyme(19, 17, 6.5, 4.6, 1)
cyme(32, 12, 7.0, 5.2, 2)
cyme(44, 18, 6.2, 4.4, 3)

-- quirk: a loose floret drifting away
c:put(51, 28, CRM[6], ftok) c:put(52, 28, CRM[5], ftok) c:put(51, 29, CRM[4], ftok) c:put(52, 29, STAMEN, ftok)
c:put(53, 30, CRM[3], ftok)

A.save(c, NAME)
