-- acai (final pass, Opus). A slim diagonal sprig: a rust-orange rachilla strand curving down-left from a cut end,
-- with small round acai berries set alternately on short pedicels (1-2 px of air between them), and one narrow
-- palm leaflet sweeping over the top-left.
-- Material: berries per-pixel sphere light on a 6-tone violet-black ramp, dusty waxy bloom specks on the lit half,
-- one bright specular each (glossy), cool reflected light on the lower-right rim, a pale star-shaped calyx where
-- each berry meets its pedicel, AO + contact shadow on the strand under the berries. Strand: tube light and a pale
-- end-grain cap at the cut. Leaflet: V fold, pale midrib, parallel veins (palm venation).
-- History: Sonnet draft (_dA12) replaced.
-- quirk: the lowest berry is split and drips one drop of purple juice.
local NAME = "acai"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local BER   = { "#160e24", "#2a1638", "#44204e", "#64306c", "#8c4c8c", "#bc80b6" }
local BLOOM, SPEC, BOUNCE = "#9c8cb4", "#f6e8f2", "#5c5ca0"
local STK   = { "#4a1c26", "#7a3026", "#a84e2c", "#cc7434", "#e89a4c", "#f8c47a" }
local CALYX = { "#6a3c2c", "#a8744a", "#d8aa72" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local JUICE = { "#3a1438", "#6a2a66", "#9a4a90", "#d08ac4" }
local FLESH = { "#c9b08a", "#eedcb6" }

-- leaflet first (behind everything)
local lm, ln, LT, LS = A.blade(48, 17, 30, 8, 9, 17, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 4.2 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.7)
end, { fold = 0.45 })
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { amb = 0.12, wrap = 0.3, tok = ltok, cuts = { 0.2, 0.37, 0.54, 0.7, 0.86 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.16 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif abs(abs(s) - 0.55) < 0.13 and t > 0.06 and t < 0.88 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)

-- rachilla strand
local path = { { 50, 12 }, { 46, 22 }, { 32, 29 }, { 19, 44 } }
local sm, sn, ST, SS = A.tube(path, function(t) return 1.5 - 0.6 * t end)
local stok = { r = { name = "strand" } }
local sbias = {}

-- berry layout: alternate sides along the strand
local function at(t)
  local x, y = A.bez(path, t)
  local x2, y2 = A.bez(path, min(1, t + 0.01))
  local x1, y1 = A.bez(path, max(0, t - 0.01))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx * tx + ty * ty)
  tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  if px + py < 0 then px, py = -px, -py end
  return x, y, tx, ty, px, py
end
local berries = {}
local list = { { 0.2, 1, 5.6 }, { 0.32, -1, 5.8 }, { 0.47, 1, 5.8 }, { 0.6, -1, 5.8 }, { 0.75, 1, 5.6 },
               { 0.88, -1, 5.4 }, { 1.0, 0, 0 } }
for _, b in ipairs(list) do
  local x, y, tx, ty, px, py = at(b[1])
  local cx, cy = x + px * b[2] * b[3], y + py * b[2] * b[3]
  if b[2] == 0 then cx, cy = x + tx * 3.6, y + ty * 3.6 end
  cx, cy = floor(cx + 0.5), floor(cy + 0.5)
  berries[#berries + 1] = { cx = cx, cy = cy, ax = x, ay = y, r = 3.8 }
end
-- pedicels (short stalks) join the strand
local ped = HP.mask()
for _, b in ipairs(berries) do
  local n = 8
  for i = 0, n do local f = i / n
    ped:set(floor(b.ax + (b.cx - b.ax) * f + 0.5), floor(b.ay + (b.cy - b.ay) * f + 0.5)) end
end
ped:cut(sm)
for _, b in ipairs(berries) do b.m = c:ellipse(b.cx, b.cy, b.r, b.r) end
local allB = HP.mask() for _, b in ipairs(berries) do allB:add(b.m) end
X.ao(sbias, sm, allB, 1, -1)
A.cast(sbias, sm, allB, 1, 1, -1)
A.shade(c, sm, sn, STK, { amb = 0.1, wrap = 0.3, bias = sbias, tok = stok })
ped:each(function(x, y) c:put(x, y, allB:has(x + 1, y) and STK[2] or STK[3], stok) end)
-- cut end-grain cap
c:put(50, 11, STK[6], stok) c:put(51, 11, STK[5], stok) c:put(49, 11, STK[5], stok) c:put(50, 10, STK[4], stok)

-- berries
for i, b in ipairs(berries) do
  local m = b.m
  local n = X.sphere(b.cx - 0.3, b.cy - 0.3, b.r + 0.3, m)
  local tok = { r = { name = "berry" .. i } }
  local idx, v = A.shade(c, m, n, BER, { amb = 0.04, wrap = 0.15, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- waxy bloom specks on the lit half (not on the edge)
  local inner = m:copy():shrink(1)
  inner:each(function(x, y) local k = K(x, y)
    if v[k] > 0.5 and v[k] < 0.9 and X.hash(x, y, 13 + i) > 0.78 then c:put(x, y, BLOOM, tok) end end)
  -- cool reflected light lower-right
  local rim = X.rim(n)
  m:edge():each(function(x, y) if rim[K(x, y)] > 0.78 then c:put(x, y, BOUNCE, tok) end end)
  -- specular: 2x1 + glint
  local sx, sy = b.cx - 2, b.cy - 2
  c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, SPEC, tok) c:put(sx, sy + 1, BER[6], tok)
  -- calyx: pale little star on the side facing the pedicel
  local dx, dy = b.ax - b.cx, b.ay - b.cy local l = sqrt(dx * dx + dy * dy)
  if l > 0.1 then
    local qx, qy = floor(b.cx + dx / l * 3.4 + 0.5), floor(b.cy + dy / l * 3.4 + 0.5)
    c:put(qx, qy, CALYX[3], tok)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      if m:has(qx + d[1], qy + d[2]) then c:put(qx + d[1], qy + d[2], CALYX[(d[1] + d[2] > 0) and 1 or 2], tok) end
    end
  end
end
-- quirk: lowest (tip) berry split, pale flesh showing, one drop of juice hanging below
local tb = berries[#berries]
for _, p in ipairs{ { 1, 1, 1 }, { 2, 2, 1 }, { 1, 2, 2 }, { 2, 3, 1 } } do c:px(tb.cx + p[1], tb.cy + p[2], FLESH[p[3]]) end
c:px(tb.cx + 3, tb.cy + 2, JUICE[2])
local dx0, dy0 = tb.cx + 2, tb.cy + floor(tb.r) + 1
c:px(dx0, dy0, JUICE[2]) c:px(dx0, dy0 + 1, JUICE[2])
local drop = c:ellipse(dx0 + 0.5, dy0 + 3.5, 1.5, 1.6)
c:fillMask(drop, JUICE[2])
c:px(dx0, dy0 + 2, JUICE[3]) c:px(dx0, dy0 + 3, JUICE[4]) c:px(dx0 + 1, dy0 + 5, JUICE[1]) c:px(dx0 + 2, dy0 + 4, JUICE[1])
A.save(c, "ph", NAME)
