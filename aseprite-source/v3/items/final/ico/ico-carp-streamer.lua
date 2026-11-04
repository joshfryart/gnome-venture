-- ico-carp-streamer (final, Opus). A koinobori: blue cloth carp windsock flying from a slim bamboo pole, its open
-- mouth held by a gold hoop at the pole, body rippling in the wind out to a forked tail.
-- Material: body = per-pixel tube light (6-tone blue, violet shade) + wind ripples (fold bands across the cloth),
-- printed scallop scales, cream belly; dark open mouth with a lit gold hoop rim; big eye (gold ring, ink pupil, glint);
-- ember fins with ray lines; bamboo pole = 6-tone cylinder with node rings (groove + lit lip) and a gold finial ball.
-- quirk: a little sparrow is perched on the finial, unbothered by the wind.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("ico-carp-streamer")
local BLUE = { "#1c2152", "#2b3a80", "#3a5cb4", "#4e84d4", "#78b0ec", "#b4dcfa" }
local BELLY = { "#7c88b8", "#c8d4ec", "#f4f0e4" }
local FIN  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local GOLD = { "#6a3418", "#a65a1c", "#d9862a", "#f5b82e", "#ffd75e", "#fff0a8" }
local BAMB = { "#4a2c22", "#7a4a2c", "#a8703c", "#c99652", "#e6bd78", "#f8dea4" }

-- pole (painted first; the carp hoop sits in front of it)
local PX0, PX1, PY0, PY1 = 10, 12, 12, 53
local ptok = A.tok("pole")
local pole = c:rect(PX0, PY0, PX1, PY1)
local pn = {}
pole:each(function(x, y) local u = (x - 11) / 1.6 pn[K(x, y)] = { u, 0, sqrt(max(0.05, 1 - u * u)) } end)
local pidx = A.shade(c, pole, pn, BAMB, { tok = ptok, amb = 0.1, wrap = 0.2, cuts = { 0.15, 0.3, 0.5, 0.7, 0.86 } })
for _, ny in ipairs{ 33, 44 } do
  for x = PX0, PX1 do A.set(c, pidx, BAMB, x, ny, 2, ptok) end
  A.set(c, pidx, BAMB, PX0, ny - 1, 6, ptok) A.set(c, pidx, BAMB, PX0 + 1, ny - 1, 5, ptok)
end
-- finial ball
local ball = A.ell(11, 9.5, 2.6, 2.6)
local bidx = A.shade(c, ball, X.sphere(11, 9.5, 2.6, ball), GOLD, { tok = A.tok("finial"), amb = 0.1, wrap = 0.2 })
c:put(10, 8, GOLD[6], A.tok("finial"))

-- carp body: tube along a wavy bezier
local p = { { 16, 21 }, { 27, 13 }, { 37, 32 }, { 50, 22 } }
local function hw(t)
  if t < 0.12 then return 7.2 + t * 4 end
  if t < 0.5 then return 7.7 - (t - 0.12) * 1.5 end
  return max(2.0, 7.1 - ((t - 0.5) / 0.5) ^ 1.2 * 5.2)
end
local bm, bn, BT, BS, samp = A.tube(p, hw)
do local s0 = samp[1]
  bm:each(function(x, y) if (x - s0.x) * s0.tx + (y - s0.y) * s0.ty < -1.2 then bm.s[K(x, y)] = nil end end) end
-- cut a flat front so the mouth face is a clean hoop
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
local btok = A.tok("carp")
local bias = {}
bm:each(function(x, y) local k = K(x, y) local t = BT[k]
  -- wind ripples: soft fold bands across the cloth
  local r = sin(t * LEN / 8 * 2 * pi + 0.6)
  if r < -0.8 and BS[k] > -0.3 then bias[k] = -1 end
  if t > 0.9 then bias[k] = (bias[k] or 0) - 1 end
end)
local v = X.light(bn, { amb = 0.06, wrap = 0.25 })
local idx = X.tone(c, bm, v, BLUE, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 }, bias = bias, tok = btok })
-- cream belly (lower side of the tube)
local ltok = A.tok("belly")
bm:each(function(x, y) local k = K(x, y)
  if BS[k] > 0.5 and BT[k] > 0.08 and BT[k] < 0.86 then
    local i = idx[k]
    c:put(x, y, BELLY[(i >= 4) and 3 or ((i >= 2) and 2 or 1)], ltok)
    if BS[k] < 0.62 then c:put(x, y, BLUE[2], btok) end
  end end)
