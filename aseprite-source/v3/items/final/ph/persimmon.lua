-- persimmon (C33 slot 2, Opus single pass). A squat Fuyu persimmon seen slightly from above: soft-square body with
-- four shallow vertical creases, per-pixel lit 6-tone orange skin, a wide flat top with a dusty waxy bloom, one hard
-- specular and a cool reflected light on the lower right. On top: a big four-lobed papery calyx (wavy, veined, edges
-- curling up, AO ring where it presses into the fruit) and a short woody stalk with a pale cut end.
-- quirk: a little bird peck on the shade side, glossy jelly-like flesh with one juice drip.
local NAME = "persimmon"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local norm = G.norm
local c = G.new3(NAME)

local OR = { "#7a2a24", "#b23e1e", "#dc5f1c", "#f38424", "#fcaa3c", "#ffd27a" }
local CAL = { "#2e2a1c", "#4a4426", "#6a6630", "#8a8a3c", "#acab52", "#d0cc7a" }
local WOOD = { "#3e2622", "#5e3a2a", "#86553a", "#b07a50", "#d8ac7c" }
local BLOOM, COOLR, SPEC = "#f2c6a0", "#c0605a", "#fff4d6"
local FLESH = { "#c2481e", "#ec7a2c", "#ffb05a", "#ffe0a4" }

-- body: soft superellipse, flatter on top, slight four-lobe waist
local CX, CY, RX, RYT, RYB = 32, 37, 21.5, 15, 17
local body, bn = HP.mask(), {}
for y = CY - RYT - 1, CY + RYB + 1 do for x = floor(CX - RX - 1), floor(CX + RX + 1) do
  local dx = x - CX + 0.5
  local dy = y - CY + 0.5
  local ry = dy < 0 and RYT or RYB
  local u, v = dx / (RX + 0.3), dy / (ry + 0.3)
  local p = 2.5
  local f = abs(u) ^ p + abs(v) ^ p
  -- four lobes: tiny inward dents at the crease lines seen in profile
  local lobe = 1 + 0.02 * cos(u * pi * 2.2)
  if f <= lobe then
    body:set(x, y)
    local gx = (u >= 0 and 1 or -1) * abs(u) ^ (p - 1) / RX
    local gy = (v >= 0 and 1 or -1) * abs(v) ^ (p - 1) / ry
    local nz = sqrt(max(0.02, 1 - f)) / 14
    -- crease ripple across x
    gx = gx + 0.012 * sin(u * pi * 2.6)
    bn[K(x, y)] = { norm(gx, gy * (dy < 0 and 1.6 or 1), nz) }
  end
end end

-- calyx: four broad wavy sepals in an X, slightly lifted at the tips
local CAX, CAY = 32, 23
local cal, cn, ci = HP.mask(), {}, {}
local seps = { -2.45, -0.7, 2.45, 0.7 }
for y = CAY - 12, CAY + 10 do for x = CAX - 16, CAX + 16 do
  local dx, dy = (x + 0.5 - CAX), (y + 0.5 - CAY) * 1.75   -- foreshortened (seen from a low angle)
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  local best, bi, bd = 0, 1, 0
  for i, sa in ipairs(seps) do
    local d = math.atan(sin(a - sa), cos(a - sa))
    local R = 13.5 * max(0, cos(min(pi / 2, abs(d) * 1.35))) ^ 0.8 + 0.6 * sin(r * 1.4 + i)
    if R > best then best, bi, bd = R, i, d end
  end
  if r <= best and r <= 14 then
    cal:set(x, y)
    local u = r / max(1, best)
    local sa = seps[bi]
    -- cupped sepal: fold along its midrib, tips curling up
    local fx, fy = -sin(sa) * (bd > 0 and 1 or -1) * 0.5, cos(sa) * (bd > 0 and 1 or -1) * 0.5
    local up = u > 0.7 and (u - 0.7) * 2.5 or 0
    cn[K(x, y)] = { norm(fx - cos(sa) * up, fy - sin(sa) * up - 0.25, 1) }
    ci[K(x, y)] = { r = r, R = best, d = bd, i = bi }
  end
end end
cal:add(c:ellipse(CAX, CAY, 4, 2))

-- quirk: bird peck on the lower right
local PX, PY = 45, 44
local peck = c:ellipse(PX, PY, 2, 2)

