-- Jade Shimmer (pl-jdf-3), yard sprite 64x64. Opus richness pass (c15/opus3), built on c15/opus2.
-- Rootwarden, common, Lair of the Jade Dragon-fly. "A sparkly green shimmer that gets everywhere on sunny days."
-- A brilliant-cut jade gem seen face-on: octagon girdle, a big flat table facet (the face sits on it), a ring of
-- star and crown facets, each facet a flat tone picked by how it faces the upper-left sun (one lower-right cel
-- shade), light seams on the lit side, dark seams in shade. Two stubby jade feet.
-- richness: 6-tone hue-shifted jade (blue-teal deeps to warm lime lights), cloudy jade mottling and a pale vein
-- through the stone, internal glow in the shaded facets (light refracting back out), rim light upper-left,
-- cool bounce lower-right, a gold-flecked girdle line.
-- opus2 weakness fixed: lower facets sat very dark; now the shade side keeps mid tones with an inner glow.
-- quirk: it sheds glitter flecks everywhere (trail on the ground, one fleck stuck on its own cheek).
-- closer look: the sun passing through it throws a tiny rainbow onto the ground beside its foot.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-jdf-3-yard", 64)

local JADE = { "#143440", "#1d5a52", "#2d8458", "#55ad5e", "#96d478", "#def4aa" }
local FEET = { "#143440", "#1d5a52", "#2d8458", "#55ad5e", "#96d478", "#def4aa" }
local BOUNCE = "#4f8eaa"

local CX, CY, R = 32, 29, 19.5
local function octR(th) -- polar radius of a regular octagon with flat top (apothem R)
  local a = (th + math.pi / 8) % (math.pi / 4) - math.pi / 8
  return R / math.cos(a)
end
c:groundShadow(32, 54, 17, 3)

-- feet first (the gem overlaps their tops)
for _, fx in ipairs({ 23, 41 }) do
  local fI, fT = O.shade(c, c:ellipse(fx, 50, 4, 2.8), FEET, { sphere = { fx - 2, 48, 5 }, amb = .3, wrap = .4, rim = true, bounce = BOUNCE, bmax = 2 })
  O.mark(c, { { fx - 2, 49 } }, FEET[6])
end

local gem = HP.mask()
for y = 4, 54 do for x = 8, 56 do
  local dx, dy = x + .5 - CX, y + .5 - CY
  local r = math.sqrt(dx * dx + dy * dy)
  if r <= octR(math.atan(dy, dx)) then gem:set(x, y) end
end end
local tok = { r = { name = "gem" } }
local LX, LY = -.62, -.78 -- light from upper-left
local function toneFor(th)
  local d = math.cos(th) * LX + math.sin(th) * LY -- 1 faces the sun, -1 faces away
  if d > .55 then return 5 elseif d > -.05 then return 4 elseif d > -.7 then return 3 else return 3 end
