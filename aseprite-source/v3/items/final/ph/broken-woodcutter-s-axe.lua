-- broken-woodcutter-s-axe (aB13_0, Opus single pass). A felling axe: slim gently S-curved hickory haft (swelled knob at
-- the butt) up into a forged steel head, bit to the right with a flared beard, short square poll behind the eye.
-- Material: haft cylinder light (6 tones) with long grain; head pillow-lit steel (6 tones) with a bright honed bevel band
-- and edge line, a specular streak on the cheek, a darker forge-scale patch near the poll, the haft's end grain and an
-- iron wedge showing in the eye; AO where haft enters the head.
-- broken: a bite chipped out of the bit (steel chip flying off), and the haft split just under the head with a lifted
-- splinter.
-- quirk: a red rag knotted round the haft, two little tails flapping.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("broken-woodcutter-s-axe")
local HICK = { "#3e2230", "#61372b", "#8d5634", "#b67c48", "#d6a266", "#efca8e" }
local STEEL = { "#2f3350", "#474a68", "#6d7090", "#9497ae", "#bdbfd0", "#e6e6f0" }
local SCALE = "#565470"
local ENDG = "#f2d7a2"
local SPEC = "#f7f7fc"
local RAG = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

-- haft
local haft = { { 17, 57 }, { 24, 47 }, { 31, 32 }, { 39, 20 } }
local function hw(t)
  if t < 0.06 then return 2.4 end
  if t < 0.12 then return 2.4 - (t - 0.06) / 0.06 * 0.9 end
  return 1.5 + t * 0.35
end
local H = A.tube(c, haft, hw, HICK, { bias = function(t) if t < 0.02 then return -1 end return 0 end })
A.grain(c, H, { { -0.45, 0.1, 0.9, 0.1 }, { 0.1, 0.18, 0.62, 0.15 }, { 0.5, 0.3, 0.95, 0.1 } })
-- split under the head: dark jagged crack along the middle, lit lip on its upper side
A.over(c, H, function(t, s, x, y, i)
  local d = t * H.len
  local L = H.len
  if d > L - 15 and d < L - 3 then
    local off = ((floor(d) % 3) - 1) * 0.18
    if abs(s - off) * (H.wfn(t) + 0.5) < 0.5 then return 1 end
  end
end)
-- lifted splinter peeling off the shade side
do
  local s = H.samp[floor(0.74 * 160) + 1]
  local x0, y0 = s.x + s.px * (s.w + 0.5), s.y + s.py * (s.w + 0.5)
  A.ln(c, { { floor(x0 + .5), floor(y0 + .5) }, { floor(x0 + 3.5), floor(y0 + 1.5) } }, HICK[4])
  c:put(floor(x0 + 3.5), floor(y0 + 1.5), ENDG)
  c:put(floor(x0 + .5), floor(y0 + 1.5), HICK[2])
end

-- head: local frame u (up the haft) / v (toward the bit)
local ox, oy = 40.5, 18.5
local ux, uy = 0.55, -0.83
local vx, vy = 0.83, 0.55
local function P(v, u) return { ox + u * ux + v * vx, oy + u * uy + v * vy } end
local head = c:poly({ P(-5, -3), P(-5, 3), P(3, 3.5), P(9, 5.5), P(12.5, 7.5), P(13.6, 5), P(14.2, 1), P(14, -3.5), P(13, -7.5),
  P(11.2, -9.5), P(9, -6.5), P(4, -4), P(-5, -3) })
-- the bite: chip knocked out of the bit edge
local bite = c:poly({ P(15, 0.6), P(12.2, -1.2), P(12.6, -2.6), P(15, -4.2) })
head:cut(bite)
local function loc(x, y) local dx, dy = x + .5 - ox, y + .5 - oy return dx * vx + dy * vy, dx * ux + dy * uy end
local bias = {}
head:each(function(x, y) local v, u = loc(x, y)
  if v < 0 then bias[K(x, y)] = -1 end -- poll sits back, darker
end)
local idx, n, htok = A.slab(c, head, STEEL, 2, { bias = bias })
-- honed bevel band + bright edge along the bit
local edge = head:edge()
head:each(function(x, y) local v, u = loc(x, y)
  if v > 10.3 then
    local i = idx[K(x, y)] or 3
    c:put(x, y, STEEL[min(6, i + 1)], htok)
    if edge:has(x, y) and u > -8 then c:put(x, y, (u > 1) and STEEL[6] or STEEL[5], htok) end
  elseif v > 9.3 and v <= 10.3 and u > -6 and u < 5 then
    c:put(x, y, STEEL[2], htok) -- grind line
  end
end)
-- forge scale near the poll
head:each(function(x, y) local v, u = loc(x, y)
  if v < -1.5 and v > -4.3 and u > -2 and u < 2.5 and A.X.hash(x, y, 7) > 0.45 then c:put(x, y, SCALE, htok) end
end)
-- cheek specular streak
for _, q in ipairs({ { 4, 2 }, { 5, 2 }, { 6, 2.4 } }) do local p = P(q[1], q[2]) c:put(floor(p[1]), floor(p[2]), STEEL[6], htok) end
do local p = P(5, 2.6) c:put(floor(p[1]), floor(p[2]), SPEC, htok) end
-- broken face of the bite: dark inner wall, bright lip
local bring = bite:grow(1):clip(head)
bring:each(function(x, y) local v, u = loc(x, y) c:put(x, y, (u > -1.2) and STEEL[2] or STEEL[5], htok) end)
-- eye: haft end grain and a dark iron wedge
local eye = c:poly({ P(-1.6, 2.4), P(1.9, 2.4), P(1.9, 3.6), P(-1.6, 3.6) })
eye:each(function(x, y) c:put(x, y, ENDG, htok) end)
local w0, w1 = P(0.2, 2.4), P(0.2, 3.6)
c:put(floor(w0[1]), floor(w0[2]), STEEL[1], htok)
-- AO where the haft enters the head (underside)
head:each(function(x, y) local v, u = loc(x, y)
  if u < -3 and u > -4.6 and v > -3 and v < 3 then c:put(x, y, STEEL[1], htok) end
end)
-- flying steel chip
A.shard(c, 56.5, 25.5, 0.9, 1.7, 1.0, STEEL)
c:put(56, 25, SPEC)

-- quirk: red rag knot on the haft with two tails
do
  local s = H.samp[floor(0.4 * 160) + 1]
  local cx, cy = s.x, s.y
  local band = HP.mask()
  H.m:each(function(x, y) local k = K(x, y) local d = H.T[k] * H.len - 0.4 * H.len
    if d > -1.6 and d < 1.6 then band:set(x, y) end end)
  local rn = X.pillow(band, 1.5)
  A.G.toneN(c, band, rn, { RAG[1], RAG[2], RAG[2], RAG[3], RAG[3], RAG[4] }, { cuts = { 0.15, 0.35, 0.5, 0.65, 0.85 } })
  -- weave: diagonal dark ticks
  band:each(function(x, y) if (x + y) % 3 == 0 and A.X.hash(x, y, 2) > 0.4 then c:put(x, y, RAG[2]) end end)
  local kx, ky = floor(cx + s.px * 2.4 + .5), floor(cy + s.py * 2.4 + .5)
  A.map(c, kx - 1, ky - 1, {
    "Rr..",
    "rRd.",
    ".dRr",
    ".d.Rd",
    "...dd",
  }, { R = RAG[3], r = RAG[4], d = RAG[2] })
end
A.fin(c)