-- scallop scales on the blue back
bm:each(function(x, y) local k = K(x, y) local t, s = BT[k], BS[k]
  if t > 0.2 and t < 0.84 and s < 0.42 and s > -0.9 then
    local a = t * LEN / 5
    local b = (s + 1) * hw(t) / 4
    local row = floor(b)
    local fa = (a + (row % 2) * 0.5) % 1
    local fb = b - row
    local dx, dy = fa - 0.5, fb - 0.15
    local d = sqrt(dx * dx * 1.6 + dy * dy)
    if d > 0.5 and d < 0.66 and fb > 0.4 then A.step(c, idx, BLUE, x, y, -1, btok) end
    if d < 0.3 and fb < 0.5 and idx[k] and idx[k] >= 4 then A.step(c, idx, BLUE, x, y, 1, btok) end
  end end)

-- tail: forked fin past the end of the tube
local se = samp[#samp]
local ftok = A.tok("fin")
local tail = HP.mask()
local tx, ty = se.tx, se.ty
local px, py = se.px, se.py
for _, lobe in ipairs{ -1, 1 } do
  local dx, dy = A.rot(tx, ty, lobe * 0.62)
  tail:add(A.rell(se.x + dx * 4.2, se.y + dy * 4.2, dx, dy, 4.8, 2.0))
end
tail:cut(bm)
local tv = {}
tail:each(function(x, y) local rx, ry = x - se.x, y - se.y
  local s = rx * px + ry * py
  local a = rx * tx + ry * ty
  local ray = cos(math.atan(s, max(0.5, a)) * 7)
  tv[K(x, y)] = 0.5 - s * 0.05 + ray * 0.2 end)
X.tone(c, tail, tv, FIN, { cuts = { 0.25, 0.45, 0.65 }, tok = ftok })
-- pectoral fin under the head
local pf = HP.poly{ { 24, 26 }, { 29, 27 }, { 27, 32 }, { 23, 31 } }
pf:cut(bm:copy():cut(c:rect(0, 28, 63, 63)))
local pv = {}
pf:each(function(x, y) pv[K(x, y)] = ((x + y) % 3 == 0) and 0.3 or ((y < 29) and 0.55 or 0.75) end)
X.tone(c, pf, pv, FIN, { cuts = { 0.25, 0.45, 0.7 }, tok = ftok })

-- mouth: dark open interior + gold hoop rim at the head end (front face)
local s0 = samp[1]
local mtok = A.tok("mouth")
local hoop = HP.mask()
local inner = HP.mask()
for y = 10, 34 do for x = 10, 24 do
  local rx, ry = x - (s0.x + 0.3), y - s0.y
  local a = rx * s0.tx + ry * s0.ty
  local s = rx * s0.px + ry * s0.py
  local q = (a / 2.6) ^ 2 + (s / 7.6) ^ 2
  if q <= 1 then hoop:set(x, y) if (a / 1.3) ^ 2 + (s / 6.0) ^ 2 <= 1 then inner:set(x, y) end end
end end
local hv = {}
hoop:each(function(x, y) local rx, ry = x - s0.x, y - s0.y
  local s = rx * s0.px + ry * s0.py
  hv[K(x, y)] = 0.62 - s * 0.07 end)
X.tone(c, hoop, hv, GOLD, { cuts = { 0.1, 0.3, 0.46, 0.62, 0.8 }, tok = mtok })
inner:each(function(x, y) local rx, ry = x - s0.x, y - s0.y
  local s = rx * s0.px + ry * s0.py
  c:put(x, y, (s > 3.5) and "#3a2a5e" or "#1e1838", mtok) end)
-- tie cord: hoop to pole
for _, q in ipairs{ { 13, 16 }, { 13, 25 } } do c:put(q[1], q[2], BAMB[2], ptok) end

-- eye: gold ring, cream disc, ink pupil, glint
A.map(c, {
  ".ggg.",
  "gcccg",
  "gcKKg",
  "gcKKg",
  ".ggg.",
}, 21, 16, { g = GOLD[4], c = A.CREAM, K = A.INK }, A.tok("eye"))
c:put(23, 18, A.CREAM, A.tok("eye"))
c:put(21, 16, GOLD[6], A.tok("eye"))

-- quirk: a sparrow perched on the finial ball, facing right
A.map(c, {
  "....bbb.",
  "...bbKbo",
  "...bwwb.",
  "dbbbwwb.",
  ".ddbbb..",
  "....k...",
}, 7, 2, { b = "#b97a4a", K = A.INK, w = "#f4e4c8", o = "#f5b82e", d = "#6a4030", k = "#4a2c22" }, A.tok("bird"))
c:put(11, 3, "#e8b982", A.tok("bird"))
A.save(c, "ico-carp-streamer")
