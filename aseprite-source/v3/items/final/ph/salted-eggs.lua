-- salted-eggs (final, single pass). A shallow blue ceramic saucer of coarse grey salt, two slim duck eggs leaning in it
-- (pale blue-green shell, freckles, a crust of salt grains creeping up from the bed) and, in front, a salt-cured egg
-- cut in half: firm bluish white, a rimmed shell edge, and a deep orange granular yolk with an oily sheen.
-- Material: ellipsoid light on 6-tone shell/white/yolk ramps, concave white cup, shell cut-rim, cast shadows of the
-- eggs on the salt, crust speckle, ceramic bevel with a lit rim, cool reflected light.
-- quirk: a single salt crystal (a tiny glinting cube) sits on the cut yolk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt
local c = A.new("salted-eggs")
local hash = A.hash

local DISH  = { "#262c4a", "#38426e", "#4f62a0", "#6f88c2", "#98b0dc", "#c6d8f0" }
local SALT  = { "#7b7596", "#a39fbc", "#c6c3d6", "#e0deea", "#f3f0f2", "#fffaf0" }
local SHELL = { "#40566a", "#5e7b8a", "#83a29d", "#a8c4b4", "#cadec8", "#e8f2dc" }
local WHITE = { "#72769a", "#989cc0", "#bec2d8", "#dddee8", "#f2f1ee", "#fffaee" }
local YOLK  = { "#7a2a1e", "#a8401c", "#d85c18", "#f27e16", "#ffa62a", "#ffd270" }
local TOKD, TOKS, TOKE1, TOKE2, TOKH, TOKY = {r={name="dish"}}, {r={name="salt"}}, {r={name="e1"}}, {r={name="e2"}}, {r={name="half"}}, {r={name="yolk"}}

c:groundShadow(32, 56, 24, 3)

-- saucer: wide ellipse, lit rim ring, sunken well
local dish = c:ellipse(32, 49, 24, 8)
local dn = A.body(dish, 31, 46, 24, 3.5, 0.35)
A.shade(c, dish, dn, DISH, { tok = TOKD, amb = 0.1, wrap = 0.28 })
-- foot ring peeking under the front edge
c:ellipse(32, 56, 12, 1):each(function(x, y) if not dish:has(x, y) then c:put(x, y, DISH[1], TOKD) end end)
-- rim highlight along the back-left arc, ink-blue lip at the front
dish:edge():each(function(x, y) local k = K(x, y)
  if y < 49 and x < 36 then c:put(x, y, DISH[6], TOKD) elseif y > 53 then c:put(x, y, DISH[2], TOKD) end end)
-- well
local well = c:ellipse(32, 48, 20, 5.8)
well:each(function(x, y) c:put(x, y, (y < 47 and x < 40) and DISH[2] or DISH[3], TOKD) end)

-- salt bed (heap), rough crust
local heap = c:ellipse(32, 47, 20, 6.4)
heap:add(c:ellipse(32, 44, 14, 3.2))
local eA = A.eggM(19, 34, 6.2, 11, 0.12, -1.8)       -- left egg leaning left
local eB = A.eggM(33, 28, 6.6, 12, 0.12, 1.6)        -- tall egg leaning right
local half = A.eggM(43, 42, 7.2, 9, 0.12, 0)
local bias = {}
G.cast(bias, heap, eA, 1, 1, -1) G.cast(bias, heap, eB, 1, 1, -1) G.cast(bias, heap, half, 2, 1, -2)
local hn = A.ellN(heap, 31, 44, 21, 8, 1.1)
local hidx = A.shade(c, heap, hn, SALT, { tok = TOKS, amb = 0.1, wrap = 0.3, bias = bias })
heap:each(function(x, y)
  local r = hash(x, y, 3)
  local k = K(x, y)
  if r < 0.16 then c:put(x, y, SALT[max(1, (hidx[k] or 3) - 1)], TOKS)
  elseif r > 0.9 then c:put(x, y, SALT[min(6, (hidx[k] or 3) + 1)], TOKS) end
end)
heap:edge():each(function(x, y) if y > 46 then c:put(x, y, SALT[2], TOKS) end end)

