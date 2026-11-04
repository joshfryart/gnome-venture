-- moringa-seed (ph, Opus single pass). Moringa's winged seeds on a torn strip of blue-green leaf: each seed is a
-- round, glossy dark-brown kernel (sphere-lit, one specular) with three pale papery wings (flat, faint radial veins,
-- AO ring where they meet the kernel). The leaf strip arcs gently, with a midrib, swept veins, a cool reflected
-- edge, a ragged torn right end and a torn notch in the lower margin; AO + contact shadow under each seed. The
-- middle seed has sprouted: a slim pale stem rising out of its split kernel with a first pinnate leaf (paired small
-- oval leaflets and a terminal one, like the crop's feathery sprig) and a smaller side leaf; a short root below.
-- quirk: the right seed has lost a wing, and the torn-off wing lies beside it.
local NAME = "moringa-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local LEAF = { "#14363a", "#1d5245", "#29714a", "#3f9150", "#62b05a", "#96cc70" }
local VEIN, COOL = "#bfe28c", "#3a6c74"
local WING = { "#5e4c40", "#806a54", "#a48c6a", "#c2ac84", "#d8c8a0", "#ece0bc" }
local KERN = { "#2c181e", "#482824", "#6a3e2e", "#8c583a", "#b0784e", "#d4a06e" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local SPEC = "#fff2dc"

-- seeds: kernel centre, kernel radius, wing rotation, wings kept
local seeds = {
  { 17, 45, 2.6, 0.3, { 1, 2, 3 } },
  { 31, 42, 2.7, -0.2, { 1, 2, 3 } },
  { 46, 46, 2.5, 0.9, { 1, 3 } },
}
local function wingMask(cx, cy, r, a)
  local ux, uy = cos(a), sin(a)
  local m = G.rell(cx + ux * (r + 1.6), cy + uy * (r + 1.6), ux, uy, 3.1, 2.3)
  return m
end
for _, s in ipairs(seeds) do
  s.k = HP.mask()
  for y = floor(s[2] - s[3]) - 1, floor(s[2] + s[3]) + 1 do for x = floor(s[1] - s[3]) - 1, floor(s[1] + s[3]) + 1 do
    if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 <= (s[3] + 0.3) ^ 2 then s.k:set(x, y) end end end
  s.w = {}
  s.all = s.k:copy()
  for _, wi in ipairs(s[5]) do
    local a = s[4] + (wi - 1) * 2 * pi / 3 - pi / 2
    local wm = wingMask(s[1], s[2], s[3], a):cut(s.k)
    s.w[#s.w + 1] = { m = wm, a = a }
    s.all:add(wm)
  end
end
-- the loose wing (quirk)
local loose = { m = G.rell(55, 45, cos(-0.4), sin(-0.4), 3.0, 2.2), a = -0.4, cx = 55, cy = 45 }

-- leaf strip
local lm, ln, LT, LS, len = G.blade(7, 50, 31, 41, 57, 51, function(t)
  if t > 0.99 then return -1 end
  return 6.6 - 1.2 * t
end, { fold = 0.3 })
-- torn right end (ragged), torn left end, notch in the lower margin
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local endT = 0.9 + 0.07 * X.hash(floor(s * 6), 1, 4) + s * 0.03
  if t > endT then cut[#cut + 1] = k end
  local stT = 0.035 + 0.04 * X.hash(floor(s * 5), 2, 6)
  if t < stT then cut[#cut + 1] = k end
  local d = abs(t * len - 34)
  if s > 0.55 - 0.0 and s > 1 - (d < 3.5 and (3.5 - d) * 0.18 or 0) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
lm:cut(loose.m)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.all, 1, -1) G.cast(bias, lm, s.all, 1, 2, -1) end
X.ao(bias, lm, loose.m, 1, -1) G.cast(bias, lm, loose.m, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.04 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 4.5) / 6.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.18 and abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end end)

-- sprout from the middle seed (drawn before the seeds so the kernel sits over the stem foot)
local stok = { r = { name = "stem" } }
local sp = { { 31, 41 }, { 29, 32 }, { 34, 22 }, { 32, 13 } }
local sm, sn = G.tube(sp, function(t) return 1.05 - 0.3 * t end)
sm:cut(seeds[2].all)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local union = HP.mask()
local function lf(cx, cy, a, ra, rb)
  local m = G.rell(cx, cy, cos(a), sin(a), ra, rb):cut(sm)
  local b = {}
  X.ao(b, m, union, 1, -2) X.ao(b, m, sm, 1, -1)
  local mm = G.leaflet(c, cx, cy, a, ra, rb, LEAF, ltok, b, { cut = sm })
  union:add(mm)
end
-- side leaf (lower, to the left): short petiole + 3 leaflets
G.pline(c, { { 29, 32 }, { 25, 29 } }, STEM[2], stok)
lf(21.2, 29.5, pi + 0.25, 2.6, 1.6)
lf(24.6, 25.6, -1.9, 2.5, 1.5)
lf(25.4, 32.6, 1.75, 2.3, 1.45)
-- first pinnate leaf at the top: paired leaflets + terminal
for i, q in ipairs{ { 0.62, 2.9 }, { 0.82, 2.6 } } do
  local x, y = G.bez(sp, q[1])
  local x2, y2 = G.bez(sp, q[1] + 0.01)
  local da = atan(y2 - y, x2 - x)
  for _, side in ipairs{ -1, 1 } do
    local a = da + side * 1.15
    lf(x + cos(a) * (q[2] + 0.8), y + sin(a) * (q[2] + 0.8), a, q[2], 1.75 - i * 0.1)
  end
end
lf(32.3, 10.3, -1.62, 2.7, 1.7)
-- short root under the sprouting seed
G.pline(c, { { 32, 45 }, { 33, 48 } }, STEM[3], stok) c:put(33, 49, STEM[2], stok)

-- seeds: wings then kernel
local function drawWing(w, cx, cy, tok, vb)
  local n = X.pillow(w.m, 1.4)
  local b = {}
  if vb then X.ao(b, w.m, vb, 1, -1) end
  local idx = G.toneN(c, w.m, n, WING, { tok = tok, bias = b, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.3, wrap = 0.4 })
  -- faint radial veins
  w.m:each(function(x, y)
    local a = atan(y - cy, x - cx)
    local d = a - w.a
    d = (d + pi) % (2 * pi) - pi
    if (abs(d - 0.32) < 0.09 or abs(d + 0.32) < 0.09) and not b[K(x, y)] then
      c:put(x, y, WING[max(1, (idx[K(x, y)] or 4) - 1)], tok) end
  end)
end
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  for _, w in ipairs(s.w) do drawWing(w, s[1], s[2], tok, s.k) end
  local n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3], s.k)
  local kb = {}
  local idx = G.toneN(c, s.k, n, KERN, { tok = tok, bias = kb, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, amb = 0.06, wrap = 0.2 })
  -- glossy kernel: one specular, upper-left
  c:put(floor(s[1] - 1), floor(s[2] - 1), SPEC, tok)
end
-- split kernel on the sprouting seed: a dark crack where the stem comes out
c:put(31, 40, KERN[1], { r = { name = "seed2" } })
c:put(30, 40, STEM[2], stok)
-- loose wing
drawWing(loose, loose.cx - 5 * cos(loose.a), loose.cy - 5 * sin(loose.a), { r = { name = "loose" } })

G.save2(c, NAME)
