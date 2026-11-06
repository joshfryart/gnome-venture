-- candied-ginger (final, Opus single pass, replaces the Sonnet draft). Three thin, knobbly coins of crystallised ginger
-- fanned on the diagonal: each is a translucent amber slab with a visible 2 px cut side (darker, fibre streaks), a
-- per-pixel lit top face, the pale cortex ring and radial fibres of a real ginger slice, a crisp lit rim, sugar
-- crystals (cream with a cool shade pixel) sitting on top, and contact shadow where a coin rests on the one below.
-- quirk: someone already took a bite out of the right-hand coin (the bite edge shows the fibrous inside).
local NAME = "candied-ginger"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)

local GIN  = { "#6a2f1c", "#9a5424", "#c8832e", "#e4a83e", "#f4cb66", "#fde6a0" }
local SIDE = { "#4e2018", "#743a1c", "#9a5a26", "#b8762e" }
local SUG, SUGS = "#fff4d6", "#d9cbb8"
local SPEC = "#fffbe8"

local function shape(cx, cy, rx, ry, ang, seed)
  local m = HP.mask()
  local ca, sa = cos(ang), sin(ang)
  local R = max(rx, ry) + 3
  local U, V = {}, {}
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / rx
    local v = (-dx * sa + dy * ca) / ry
    local a = atan(v, u)
    local wob = 1 + 0.07 * sin(a * 5 + seed) + 0.05 * sin(a * 3 - seed * 2)
    local r = sqrt(u * u + v * v) / wob
    if r <= 1 then m:set(x, y) U[K(x, y)] = r V[K(x, y)] = a end
  end end
  return m, U, V
end

local coins = {
  { cx = 22, cy = 23, rx = 13, ry = 8, ang = -0.42, seed = 1.3 },
  { cx = 42, cy = 30, rx = 12, ry = 7.5, ang = 0.32, seed = 2.9, bite = true },
  { cx = 27, cy = 41, rx = 14, ry = 8, ang = -0.12, seed = 4.4 },
}
for _, q in ipairs(coins) do
  q.top, q.R, q.A = shape(q.cx, q.cy, q.rx, q.ry, q.ang, q.seed)
  if q.bite then
    local ex, ey = q.cx + q.rx * 0.95 * cos(q.ang), q.cy + q.rx * 0.95 * sin(q.ang)
    local b = c:ellipse(floor(ex), floor(ey - 2), 3, 3):add(c:ellipse(floor(ex - 1), floor(ey + 3), 3, 2.5))
    q.top:cut(b) q.bitem = b
  end
  q.side = q.top:shift(0, 2):cut(q.top)
  q.side:add(q.top:shift(0, 1):cut(q.top))
  q.all = q.top:copy():add(q.side)
end

local painted = {}
for i, q in ipairs(coins) do
  -- contact shadow on the coins already painted: this coin's footprint shifted down-right
  local shadow = q.all:shift(1, 2):add(q.all:shift(2, 3))
  for _, p in ipairs(painted) do
    shadow:each(function(x, y) if p.top:has(x, y) and not q.all:has(x, y) and p.idx[K(x, y)] then
      A.step(c, p.idx, GIN, x, y, -2, p.tok) end end)
  end
  local tok = { r = { name = "coin" .. i } }
  -- cut side: 2 px band, fibre streaks
  q.side:each(function(x, y)
    local below = q.top:has(x, y - 2) and 2 or 1
    local lx = (x - q.cx)
    local col = lx < -q.rx * 0.5 and SIDE[3] or (lx > q.rx * 0.45 and SIDE[1] or SIDE[2])
    if below == 1 and lx < q.rx * 0.3 then col = SIDE[min(4, (lx < -q.rx * 0.5 and 4 or 3))] end
    if X.hash(x, i, 3) > 0.78 then col = SIDE[1] end
    c:put(x, y, col, tok)
  end)
  -- top face: shallow pillow + slight dome so the slab reads round-edged
  local n = X.pillow(q.top, 2.2)
  local ns = X.sphere(q.cx, q.cy, max(q.rx, q.ry) * 1.6, q.top)
  for k, a in pairs(n) do local b = ns[k] n[k] = { A.norm(a[1] * 0.7 + b[1] * 0.3, a[2] * 0.7 + b[2] * 0.3, a[3] * 0.7 + b[3] * 0.3) } end
  local idx = A.shade(c, q.top, n, GIN, { amb = 0.16, wrap = 0.3, cuts = { 0.24, 0.4, 0.56, 0.72, 0.88 }, tok = tok })
  q.idx, q.tok = idx, tok
  -- cortex ring + radial fibres
  q.top:each(function(x, y) local k = K(x, y)
    local r, a = q.R[k], q.A[k]
    if not r then return end
    if r > 0.58 and r < 0.72 then A.step(c, idx, GIN, x, y, -1, tok)
    elseif r < 0.55 and abs(((a + pi) * 7 / pi) % 1 - 0.5) < 0.09 and r > 0.15 then A.step(c, idx, GIN, x, y, 1, tok)
    elseif r > 0.85 and a > -2.6 and a < -0.9 then A.step(c, idx, GIN, x, y, 1, tok) end
  end)
  -- bite edge: exposed fibres (alternating dark/pale teeth)
  if q.bitem then
    q.bitem:grow(1):cut(q.bitem):each(function(x, y) if q.top:has(x, y) then
      c:put(x, y, (x + y) % 2 == 0 and GIN[6] or GIN[3], tok) idx[K(x, y)] = 5 end end)
  end
  -- sugar crystals
  local cnt = 0
  q.top:each(function(x, y) local k = K(x, y)
    local r = q.R[k]
    if r and r < 0.9 and X.hash(x, y, 11 + i) > 0.93 and q.top:has(x + 1, y + 1) and q.top:has(x - 1, y) then
      c:put(x, y, SUG, tok) c:put(x + 1, y + 1, (idx[K(x + 1, y + 1)] or 3) > 3 and SUGS or GIN[max(1, (idx[K(x + 1, y + 1)] or 3) - 1)], tok)
      cnt = cnt + 1
    end
  end)
  -- one glossy syrup glint
  local bx, by = A.specAt(q.top, n, 60)
  c:put(bx, by, SPEC, tok) if q.top:has(bx + 1, by) then c:put(bx + 1, by, GIN[6], tok) end
  painted[#painted + 1] = q
end
-- a few loose sugar grains on the ground line
for _, g in ipairs{ { 10, 47 }, { 47, 44 }, { 52, 42 } } do c:put(g[1], g[2], SUG) end

A.save(c, NAME)
