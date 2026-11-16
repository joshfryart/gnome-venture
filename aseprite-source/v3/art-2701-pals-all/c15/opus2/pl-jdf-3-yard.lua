-- Jade Shimmer (pl-jdf-3), yard sprite 64x64. Opus second pass (c15/opus2), built on the Haiku idea.
-- Rootwarden, common, Lair of the Jade Dragon-fly. "A sparkly green shimmer that gets everywhere on sunny days."
-- A brilliant-cut jade gem seen face-on: octagon girdle, a big flat table facet (the face sits on it), a ring of
-- star facets and girdle facets, each facet a flat tone picked by how it faces the upper-left sun, bright edge
-- glints on the lit side. Two stubby jade feet.
-- Haiku weakness fixed: the gem read as a half-teal/half-green split blob; now one jade material, true facets.
-- quirk: it sheds glitter flecks everywhere: a trail on the ground and one fleck stuck on its own cheek.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-3-yard", 64)

local JADE = { "#173f36", "#22604a", "#33895a", "#58b468", "#98dc84", "#dcf6b8" }
local FEET = { "#173f36", "#22604a", "#33895a", "#58b468" }

local CX, CY, R = 32, 30, 19.5
local function octR(th) -- polar radius of a regular octagon with flat top (apothem R)
  local a = (th + math.pi / 8) % (math.pi / 4) - math.pi / 8
  return R / math.cos(a)
end
c:groundShadow(32, 54, 16, 3)

-- feet first (the gem overlaps their tops)
for _, fx in ipairs({ 24, 40 }) do
  O.shade(c, c:ellipse(fx, 50, 3.5, 2.5), FEET, { R = 2, amb = .3, wrap = .4, cuts = { .3, .55, .8 } })
end

local gem = HP.mask()
for y = 6, 54 do for x = 8, 56 do
  local dx, dy = x + .5 - CX, y + .5 - CY
  local r = math.sqrt(dx * dx + dy * dy)
  if r <= octR(math.atan(dy, dx)) then gem:set(x, y) end
end end
local tok = { r = { name = "gem" } }
local LX, LY = -.62, -.78 -- light from upper-left
local function toneFor(th, lift)
  local d = math.cos(th) * LX + math.sin(th) * LY
  local i = 3 + math.floor(d * 2.2 + .5) + (lift or 0)
  return math.max(1, math.min(6, i))
end
local zone = {}
gem:each(function(x, y)
  local dx, dy = x + .5 - CX, y + .5 - CY
  local th = math.atan(dy, dx)
  local rr = math.sqrt(dx * dx + dy * dy) / octR(th)
  local i, z
  if rr < .5 then
    i, z = 4, "t"
  else
    -- crown facets, one per side; a star wedge (one tone up) at each corner, next to the table
    local s = math.floor((th + math.pi + math.pi / 8) / (math.pi / 4)) % 8
    local mid = -math.pi + s * math.pi / 4
    local a = (th + math.pi / 8) % (math.pi / 4) - math.pi / 8 -- -22.5..22.5 deg within the side
    local star = rr < .74 and math.abs(a) > (rr - .5) * 1.6
    i, z = toneFor(mid, star and 1 or 0), (star and "s" or "g") .. s .. (star and (a > 0 and "a" or "b") or "")
    if i < 2 then i = 2 end
  end
  zone[K(x, y)] = z
  c:put(x, y, JADE[i], tok)
end)
-- facet edges: a lighter seam on the lit half, a darker seam on the shade half
local seams = {}
gem:each(function(x, y)
  local z = zone[K(x, y)]
  local zr, zd = zone[K(x + 1, y)], zone[K(x, y + 1)]
  if (zr and zr ~= z) or (zd and zd ~= z) then seams[#seams + 1] = { x, y } end
end)
for _, p in ipairs(seams) do
  local x, y = p[1], p[2]
  local lit = (x + .5 - CX) * LX + (y + .5 - CY) * LY
  c.pix[y * c.w + x] = (lit > -2) and JADE[6] or JADE[2]
end
-- the table: soft glow toward the upper left, a long glint streak
for y = 20, 40 do for x = 22, 42 do
  if zone[K(x, y)] == "t" then
    local d = (x - 26) + (y - 24)
    if d < -3 then c.pix[y * c.w + x] = JADE[5] end
  end
end end
O.mark(c, { { 25, 22 }, { 24, 23 }, { 26, 22 }, { 23, 24 } }, JADE[6])
-- inner cloud inclusions in the jade (closer look): two milky wisps in the lower facets
O.mark(c, { { 38, 42 }, { 39, 42 }, { 40, 43 }, { 21, 41 }, { 22, 42 } }, "#b6e8a2")

-- face on the table
c:eyeLocked(25, 27)
c:eyeLocked(34, 27)
c:cheek(23, 33) c:cheek(39, 33)
O.mark(c, { { 30, 34 }, { 34, 34 }, { 31, 35 }, { 32, 35 }, { 33, 35 } }, P.ink)
O.mark(c, { { 32, 36 } }, P.petal.shade)
-- glitter fleck stuck on its own cheek
O.mark(c, { { 41, 32 } }, "#fff0a0")

O.done(c, "pl-jdf-3-yard", function(c)
  -- shimmer it sheds everywhere: sparkles in the air, a fleck trail on the ground
  c:sparkle(10, 12) c:sparkle(53, 9) c:sparkle(56, 38)
  for _, p in ipairs({ { 7, 52 }, { 11, 56 }, { 14, 51 }, { 50, 57 }, { 54, 52 }, { 58, 55 }, { 9, 30 }, { 52, 47 } }) do
    c:put(p[1], p[2], "#98dc84")
  end
  for _, p in ipairs({ { 8, 56 }, { 56, 56 }, { 12, 48 } }) do c:put(p[1], p[2], "#fff0a0") end
end)
