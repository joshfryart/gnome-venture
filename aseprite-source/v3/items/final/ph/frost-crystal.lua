-- frost-crystal (aB32_5, Opus single pass). A slim cluster of hexagonal ice prisms (tall centre spire, two leaning
-- side prisms, a tiny chip) growing out of a snow-capped rock. Each prism has three flat faces (lit left, glassy front
-- with a pale core and fracture planes, cool right), a brighter pointed cap, a bright ridge on the lit edge, a dark
-- seam where prisms overlap and ambient shading where they sink into the rock. Snow cap is pillow-lit cream/sky.
-- quirk: a tiny pine sprig is frozen inside the big spire.
local NAME = "frost-crystal"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min = math.floor, math.abs, math.sin, math.cos, math.max, math.min
local c = A.new(NAME)
local ICE = { "#26346c", "#2f5c9a", "#3d8cc2", "#6cc0de", "#a9e4ee", "#e4fbf6" }
local ROCK = { "#2f2c48", "#46445f", "#62617c", "#83839a", "#a9a8b9", "#cfced8" }
local SNOW = { "#5f7fb8", "#8eaedb", "#b9d6ee", "#dcecf7", "#f4f7f4", "#fff4d6" }

local all = HP.mask()
local owner = {}
local function prism(id, bx, by, ang, L, w, tl, core)
  local ux, uy = sin(ang), -cos(ang)
  local px, py = cos(ang), sin(ang)
  local m, A_, S_ = HP.mask(), {}, {}
  for y = 0, 63 do for x = 0, 63 do
    local rx, ry = x - bx, y - by
    local a = rx * ux + ry * uy
    local s = rx * px + ry * py
    if a >= -2 and a <= L then
      local wa = a <= L - tl and w or w * (L - a) / tl
      if abs(s) <= wa + 0.2 then m:set(x, y) local k = K(x, y) A_[k] = a S_[k] = s / max(wa, 0.6) end
    end
  end end
  local tok = { r = { name = "ice" .. id } }
  local prev = all:copy()
  m:each(function(x, y) local k = K(x, y)
    local a, sn = A_[k], S_[k]
    local tip = a > L - tl
    local i
    if sn < -0.42 then i = tip and 6 or 5 elseif sn <= 0.36 then i = tip and 5 or 4 else i = tip and 3 or 2 end
    -- ridges: bright on the lit edge, cooler on the shade edge
    if abs(sn + 0.42) < 0.22 and not tip then i = 6 end
    if abs(sn - 0.36) < 0.2 then i = 3 end
    -- cap line
    if abs(a - (L - tl)) < 0.6 then i = sn < 0.36 and 6 or 3 end
    -- glass: pale core streak and fracture planes on the front face
    if core and not tip and sn > -0.42 and sn <= 0.36 then
      if abs(sn + 0.08) < 0.14 and a > L * 0.18 and a < L * 0.62 then i = 5 end
      local f = (a + sn * w * 1.4) % 11
      if f < 0.8 and a > 5 and a < L - tl - 2 then i = 5 end
    end
    if a < 3 then i = i - 1 end  -- ambient where it sinks into the rock
    i = max(1, min(6, i))
    c:put(x, y, ICE[i], tok)
    owner[k] = id
  end)
  -- seam: earlier prisms darken where this one overlaps them
  m:grow(1):cut(m):each(function(x, y) if prev:has(x, y) then c:put(x, y, ICE[1], { r = { name = "ice" .. owner[K(x, y)] } }) end end)
  all:add(m)
  return m, ux, uy, px, py
end

prism(1, 23, 53, -0.42, 23, 3.0, 5, false)
prism(2, 42, 53, 0.36, 18, 2.8, 4.5, false)
local mm, ux, uy, px, py = prism(3, 32, 54, -0.05, 45, 4.6, 8.5, true)
prism(4, 46, 56, 0.95, 7, 1.7, 3, false)

-- quirk: pine sprig frozen inside the spire (muted through the ice)
local NEED, NEED2 = "#3f7f72", "#2b5a5c"
for i = 0, 6 do
  local a, s = 17 + i, -1.6 + i * 0.45
  local x, y = floor(32 + ux * a + px * s + 0.5), floor(54 + uy * a + py * s + 0.5)
  c:put(x, y, NEED2, { r = { name = "ice3" } })
  if i % 2 == 1 and i < 6 then c:put(x - 1, y, NEED, { r = { name = "ice3" } }) c:put(x + 1, y + 1, NEED, { r = { name = "ice3" } }) end
end

-- rock + snow cap in front, hiding the prism roots
local rock = c:poly{ { 14, 59 }, { 16, 54 }, { 22, 51 }, { 30, 52 }, { 37, 50 }, { 45, 52 }, { 50, 55 }, { 51, 59 } }
local rbias = {}
local ridx = A.shade(c, rock, X.pillow(rock, 3), ROCK, { tok = { r = { name = "rock" } } })
-- rock strata cracks
for _, p in ipairs{ { 19, 57 }, { 20, 57 }, { 21, 58 }, { 38, 57 }, { 39, 56 }, { 40, 56 }, { 46, 57 } } do
  if rock:has(p[1], p[2]) then c:put(p[1], p[2], ROCK[2], { r = { name = "rock" } }) end
end
local snow = c:poly{ { 15, 55 }, { 18, 52 }, { 23, 50 }, { 30, 51 }, { 37, 49 }, { 45, 51 }, { 50, 54 }, { 47, 55 }, { 43, 54 }, { 39, 56 }, { 34, 55 }, { 28, 56 }, { 22, 55 }, { 18, 57 } }
snow:clip(rock:grow(1))
local sidx = A.shade(c, snow, X.pillow(snow, 2.2), SNOW, { tok = { r = { name = "snow" } }, cuts = { 0.15, 0.3, 0.48, 0.66, 0.86 } })
-- contact shadow on the rock under the snow lip
snow:shift(0, 1):each(function(x, y) if rock:has(x, y) and not snow:has(x, y) then c:put(x, y, ROCK[2], { r = { name = "rock" } }) end end)
-- ambient on prisms just above the snow
snow:shift(0, -1):each(function(x, y) if all:has(x, y) and not snow:has(x, y) then c:put(x, y, ICE[2], { r = { name = "ice" .. owner[K(x, y)] } }) end end)

-- pop: specular on the spire's lit cap, one cream sparkle
c:put(29, 14, A.CREAM, { r = { name = "ice3" } }) c:put(29, 15, A.CREAM, { r = { name = "ice3" } })
c:sparkle(29, 31)

A.save(c, NAME)
