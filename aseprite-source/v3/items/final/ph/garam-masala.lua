-- garam-masala (aB33_0, Opus single pass). An open brass spice tin heaped with warm-brown masala: rolled bright lip,
-- two pressed beads, a red paper label wrapping the curve (cream border, gold sunburst), the powder grainy with
-- dark clove and pale cardamom flecks. In front a cinnamon quill leans on the tin (bark lines, curled spiral end),
-- a green cardamom pod and two peppercorns at its foot. Ground shadow under the tin.
-- quirk: a star anise sits on the very top of the heap, tipped at a jaunty angle like a hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, atan, cos, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.atan, math.cos, math.sin, math.pi
local NAME = "garam-masala"
local c = A.new(NAME)
local BRASS = { "#4a2a1c", "#7a4a1f", "#a8701f", "#d29a2c", "#efc65c", "#fff0a8" }
local RED   = { "#5c1a2c", "#8e2534", "#b8333a", "#dc4b3e", "#f2774f", "#ffa36c" }
local SPICE = { "#4a2019", "#73321f", "#9b4f28", "#c06f34", "#dc9447", "#f2bb6e" }
local ANISE = { "#2e1718", "#4c2420", "#6e3624", "#8f4c2c", "#b06a3a", "#d08c55" }
local BARK  = { "#3f1d17", "#62301f", "#8a4a2a", "#ad6636", "#cd8648", "#e8ac68" }
local CARD  = { "#24443a", "#36633f", "#4f8546", "#75a656", "#a3c770", "#d1e49a" }
local PEP   = { "#1f1418", "#35232a", "#4f3638", "#6c4f4c", "#8f716a", "#b89a8e" }
local CX, TOP, BOT, RX, RY = 31.5, 19, 48, 10, 3.5
local CUTS = { 0.16, 0.32, 0.48, 0.64, 0.82 }
local function off(x) local f = (x - CX) / (RX + 0.4) return RY * sqrt(max(0, 1 - f * f)) end
local function inEll(x, y, cy, rx, ry) local a, b = (x - CX) / rx, (y - cy) / ry return a*a + b*b <= 1 end

c:groundShadow(32, BOT + 4, 14, 2)

-- masks
local body, backRim, frontRim, mound = HP.mask(), HP.mask(), HP.mask(), HP.mask()
for x = 22, 41 do
  local o = off(x)
  for y = 8, 56 do
    local outer = inEll(x, y, TOP, RX + 0.4, RY + 0.4)
    local inner = inEll(x, y, TOP, 8.4, 2.6)
    local dome = y < TOP and inEll(x, y, TOP, 8.4, 5.6)
    if inner or dome then mound:set(x, y)
    elseif outer then if y < TOP then backRim:set(x, y) else frontRim:set(x, y) end
    elseif y > TOP + o and y <= BOT + o + 0.3 then body:set(x, y) end
  end
end
local function cylN(m, tilt)
  local n = {}
  m:each(function(x, y) local t = max(-0.96, min(0.96, (x - CX) / (RX + 0.6))) n[K(x, y)] = { A.norm(t, tilt or 0, sqrt(1 - t*t)) } end)
  return n