-- whole egg: shell tone, freckles, crust creeping up from the bed
local function wholeEgg(m, cx, cy, rx, ry, tok, seed)
  local n = A.ellN(m, cx, cy, rx, ry, 1.0)
  local idx = A.shade(c, m, n, SHELL, { tok = tok, amb = 0.08, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y)
    local r = hash(x, y, seed)
    if r < 0.05 then c:put(x, y, SHELL[max(1, idx[k] - 2)], tok) end        -- freckles
    local lim = cy + ry * (0.38 + (hash(x, 0, seed + 5) - 0.5) * 0.5)
    if y > lim then                                                           -- salt crust, same light
      local si = max(1, min(6, idx[k] + 1))
      c:put(x, y, (hash(x, y, seed + 2) < 0.28) and SALT[max(1, si - 1)] or SALT[si], tok)
    end
  end)
  -- cool reflected light on the lower-right rim, then shell specular
  local rim = X.rim(n)
  m:edge():each(function(x, y) if rim[K(x, y)] > 0.8 and y < cy + ry * 0.38 then c:put(x, y, "#8aa6c8", tok) end end)
  c:put(floor(cx - rx * 0.45), floor(cy - ry * 0.55), SHELL[6], tok)
  c:put(floor(cx - rx * 0.45) + 1, floor(cy - ry * 0.55), SHELL[6], tok)
  c:put(floor(cx - rx * 0.45), floor(cy - ry * 0.55) + 1, SHELL[5], tok)
  -- an ink-free contact line where the egg meets the salt
end
wholeEgg(eB, 33, 28, 6.6, 12, TOKE2, 11)
wholeEgg(eA:copy():cut(eB:copy():shift(0, 0)), 19, 34, 6.2, 11, TOKE1, 4)
-- inner separation line where the left egg tucks behind the tall one
eB:edge():each(function(x, y) if eA:has(x - 1, y) and not eB:has(x - 1, y) then c:put(x - 1, y, SHELL[1], TOKE1) end end)

-- front: the cut half egg (shell rim, concave bluish white, yolk dome)
local hn0 = A.ellN(half, 43, 42, 7.2, 9, 1)
A.shade(c, half, hn0, SHELL, { tok = TOKH, amb = 0.1, wrap = 0.25 })
local cup = half:shrink(1)
local wn = X.pillow(cup, 3.4, -0.8)
local wb = {}
local yolk = c:ellipse(43.5, 43, 4.4, 4.4)
G.cast(wb, cup, yolk, 1, 1, -2)
A.shade(c, cup, wn, WHITE, { tok = TOKH, amb = 0.18, wrap = 0.35, bias = wb })
-- soft cut-edge shadow ring just inside the shell rim (upper-left in shade, lower-right lit)
cup:edge():each(function(x, y) if x + y < 84 then c:put(x, y, WHITE[2], TOKH) end end)
-- yolk: dome, granular, darker ring, oily sheen
local yn = X.sphere(42.4, 41.6, 4.4, yolk)
local yidx = A.shade(c, yolk, yn, YOLK, { tok = TOKY, amb = 0.12, wrap = 0.25 })
yolk:each(function(x, y) local k = K(x, y)
  local r = hash(x, y, 8)
  if r < 0.22 then c:put(x, y, YOLK[max(1, yidx[k] - 1)], TOKY)
  elseif r > 0.84 then c:put(x, y, YOLK[min(6, yidx[k] + 1)], TOKY) end
end)
yolk:edge():each(function(x, y) if x + y > 84 then c:put(x, y, YOLK[1], TOKY) end end)
c:put(41, 40, "#ffe9a8", TOKY) c:put(42, 40, "#ffe9a8", TOKY) c:put(40, 41, YOLK[6], TOKY)   -- oil sheen
-- quirk: a salt crystal cube on the yolk
for _, q in ipairs{ {45, 43, SALT[5]}, {46, 43, SALT[6]}, {45, 44, SALT[3]}, {46, 44, SALT[2]} } do c:put(q[1], q[2], q[3], TOKY) end
c:put(46, 42, "#fffaf0", TOKY)

-- loose coarse grains at the egg feet and on the saucer rim
for _, q in ipairs{ {13, 45}, {15, 46}, {28, 51}, {34, 52}, {52, 47}, {24, 40}, {30, 43} } do
  c:put(q[1], q[2], SALT[6], TOKS) c:put(q[1] + 1, q[2], SALT[4], TOKS)
end
A.save(c, "salted-eggs")
