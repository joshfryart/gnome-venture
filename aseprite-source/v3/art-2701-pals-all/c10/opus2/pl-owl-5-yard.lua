-- Snowcrag Halo (pl-owl-5), yard sprite 64x64. Opus second pass (c10/opus2), built on c10/haiku.
-- Rootwarden, uncommon. "A round snowy hollow where the owlets nap under the aurora."
-- A plump snow mound on a grey crag: the top is scooped into a round hollow (deep blue shadow inside, lit lip on
-- the far rim), dark crag rock breaks through the snow low on both sides, and an aurora ring floats over the
-- hollow like a halo (green front, violet back). The face sits on the snowy front.
-- Haiku pass fixed: it was a pale blue blob with a floating arc (read as a slime); no hollow, no crag.
-- quirk: two tiny owlets asleep in the hollow, just their round grey heads showing, eyes shut, one "z".
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-owl-5-yard", 64)

local SNOW = { "#3a4a78", "#5f7aa8", "#8eaccc", "#bcd4e6", "#e0eef4", "#f6fbfa" }
local ROCK = { "#2e2c40", "#47465e", "#666780", "#8a8ca2", "#aeb0c2" }
local OWL  = { "#6a6482", "#9a94b0", "#c4c0d4", "#e2e0ea", "#f6f4f6" }
local GRN  = { "#24544a", "#2f8a6a", "#4fc08e", "#9aeab4", "#d6fbe0" }
local VIO  = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }
local GOLD = { "#d98322", "#f5b82e" }

c:groundShadow(32, 56, 24, 2.5)

-- aurora halo, back half (behind the mound)
local ringO, ringI = c:ellipse(32, 13, 17, 5), c:ellipse(32, 13, 14, 3)
local back = ringO:copy():cut(ringI):clip(c:rect(0, 0, 63, 12))
O.shade(c, back, VIO, { R = 1, amb = .45, wrap = .5, cuts = { .3, .55, .8 }, nopop = true })

-- crag rock under the snow
local rock = O.unionCircles{ { 13, 48, 6, 6 }, { 51, 49, 6, 5 }, { 22, 52, 6, 3 }, { 42, 52, 6, 3 } }
local rI, rT = O.shade(c, rock, ROCK, { R = 2, amb = .25, wrap = .4, cuts = { .25, .45, .65, .85 }, bounce = "#5a6a98", bmax = 2 })
O.tex(c, rI, rT, ROCK, function(x, y, i) if (x * 3 + y * 5) % 11 == 0 and i >= 2 then return -1 end end) -- cracks

-- the snow mound with its scooped top
local mound = c:ellipse(32, 40, 21, 13)
mound:add(c:ellipse(32, 30, 18, 6))
mound:cut(c:rect(0, 53, 63, 63))
local mb = {}
mound:each(function(x, y) if y > 44 and H(x, y, 11) > .8 then mb[K(x, y)] = -1 end end)
local sI, sT = O.shade(c, mound, SNOW, { sphere = { 26, 30, 28 }, bias = mb, amb = .35, wrap = .55, rim = true, bounce = "#7a8ad0", bmax = 3, sep = ROCK[1] })
-- the hollow: deep blue bowl, far rim lit
local hollow = c:ellipse(32, 30, 15, 4)
hollow:each(function(x, y)
  local t = (y - 26) / 8
  local i = (x > 36 and y < 30) and 3 or (y < 29 and 1 or 2)
  c.pix[y * c.w + x] = SNOW[i]:lower()
end)
-- near lip of the bowl, lit
for x = 18, 46 do
  local u = (x - 32) / 15
  local y = math.floor(30 + 4 * math.sqrt(math.max(0, 1 - u * u)) + .5)
  if mound:has(x, y) then O.mark(c, { { x, y } }, SNOW[6]) end
end
-- crag teeth breaking through the snow on the sides
for _, s in ipairs({ { 12, 43 }, { 52, 44 } }) do
  local m = c:poly{ { s[1] - 3, s[2] + 6 }, { s[1], s[2] }, { s[1] + 3, s[2] + 6 } }
  m:clip(mound)
  O.shade(c, m, ROCK, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 }, sep = SNOW[3] })
end

-- quirk: two sleeping owlets in the hollow
for _, o in ipairs({ { 26, 29 }, { 37, 29 } }) do
  local h = c:ellipse(o[1], o[2] - 1, 4, 3.5)
  h:cut(c:rect(0, o[2] + 2, 63, 63))
  O.shade(c, h, OWL, { sphere = { o[1] - 1, o[2] - 2, 5 }, amb = .3, wrap = .5, cuts = { .25, .45, .65, .85 }, sep = OWL[1] })
  O.dots(c, { { o[1] - 3, o[2] - 1 }, { o[1] - 2, o[2] }, { o[1] - 1, o[2] - 1 }, { o[1] + 1, o[2] - 1 }, { o[1] + 2, o[2] }, { o[1] + 3, o[2] - 1 } }, OWL[1]) -- shut eyes
  O.dot(c, o[1], o[2], GOLD[2]) O.dot(c, o[1], o[2] + 1, GOLD[1])
end

-- face on the snowy front
c:eyeLocked(23, 38)
c:eyeLocked(36, 38)
c:cheek(21, 44) c:cheek(41, 44)
O.dots(c, { { 29, 45 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 45 } }, P.ink)

-- aurora halo, front half
local front = ringO:copy():cut(ringI):clip(c:rect(0, 13, 63, 63))
local fI, fT = O.shade(c, front, GRN, { R = 1, amb = .4, wrap = .5, cuts = { .25, .45, .65, .85 } })
O.tex(c, fI, fT, GRN, function(x, y, i) if (x % 5 == 0) then return 1 end end) -- shimmer streaks

O.shift(c, 0, 2)
O.done(c, "pl-owl-5-yard", function(c)
  -- a "z" over the left owlet
  local z = { "####", "..#.", ".#..", "####" }
  for j, row in ipairs(z) do for i = 1, 4 do if row:sub(i, i) == "#" then c:put(16 + i, 21 + j, P.cream) end end end
  c:sparkle(56, 8)
end)
