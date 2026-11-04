-- samphire-salad (final, single pass). A wide, shallow cream stoneware bowl with a terracotta band, heaped with a tangle
-- of dressed samphire: short jointed green tubes, glossy with oil, a few pale young tips sticking up, two cherry
-- tomatoes tucked in, flakes of sea salt, and a lemon wedge perched on the right rim.
-- Material: bowl lit as a rounded shell (6-tone cream, lit rim ring, concave inner wall, curved terracotta band,
-- foot ring), each samphire piece a lit cylinder with node bands and AO from the pieces in front, oil glints,
-- glossy tomatoes with calyx, lemon: peel / pith / segmented flesh with membranes and juice glints.
-- quirk: a drop of lemon juice is just about to fall off the wedge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("samphire-salad")
local hash = A.hash

local GREEN = { "#10352d", "#1b5636", "#2a783e", "#43a042", "#6fc44e", "#a8e072" }
local TIP   = { "#3f7a36", "#6aa83e", "#94c84e", "#bfe16c", "#dcf08c", "#f0fab0" }
local CREAM = { "#6a5a6e", "#9a8896", "#c8b8b4", "#e8d8c6", "#f8ecd4", "#fffaf0" }
local TERRA = { "#4a2430", "#7a3a38", "#a85440", "#c97452", "#e4966a", "#f6bc8e" }
local TOM   = { "#5e1230", "#8c1f38", "#b92e3c", "#dd4a40", "#f26e58", "#ff9e7a" }
local PEEL  = { "#8c5a10", "#c08418", "#e8aa20", "#f8c83a", "#ffe068", "#fff0a0" }
local FLESH = { "#c88a10", "#e8b014", "#f8d02c", "#ffe454", "#fff08c", "#fffbd0" }
local btok = { r = { name = "bowl" } }
local bandtok = { r = { name = "band" } }

c:groundShadow(32, 58, 22, 3)
-- ---------------------------------------------------------------- bowl
local rimO = c:ellipse(32, 38, 23, 8)
local body = c:ellipse(32, 40, 23, 15):clip(c:rect(0, 38, 63, 63)):add(rimO)
body:add(c:ellipse(32, 56, 9, 2.2))
local bn = A.ellN(body, 29, 35, 25, 24, 1.0)
local bidx = A.shade(c, body, bn, CREAM, { tok = btok, amb = 0.3, wrap = 0.55, cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 } })
local function yfront(x, rx, ry, cy) local nx = (x - 32) / rx return cy + ry * sqrt(max(0, 1 - nx * nx)) end
-- terracotta band following the curve of the bowl
body:each(function(x, y) local k = K(x, y)
  local d = y - yfront(x, 23, 8, 38)
  if d >= 4.2 and d <= 7.4 and y < 55 then
    c:put(x, y, TERRA[max(1, min(6, bidx[k] - 0 ))], bandtok)
  end
end)
-- band edge lines
body:each(function(x, y)
  local d = y - yfront(x, 23, 8, 38)
  if y < 55 and (abs(d - 4.2) < 0.55 or abs(d - 7.4) < 0.55) then c:put(x, y, TERRA[2], bandtok) end
end)
-- foot ring: darker, tucked under
for x = 24, 40 do if body:has(x, 56) then c:put(x, 56, CREAM[2], btok) end end
for x = 25, 39 do if body:has(x, 57) then c:put(x, 57, CREAM[1], btok) end end
-- rim ring (lit lip) and concave inner wall
local inner = c:ellipse(32, 38, 20.5, 6)
local ring = rimO:copy():cut(inner)
local rn = X.pillow(ring, 1.6)
A.shade(c, ring, rn, CREAM, { tok = btok, amb = 0.2, wrap = 0.3, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 } })
inner:each(function(x, y) local k = K(x, y)
  local lit = (x - 32) * 0.5 + (y - 38) * 0.8
  c:put(x, y, (y < 36 and x < 36) and CREAM[1] or (lit > 3 and CREAM[3] or CREAM[2]), btok)
end)
-- inner rim contact line
inner:edge():each(function(x, y) if y > 38 then c:put(x, y, CREAM[2], btok) end end)

