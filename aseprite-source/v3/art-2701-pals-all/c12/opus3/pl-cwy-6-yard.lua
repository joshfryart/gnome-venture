-- Last Forge Flame (pl-cwy-6), yard sprite 64x64. Opus richness pass (c12/opus3), built on c12/opus2.
-- Wayfinder, rare, Forge of the Cinder Wyrm. "The wyrm's last little flame from the forge, curled up and
-- dreaming of dragons."
-- Haiku stood the flame upright on a red puddle (read as a candle / ketchup). Now it is truly curled up: a
-- round, low flame lying in a little iron forge dish on its last coals, three flame licks along its back and
-- its tail tongue wrapped round the front like a sleeping cat. Heat is toned from the edge in (deep red rim,
-- orange body, gold, a cream-yellow core at the back), so the cream eyes sit on orange and stay readable.
-- Daydreaming: the locked eyes are left whole (opus2 overpainted lids on them), a small "z" drifts up. Rare: two
-- sparkles.
-- quirk: a dream bubble (three rising bubbles) with a tiny violet dragon in it, wings up.
-- closer look: the coals under it still have hot cracks; the dragon in the dream breathes a tiny puff of fire.
-- richness (opus3): plum-to-butter hue-shifted flame ramp, curling inner tongues, rising sparks, a hammered
-- iron dish that catches the flame's warm glow on its lip, ash-grey coal crust. The dream bubble and dragon are
-- now about twice as big (opus2 weak spot: dragon only readable at 2x).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-6-yard", 64)

local FL   = { "#682040", "#b02c3e", "#e64a36", "#ff8838", "#ffc246", "#ffeaa0" }
local IRON = { "#241c2e", "#352a40", "#4c3e56", "#685a72", "#8c7e94", "#b4a8b8" }
local BUB  = { "#5f7fb8", "#8bb0dc", "#b9d6ef", "#dceef8", "#eef8fc" }
local DUSK = P.dusk

c:groundShadow(30, 58, 18, 2)

-- forge dish: shallow iron bowl on two little feet, coals in the rim
O.shade(c, c:rect(17, 54, 19, 56), IRON, { R = 1, amb = .2 })
O.shade(c, c:rect(41, 54, 43, 56), IRON, { R = 1, amb = .2 })
local bowl = c:ellipse(30, 47, 19, 8)
bowl:cut(c:rect(0, 0, 63, 46))
local dI, dT = O.shade(c, bowl, IRON, { R = 3, amb = .25, wrap = .4, rim = true, bounce = "#5a5a86", bmax = 2 })
-- hammered iron: scattered dents (dark pit, lit lower lip); the lip catches the flame's warm glow
O.tex(c, dI, dT, IRON, function(x, y, i) if H(x, y, 41) > .86 and i >= 2 then return -1 end end)
for x = 13, 47 do
  if bowl:has(x, 47) and not (x >= 15 and x <= 45 and H(x, 47, 3) > .6) then O.mark(c, { { x, 47 } }, (x > 20 and x < 40) and "#b86a52" or "#8a5a5a") end
end
O.mark(c, { { 13, 48 }, { 14, 50 }, { 16, 51 } }, IRON[6])
-- rivets on the bowl band
for _, x in ipairs({ 18, 24, 30, 36, 42 }) do O.mark(c, { { x, 50 } }, IRON[2]) O.mark(c, { { x, 49 } }, IRON[5]) end
local coals = HP.mask()
for _, q in ipairs({ { 15, 45, 3 }, { 21, 44, 3 }, { 39, 44, 3 }, { 45, 45, 3 }, { 30, 45, 4 } }) do coals:add(c:ellipse(q[1], q[2], q[3], 2.2)) end
local cI, cT = O.shade(c, coals, { "#2a1c26", "#3a2630", "#4e3238", "#6a4040", "#8a5248", "#a8644e" }, { R = 2, amb = .2, sep = "#2a1c26" })
O.tex(c, cI, cT, { "#2a1c26", "#3a2630", "#4e3238", "#6a4040", "#8a5248", "#9a8e96" }, function(x, y, i) if i >= 4 and H(x, y, 8) > .7 then return 6 - i end end) -- ash crust
O.mark(c, { { 14, 45 }, { 15, 46 }, { 44, 44 }, { 45, 45 }, { 46, 45 }, { 20, 45 } }, "#ff8a3c")
O.mark(c, { { 13, 44 }, { 46, 46 } }, "#e8493b")