end
local zone, idx = {}, {}
gem:each(function(x, y)
  local dx, dy = x + .5 - CX, y + .5 - CY
  local th = math.atan(dy, dx)
  local rr = math.sqrt(dx * dx + dy * dy) / octR(th)
  local i, z
  if rr < .5 then
    -- table: lit toward the upper-left, one shade band lower-right
    local d = (dx * LX + dy * LY) / (R * .5)
    i, z = (d > .25 and 5 or d > -.45 and 4 or 3), "t"
  else
    local s = math.floor((th + math.pi + math.pi / 8) / (math.pi / 4)) % 8
    local mid = -math.pi + s * math.pi / 4
    local a = (th + math.pi / 8) % (math.pi / 4) - math.pi / 8
    local star = rr < .74 and math.abs(a) > (rr - .5) * 1.6
    local dd = math.cos(mid) * LX + math.sin(mid) * LY
    i = toneFor(mid) + (star and 1 or 0)
    -- the outer girdle band of the far (shade) facets drops one more tone: a single lower-right cel shade
    if dd < -.3 and rr > .9 then i = i - 1 end
    -- internal glow: the star facets on the shade side catch light refracted back out of the stone
    if dd < -.3 and star then i = i + 1 end
    z = (star and "s" or "g") .. s .. (star and (a > 0 and "a" or "b") or "")
  end
  i = math.max(2, math.min(6, i))
  zone[K(x, y)] = z
  idx[K(x, y)] = i
  c:put(x, y, JADE[i], tok)
end)
-- jade mottling: soft cloudy blotches (blocky noise), one tone either way, never on the brightest tone
gem:each(function(x, y)
  local i = idx[K(x, y)]
  local n = H(x // 3, y // 3, 11) * .6 + H(x // 2, y // 2, 12) * .4
  local j = i
  if n > .84 and i <= 4 and i >= 4 then j = i + 1 elseif n < .1 and i == 4 then j = 3 end
  if j ~= i then idx[K(x, y)] = j c.pix[y * c.w + x] = JADE[j]:lower() end
end)
-- a pale milky vein winding up through the lit left facets
do
  local vx, vy = 12.0, 30.0
  for s = 0, 14 do
    local x, y = math.floor(vx), math.floor(vy)
    if gem:has(x, y) and zone[K(x, y)] ~= "t" then
      local i = idx[K(x, y)]
      c.pix[y * c.w + x] = JADE[math.min(6, i + 1)]:lower()
    end
    vx = vx + 1
    vy = vy + math.sin(s * .5) * .7 - .55
  end
end
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
  c.pix[y * c.w + x] = (lit > 1) and JADE[6] or (lit > -5 and JADE[5] or JADE[2])
end
-- table glint streak (upper-left corner of the table) and a second small glint
O.mark(c, { { 23, 21 }, { 24, 20 }, { 25, 19 }, { 24, 21 }, { 23, 22 } }, JADE[6])
O.mark(c, { { 16, 16 }, { 17, 15 } }, JADE[6])
-- tiny gold flecks caught in the girdle (shimmer sitting in the stone)
O.mark(c, { { 13, 33 }, { 50, 21 }, { 44, 46 } }, "#f5cf4e")

-- register for rim light and bounce (O.done applies it)
c._lit = c._lit or {}
c._lit[#c._lit + 1] = { idx = idx, tok = tok, ramp = JADE, rim = true, bounce = BOUNCE, bmax = 3 }

-- face on the table
c:eyeLocked(25, 26)
c:eyeLocked(34, 26)
c:cheek(23, 32) c:cheek(39, 32)
O.mark(c, { { 30, 33 }, { 34, 33 }, { 31, 34 }, { 32, 34 }, { 33, 34 } }, P.ink)
O.mark(c, { { 32, 35 } }, "#c94f84")
-- glitter fleck stuck on its own cheek
O.mark(c, { { 41, 30 } }, "#fff0a0")

O.done(c, "pl-jdf-3-yard", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  -- shimmer it sheds everywhere: sparkles in the air, a fleck trail on the ground
  c:sparkle(7, 10) c:sparkle(55, 7) c:sparkle(59, 34)
  for _, p in ipairs({ { 6, 52 }, { 10, 56 }, { 13, 51 }, { 4, 30 }, { 6, 42 }, { 58, 46 } }) do put(p[1], p[2], "#96d478") end
  for _, p in ipairs({ { 8, 57 }, { 12, 47 }, { 3, 36 } }) do put(p[1], p[2], "#fff0a0") end
  -- the little rainbow it throws on the ground (sun from upper-left, cast to the lower right)
  local bow = { "#e8493b", "#ff9a2e", "#f5cf4e", "#55ad5e", "#4a86cc", "#8068c0" }
  for i, h in ipairs(bow) do
    put(50 + i, 57 + (i > 3 and 0 or 0), h)
    put(49 + i, 58, h)
  end
end)
