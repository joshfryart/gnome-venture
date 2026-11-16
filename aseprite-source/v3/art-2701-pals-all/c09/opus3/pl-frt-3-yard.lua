-- Thawdrop Pip (pl-frt-3), yard sprite 64x64. Opus richness pass (c09/opus3), built on c09/opus2.
-- Brewroot, common, Barrow of the Frost Toad. "A drop of spring meltwater saved from the toad's last yawn."
-- A plump meltwater drop with a tip that leans as it wobbles. Glass/water cues: 6-tone hue-shifted ramp
-- (indigo core -> teal -> mint), a curved window highlight upper-left, caustic crescent inside the lower-right edge,
-- rim light and a violet bounce. Richness: a frozen ice sliver still floating in the core, three trapped air
-- bubbles (lit rim, dark centre), faint ripple rings, frosted crown on the tip.
-- quirk: still mid-yawn. Opus2's round mouth read as "wow"; now the yawn is wide and lopsided (stretched up on
-- the left, flat on the right) with a tongue and a dark throat, a yawn tear at the corner of the right eye and a
-- frosty breath curl drifting out of the mouth.
-- closer look: a snowdrop sprouting through the puddle at its foot (spring is coming).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-3-yard", 64)

local WATER = { "#26346e", "#2a5a98", "#3184ae", "#55bec4", "#97e2d6", "#d8f8ee" }
local ICE = { "#6f9fd8", "#a9dcf2", "#e2f7fb" }
local LEAF = { "#2e5a3a", "#4f8a44", "#86b84e" }

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
local dI, dT = O.shade(c, drop, WATER, { sphere = { 28, 32, 20 }, amb = .28, wrap = .6, rim = true, bounce = "#7a6cc4", bmax = 3 })
local ring = drop:edge()
local inner = drop:copy():cut(ring)
local ring2 = inner:edge()
local ring3 = inner:shrink(1):edge()
O.tex(c, dI, dT, WATER, function(x, y, i)
  local dx, dy = x - 32, y - 40
  -- caustic crescent: light through the drop lands inside the lower-right edge
  if dy > 1 and dx > -8 and ring2:has(x, y) and (dx + dy) > 6 then return 3 end
  if dy > 3 and dx > -9 and ring3:has(x, y) and (dx + dy) > 9 then return 1 end
  -- faint ripple rings round the belly (concentric, every 4 px), only in the mid tones
  local d = math.sqrt((x - 30) ^ 2 + ((y - 36) * 1.2) ^ 2)
  if i == 4 and math.abs(d - 11) < .5 and x < 30 and y > 36 then return -1 end
end)

-- frozen ice sliver floating in the core (lower right, in the dark water): a little faceted shard
local shard = c:poly{ { 37, 48 }, { 40, 44 }, { 43, 45 }, { 42, 49 }, { 39, 50 } }
shard:each(function(x, y)
  local t = (x - 37) + (y - 44)
  O.dot(c, x, y, (shard:has(x - 1, y) and shard:has(x, y - 1)) and ICE[2] or ICE[3])
end)
shard:edge():each(function(x, y) if not shard:has(x + 1, y) or not shard:has(x, y + 1) then O.dot(c, x, y, ICE[1]) end end)
O.dots(c, { { 40, 46 }, { 41, 47 } }, ICE[3])

-- trapped air bubbles: lit rim upper-left, dark core
local function bubble(x, y)
  O.dots(c, { { x, y - 1 }, { x - 1, y } }, WATER[6])
  O.dots(c, { { x + 1, y }, { x, y + 1 } }, WATER[4])
  O.dot(c, x, y, WATER[3])
end
bubble(26, 46) bubble(44, 37)
O.dots(c, { { 23, 43 } }, WATER[5]) O.dots(c, { { 45, 43 } }, WATER[5])

-- window highlight: a curved streak upper-left and a round spec
O.dots(c, { { 21, 30 }, { 21, 31 }, { 21, 32 }, { 22, 28 }, { 22, 29 }, { 23, 27 }, { 24, 26 }, { 25, 25 } }, WATER[6])
O.dots(c, { { 22, 33 }, { 26, 24 }, { 20, 33 } }, WATER[5])
O.dots(c, { { 27, 29 }, { 26, 29 }, { 26, 30 } }, WATER[6])

-- frosted crown: the very tip is still frozen (pale ice cap with a flake)
for _, p in ipairs({ { 35, 8 }, { 35, 9 }, { 36, 9 }, { 34, 10 }, { 35, 10 }, { 36, 10 }, { 34, 11 }, { 37, 11 } }) do
  if drop:has(p[1], p[2]) then O.dot(c, p[1], p[2], ICE[3]) end
