-- oak-gall (final, C3 Opus single pass). A round oak-apple gall, waxy tan with russet freckles, grown on a slim
-- grey-brown oak twig; two lobed oak leaves at the twig tip. Sphere-lit gall with a cool bounce on the shade side,
-- one specular, AO + contact shadow where it hugs the twig, bud scales at the twig nodes.
-- quirk: the gall-wasp is peeking out of its round exit hole, antennae up.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "oak-gall"
local c = A.new(NAME)
local BARK = { "#2f2228", "#4a3532", "#6a4c3e", "#8a6a52", "#ad8f72", "#d0b896" }
local GALL = { "#4a2626", "#77402e", "#a5653c", "#c98d52", "#e3b46e", "#f7dc9e" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local COOL = "#8a7a9c"

-- gall geometry first (masks), so the twig can be shadowed by it
local gcx, gcy, gr = 25, 37, 10.2
local gm = HP.mask()
for y = floor(gcy - gr) - 1, floor(gcy + gr) + 1 do for x = floor(gcx - gr) - 1, floor(gcx + gr) + 1 do
  local dx, dy = x - gcx, y - gcy
  -- very slightly lumpy outline (galls are not perfect spheres)
  local a = math.atan(dy, dx)
  local rr = gr + 0.45 * sin(a * 3 + 0.6)
  if dx * dx + dy * dy <= rr * rr then gm:set(x, y) end
end end

-- twig: from lower-left, passing behind the gall's upper-right shoulder, out to the leaves
local tok = { r = { name = "twig" } }
local tw = { { 11, 54 }, { 17, 48 }, { 34, 30 }, { 47, 16 } }
local bias = {}
local tm, tn, TT = A.HP.mask(), nil, nil
do
  local m, n, T, S = A.tube(tw, function(t) return 1.75 - 0.75 * t end)
  m:cut(gm)
  X.ao(bias, m, gm, 2, -1)
  A.cast(bias, m, gm, 1, 2, -1)
  local idx = A.shade(c, m, n, BARK, { bias = bias, tok = tok, amb = 0.12, wrap = 0.3 })
  -- bark texture: short dark flecks along the twig
  m:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, 7) > 0.8 and (idx[k] or 1) > 2 then c:put(x, y, BARK[idx[k] - 1], tok) end end)
  tm, tn, TT = m, n, T
end
-- side spur toward the upper-left with a bud (twig fork)
do
  local m, n = A.tube({ { 39, 25 }, { 36, 21 }, { 34, 18 }, { 33, 15 } }, function(t) return 1.05 - 0.3 * t end)
  m:cut(tm)
  A.shade(c, m, n, BARK, { tok = tok, amb = 0.14, wrap = 0.3 })
  tm:add(m)
end

-- leaves: lobed oak blades (rounded lobes from a wavy width function)
local function oakWidth(w, nl)
  return function(t)
    if t > 0.985 then return -1 end
    local env = w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6
    local lobe = 0.62 + 0.38 * abs(cos(pi * nl * t))
    return max(0.5, env * lobe)
  end
end
local ltok = { r = { name = "leaf" } }
local l1 = A.leaf(c, 46, 17, 51, 11, 55, 6, 5.8, LEAF, { wfn = oakWidth(5.8, 3.5), tok = ltok, vs = 3.6, fold = 0.4 })
local l2 = A.leaf(c, 33, 15, 30, 11, 24, 8, 4.2, LEAF, { wfn = oakWidth(4.2, 2.5), tok = ltok, vs = 3.4, fold = 0.4, cut = l1 })
-- leaf stalk joins: ambient dark where the leaves meet the twig
for _, p in ipairs{ { 46, 17 }, { 47, 16 }, { 33, 15 } } do c:put(p[1], p[2], LEAF[1], ltok) end
-- bud scales at the fork
for _, q in ipairs{ { 40, 24, BARK[6] }, { 41, 23, BARK[4] }, { 41, 24, BARK[3] } } do c:put(q[1], q[2], q[3], tok) end

-- gall body: sphere light, freckles, cool bounce, spec
local gtok = { r = { name = "gall" } }
local gn = X.sphere(gcx, gcy, gr, gm)
local gb = {}
local gidx = A.shade(c, gm, gn, GALL, { tok = gtok, amb = 0.05, wrap = 0.18, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = gb })
local rim = X.rim(gn)
gm:each(function(x, y) local k = K(x, y)
  -- cool reflected light on the lower-right rim
  if rim[k] > 0.62 and gidx[k] <= 2 then c:put(x, y, COOL, gtok) return end
  -- russet freckles (sparse, never on the highlight)
  if X.hash(x, y, 3) > 0.9 and gidx[k] >= 3 and gidx[k] <= 5 then c:put(x, y, GALL[gidx[k] - 1], gtok) end
end)
-- waxy bloom: a soft pale band of the hi tone upper-left, then one hard specular
for _, p in ipairs{ { 19, 31 }, { 20, 30 }, { 21, 30 }, { 18, 32 } } do if gm:has(p[1], p[2]) then c:put(p[1], p[2], GALL[6], gtok) end end
c:put(20, 31, "#fff4d6", gtok) c:put(21, 31, "#fff4d6", gtok)
-- attachment scar where the gall grows from the twig (upper-right shoulder)
for _, p in ipairs{ { 31, 30 }, { 32, 30 }, { 32, 31 } } do if gm:has(p[1], p[2]) then c:put(p[1], p[2], GALL[2], gtok) end end
c:put(31, 31, GALL[1], gtok)

-- quirk: exit hole with the gall-wasp peeking out
local hx, hy = 28, 42
for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 2, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 1, -1 }, { 1, 2 } } do
  c:put(hx + p[1], hy + p[2], "#2b1c26", gtok) end
-- rim of the hole (lit lip lower-right, dark lip upper-left)
c:put(hx + 3, hy, GALL[4], gtok) c:put(hx + 3, hy + 1, GALL[4], gtok) c:put(hx + 2, hy + 2, GALL[4], gtok)
-- wasp head: glossy black-violet with an amber eye glint
c:put(hx + 1, hy, "#4a3a6e", gtok) c:put(hx + 1, hy + 1, "#35295f", gtok) c:put(hx, hy, "#f5b82e", gtok)
-- antennae
c:put(hx + 2, hy - 1, "#35295f", gtok) c:put(hx + 3, hy - 2, "#35295f", gtok)
c:put(hx, hy - 1, "#35295f", gtok) c:put(hx - 1, hy - 2, "#35295f", gtok)

A.save(c, NAME)