-- ---------------------------------------------------------------- samphire heap
local below = HP.mask()
for x = 8, 56 do local yf = floor(yfront(x, 20.5, 6, 38) + 0.5) for y = yf, 50 do below:set(x, y) end end
local parts = {}
local N = 40
for i = 1, N do
  local r1, r2, r3, r4 = hash(i, 1, 21), hash(i, 2, 21), hash(i, 3, 21), hash(i, 4, 21)
  local x = 32 + (r1 - 0.5) * 33
  local nx = max(-1, min(1, (x - 32) / 19))
  local top = 18 + (1 - sqrt(max(0, 1 - nx * nx))) * 10
  local y = top + (42 - nx * nx * 4 - top) * (r2 ^ 0.75)
  local ang = (r3 - 0.5) * 2.3
  if y < top + 6 and r4 > 0.3 then ang = -1.57 + (r3 - 0.5) * 1.5 end   -- some sprigs reach up
  local L = 8.5 + r4 * 3.5
  local ux, uy = cos(ang), sin(ang)
  if uy > 0.6 then uy = 0.6 end
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local bend = (r1 - 0.5) * 3.4
  local px, py = -uy, ux
  local p = { { x - ux * L / 2, y - uy * L / 2 },
    { x - ux * L / 6 + px * bend, y - uy * L / 6 + py * bend },
    { x + ux * L / 6 + px * bend, y + uy * L / 6 + py * bend },
    { x + ux * L / 2, y + uy * L / 2 } }
  local m, n, T, S, sm, Lg = A.segtube(p, 1.55 + (r2 - 0.5) * 0.3, 3.5, 0.6, { off = r3 })
  m:cut(below)
  parts[#parts + 1] = { m = m, n = n, T = T, S = S, sm = sm, L = Lg, w = 1.55, seg = 3.5, off = r3, y = y, young = r4 > 0.72 }
end
table.sort(parts, function(a, b) return a.y < b.y end)
-- tomatoes (placed among the greens, drawn after the back pieces)
local toms = { { 21, 38, 3.6 }, { 39, 40, 3.4 } }
local function tomato(cx, cy, r)
  local m = c:ellipse(cx, cy, r, r):cut(below)
  local n = X.sphere(cx - 0.6, cy - 0.6, r, m)
  local tok = { r = { name = "tom" } }
  local idx = A.shade(c, m, n, TOM, { tok = tok, amb = 0.08, wrap = 0.2 })
  local rim = X.rim(n)
  m:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.78 then c:put(x, y, "#a8467a", tok) end end)
  c:put(floor(cx - r * 0.5), floor(cy - r * 0.5), "#fff0dc", tok) c:put(floor(cx - r * 0.5) + 1, floor(cy - r * 0.5), "#fff0dc", tok)
  -- calyx
  for _, q in ipairs{ { 0, -r + 0.5, 4 }, { -1, -r + 1, 3 }, { 1, -r + 1, 3 }, { 0, -r - 0.5, 5 } } do
    local x, y = floor(cx + q[1] + 0.5), floor(cy + q[2] + 0.5)
    if not below:has(x, y) then c:put(x, y, GREEN[q[3]], tok) end
  end
  return m
end
local tomDone = { false, false }
local masks = {}
for i, pt in ipairs(parts) do
  -- paint tomatoes once the pieces behind them are down
  for ti, t in ipairs(toms) do
    if false then tomDone[ti] = true masks[ti] = tomato(t[1], t[2], t[3]) end
  end
  local bias = {}
  for j = i + 1, min(#parts, i + 7) do X.ao(bias, pt.m, parts[j].m, 1, -2) end
  for _, tm in pairs(masks) do X.ao(bias, pt.m, tm, 1, -2) end
  local tok = { r = { name = "piece" .. i } }
  local v = X.light(pt.n, { amb = 0.12, wrap = 0.3 })
  local idx = X.tone(c, pt.m, v, GREEN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })
  pt.m:each(function(x, y) local k = K(x, y)
    if pt.young or pt.T[k] > 0.86 then c:put(x, y, TIP[min(6, max(1, idx[k] + (pt.young and 1 or 0)))], tok) end
  end)
  A.joints(c, pt.sm, pt.L, pt.seg, pt.w, pt.young and TIP[1] or GREEN[1], tok, pt.off)
  -- oil sheen: a bright streak on the lit side
  local tt = 0.3 + hash(i, 7, 5) * 0.4
  local best, bs = 1e9
  for _, q in ipairs(pt.sm) do local d = abs(q.t - tt) if d < best then best, bs = d, q end end
  for d = 0, 1 do
    local x, y = floor(bs.x - bs.px * 0.9 + bs.tx * d + 0.5), floor(bs.y - bs.py * 0.9 + bs.ty * d + 0.5)
    if pt.m:has(x, y) and not bias[K(x, y)] then c:put(x, y, "#e8ffc0", tok) end
  end
