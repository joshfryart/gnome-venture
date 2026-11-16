-- Frostwart Bumps (pl-frt-4), yard sprite 64x64. Opus richness pass (c09/opus3), built on c09/opus2.
-- Thornblade, uncommon, Barrow of the Frost Toad. "Four frosty warts off the toad's back that go bump in the cold."
-- A squat patch of frost-toad back: mossy sage skin (6-tone, teal deep -> lime light) with darker toad spots,
-- goosebump grain and a pale belly, two stubby toed front feet, four warts along its top. Richness: each wart
-- has its own pimples and a pore, frost caps with hanging icicle points, crystal glints.
-- quirk: one wart "goes bump": it has hopped clean off the back (opus2 had it on a stalk, which read as a little
-- tree) and hangs in the air over the empty dimple it left, with bump ticks.
-- closer look: a single snowflake has landed on the left wart's cap, and the toad's goosebumps (cold).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-4-yard", 64)

local TOAD = { "#1d3540", "#2b5648", "#467a50", "#72a05a", "#a5c676", "#d2e4a2" }
local BELLY = { "#8fb86a", "#bcd88a", "#dcecb0", "#f0f8d4" }
local ICE = { "#3a5a9a", "#5a8cd0", "#86c2ea", "#b6e0f5", "#e0f4fc", "#f2fbff" }

c:groundShadow(32, 54, 21, 2.5)

-- feet first (behind the body front)
for _, fx in ipairs({ 21, 43 }) do
  local f = c:ellipse(fx, 51, 4, 2)
  O.shade(c, f, TOAD, { R = 2, amb = .35, wrap = .4, sep = TOAD[1] })
end

-- body: squat dome with a dimple on top where the jumping wart came out
local body = c:ellipse(32, 41, 20, 11)
body:cut(c:rect(0, 51, 63, 63))
body:cut(c:ellipse(38, 29.5, 3.5, 2))
local bI, bT = O.shade(c, body, TOAD, { sphere = { 27, 34, 24 }, amb = .3, wrap = .45, rim = true, bounce = "#4a6aa8", bmax = 2 })
O.tex(c, bI, bT, TOAD, function(x, y, i)
  if (x >= 19 and x <= 45 and y >= 36 and y <= 48) then return 0 end
  -- toad spots (irregular blotches, darker centre)
  local h = H(x // 3, y // 3, 7)
  if h > .74 and H(x, y, 3) > .2 then return (i >= 4) and -2 or -1 end
  -- goosebump grain: a lit speck with a dark pixel under it
  if i >= 3 and H(x, y, 11) > .9 then return 1 end
  if i >= 3 and H(x, y - 1, 11) > .9 then return -1 end
end)
-- the empty dimple: a dark socket with a lit lower lip
O.dots(c, { { 35, 31 }, { 36, 32 }, { 37, 32 }, { 38, 32 }, { 39, 32 }, { 40, 32 }, { 41, 31 } }, TOAD[1])
O.dots(c, { { 36, 33 }, { 37, 33 }, { 38, 33 }, { 39, 33 }, { 40, 33 } }, TOAD[2])
O.dots(c, { { 37, 34 }, { 38, 34 }, { 39, 34 } }, TOAD[5])

-- pale belly band low on the front
local belly = c:ellipse(32, 50, 12, 4):clip(body)
local beI, beT = O.shade(c, belly, BELLY, { R = 2, amb = .45, wrap = .4, cuts = { .35, .6, .85 } })
O.tex(c, beI, beT, BELLY, function(x, y, i) if y == 49 and x % 3 == 0 and i >= 2 then return -1 end end)

-- toes on the feet (over the belly edge)
for _, fx in ipairs({ 18, 21, 24, 40, 43, 46 }) do O.dot(c, fx, 52, TOAD[2]) end
for _, fx in ipairs({ 17, 20, 23, 39, 42, 45 }) do O.dot(c, fx, 51, TOAD[5]) end

-- four warts along the top; the third one has jumped up into the air
local warts = { { 16, 34, 5 }, { 26, 29, 5.5 }, { 38, 18, 5.5 }, { 48, 34, 5 } }
for wi, w in ipairs(warts) do
  local cx, cy, r = w[1], w[2], w[3]
  local m = c:ellipse(cx, cy, r, r - .5)
  local I, T = O.shade(c, m, TOAD, { sphere = { cx - 2, cy - 2, r + 2 }, amb = .3, wrap = .4, rim = true, bounce = "#4a6aa8", bmax = 2, sep = TOAD[1] })
  -- pimples on the wart skin and a pore
  O.tex(c, I, T, TOAD, function(x, y, i)
    if y > cy and H(x, y, 20 + wi) > .8 and i >= 2 then return 1 end
    if y > cy and H(x, y - 1, 20 + wi) > .8 and i >= 3 then return -1 end
  end)
  O.dot(c, cx + 1, cy + 2, TOAD[1])
  -- frost cap with icicle points hanging over its edge
  local cap = HP.mask()
  m:each(function(x, y)
    local drip = (H(x, 1, wi) > .55) and 1 or 0
    if y <= cy - 1 + drip then cap:set(x, y) end
  end)
  O.shade(c, cap, ICE, { sphere = { cx - 2, cy - 3, r + 1 }, amb = .35, wrap = .5 })
  for x = math.floor(cx - r + 2), math.floor(cx + r - 2) do
    if H(x, 5, wi) > .62 then
      local y0 = cy + ((H(x, 1, wi) > .55) and 1 or 0)
      if m:has(x, y0) then O.dot(c, x, y0, ICE[4]) end
      if m:has(x, y0 + 1) and H(x, 6, wi) > .5 then O.dot(c, x, y0 + 1, ICE[3]) end
    end
  end
  -- crystal glints
  O.dot(c, cx - 2, cy - 3, ICE[6]) O.dot(c, cx - 1, cy - 4, ICE[6]) O.dot(c, cx - 3, cy - 2, ICE[5])
  O.dot(c, cx + 2, cy - 2, ICE[2])
end
-- snowflake landed on the left wart's cap
O.dots(c, { { 15, 30 }, { 14, 31 }, { 16, 31 }, { 15, 32 } }, ICE[2])
O.dot(c, 15, 31, ICE[6])

-- face
c:eyeLocked(22, 38)
c:eyeLocked(37, 38)
c:cheek(20, 44) c:cheek(43, 44)
-- wide toad grin with a lit lower lip
O.dots(c, { { 27, 45 }, { 28, 46 }, { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 }, { 34, 46 }, { 35, 46 }, { 36, 45 } }, P.ink)
O.dots(c, { { 30, 47 }, { 31, 47 }, { 32, 47 }, { 33, 47 } }, TOAD[5])
O.dots(c, { { 31, 44 }, { 32, 44 } }, TOAD[3]) -- nostril dents
O.dots(c, { { 30, 44 }, { 33, 44 } }, TOAD[2])

O.done(c, "pl-frt-4-yard", function(c)
  -- bump ticks above and motion ticks below the jumping wart
  O.dots(c, { { 32, 12 }, { 31, 11 }, { 38, 8 }, { 38, 9 }, { 44, 12 }, { 45, 11 } }, ICE[3])
  for _, p in ipairs({ { 34, 26 }, { 34, 27 }, { 42, 26 }, { 42, 27 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], ICE[3]) end
  end
end)
