-- Rime Crumb (pl-frt-1), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Common, rootwarden, from the Barrow of the Frost Toad. "A crumb of frost the toad coughed up, still croaking softly."
-- A cut-gem lump of blue ice on stubby toad feet: flat facets each in its own tone (lit top/left, deep lower-right),
-- pale bevel lines along the facet ridges, frost flecks frozen inside, three small ice shards on its crown, a crack.
-- The front facet carries the face: locked eyes and a wide toad mouth open mid-croak.
-- Fixes: the Haiku rounded blob with floating feet is now clearly faceted ice with feet joined to the body, and the
-- croak is a real open toad mouth instead of a small square.
-- quirk: each soft croak puffs out a little frost cloud with a snowflake in it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("pl-frt-1-yard", 64)

local ICE = { "#1e3466", "#2c5294", "#4a82c0", "#78b2de", "#aed8f2", "#def2ff" }

c:groundShadow(32, 57, 18, 2.5)

-- feet (behind the body)
for _, f in ipairs({ { 24, -1 }, { 40, 1 } }) do
  local foot = c:ellipse(f[1], 53, 5, 2.5)
  O.shade(c, foot, ICE, { R = 1, amb = .3, sep = ICE[1] })
  for k = 0, 2 do O.dot(c, f[1] - 3 + k * 3, 55, ICE[5]) end
end

-- crown shards
for _, s in ipairs({ { { 24, 21 }, { 25, 11 }, { 29, 19 }, 5 }, { { 30, 17 }, { 33, 7 }, { 36, 17 }, 6 }, { { 38, 19 }, { 42, 12 }, { 43, 21 }, 4 } }) do
  local m = c:poly{ s[1], s[2], s[3] }
  local t = O.flat(c, m, ICE[s[4]], "shard")
  -- dark right half of each shard
  m:each(function(x, y) if x > s[2][1] then c.pix[y * c.w + x] = ICE[s[4] - 2]:lower() end end)
end

-- the faceted body
local V = {
  A = { 19, 21 }, B = { 32, 16 }, C = { 45, 20 }, D = { 51, 31 }, E = { 49, 45 }, F = { 40, 51 }, G = { 24, 51 }, H = { 14, 44 }, I = { 13, 30 },
  J = { 25, 24 }, K = { 39, 24 }, L = { 44, 33 }, M = { 39, 45 }, N = { 25, 45 }, Q = { 20, 33 },
}
local facets = {
  { { "A", "B", "K", "J" }, 6 }, { { "B", "C", "K" }, 5 }, { { "A", "J", "Q", "I" }, 5 }, { { "C", "D", "L", "K" }, 4 },
  { { "D", "E", "M", "L" }, 2 }, { { "E", "F", "M" }, 1 }, { { "F", "G", "N", "M" }, 2 }, { { "G", "H", "N" }, 3 },
  { { "H", "I", "Q", "N" }, 4 }, { { "J", "K", "L", "M", "N", "Q" }, 4 },
}
local body = HP.mask()
local fm = {}
for i, f in ipairs(facets) do
  local pts = {}
  for _, k in ipairs(f[1]) do pts[#pts+1] = V[k] end
  fm[i] = c:poly(pts)
  body:add(fm[i])
end
local tok = { r = { name = "ice" } }
for i, f in ipairs(facets) do fm[i]:each(function(x, y) c:put(x, y, ICE[f[2]], tok) end) end
-- soft gradient on the big front facet (lighter upper-left) so the face sits on a lit plane
fm[10]:each(function(x, y) if x + y < 52 then c.pix[y * c.w + x] = ICE[5]:lower() elseif x + y > 76 then c.pix[y * c.w + x] = ICE[3]:lower() end end)
-- ridge bevels: pale line along the upper ridges, dark along the lower ones
local function ridge(a, b, hex)
  local p, q = V[a], V[b]
  local n = math.max(math.abs(q[1] - p[1]), math.abs(q[2] - p[2]), 1)
  for t = 0, n do
    local x, y = math.floor(p[1] + (q[1] - p[1]) * t / n + .5), math.floor(p[2] + (q[2] - p[2]) * t / n + .5)
    if body:has(x, y) then c.pix[y * c.w + x] = hex:lower() end
  end
end
ridge("J", "K", ICE[6]) ridge("J", "Q", ICE[6]) ridge("B", "K", ICE[6]) ridge("A", "J", "#ffffef")
ridge("K", "L", ICE[5]) ridge("L", "M", ICE[2]) ridge("M", "N", ICE[2]) ridge("N", "Q", ICE[3])
-- frozen frost flecks and a crack
O.mark(c, { { 17, 36 }, { 46, 27 }, { 44, 40 }, { 31, 19 }, { 19, 41 }, { 34, 48 } }, "#fff4d6")
O.mark(c, { { 46, 34 }, { 47, 35 }, { 47, 36 }, { 48, 37 } }, ICE[1])

-- face
c:eyeLocked(24, 27)
c:eyeLocked(35, 27)
c:cheek(21, 34) c:cheek(41, 34)
-- wide croaking toad mouth (D-shape), dark blue inside, pale tongue
local mouth = c:poly{ { 24, 36 }, { 40, 36 }, { 38, 40 }, { 34, 42 }, { 30, 42 }, { 26, 40 } }
O.flat(c, mouth, P.ink, "mouth")
local inner = c:poly{ { 26, 37 }, { 38, 37 }, { 37, 39 }, { 33, 41 }, { 31, 41 }, { 27, 39 } }
O.flat(c, inner, "#1c1e48", "mouthin")
O.flat(c, c:rect(30, 39, 34, 40), "#c4709a", "tongue")
O.dots(c, { { 31, 39 }, { 32, 39 } }, "#ffc4d8")

O.shift(c, -3, 0)
O.done(c, "pl-frt-1-yard", function(c)
  -- frost puff out of the mouth corner, with a snowflake in it
  local m = c:ellipse(52, 34, 2, 1.5):add(c:ellipse(55, 32.5, 2.2, 2.2)):add(c:ellipse(58, 34, 2, 1.5))
  m:cut(c:rect(0, 36, 63, 63))
  local e = m:edge()
  m:each(function(x, y) if not c:get(x, y) then c:put(x, y, e:has(x, y) and "#5f9ad0" or "#e4f6ff") end end)
  for _, q in ipairs({ { 51, 33 }, { 54, 32 }, { 55, 31 } }) do c:put(q[1], q[2], "#fff4d6") end
  -- snowflake
  local sx, sy = 58, 26
  for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 2, 0 }, { -2, 0 }, { 0, 2 }, { 0, -2 } }) do c:put(sx + d[1], sy + d[2], "#b9e2f5") end
  for _, d in ipairs({ { 1, 1 }, { -1, -1 }, { 1, -1 }, { -1, 1 } }) do c:put(sx + d[1], sy + d[2], "#8bc4ea") end
  c:put(sx, sy, "#fff4d6")
end)
