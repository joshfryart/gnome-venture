-- kidney-bean (final, Opus single pass). A slim, curved fresh bean pod (yellow-green, magenta speckle streaks along
-- the fibres) split open along its seam: pale quilted lining with three glossy dark-red kidney beans nested in their
-- pockets (AO where they sit, a white hilum eye on each concave edge). A fourth, larger loose bean lies in front,
-- lower left, with one specular, a cool reflected rim and faint waxy bloom.
-- quirk: the pod's beak tip curls into a tiny pigtail tendril.
local NAME = "kidney-bean"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local POD   = { "#22403a", "#33613f", "#4f8844", "#78ad50", "#a5cc63", "#d6ea92" }
local LINE  = { "#55704c", "#8fae7c", "#c4dba6", "#ecf5d2" }
local BEAN  = { "#33111f", "#561a2c", "#7e2331", "#a8323a", "#cf5548", "#f08f72" }
local STREAK, STREAK2 = "#9c3a64", "#6e2a50"
local SPEC, COOL, HILUM, HILUM2 = "#fff0e6", "#6a5a8e", "#f4ecd8", "#c9b8a0"

-- ---------------------------------------------------------------- pod
local PP = { { 13, 20 }, { 25, 11 }, { 45, 22 }, { 50, 42 } }
local pm, pn, PT, PS = A.tube(PP, function(t)
  return 5.2 * sin(pi * (t * 0.9 + 0.05)) ^ 0.42
end)
local open = HP.mask()
pm:each(function(x, y) local k = K(x, y)
  if abs(PS[k]) < 0.55 and PT[k] > 0.1 and PT[k] < 0.9 then open:set(x, y) end end)
local wall = pm:copy():cut(open)
local ptok = { r = { name = "pod" } }
local pidx = A.shade(c, wall, pn, POD, { amb = 0.1, wrap = 0.3, tok = ptok })
-- fibre line along the outer wall + magenta speckle streaks (short dashes along the pod)
wall:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  if abs(s) > 0.66 and abs(s) < 0.8 and t > 0.08 and t < 0.92 then c:put(x, y, POD[max(1, pidx[k] - 1)], ptok) end
  local seg = floor(t * 26)
  if X.hash(seg, s > 0 and 1 or 0, 5) > 0.62 and abs(s) > 0.6 and (t * 26 - seg) < 0.55 then
    c:put(x, y, pidx[k] >= 4 and STREAK or STREAK2, ptok) end
end)
-- lining: quilted pockets (dips between beans), AO under the lit wall
local BT = { 0.3, 0.51, 0.72 }
local lbias = {}
local ltok = { r = { name = "lining" } }
open:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  local i = 3
  if s < -0.3 then i = 2 end            -- under the lit (upper-left) wall: shadowed
  if s > 0.35 then i = 4 end            -- far side faces the light
  for _, b in ipairs(BT) do if abs(t - (b + 0.105)) < 0.012 then i = i - 1 end end   -- pocket ridges
  c:put(x, y, LINE[max(1, i)], ltok)
end)

-- ---------------------------------------------------------------- beans
local function tan(t) local x2, y2 = A.bez(PP, min(1, t + 0.01)) local x1, y1 = A.bez(PP, max(0, t - 0.01)) return atan(y2 - y1, x2 - x1) end
-- kidney: oval minus a shallow dent on the +v side (concave edge)
local function bean(cx, cy, rx, ry, ang, dentSide)
  local m, n = A.oval(cx, cy, rx, ry, ang, 0.85)
  local ca, sa = cos(ang), sin(ang)
  local dx, dy = -sa * dentSide, ca * dentSide
  local dc = HP.mask()
  local r = ry * 0.95
  local ex, ey = cx + dx * (ry * 1.5), cy + dy * (ry * 1.5)
  for y = floor(cy - 10), floor(cy + 10) do for x = floor(cx - 10), floor(cx + 10) do
    if (x - ex)^2 + (y - ey)^2 <= r * r then dc:set(x, y) end end end
  m:cut(dc)
  return { m = m, n = n, cx = cx, cy = cy, ex = ex, ey = ey, dx = dx, dy = dy, ry = ry, ca = ca, sa = sa, rx = rx }