end
-- body: beads + label band follow the curve
local btok = { r = { name = "brass" } }
local bb = {}
local label = HP.mask()
body:each(function(x, y) local k = K(x, y) local r = y - off(x) -- row in "unrolled" coordinates
  if abs(r - (TOP + 2.2)) < 0.5 then bb[k] = 1 elseif abs(r - (TOP + 3.2)) < 0.5 then bb[k] = -1 end
  if abs(r - (BOT - 2.6)) < 0.5 then bb[k] = 1 elseif abs(r - (BOT - 1.6)) < 0.5 then bb[k] = -1 end
  if r >= TOP + 7 and r < TOP + 18 then label:set(x, y) end
end)
-- AO: under the rolled lip
body:each(function(x, y) local k = K(x, y) if y - off(x) < TOP + 1.2 then bb[k] = (bb[k] or 0) - 1 end end)
A.tone(c, body, cylN(body), BRASS, { bias = bb, tok = btok, amb = 0.1, cuts = CUTS })
-- vertical specular streak on the lit side
body:each(function(x, y) if x == 26 and not label:has(x, y) and y - off(x) > TOP + 3.6 then c:put(x, y, BRASS[6], btok) end end)
-- label
local ltok = { r = { name = "label" } }
local lb = {}
label:each(function(x, y) local r = y - off(x) if r < TOP + 8 or r >= TOP + 17 then lb[K(x, y)] = 9 end end)
A.tone(c, label, cylN(label), RED, { bias = lb, tok = ltok, amb = 0.12, cuts = CUTS })
label:each(function(x, y) local r = y - off(x) if r < TOP + 8 or r >= TOP + 17 then
  c:put(x, y, x > 37 and "#e9cf9e" or "#fff4d6", ltok) end end)
do -- gold sunburst on the label front (slightly left of centre, on the lit side)
  local sx, sy = 30, floor(TOP + 12.5 + off(30))
  for _, q in ipairs{ {0,0,"#fff0a8"}, {-1,0,"#f5b82e"}, {1,0,"#f5b82e"}, {0,-1,"#f5b82e"}, {0,1,"#d98322"},
                      {-2,-2,"#f5b82e"}, {2,-2,"#f5b82e"}, {-2,2,"#d98322"}, {2,2,"#d98322"}, {0,-3,"#ffe38a"}, {0,3,"#d98322"},
                      {-3,0,"#f5b82e"}, {3,0,"#d98322"} } do c:put(sx + q[1], sy + q[2], q[3], ltok) end
end
-- back rim (inside wall, darker) then the heap
local rb = {}
backRim:each(function(x, y) rb[K(x, y)] = -1 end)
A.tone(c, backRim, cylN(backRim, -0.4), BRASS, { bias = rb, tok = btok, cuts = CUTS })
local stok = { r = { name = "spice" } }
local mn = {}
mound:each(function(x, y) local a, b = (x - CX) / 9, (y - (TOP - 0.5)) / 6.4
  mn[K(x, y)] = { A.norm(a, b, sqrt(max(0.05, 1 - a*a - b*b))) } end)
local mb = {}
mound:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 3)
  if h < 0.13 then mb[k] = -2 elseif h > 0.9 then mb[k] = 1 end end)
local midx = A.tone(c, mound, mn, SPICE, { bias = mb, tok = stok, amb = 0.12, cuts = CUTS })
-- clove fleck and cardamom fleck
c:put(27, 17, ANISE[1], stok) c:put(36, 16, CARD[5], stok) c:put(33, 19, ANISE[2], stok)
-- front rim: rolled lip, bright edge
local fb = {}
frontRim:each(function(x, y) local k = K(x, y) if y - off(x) > TOP - 0.2 then fb[k] = -1 end
  if inEll(x, y + 1, TOP, 8.4, 2.6) then fb[k] = 1 end end)
A.tone(c, frontRim, cylN(frontRim, -0.5), BRASS, { bias = fb, tok = btok, amb = 0.2, cuts = CUTS })
c:put(25, 21, BRASS[6], btok) c:put(26, 21, "#fff4d6", btok)

-- quirk: star anise tipped on the summit
local atok = { r = { name = "anise" } }
local am, an = HP.mask(), {}
local ax, ay, rot = 31.6, 11.6, 0.3
for y = 5, 18 do for x = 24, 40 do
  local dx, dy = (x - ax), (y - ay) * 1.25           -- squashed: lying tilted on the heap
  local r = sqrt(dx*dx + dy*dy)
  local th = atan(dy, dx) + rot
  local petal = 1.3 + 2.9 * max(0, cos(4 * th)) ^ 1.6
  if r <= petal and r < 4.6 then am:set(x, y)
    local pc = (4 * th) - floor((4 * th + pi) / (2 * pi)) * 2 * pi -- -pi..pi within each pod
    an[K(x, y)] = { A.norm(dx / 5 + sin(pc) * 0.25, dy / 5 - 0.2, 1) } end
