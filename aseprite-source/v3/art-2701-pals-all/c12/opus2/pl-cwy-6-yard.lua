-- Last Forge Flame (pl-cwy-6), yard sprite 64x64. Opus second pass (c12/opus2), built on c12/haiku.
-- Wayfinder, rare, Forge of the Cinder Wyrm. "The wyrm's last little flame from the forge, curled up and
-- dreaming of dragons."
-- Haiku stood the flame upright on a red puddle (read as a candle / ketchup). Now it is truly curled up: a
-- round, low flame lying in a little iron forge dish on its last coals, three flame licks along its back and
-- its tail tongue wrapped round the front like a sleeping cat. Heat is toned from the edge in (deep red rim,
-- orange body, gold, a cream-yellow core at the back), so the cream eyes sit on orange and stay readable.
-- Eyes half-lidded: drowsy. Rare: two sparkles.
-- quirk: a dream bubble (three rising bubbles) with a tiny violet dragon in it, wings up.
-- closer look: the coals under it still have hot cracks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-6-yard", 64)

local FL   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a3c", "#ffc048", "#ffe89a" }
local IRON = { "#241c2e", "#352a40", "#4c3e56", "#685a72", "#8c7e94", "#b4a8b8" }
local BUB  = { "#5f7fb8", "#8bb0dc", "#b9d6ef", "#dceef8", "#eef8fc" }
local DUSK = P.dusk

c:groundShadow(30, 58, 18, 2)

-- forge dish: shallow iron bowl on two little feet, coals in the rim
O.shade(c, c:rect(17, 54, 19, 56), IRON, { R = 1, amb = .2 })
O.shade(c, c:rect(41, 54, 43, 56), IRON, { R = 1, amb = .2 })
local bowl = c:ellipse(30, 47, 19, 8)
bowl:cut(c:rect(0, 0, 63, 46))
local dI, dT = O.shade(c, bowl, IRON, { R = 3, amb = .25, wrap = .4, rim = true })
O.mark(c, { { 13, 48 }, { 14, 50 }, { 16, 51 } }, IRON[6])
-- rivets on the bowl band
for _, x in ipairs({ 18, 24, 30, 36, 42 }) do O.mark(c, { { x, 50 } }, IRON[2]) O.mark(c, { { x, 49 } }, IRON[5]) end
local coals = HP.mask()
for _, q in ipairs({ { 15, 45, 3 }, { 21, 44, 3 }, { 39, 44, 3 }, { 45, 45, 3 }, { 30, 45, 4 } }) do coals:add(c:ellipse(q[1], q[2], q[3], 2.2)) end
local cI, cT = O.shade(c, coals, { "#2a1c26", "#3a2630", "#4e3238", "#6a4040", "#8a5248", "#a8644e" }, { R = 2, amb = .2, sep = "#2a1c26" })
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
-- flicker streaks in the body (upward strokes one tone lighter)
O.tex(c, fI, fT, FL, function(x, y, i)
  if y > 37 and x > 22 and x < 40 then return 0 end
  if i >= 3 and i <= 4 and (x * 5 + y * 2) % 13 == 0 then return 1 end
end)

-- face: low on the orange belly
c:cheek(21, 42) c:cheek(36, 42)
O.dots(c, { { 27, 42 }, { 28, 43 }, { 29, 43 }, { 30, 42 } }, P.ink)

-- quirk: dream bubble with a little dragon
for _, q in ipairs({ { 44, 21, 1 }, { 47, 17, 1.5 } }) do
  O.shade(c, c:ellipse(q[1], q[2], q[3], q[3]), BUB, { sphere = { q[1] - 1, q[2] - 1, q[3] + 1 }, amb = .5, wrap = .5, cuts = { .3, .5, .7, .85 } })
end
local bub = O.unionCircles({ { 52, 9, 7.5, 6.5 }, { 47, 11, 4, 3.5 }, { 57, 12, 4, 3.5 } })
local bI, bTk = O.shade(c, bub, BUB, { sphere = { 49, 6, 11 }, amb = .55, wrap = .5, cuts = { .3, .5, .7, .85 } })
c:paint({
  ".....a......",
  "....aa......",
  "...abb....c.",
  "..abbb...bbb",
  "c..bbbbbbbb.",
  ".cbbbbbbb...",
  "...c.c..c.c.",
}, 46, 4, { a = DUSK.base, b = DUSK.shade, c = DUSK.deep })
O.dot(c, 56, 7, P.ink)

O.done(c, "pl-cwy-6-yard", function(c)
  -- drowsy half-lidded eyes: locked eyes with the top two rows closed by a flame-coloured lid and an ink lash line
  for _, e in ipairs({ { 22, 35 }, { 31, 35 } }) do
    c:eyeLocked(e[1], e[2])
    for i = 1, 3 do c:put(e[1] + i, e[2], FL[4]) end
    for i = 0, 4 do c:put(e[1] + i, e[2] + 1, P.ink) end
    c:put(e[1] + 1, e[2] + 2, P.cream)
  end
  c:sparkle(10, 12)
  c:sparkle(58, 30)
end)
