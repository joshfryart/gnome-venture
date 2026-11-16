-- Aurora Thread (pl-owl-3), yard sprite 64x64. Opus richness pass (c10/opus3), built on c10/opus2.
-- Richness pass: each strand now shows its ply twist (regular lit slants along the strand), fuzzy fibre hairs
-- stick out of the ball's silhouette, the scarf has knit V columns and a ribbed hem, the tails have lit edges.
-- closer look: a tiny gold bead threaded on the loose end of the thread.
-- Bloomcaller, common. "A green and purple thread the owl wears like a scarf."
-- A round ball of aurora yarn wound in two crossing directions, strands alternating green and violet with dark
-- grooves between them (so it reads as yarn, not as a striped ball). The face sits on the front of the ball.
-- Haiku pass fixed: the pal was a banded purple ball on two leg sticks (read as a beetle or a planet).
-- quirk: it wears its own thread as a scarf. A knitted green-and-violet band wraps its middle, knotted on the
-- right, with two fringed tails flicking out in the breeze.
-- closer look: the loose end of the thread springing off the top in a little curl.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-owl-3-yard", 64)

local GRN = { "#1f4a44", "#2c7860", "#3fa878", "#72d08e", "#b2eca8", "#e4fbd2" }
local VIO = { "#2e2458", "#4a3a8a", "#6e56b8", "#9a80dc", "#c6aef2", "#ece0fc" }
local BNC = "#5a7ab0"

c:groundShadow(30, 52, 16, 2.5)


-- the ball
local cx, cy, r = 30, 32, 17
local ball = c:ellipse(cx, cy, r, r)
local bI, bT = O.shade(c, ball, GRN, { sphere = { 24, 25, 23 }, amb = .2, wrap = .45, rim = true, bounce = BNC, bmax = 2 })
-- winding: two crossing groups of strands, 3 px wide, alternating green and violet, dark grooves between
local function strand(x, y)
  local a = (x - cx) + (y - cy) * .55 < 4 and math.rad(-30) or math.rad(52)
  local s = (x - cx) * math.cos(a) + (y - cy) * math.sin(a)
  -- bend the strands round the sphere a little
  local dx, dy = (x - cx) / r, (y - cy) / r
  s = s * (1 + .25 * (dx * dx + dy * dy))
  return s
