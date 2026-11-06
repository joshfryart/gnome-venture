-- glowing-bead (final pass, Opus). A round amber glass bead lit from inside: hot cream core, warm body, a darker
-- glass rim, a faint swirl in the glass, a crisp specular window upper-left and a cool reflected rim lower-right.
-- It hangs on a twisted plum cord that runs through the drilled hole (dark bore collars both sides) and loops down
-- to a knot with two short tails. Cord: lit tube with diagonal twist grooves; AO where the cord meets the bead.
-- quirk: one tail has frayed into three loose threads.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan
local c = A.new("glowing-bead")
local AMB  = { "#6a2630", "#a8402c", "#dc7428", "#f6a838", "#ffd668", "#fff2b8" }
local CORD = { "#3a1834", "#5e2446", "#86345a", "#ae4e6e", "#d07888", "#eaa2a6" }
local tA, tC = { r = { name = "amber" } }, { r = { name = "cord" } }
local CX, CY, R = 32, 25, 10

-- cord loop (behind the bead first): left exit down to knot, right exit down to knot
local lm = A.cord(c, { { CX - R - 1, CY + 1 }, { 15, 34 }, { 24, 44 }, { 31, 47 } }, 1.0, CORD, { tok = tC })
local rm = A.cord(c, { { CX + R + 1, CY + 1 }, { 49, 34 }, { 40, 44 }, { 33, 47 } }, 1.0, CORD, { tok = tC })
-- tails
local t1 = A.cord(c, { { 31, 48 }, { 30, 51 }, { 29, 53 }, { 28, 56 } }, 0.8, CORD, { tok = tC })
local t2 = A.cord(c, { { 33, 48 }, { 34, 50 }, { 35, 52 }, { 36, 53 } }, 0.8, CORD, { tok = tC })
-- frayed end of the right tail (quirk): three single-pixel threads splaying
for _, p in ipairs{ { 37, 54 }, { 38, 55 }, { 36, 55 }, { 36, 56 }, { 38, 56 }, { 39, 56 } } do c:put(p[1], p[2], CORD[4], tC) end
c:put(37, 55, CORD[3], tC)
-- knot
local knot = c:ellipse(32, 47.5, 2.5, 2)
local ki = A.shade(c, knot, X.sphere(31.6, 47, 3, knot), CORD, { tok = tC })
c:put(32, 47, CORD[2], tC) c:put(31, 48, CORD[2], tC) c:put(33, 46, CORD[2], tC) -- wrap crease
c:put(31, 46, CORD[6], tC)

-- bead: emissive body + glass rim
local bead = c:ellipse(CX, CY, R, R)
local bn = X.sphere(CX, CY, R, bead)
local lam = X.light(bn, { amb = 0.05, wrap = 0.2 })
local v = {}
bead:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - CX + 1) ^ 2 + (y - CY + 0.5) ^ 2) / (R + 0.5)
  local core = max(0, 1 - d) ^ 0.7
  local rimdark = d > 0.82 and -0.22 or 0
  v[k] = core * 0.72 + lam[k] * 0.38 + rimdark
end)
local bias = {}
-- AO where cord meets the bead
for _, s in ipairs{ -1, 1 } do for dy = -2, 3 do
  local x = CX + s * R
  for dx = 0, 1 do local xx = x - s * dx local k = K(xx, CY + dy) if bead:has(xx, CY + dy) then bias[k] = -1 end end
end end
local idx = X.tone(c, bead, v, AMB, { cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 }, bias = bias, tok = tA })
-- swirl inside the glass: a curved streak one step lighter
for i = 0, 40 do
  local a = -0.4 + i / 40 * 3.2
  local r = 3 + i / 40 * 4.5
  local x, y = floor(CX + r * math.cos(a) + 0.5), floor(CY + r * math.sin(a) * 0.8 + 0.5)
  if bead:has(x, y) and (idx[K(x, y)] or 6) < 6 then A.step(c, idx, AMB, x, y, 1, tA) end
end
-- bore collars: drilled hole visible at both sides, dark ring with the cord entering
for _, s in ipairs{ -1, 1 } do
  local x = CX + s * R
  c:put(x, CY, AMB[1], tA) c:put(x, CY + 1, AMB[1], tA) c:put(x, CY + 2, AMB[2], tA) c:put(x, CY - 1, AMB[2], tA)
  c:put(x + s, CY, CORD[2], tC) c:put(x + s, CY + 1, CORD[3], tC) c:put(x + s, CY + 2, CORD[2], tC)
end
-- specular window (glossy glass: two marks allowed) + cream core
c:put(CX - 5, CY - 6, A.CREAM, tA) c:put(CX - 4, CY - 6, A.CREAM, tA) c:put(CX - 5, CY - 5, A.CREAM, tA)
c:put(CX - 6, CY - 4, AMB[6], tA)
c:put(CX + 4, CY - 7, AMB[6], tA)
-- cool reflected light lower-right rim
local rim = X.rim(bn)
bead:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y > CY + 2 then c:put(x, y, "#c0587a", tA) end end)
-- one sparkle of glow escaping upper-right
c:sparkle(46, 11)

A.save(c, "glowing-bead")