end end
local ab = {}
am:each(function(x, y) local dx, dy = x - ax, (y - ay) * 1.25 if dx*dx + dy*dy < 1.2 then ab[K(x, y)] = -2 end end)
local mb2 = {}
X.ao(mb2, mound, am, 1, -1) A.cast(mb2, mound, am, 1, 1, -1)
for k, v in pairs(mb2) do local x, y = k % 1024 - 256, k // 1024 - 256 if not am:has(x, y) then
  c:put(x, y, SPICE[max(1, (midx[k] or 3) + v)], stok) end end
A.tone(c, am, an, ANISE, { bias = ab, tok = atok, amb = 0.14, cuts = CUTS })
-- glossy seed in two pods
c:put(29, 10, ANISE[6], atok) c:put(34, 13, ANISE[6], atok)

-- cinnamon quill leaning on the tin, curled end at lower left
local qtok = { r = { name = "bark" } }
local qp = { { 14, 51 }, { 19, 46 }, { 24, 41 }, { 28, 37 } }
local qm, qn, QT, QS = A.tube(qp, function(t) return 2.15 end)
local qb = {}
qm:each(function(x, y) local k = K(x, y) local s, t = QS[k], QT[k]
  if abs(s + 0.05) < 0.16 and t > 0.12 then qb[k] = -2 end            -- the seam of the roll
  if abs(s - 0.55) < 0.15 and X.hash(floor(t * 9), 1, 5) > 0.35 then qb[k] = -1 end
end)
A.tone(c, qm, qn, BARK, { bias = qb, tok = qtok, amb = 0.1, cuts = CUTS })
-- AO on the tin where the quill rests
local tb = {}
A.cast(tb, body, qm, 1, 1, -1)
for k in pairs(tb) do local x, y = k % 1024 - 256, k // 1024 - 256
  if not label:has(x, y) then c:put(x, y, BRASS[2], btok) else c:put(x, y, RED[1], ltok) end end
-- curled end: spiral of the rolled bark
local em = HP.mask()
for y = 46, 56 do for x = 9, 19 do local a, b = (x - 13.2) / 2.4, (y - 51.6) / 2.6 if a*a + b*b <= 1 then em:set(x, y) end end end
em:each(function(x, y) local r = sqrt(((x - 13.2) / 2.4)^2 + ((y - 51.6) / 2.6)^2)
  c:put(x, y, r > 0.72 and BARK[5] or (r > 0.38 and BARK[2] or BARK[4]), qtok) end)
c:put(14, 52, BARK[1], qtok) c:put(12, 50, BARK[6], qtok)

-- cardamom pod + peppercorns at the foot
local cm, cn = A.oval(46.5, 50.5, 3.2, 1.7, -0.45, 0.9)
local ctok = { r = { name = "cardamom" } }
local cb = {}
cm:each(function(x, y) local k = K(x, y) if X.hash(x, y, 9) > 0.8 then cb[k] = -1 end end)
A.tone(c, cm, cn, CARD, { bias = cb, tok = ctok, amb = 0.12, cuts = CUTS })
c:put(44, 50, CARD[6], ctok)
for _, q in ipairs{ { 43.2, 54.0 }, { 51.4, 53.4 } } do
  local m = HP.ellipse(floor(q[1]), floor(q[2]), 1, 1)
  local n = X.sphere(q[1] - 0.3, q[2] - 0.3, 1.4, m)
  A.tone(c, m, n, PEP, { tok = { r = { name = "pep" } }, cuts = CUTS })
  c:put(floor(q[1]), floor(q[2]) - 1, PEP[6], {})
end

A.save(c, NAME)