-- body paint
local bias = {}
X.ao(bias, body, cal, 1, -1) G.cast(bias, body, cal, 0, 2, -1) G.cast(bias, body, cal, 1, 1, -1)
local btok = { r = { name = "body" } }
local bidx = G.toneN(c, body, bn, OR, { bias = bias, tok = btok, amb = 0.12, wrap = 0.35, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
-- creases: two curved vertical lines one tone down, fading near the top
for _, cxo in ipairs{ -9, 9 } do
  for y = CY - 8, CY + RYB - 2 do
    local t = (y - (CY - 8)) / (RYB + 6)
    local x = floor(CX + cxo * (1 - 0.35 * t * t) + 0.5)
    local k = K(x, y)
    if body:has(x, y) and not cal:has(x, y) and bidx[k] then c:put(x, y, OR[max(1, bidx[k] - 1)], btok) end
  end
end
-- cool reflected light on the lower-right rim
local rim = X.rim(bn)
body:each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.55 and (bidx[k] or 1) <= 2 and not bias[k] then c:put(x, y, COOLR, btok) end end)
-- waxy bloom: dusty pale specks on the lit top shoulder
body:each(function(x, y) local k = K(x, y)
  if (bidx[k] or 1) >= 5 and not bias[k] and X.hash(x, y, 4) > 0.93 and not cal:grow(1):has(x, y) then c:put(x, y, BLOOM, btok) end end)
-- one hard specular (2x1 + a pixel) upper left
c:put(19, 30, SPEC, btok) c:put(20, 30, SPEC, btok) c:put(19, 31, OR[6], btok)

-- peck: dark rim, glossy flesh, drip
local ptok = { r = { name = "peck" } }
peck:each(function(x, y) c:put(x, y, FLESH[2], ptok) end)
peck:edge():each(function(x, y) c:put(x, y, (x + y < PX + PY) and OR[1] or FLESH[1], ptok) end)
c:put(PX - 1, PY - 1, FLESH[1], ptok) c:put(PX, PY, FLESH[3], ptok) c:put(PX - 1, PY, FLESH[3], ptok) c:put(PX, PY - 1, FLESH[4], ptok)
-- juice drip running down
for _, q in ipairs{ { 45, 47, FLESH[2] }, { 45, 48, FLESH[2] }, { 45, 49, FLESH[3] }, { 44, 49, FLESH[1] } } do c:put(q[1], q[2], q[3], ptok) end

-- calyx paint
local ctok = { r = { name = "calyx" } }
local cb = {}
local stalk = c:rect(31, 15, 33, 22)
X.ao(cb, cal, stalk, 1, -1)
local cidx = G.toneN(c, cal, cn, CAL, { tok = ctok, bias = cb, amb = 0.15, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
cal:each(function(x, y) local k = K(x, y) local f = ci[k]
  if not f then return end
  if abs(f.d) * f.r < 0.6 and f.r > 3 and f.r < f.R - 1 then c:put(x, y, CAL[6], ctok)            -- midrib
  elseif abs(f.d) * f.r > 1.4 and abs((f.r - abs(f.d) * f.r) % 4 - 2) < 0.4 and f.r < f.R - 1.5 then
    c:put(x, y, CAL[max(1, (cidx[k] or 3) - 1)], ctok) end                                         -- side veins
end)
-- curled sepal tips: a brown dried edge on the outer rim
cal:edge():each(function(x, y) local f = ci[K(x, y)]
  if f and f.r > f.R - 1.2 and f.r > 9 then c:put(x, y, (y < CAY) and WOOD[4] or WOOD[3], ctok) end end)

-- stalk: short woody stub, grain line, pale cut end
local stok = { r = { name = "stalk" } }
for y = 16, 22 do
  c:put(31, y, WOOD[4], stok) c:put(32, y, WOOD[3], stok) c:put(33, y, WOOD[2], stok)
  if y % 3 == 0 then c:put(32, y, WOOD[2], stok) end
end
c:put(31, 15, WOOD[5], stok) c:put(32, 15, WOOD[5], stok) c:put(33, 15, WOOD[4], stok)
c:put(31, 23, WOOD[1], stok) c:put(32, 23, WOOD[1], stok) c:put(33, 23, WOOD[1], stok)
G.done(c, NAME)