-- the flame: low round body, three licks along the back, tail tongue wrapping the front
local body = c:ellipse(30, 37, 14, 9)
body:add(c:poly{ { 18, 34 }, { 15, 22 }, { 22, 29 } })
body:add(c:poly{ { 23, 30 }, { 25, 17 }, { 31, 28 } })
body:add(c:poly{ { 30, 29 }, { 36, 20 }, { 38, 31 } })
local tail, tn, tT = O.tube({ { 42, 42 }, { 49, 38 }, { 49, 29 }, { 43, 25 } }, function(t) return 3.6 * (1 - t) + .5 end)
local d = X.dist(body)
local function heat(m, dd, extra)
  local tok = { r = { name = "flame" } }
  local idx = {}
  m:each(function(x, y)
    local v = dd[K(x, y)] or 0
    local i = v < 1.5 and 1 or v < 3 and 2 or v < 4.5 and 3 or 4
    if v >= 4.5 and y < 36 then i = 5 end
    if v >= 6 and y < 33 then i = 6 end
    if extra then i = extra(x, y, i) end
    -- light from upper left warms the left edge one step
    if v < 3 and (x - 30) + (y - 34) < -12 then i = math.min(6, i + 1) end
    idx[K(x, y)] = i
    c:put(x, y, FL[i], tok)
  end)
  return idx, tok
end
local fI, fT = heat(body, d)
-- tail drawn over the body (wraps the front), with its own heat from its spine
local tm = tail:copy() tm:cut(body:shrink(1))
local tI, tTk = heat(tail, X.dist(tail), function(x, y, i)
  local t = tT[K(x, y)] or 0
  if t > .8 then return math.min(i + 1, 5) end
  return i
end)
-- a dark seam where the tail lies over the body
tail:each(function(x, y) if body:has(x, y) and not tail:has(x - 1, y) then c:put(x, y, FL[1], tTk) end end)
-- curling inner tongues: arcs one tone lighter sweeping up into each lick, darker gaps beside them
O.tex(c, fI, fT, FL, function(x, y, i)
  if y > 36 and x > 20 and x < 41 then return 0 end -- face area stays smooth
  local w = (x + (y - 30) ^ 2 * .12) % 6
  if i >= 3 and i <= 5 and w < 1 then return 1 end
  if i >= 3 and i <= 4 and w > 4.6 and w < 5.4 and y < 36 then return -1 end
end)
O.mark(c, { { 16, 25 }, { 25, 20 }, { 25, 21 }, { 35, 23 } }, FL[6]) -- hot tips of the licks

-- face: low on the orange belly
c:cheek(21, 42) c:cheek(36, 42)
O.dots(c, { { 27, 42 }, { 28, 43 }, { 29, 43 }, { 30, 42 } }, P.ink)

-- quirk: dream bubble with a little dragon (big enough to read at 1x)
for _, q in ipairs({ { 44, 22, 1 }, { 46, 18, 1.4 } }) do
  O.shade(c, c:ellipse(q[1], q[2], q[3], q[3]), BUB, { sphere = { q[1] - 1, q[2] - 1, q[3] + 1 }, amb = .5, wrap = .5, cuts = { .3, .5, .7, .85 } })
end
local bub = O.unionCircles({ { 51, 9, 10.5, 7.5 }, { 45, 12, 5, 4 } })
local bI, bTk = O.shade(c, bub, BUB, { sphere = { 47, 5, 15 }, amb = .55, wrap = .5, cuts = { .3, .5, .7, .85 } })
-- dragon: tail curled left, wing raised, head right with a horn, a puff of fire
c:paint({
  "......a..........",
  ".....aa.......d..",
  "....aab......bbd.",
  "...aabb......bebf",
  "c.aabbb.....bbb.g",
  "cc.bbbbbbbbbbb...",
  ".ccbbbbbbbbbb....",
  "...db..d..db.....",
}, 42, 4, { a = DUSK.base, b = DUSK.shade, c = DUSK.deep, d = DUSK.deep, e = P.ink, f = FL[4], g = FL[5] })

O.done(c, "pl-cwy-6-yard", function(c)
  -- daydreaming: whole locked eyes, and a small "z" drifting up beside the bubble trail
  c:eyeLocked(22, 35)
  c:eyeLocked(31, 35)
  for _, p in ipairs({ { 50, 21 }, { 51, 21 }, { 52, 21 }, { 53, 21 }, { 52, 22 }, { 51, 23 }, { 50, 24 }, { 51, 24 }, { 52, 24 }, { 53, 24 } }) do c:put(p[1], p[2], BUB[3]) end
  -- sparks rising off the licks
  c:put(14, 18, FL[5]) c:put(27, 13, FL[4]) c:put(21, 9, FL[5]) c:put(38, 15, FL[4])
  c:sparkle(10, 12)
  c:sparkle(58, 30)
end)