end
O.dots(c, { { 36, 11 }, { 33, 12 }, { 37, 10 } }, ICE[2])
-- frost fleck melting on the shoulder
O.dots(c, { { 40, 24 }, { 38, 26 }, { 42, 26 }, { 40, 28 } }, ICE[3])
O.dots(c, { { 40, 25 }, { 39, 26 }, { 41, 26 }, { 40, 27 } }, ICE[2])
O.dot(c, 40, 26, "#5f8fd0")

-- face
c:eyeLocked(22, 33)
c:eyeLocked(37, 33)
c:cheek(20, 40) c:cheek(43, 40)
-- yawn tear: one bead at the outer corner of the right eye
O.dots(c, { { 43, 34 }, { 43, 35 }, { 44, 35 }, { 43, 36 }, { 44, 36 } }, ICE[3]) O.dots(c, { { 44, 37 }, { 43, 37 } }, ICE[1]) O.dot(c, 42, 34, WATER[2])

-- the yawn: wide and lopsided, top lip arched high on the left, dropping to the right
local mouth = HP.mask()
local mt = { [27] = 44, [28] = 42, [29] = 41, [30] = 41, [31] = 41, [32] = 41, [33] = 42, [34] = 42, [35] = 43, [36] = 44, [37] = 45 }
local mb = { [27] = 47, [28] = 48, [29] = 49, [30] = 49, [31] = 49, [32] = 49, [33] = 49, [34] = 49, [35] = 48, [36] = 48, [37] = 47 }
for x = 27, 37 do for y = mt[x], mb[x] do mouth:set(x, y) end end
local mIn = mouth:copy():cut(mouth:edge())
O.flat(c, mIn, "#4a2240", "mouth")
-- dark throat at the top, tongue curled up at the bottom
O.dots(c, { { 30, 42 }, { 31, 42 }, { 32, 42 }, { 31, 43 } }, "#2f1a3a")
local tongue = c:ellipse(32.5, 47.5, 3, 1.2):clip(mIn)
O.flat(c, tongue, P.petal.base, "tongue")
O.dots(c, { { 31, 47 }, { 32, 47 } }, P.petal.hi)
O.dots(c, { { 32, 48 } }, "#c45a78")
mouth:edge():each(function(x, y) c:put(x, y, P.ink, { r = { name = "lip" } }) end)

-- sleepy bead running off the tip
local bead = c:ellipse(44, 18, 1.5, 2)
O.shade(c, bead, WATER, { sphere = { 43, 17, 3 }, amb = .3, wrap = .5 })
O.dot(c, 43, 17, WATER[6])

-- snowdrop sprouting by the puddle (closer look): stem, two leaves, nodding white bell
O.dots(c, { { 51, 50 }, { 51, 51 }, { 51, 52 }, { 51, 53 }, { 50, 54 } }, LEAF[2])
O.dots(c, { { 52, 52 }, { 53, 51 }, { 49, 53 } }, LEAF[3])
O.dots(c, { { 50, 53 } }, LEAF[1])
O.dots(c, { { 52, 49 }, { 52, 48 }, { 53, 48 } }, LEAF[2])
O.dots(c, { { 53, 49 }, { 54, 49 }, { 53, 50 }, { 54, 50 }, { 55, 50 } }, "#eef2ee")
O.dots(c, { { 54, 51 }, { 55, 51 } }, "#b8c6d6")
O.dot(c, 53, 51, "#86b84e")

O.done(c, "pl-frt-3-yard", function(c)
  -- wet gleam in the ground shadow
  for _, p in ipairs({ { 21, 55 }, { 22, 55 }, { 23, 55 }, { 24, 56 }, { 39, 56 }, { 40, 56 }, { 41, 56 } }) do
    if c:get(p[1], p[2]) and c:get(p[1], p[2]) ~= P.ink then c.pix[p[2] * c.w + p[1]] = "#8bc4ea" end
  end
  -- frosty breath curl drifting out of the mouth (un-outlined puff)
  for _, p in ipairs({ { 49, 43 }, { 50, 42 }, { 51, 42 }, { 52, 43 }, { 52, 44 }, { 51, 45 }, { 50, 44 }, { 54, 40 }, { 55, 39 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#c4ecfa") end
  end
  -- sleepy z drifting off the tip
  for _, p in ipairs({ { 47, 8 }, { 48, 8 }, { 49, 8 }, { 48, 9 }, { 47, 10 }, { 48, 10 }, { 49, 10 }, { 51, 4 }, { 52, 4 }, { 52, 5 }, { 51, 6 }, { 52, 6 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#9ec4e8") end
  end
end)
