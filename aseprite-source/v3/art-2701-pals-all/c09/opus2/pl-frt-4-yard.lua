-- Frostwart Bumps (pl-frt-4), yard sprite 64x64. Opus second pass (c09/opus2), built on the c09/haiku concept.
-- Thornblade, uncommon, Barrow of the Frost Toad. "Four frosty warts off the toad's back that go bump in the cold."
-- A squat patch of frost-toad back: mossy sage skin with darker toad spots and a pale belly, two stubby front
-- feet, and four big warts along its top, each one capped with a crust of frost that drips over its edge.
-- quirk: one wart "goes bump": it has popped up higher than the others, with bump ticks above it.
-- closer look: a tiny icicle hanging from the frost cap of the left wart.
-- Fixes over haiku: blue blob with purple warts read as a bush/flower (now toad skin with frost-capped warts),
-- flat ramps (now 6-tone skin and ice), tiny feet lost under the body (now stubby toed feet).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-4-yard", 64)

local TOAD = { "#1f3a3a", "#2e5a48", "#4a7d52", "#76a35e", "#a8c97a", "#d4e6a6" }
local BELLY = { "#8fb86a", "#bcd88a", "#dcecb0", "#f0f8d4" }
local ICE = { "#3a5f9a", "#5f8fd0", "#8bc4ea", "#b9e2f5", "#e4f6ff", "#f4fcff" }

c:groundShadow(32, 54, 21, 2.5)

-- feet first (behind the body front)
for _, fx in ipairs({ 21, 43 }) do
  local f = c:ellipse(fx, 51, 4, 2)
  local I, T = O.shade(c, f, TOAD, { R = 2, amb = .35, wrap = .4, sep = TOAD[1] })
end

-- body: squat dome
local body = c:ellipse(32, 41, 20, 11)
body:cut(c:rect(0, 51, 63, 63))
local bI, bT = O.shade(c, body, TOAD, { sphere = { 27, 34, 24 }, amb = .3, wrap = .45, rim = true, bounce = "#4a6aa0", bmax = 2 })
-- toad spots
O.tex(c, bI, bT, TOAD, function(x, y, i)
  if (x >= 19 and x <= 45 and y >= 36 and y <= 48) then return 0 end
  local h = H(x // 3, y // 3, 7)
  if h > .74 and H(x, y, 3) > .2 then return (i >= 4) and -2 or -1 end
  if H(x, y, 11) > .93 and i >= 3 then return 1 end
end)
-- pale belly band low on the front
local belly = c:ellipse(32, 50, 12, 4):clip(body)
O.shade(c, belly, BELLY, { R = 2, amb = .45, wrap = .4, cuts = { .35, .6, .85 } })

-- toes on the feet (over the belly edge)
for _, fx in ipairs({ 18, 21, 24, 40, 43, 46 }) do O.dot(c, fx, 52, TOAD[2]) end

-- four warts along the top; the third one bumps up
local warts = { { 16, 34, 5 }, { 26, 29, 5.5 }, { 38, 22, 5.5 }, { 48, 34, 5 } }
for wi, w in ipairs(warts) do
  local cx, cy, r = w[1], w[2], w[3]
  local m = c:ellipse(cx, cy, r, r - .5)
  if wi == 3 then m:add(c:rect(cx - 2, cy, cx + 2, 31)) end -- little stalk: it has hopped up out of the skin
  O.shade(c, m, TOAD, { sphere = { cx - 2, cy - 2, r + 2 }, amb = .3, wrap = .4, rim = true, sep = TOAD[1] })
  -- frost cap with a drippy edge
  local cap = HP.mask()
  m:each(function(x, y)
    local drip = (H(x, 1, wi) > .55) and 1 or 0
    if y <= cy - 1 + drip then cap:set(x, y) end
  end)
  local I, T = O.shade(c, cap, ICE, { sphere = { cx - 2, cy - 3, r + 1 }, amb = .35, wrap = .5 })
  O.dot(c, cx - 2, cy - 3, ICE[6]) O.dot(c, cx - 1, cy - 4, ICE[6])
end
-- icicle off the left wart's cap
O.dots(c, { { 19, 34 }, { 19, 35 } }, ICE[4]) O.dot(c, 19, 36, ICE[3])

-- face
c:eyeLocked(22, 38)
c:eyeLocked(37, 38)
c:cheek(20, 44) c:cheek(43, 44)
-- wide toad grin
O.dots(c, { { 27, 45 }, { 28, 46 }, { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 }, { 34, 46 }, { 35, 46 }, { 36, 45 } }, P.ink)
O.dots(c, { { 31, 47 }, { 32, 47 } }, TOAD[2])

O.done(c, "pl-frt-4-yard", function(c)
  -- bump ticks above the jumping wart
  O.dots(c, { { 32, 14 }, { 31, 13 }, { 38, 10 }, { 38, 11 }, { 44, 14 }, { 45, 13 } }, ICE[2])
end)
