-- Barrow Icecrown (pl-frt-6), yard sprite 64x64. Opus second pass (c09/opus2), built on the c09/haiku concept.
-- Thornblade, rare, Barrow of the Frost Toad. "The frost toad's spare crown of ice, still croaking when nobody looks."
-- A chunky crown carved from clear ice: a curved band and five icicle points (the middle one tallest), glass cues
-- (bright rim, pale core streak down each point, deep blue where the band turns away), a row of frost-violet gems
-- set in the band, rare sparkles.
-- quirk: it croaks like its owner: a round mouth and a toad's green throat sac ballooning out under the band,
-- with little croak ripples beside it.
-- closer look: a frozen bubble trapped inside the tallest point.
-- Fixes over haiku: flat zig-zag outline with a black stand under it (now a rounded band with icicle points and
-- a green croak sac), pale one-tone ice (now a 6-tone glassy ramp), face squeezed by gems.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-6-yard", 64)

local ICE = { "#2a3f7a", "#3a63a8", "#5f9ad0", "#8bc4ea", "#c4ecfa", "#eefaff" }
local GEM = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }
local SAC = { "#2e5a48", "#4a7d52", "#76a35e", "#a8c97a", "#d4e6a6", "#eef6cc" }

c:groundShadow(32, 54, 18, 2)

-- icicle points (behind the band)
local pts = { { 15, 20, -2 }, { 23, 14, -1 }, { 32, 7, 0 }, { 41, 14, 1 }, { 49, 20, 2 } }
local spikes = HP.mask()
for _, p in ipairs(pts) do
  local bx, ty, lean = p[1], p[2], p[3]
  spikes:add(c:poly({ { bx - 5, 33 }, { bx + lean, ty }, { bx + 5, 33 } }))
  spikes:add(c:ellipse(bx + lean * .5, ty + 1.5, .6, 1.2))
end
local kI, kT = O.shade(c, spikes, ICE, { R = 3, amb = .3, wrap = .5, rim = true, sep = ICE[2] })
-- pale core streak down each point, deep blue at the right edge
O.tex(c, kI, kT, ICE, function(x, y, i)
  for _, p in ipairs(pts) do
    local cx = p[1] + p[3] * (33 - y) / (33 - p[2])
    if y > p[2] + 2 and math.abs(x - (cx - 1)) < .6 and y < 31 then return 2 end
  end
end)
-- frozen bubble inside the tallest point
O.dots(c, { { 32, 19 }, { 31, 20 }, { 33, 20 }, { 32, 21 } }, ICE[6]) O.dot(c, 32, 20, ICE[3])

-- the band, curved: top edge dips at the middle
local band = HP.mask()
for x = 12, 52 do
  local d = (x - 32) / 20
  local y0 = 31 + math.floor(d * d * -3 + .5) + 3
  local y1 = 45 - math.floor(d * d * 5 + .5)
  for y = y0 - 2, y1 do band:set(x, y) end
end
local bI, bT = O.shade(c, band, ICE, { sphere = { 26, 30, 28 }, amb = .3, wrap = .5, rim = true, bounce = "#7a6fc0", bmax = 3, sep = ICE[1] })
-- frosted top ridge and lower lip
O.tex(c, bI, bT, ICE, function(x, y, i)
  local d = (x - 32) / 20
  local y0 = 31 + math.floor(d * d * -3 + .5) + 1
  if y == y0 then return 2 end
  if y == y0 + 1 then return 1 end
end)
-- gems along the band sides
for _, g in ipairs({ { 16, 37 }, { 48, 37 } }) do
  local m = c:ellipse(g[1], g[2], 2, 2.5)
  O.shade(c, m, GEM, { sphere = { g[1] - 1, g[2] - 1, 3 }, amb = .3, wrap = .5, cuts = { .3, .55, .8 }, sep = GEM[1] })
  O.dot(c, g[1] - 1, g[2] - 1, "#f0e6ff")
end
-- centre gem at the base of the tallest point
local cg = c:poly({ { 32, 30 }, { 35, 33 }, { 32, 36 }, { 29, 33 } })
O.shade(c, cg, GEM, { R = 2, amb = .3, wrap = .5, cuts = { .3, .55, .8 }, sep = GEM[1] })
O.dot(c, 31, 32, "#f0e6ff")

-- face on the band
c:eyeLocked(21, 37)
c:eyeLocked(38, 37)
c:cheek(20, 43) c:cheek(42, 43)
-- croak sac: ballooning out of the chin, over the band's lower edge
local sac = c:ellipse(32, 47, 6.5, 4.5)
local sI, sT = O.shade(c, sac, SAC, { sphere = { 29, 44, 9 }, sep = SAC[1], amb = .3, wrap = .5, rim = true, bounce = "#5f8fd0", bmax = 2 })
O.dots(c, { { 28, 44 }, { 29, 44 }, { 27, 45 } }, SAC[6])

-- croaking mouth: a wide toad line just above the sac
O.dots(c, { { 27, 41 }, { 28, 42 }, { 29, 42 }, { 30, 42 }, { 31, 42 }, { 32, 42 }, { 33, 42 }, { 34, 42 }, { 35, 42 }, { 36, 41 } }, P.ink)

O.done(c, "pl-frt-6-yard", function(c)
  -- croak ripples beside the sac and rare sparkles
  O.dots(c, { { 41, 46 }, { 42, 47 }, { 42, 48 }, { 41, 49 }, { 44, 45 }, { 45, 46 }, { 45, 47 }, { 45, 48 }, { 45, 49 }, { 44, 50 } }, ICE[3])
  O.dots(c, { { 23, 46 }, { 22, 47 }, { 22, 48 }, { 23, 49 } }, ICE[3])
  c:sparkle(8, 22) c:sparkle(56, 11)
end)
