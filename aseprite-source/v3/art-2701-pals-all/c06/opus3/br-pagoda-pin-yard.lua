-- Pagoda Pin (br-pagoda-pin), yard sprite 64x64. Opus richness pass (c06/opus3), built on c06/opus2.
-- Uncommon, rootwarden. "Points to the top of the pagoda and says it was up there first."
-- The pal is a little three-tier pagoda: ember-red tiled roofs with swept-up eave tips, warm wood walls with red
-- corner posts, a gold spire with stacked rings, on a stone step. Its face is on the big ground-floor wall and
-- one little arm reaches out and points straight up at the top.
-- Richness: round tile-end caps along every eave and tile courses on the roofs, plank grain and knots on the
-- walls, a lattice window, cut stone blocks with mortar lines on the step.
-- quirk: it was up there first, and proved it: its pennant (now a bigger swallow-tail flag with a cream
-- dot) flutters on the very tip of the spire. Closer look: a sparrow sits on the lowest eave tip, unbothered.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-pagoda-pin-yard", 64)

local ROOF = { "#4a1420", "#7a1e26", "#aa2e2a", "#d24a32", "#ec7a4a", "#f8ae7a" }
local WALL = { "#4a2a22", "#6e4430", "#946240", "#b88458", "#d6a878", "#eccaa0" }
local POST = { "#5a1a1e", "#8e2a26", "#c0402e" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local STON = { "#3a3446", "#58526a", "#7c7890", "#a4a2b4", "#c8c8d2" }
local FLAG = { "#a8283a", "#e04a4a", "#f8e6c8" }
local BNC  = "#5a6a9a"

c:groundShadow(32, 55, 20, 2.5)

-- stone step
local step = c:rect(13, 49, 51, 52)
local sb = {} step:each(function(x, y) if y == 49 then sb[K(x, y)] = 1 end
  if y > 49 and (x + (y > 50 and 4 or 0)) % 8 == 0 then sb[K(x, y)] = -2 end end)
O.shade(c, step, STON, { R = 2, amb = .3, wrap = .4, bias = sb, rim = true, bounce = BNC, bmax = 2, cuts = { .25, .45, .65, .85 } })

local function wall(x0, y0, x1, y1)
  local m = c:rect(x0, y0, x1, y1)
  local b = {} m:each(function(x, y) if y == y0 then b[K(x, y)] = -2 end if x % 3 == 0 and y > y0 then b[K(x, y)] = -1 end end)
  local wI, wT = O.shade(c, m, WALL, { R = 3, amb = .3, wrap = .4, bias = b, sep = WALL[1], rim = true, bounce = BNC, bmax = 2 })
  -- plank grain dashes and a knot here and there
  O.tex(c, wI, wT, WALL, function(x, y, i)
    if x >= 21 and x <= 43 and y >= 35 and y <= 47 then return 0 end -- keep the face clean
    if x % 3 ~= 0 and y > y0 + 1 and (y * 5 + x * 3) % 11 == 0 and O.H(x, y, 6) > .3 then return -1 end
    if x % 3 == 1 and (y * 7 + x) % 23 == 0 then return 1 end
  end)
  O.flat(c, c:rect(x0, y0 + 1, x0 + 1, y1), POST[3], "post") O.flat(c, c:rect(x1 - 1, y0 + 1, x1, y1), POST[2], "post")
  O.dots(c, { { x0, y0 + 1 }, { x0, y0 + 2 } }, "#e06048")
end
local function roof(y0, y1, xl, xr)
  local m = c:poly{ { xl + 7, y0 }, { xr - 7, y0 }, { xr - 1, y1 - 2 }, { xr + 2, y1 - 4 }, { xr + 1, y1 - 1 }, { xr - 2, y1 },
                    { xl + 2, y1 }, { xl - 1, y1 - 1 }, { xl - 2, y1 - 4 }, { xl + 1, y1 - 2 } }
  local b = {} m:each(function(x, y)
    if y == y1 then b[K(x, y)] = -3 elseif y == y1 - 1 then b[K(x, y)] = 1 elseif x % 3 == 0 then b[K(x, y)] = -2 else b[K(x, y)] = -1 end
  end)
  local rI, rT = O.shade(c, m, ROOF, { R = 2, amb = .3, wrap = .45, bias = b, sep = ROOF[1], rim = true, bounce = BNC, bmax = 2 })
  -- tile courses (a darker row every 2) and round tile-end caps along the eave
  O.tex(c, rI, rT, ROOF, function(x, y, i)
    if y == y1 and x % 3 == 1 then return 3 end
    if y < y1 - 1 and (y - y0) % 2 == 1 and x % 3 ~= 0 then return -1 end
  end)
  O.dots(c, { { xl - 2, y1 - 4 }, { xr + 2, y1 - 4 } }, GOLD[3]) -- gold bells on the eave tips
end

-- ground floor wall (face) + tiers, bottom up
wall(17, 33, 47, 48)
roof(27, 34, 8, 56)
wall(23, 22, 41, 27)
roof(17, 23, 14, 50)
wall(28, 13, 36, 17)
roof(9, 14, 20, 44)

-- spire: rod with stacked gold rings, rooted in the top roof
local rod = c:rect(31, 2, 32, 9)
O.shade(c, rod, GOLD, { R = 1, amb = .35, sep = GOLD[1], cuts = { .25, .45, .65, .85 } })
for _, y in ipairs({ 4, 6, 8 }) do
  O.shade(c, c:rect(30, y, 33, y), GOLD, { R = 1, amb = .35, sep = GOLD[1], cuts = { .25, .45, .65, .85 } })
  O.dot(c, 30, y, GOLD[5])
end
-- quirk: its pennant planted on the very tip: a swallow-tail flag fluttering right, cream dot emblem
O.pat(c, 33, 0, { "bbb....", "bwbbbc.", "bbbbccc", "bbc..cc" }, { b = FLAG[2], w = FLAG[3], c = FLAG[1] }, "pennant")

-- windows on the upper walls
O.pat(c, 30, 23, { "acaca", "ccccc", "acaca" }, { a = WALL[1], b = "#c0402e", c = WALL[2] }, "window") -- lattice
-- closer look: a sparrow sitting on the lowest left eave tip, unbothered
O.pat(c, 4, 26, { ".hh..", "khbbt", ".cbb." }, { h = "#7a4a2e", k = "#f0aa2a", b = "#a8724a", c = "#eccaa0", t = "#4a2a22" }, "sparrow")
O.dot(c, 5, 26, P.ink)
-- face on the ground floor
c:eyeLocked(23, 37)
c:eyeLocked(36, 37)
O.dots(c, { { 29, 44 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 44 } }, P.ink) -- proud grin
O.dots(c, { { 31, 46 }, { 32, 46 } }, "#c0402e")
c:cheek(20, 43) c:cheek(42, 43)
-- little door under the grin
O.flat(c, c:rect(30, 47, 33, 48), WALL[1], "door") O.dot(c, 32, 47, GOLD[3])

-- arm: out of the right wall, then straight up, index finger pointing at the top
local arm, an = O.tube({ { 47, 42 }, { 52, 42 }, { 55, 40 }, { 56, 35 } }, function(t) return 1.1 end)
O.shadeN(c, arm, an, WALL, { amb = .35, wrap = .4, sep = WALL[1] })
-- fist with the index finger straight up
local fist = c:rect(55, 31, 58, 34)
O.shade(c, fist, WALL, { R = 1, amb = .35, wrap = .4, sep = WALL[1] })
O.dots(c, { { 56, 33 }, { 57, 33 } }, WALL[2]) -- curled finger line
O.shade(c, c:rect(55, 25, 56, 30), WALL, { R = 1, amb = .45, sep = WALL[1] })

O.shift(c, 0, 2)
O.done(c, "br-pagoda-pin-yard", function(c)
  -- "up there!" ticks beside the finger (un-outlined)
  for _, p in ipairs({ { 59, 22 }, { 60, 21 }, { 52, 22 }, { 51, 21 }, { 56, 20 }, { 56, 19 } }) do
    local y = p[2] + 2 if not c.pix[y * c.w + p[1]] then c:put(p[1], y, GOLD[4]) end
  end
end)
