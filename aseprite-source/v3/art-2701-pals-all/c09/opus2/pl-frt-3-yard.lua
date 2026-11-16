-- Thawdrop Pip (pl-frt-3), yard sprite 64x64. Opus second pass (c09/opus2), built on the c09/haiku concept.
-- Brewroot, common, Barrow of the Frost Toad. "A drop of spring meltwater saved from the toad's last yawn."
-- A plump meltwater drop with a tip that leans as it wobbles. Glass/water cues: deep blue core on the shade side,
-- a bright caustic crescent inside the lower-right edge (light passing through), a curved window highlight
-- upper-left, rim light and a cool bounce.
-- quirk: it is still mid-yawn (the toad's yawn it came from): a wide open mouth with a pink tongue, one
-- sleepy bead of water running off its tip.
-- closer look: a fleck of frost still melting on its crown, and a wet blue gleam in the ground shadow (a puddle).
-- Fixes over haiku: flat two-tone fill (now a 6-tone glassy ramp with caustic and window), dark blob mouth
-- (now a readable yawn with tongue), stray sparkle (now the frost fleck sits on the drop).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-3-yard", 64)

local WATER = { "#1f3a6e", "#2a5f9a", "#3a86b0", "#5fc4c8", "#9ee6dc", "#dcfaf2" }
local FROST = { "#8bc4ea", "#c4ecfa", "#eefaff" }

c:groundShadow(32, 55, 15, 2.5)

-- drop mask: round belly, concave neck rising to a tip that leans right
local cy, r, top = 38, 15, 8
local drop = HP.mask()
for y = top, cy + r do
  local w, cx
  if y <= cy then
    local s = (y - top) / (cy - top)
    w = r * math.sin(s * math.pi / 2) ^ 1.6
    cx = 31.5 + 4 * (1 - s) ^ 2
  else
    w = math.sqrt(math.max(0, r * r - (y - cy) ^ 2)) + .3
    cx = 31.5
  end
  for x = math.floor(cx - w), math.ceil(cx + w) do
    if math.abs(x + .5 - cx - .5) <= w then drop:set(x, y) end
  end
end
local dI, dT = O.shade(c, drop, WATER, { sphere = { 28, 32, 20 }, amb = .2, wrap = .5, rim = true, bounce = "#7a6fc0", bmax = 3 })
-- caustic crescent: light through the drop lands inside the lower-right edge
local ring = drop:edge()
local inner = drop:copy():cut(ring)
local ring2 = inner:edge()
O.tex(c, dI, dT, WATER, function(x, y, i)
  local dx, dy = x - 32, y - 40
  if dy > 2 and dx > -6 and ring2:has(x, y) and (dx + dy) > 8 then return 2 end
  if dy > 0 and dx > -2 and ring:has(x, y) and i <= 3 then return 1 end
end)
-- window highlight: a curved streak upper-left and a round spec
O.dots(c, { { 21, 30 }, { 21, 31 }, { 21, 32 }, { 22, 28 }, { 22, 29 }, { 23, 27 }, { 24, 26 } }, WATER[6])
O.dots(c, { { 22, 33 }, { 25, 25 } }, WATER[5])
O.dots(c, { { 27, 29 }, { 26, 29 } }, WATER[6])

-- frost fleck melting on the crown
O.dots(c, { { 34, 14 }, { 35, 14 }, { 34, 15 } }, FROST[3])
O.dots(c, { { 33, 15 }, { 35, 15 }, { 34, 16 } }, FROST[2])

-- face: sleepy-wide eyes and the yawn
c:eyeLocked(22, 33)
c:eyeLocked(37, 33)
c:cheek(21, 40) c:cheek(42, 40)
local mouth = c:ellipse(32, 44, 3, 4)
O.flat(c, mouth, "#5a2a4a", "mouth")
O.flat(c, c:ellipse(32, 46.5, 2, 1.2), P.petal.base, "tongue")
O.dots(c, { { 31, 46 } }, P.petal.hi)
mouth:edge():each(function(x, y) c:put(x, y, P.ink, { r = { name = "lip" } }) end)
O.dots(c, { { 30, 41 }, { 31, 41 } }, "#3a2a50") -- top palate shade

-- sleepy bead running off the tip
local bead = c:ellipse(44, 18, 1.5, 2)
O.shade(c, bead, WATER, { sphere = { 43, 17, 3 }, amb = .3, wrap = .5 })
O.dot(c, 43, 17, WATER[6])

O.done(c, "pl-frt-3-yard", function(c)
  -- wet gleam in the ground shadow
  for _, p in ipairs({ { 22, 55 }, { 23, 55 }, { 24, 56 }, { 40, 56 }, { 41, 56 } }) do
    if c:get(p[1], p[2]) and c:get(p[1], p[2]) ~= P.ink then c.pix[p[2] * c.w + p[1]] = "#8bc4ea" end
  end
end)