end
for ti, t in ipairs(toms) do
  local m0 = c:ellipse(t[1], t[2], t[3], t[3])
  m0:grow(1):cut(m0):cut(below):each(function(x, y) if c:get(x, y) then c:put(x, y, GREEN[1], { r = { name = "tomao" } }) end end)
  masks[ti] = tomato(t[1], t[2], t[3])
end
-- sea-salt flakes on the greens
for _, q in ipairs{ { 26, 29 }, { 35, 25 }, { 29, 34 }, { 44, 31 }, { 19, 30 }, { 36, 32 } } do
  local k = c:get(q[1], q[2])
  if k then c:put(q[1], q[2], "#fffaf0", { r = { name = "flake" } }) c:put(q[1] + 1, q[2], "#c8c6d8", { r = { name = "flake" } }) end
end

-- ---------------------------------------------------------------- lemon wedge on the right rim
local lcx, lcy, R, a = 48, 34, 8.6, 0.42
local ca, sa = cos(a), sin(a)
local wedge = HP.mask()
local U, V = {}, {}
for y = floor(lcy - R - 2), floor(lcy + R + 2) do for x = floor(lcx - R - 2), floor(lcx + R + 2) do
  local dx, dy = x - lcx, y - lcy
  local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
  if v >= -0.2 and u * u + v * v <= R * R then wedge:set(x, y) local k = K(x, y) U[k], V[k] = u, v end
end end
local ltok = { r = { name = "lemon" } }
local lb = {}
local wn = A.ellN(wedge, lcx - 3, lcy + 1, R + 1, R + 1, 0.9)
local lidx = A.shade(c, wedge, wn, PEEL, { tok = ltok, amb = 0.14, wrap = 0.3 })
wedge:each(function(x, y) local k = K(x, y)
  local u, v = U[k], V[k]
  local r = sqrt(u * u + v * v)
  local th = atan(v, u)
  if th < 0 then th = 0 end
  if r < R - 1.0 then c:put(x, y, "#fff0b8", ltok) end                    -- pith
  if r < R - 2.2 and v > 0.6 then                                            -- segmented flesh
    local seg = th / (pi / 4)
    local s = floor(seg)
    local e = abs(seg - s - 0.5) * 2
    local tone = 4
    if e < 0.42 and r > 2.2 then tone = 5 end
    if e > 0.78 then tone = 2 end
    if r > R - 3.1 then tone = max(2, tone - 1) end
    if (u + v) * 0.5 > 3.2 then tone = max(1, tone - 1) end             -- shade side
    if hash(x, y, 12) < 0.07 then tone = min(6, tone + 2) end              -- juice glints
    if r < 1.6 then tone = 5 end
    if abs(seg - floor(seg + 0.5)) * (pi / 4) * r < 0.55 and r > 1.0 and floor(seg + 0.5) >= 1 and floor(seg + 0.5) <= 3 then tone = 6 end -- membranes
    c:put(x, y, FLESH[tone], ltok)
  end
end)
-- bright lip on the lit peel edge, dark peel underside
wedge:edge():each(function(x, y) local k = K(x, y)
  if V[k] > 3 and (x + y) < 78 then c:put(x, y, PEEL[5], ltok) elseif V[k] > 3 then c:put(x, y, PEEL[2], ltok) end
end)
-- quirk: a juice drop about to fall from the lowest point of the wedge
local bx, by = 0, -1
wedge:each(function(x, y) if y > by or (y == by and x > bx) then bx, by = x, y end end)
local dtok = { r = { name = "drop" } }
c:put(bx, by + 1, FLESH[3], dtok) c:put(bx, by + 2, FLESH[4], dtok)
c:put(bx - 1, by + 3, FLESH[3], dtok) c:put(bx, by + 3, FLESH[2], dtok) c:put(bx + 1, by + 3, FLESH[2], dtok)
c:put(bx - 1, by + 3, FLESH[6], dtok)
A.save(c, "samphire-salad")