end
local function paintBean(b, tok, bias, glint)
  local idx = A.shade(c, b.m, b.n, BEAN, { amb = 0.0, wrap = 0.1, bias = bias, tok = tok, cuts = { 0.3, 0.5, 0.66, 0.8, 0.93 } })
  -- cool reflected light on the lower-right rim
  local rim = X.rim(b.n)
  b.m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and (idx[k] or 1) <= 3 and not (bias and bias[k]) then c:put(x, y, COOL, tok) end end)
  -- hilum: white eye at the middle of the dent (pixel of m closest to dent centre)
  local best, hx, hy
  b.m:each(function(x, y) local q = (x - b.ex)^2 + (y - b.ey)^2 if not best or q < best then best, hx, hy = q, x, y end end)
  c:put(hx, hy, HILUM, tok)
  local ux, uy = floor(b.ca + .5), floor(b.sa + .5)
  if b.m:has(hx + ux, hy + uy) then c:put(hx + ux, hy + uy, HILUM2, tok) end
  -- waxy bloom specks on the lit half
  b.m:copy():shrink(1):each(function(x, y) local k = K(x, y) if idx[k] == 5 and X.hash(x, y, 9) > 0.85 then c:put(x, y, BEAN[6], tok) end end)
  if glint then
    local sx, sy = A.specAt(b.m:copy():shrink(1), b.n, 30)
    c:put(sx, sy, SPEC, tok) if b.m:has(sx + 1, sy) then c:put(sx + 1, sy, BEAN[6], tok) end
  end
  return idx
end
local nest = {}
for i, t in ipairs(BT) do
  local x, y = A.bez(PP, t)
  local b = bean(x + 0.3, y + 0.2, 3.9, 2.8, tan(t), -1)
  b.m:clip(open:copy():grow(1))
  nest[i] = b
end
for i, b in ipairs(nest) do
  local bias = {}
  -- AO where the bean meets the pod wall
  b.m:each(function(x, y) local k = K(x, y) if PS[k] and abs(PS[k]) > 0.5 then bias[k] = -1 end end)
  paintBean(b, { r = { name = "bean" .. i } }, bias, i == 2)
end
-- contact shadow on the lining: lower-right of each nested bean
for _, b in ipairs(nest) do
  b.m:shift(1, 1):each(function(x, y) if open:has(x, y) and not b.m:has(x, y) then
    local ok = true for _, o in ipairs(nest) do if o.m:has(x, y) then ok = false end end
    if ok then c:put(x, y, LINE[1], ltok) end end end)
end
-- the near (lower-right) lip curls over the beans a touch: redraw wall pixels on top
wall:each(function(x, y) local k = K(x, y) if PS[k] > 0.6 and PT[k] > 0.12 and PT[k] < 0.88 then
  local touch = false for _, b in ipairs(nest) do if b.m:has(x - 1, y - 1) or b.m:has(x - 1, y) or b.m:has(x, y - 1) then touch = true end end
  if touch and pidx[k] and pidx[k] > 2 then c:put(x, y, POD[pidx[k] - 1], ptok) end end end)

-- stem end: short calyx stalk at t=0
local sm, sn = A.tube({ { 13, 20 }, { 10, 19 }, { 8, 17 }, { 7, 14 } }, function(t) return 1.3 - t * 0.4 end)
sm:cut(pm)
A.shade(c, sm, sn, { "#2c4a3a", "#3f6a44", "#5f9150", "#8ab968", "#b2d684" }, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = { r = { name = "stalk" } } })
for _, q in ipairs{ { 13, 17, 2 }, { 14, 18, 3 }, { 12, 23, 2 }, { 11, 22, 1 } } do c:put(q[1], q[2], POD[q[3]], ptok) end

-- quirk: beak curl at the tip
local tx, ty = A.bez(PP, 1)
local curl = { { 50, 42 }, { 51, 44 }, { 51, 46 }, { 52, 47 }, { 53, 47 }, { 54, 46 }, { 54, 45 }, { 53, 44 } }
for i, p in ipairs(curl) do c:put(p[1], p[2], i < 4 and POD[3] or (i < 6 and POD[2] or POD[4]), ptok) end

-- ---------------------------------------------------------------- loose bean (hero), lower left, in front
local hb = bean(20, 46, 7.2, 4.2, -0.32, -1)
local hbias = {}
paintBean(hb, { r = { name = "hero" } }, hbias, true)

A.save(c, NAME)
