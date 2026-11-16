-- Whirl Pincer (pl-hcr-4), yard sprite 64x64. Opus second pass (c14/opus2), built on c14/haiku.
-- Thornblade, uncommon, Lair of the Hurricane Crab. "Four pincers spun into a whirl and stuck together."
-- Haiku drew four straight red sticks on a ball (it read as a jack or a molecule). Now four real crab arms,
-- each curving the same way round like a pinwheel and ending in an open pincer with dark fingertips, joined
-- at a pale belly-shell hub that carries the face. Arm segments have joints and pale bands.
-- quirk: it is spinning: curved swish arcs trail behind every arm.
-- closer look: the hub's crab-belly plates (a T of seams below the mouth) and one chipped fingertip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-hcr-4-yard", 64)
local cos, sin, pi, floor = math.cos, math.sin, math.pi, math.floor

local CRAB = { "#5c1626", "#962a30", "#c8443a", "#e8683e", "#f69460", "#fcc494" }
local TIP  = { "#2e1a24", "#4a2830", "#6a3a3a", "#8c5048" }
local BELY = { "#8a5a54", "#bf8a72", "#e2b892", "#f4d6ac", "#fcecca", "#fff6e2" }
local SWSH = "#e4ecf0"

local HX, HY = 32, 30
local function D(a, r) return HX + r * cos(a * pi / 180), HY + r * sin(a * pi / 180) end

c:groundShadow(32, 58, 14, 2.5)

local tips = {}
for i = 0, 3 do
  local a = -60 + 90 * i
  local x0, y0 = D(a, 5) local x1, y1 = D(a, 12) local x2, y2 = D(a + 22, 16) local x3, y3 = D(a + 40, 17.5)
  local m, n, T = O.tube({ { x0, y0 }, { x1, y1 }, { x2, y2 }, { x3, y3 } }, function(t) return 3.2 - 1 * t end)
  local I, Tk = O.shadeN(c, m, n, CRAB, { amb = .3, wrap = .42, rim = true, bounce = "#7a5a8a", bmax = 2, sep = CRAB[1] })
  O.tex(c, I, Tk, CRAB, function(x, y, i) local t = T[K(x, y)] if t and math.abs(t - .45) < .035 then return -2 end
    if t and math.abs(t - .5) < .03 then return 1 end end) -- joint and pale band
  -- the claw: a fat palm and two fingers pointing on round the circle
  local ex, ey = D(a + 46, 19)
  local ta = (a + 46 + 90) * pi / 180 -- travel direction (clockwise)
  local palm = c:ellipse(ex, ey, 4.2, 4.2)
  O.shade(c, palm, CRAB, { sphere = { ex - 2, ey - 2, 6 }, amb = .3, wrap = .45, rim = true, sep = CRAB[1] })
  for j, s in ipairs({ { -32, 3.4, 6.5 }, { 30, 2.6, 5.5 } }) do
    local fa = ta + s[1] * pi / 180
    local bx, by = ex + 2.5 * cos(fa), ey + 2.5 * sin(fa)
    local qx, qy = ex + s[3] * cos(fa) + 3.2 * cos(ta), ey + s[3] * sin(fa) + 3.2 * sin(ta)
    local mx, my = (bx + qx) / 2 + 1.2 * cos(ta - (s[1] > 0 and -1 or 1) * pi / 2), (by + qy) / 2 + 1.2 * sin(ta - (s[1] > 0 and -1 or 1) * pi / 2)
    local fm, fn, fT = O.tube({ { bx, by }, { mx, my }, { mx, my }, { qx, qy } }, function(t) return s[2] * (1 - t) ^ .8 + .5 end)
    local fI, fTk = O.shadeN(c, fm, fn, CRAB, { amb = .3, wrap = .45, sep = CRAB[1] })
    -- dark fingertips (real crab claws darken at the tips)
    fm:each(function(x, y) local t = fT[K(x, y)] if t and t > .62 and c.own[y * 64 + x] == fTk then c.pix[y * 64 + x] = (t > .82 and TIP[2] or TIP[3]) end end)
    tips[#tips+1] = { qx, qy }
  end
end

-- hub: pale crab-belly shell with the face
local hub = c:ellipse(HX, HY, 9.5, 9)
local hI, hT = O.shade(c, hub, BELY, { sphere = { HX - 3, HY - 4, 13 }, amb = .35, wrap = .5, rim = true, bounce = "#9a7aa0", bmax = 2, sep = BELY[1] })
O.mark(c, { { 32, 37 }, { 32, 38 }, { 29, 36 }, { 30, 36 }, { 34, 36 }, { 35, 36 } }, BELY[2]) -- belly plate seams
-- chipped fingertip: the last claw loses a pixel at its point
local ct = tips[3] O.mark(c, { { floor(ct[1] + .5), floor(ct[2] + .5) } }, TIP[4])

c:eyeLocked(26, 25)
c:eyeLocked(33, 25)
c:cheek(25, 31) c:cheek(37, 31)
O.dots(c, { { 30, 32 }, { 31, 33 }, { 32, 33 }, { 33, 32 } }, P.ink)
O.dots(c, { { 25, 23 }, { 26, 22 }, { 27, 22 }, { 36, 22 }, { 37, 22 }, { 38, 23 } }, P.ink) -- keen brows

O.done(c, "pl-hcr-4-yard", function(c)
  -- swish arcs trailing each arm (counter to the spin)
  for i = 0, 3 do
    local a = -60 + 90 * i
    for k = 0, 6 do
      local x, y = D(a + 8 - k * 5, 24)
      x, y = floor(x + .5), floor(y + .5)
      if not c:get(x, y) and k ~= 3 then O.dot(c, x, y, SWSH) end
    end
  end
end)