end
for k, i in pairs(bI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == bT then
    local s = strand(x, y)
    local band = math.floor(s / 3.2)
    local R = (band % 2 == 0) and GRN or VIO
    local f = s / 3.2 - band
    local ii = i
    if f < .3 then ii = i - 2 end -- groove
    -- ply twist: lit slants running across each strand
    local a = (x - cx) + (y - cy) * .55 < 4 and math.rad(-30) or math.rad(52)
    local along = -(x - cx) * math.sin(a) + (y - cy) * math.cos(a)
    if f > .4 and f < .9 and math.floor(along + f * 3) % 3 == 0 then ii = i + 1 end
    c.pix[p] = R[math.max(1, math.min(6, ii))]:lower()
  end
end
-- smooth patch for the face so it reads
local face = c:ellipse(28, 26, 9, 6)
face:clip(ball)
O.tex(c, bI, bT, GRN, function(x, y, i) if face:has(x, y) then return 0 end end)
face:each(function(x, y) c.pix[y * c.w + x] = GRN[math.max(3, math.min(6, (bI[K(x, y)] or 4)))]:lower() end)

-- closer look: a loose end of thread springing off the top in a curl
local loop = O.tube({ { 33, 16 }, { 36, 6 }, { 46, 5 }, { 43, 12 } }, function(t) return t > .85 and .9 or 1.1 end)
O.shade(c, loop, VIO, { R = 1, amb = .45, wrap = .5, nopop = true, sep = VIO[1] })
O.dots(c, { { 44, 9 }, { 45, 9 }, { 44, 10 }, { 45, 10 } }, "#f5b82e") O.dot(c, 44, 9, "#ffe38a") O.dot(c, 45, 10, "#d98322")

c:eyeLocked(21, 23)
c:eyeLocked(31, 23)
c:cheek(19, 29) c:cheek(36, 29)
O.dots(c, { { 26, 29 }, { 27, 30 }, { 28, 30 }, { 29, 29 } }, P.ink)

-- quirk: knitted scarf band round the middle
local band = HP.mask()
for x = cx - r - 1, cx + r + 1 do
  local u = (x - cx) / (r + 1)
  local yc = 36 + 3 * (1 - u * u)
  for y = math.floor(yc - 3), math.floor(yc + 2) do
    if ball:grow(1):has(x, y) then band:set(x, y) end
  end
end
local sb = {}
band:each(function(x, y)
  local u = (x - cx) / (r + 1)
  local yc = 36 + 3 * (1 - u * u)
  local row = math.floor(y - yc + 3)
  if (x + row) % 2 == 0 then sb[K(x, y)] = -1 end -- knit V texture
  if row == 0 or row == 5 then sb[K(x, y)] = (x % 2 == 0) and -2 or -1 end -- ribbed hem
end)
local function scarfPaint(m, bias, o)
  local I, T = O.shade(c, m, GRN, { R = 2, bias = bias, amb = .3, wrap = .5, rim = o and o.rim, bounce = BNC, bmax = 2, sep = GRN[1] })
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    if c.own[p] == T and math.floor((x + (o and o.ofs or 0)) / 3) % 2 == 1 then c.pix[p] = VIO[i]:lower() end
  end
end
scarfPaint(band, sb, { rim = true })
-- the knot and two tails flicking right
local knot = c:ellipse(44, 39, 2.5, 2.5)
O.shade(c, knot, VIO, { R = 1, amb = .3, wrap = .5, sep = VIO[1] })
local t1 = O.tube({ { 45, 41 }, { 48, 46 }, { 54, 47 }, { 58, 44 } }, function(t) return 2 end)
local t2 = O.tube({ { 44, 42 }, { 45, 48 }, { 49, 52 }, { 54, 53 } }, function(t) return 2 end)
local tb = {}
t2:each(function(x, y) tb[K(x, y)] = -1 end)
scarfPaint(t2, tb, { ofs = 1 })
scarfPaint(t1, {}, { ofs = 0 })
O.shade(c, knot, VIO, { R = 1, amb = .3, wrap = .5, sep = VIO[1] })

O.shift(c, -2, 2)
O.done(c, "pl-owl-3-yard", function(c)
  -- fuzz: fibre hairs sticking out of the ball (attached to the outline)
  for _, h in ipairs({ { 200, GRN[4], GRN[5] }, { 235, VIO[4], VIO[5] }, { 300, GRN[4], GRN[3] }, { 150, VIO[3], VIO[4] }, { 125, GRN[3], GRN[4] } }) do
    local a = math.rad(h[1])
    local px, py
    for d = 10, 30 do
      local x, y = math.floor(cx - 2 + math.cos(a) * d + .5), math.floor(cy + 2 + math.sin(a) * d + .5)
      if not c:get(x, y) then px, py = x, y break end
    end
    if px then
      c:put(px, py, h[2])
      local ox, oy = (math.cos(a) > .3) and 1 or ((math.cos(a) < -.3) and -1 or 0), (math.sin(a) > .3) and 1 or ((math.sin(a) < -.3) and -1 or 0)
      if ox ~= 0 then c:put(px + ox, py, h[3]) else c:put(px, py + oy, h[3]) end
    end
  end
  -- fringe on the tail ends
  for _, p in ipairs({ { 59, 46 }, { 59, 48 }, { 58, 49 }, { 55, 57 }, { 56, 55 }, { 55, 56 } }) do c:put(p[1], p[2], VIO[3]) end
end)
