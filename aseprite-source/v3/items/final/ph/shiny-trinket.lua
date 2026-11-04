-- shiny-trinket (D15 final, Sonnet). A gold oval locket on a two-link chain: domed lid with a raised beaded rim, engraved
-- sunburst rays round a faceted ruby held by four prongs, a ring bail at the top, an edge-on chain link through it and a
-- face-on link above, and a pearl drop swinging from an eye under the locket. Per-pixel torus/dome light on the gold,
-- bevelled rim with a specular arc, deep rows where the links and bail overlap.
-- quirk: one chain link is a bright silver mend among the gold ones.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("shiny-trinket")

local GOLD = { "#5e2f1a", "#93501f", "#c97a22", "#f0a92c", "#ffd35a", "#fff3a6" }
local SIL  = { "#3c4262", "#5d6690", "#8c97bc", "#b8c4de", "#dde6f4", "#f8fcff" }
local RUBY = { "#3d0f24", "#6e1633", "#a21f3f", "#d23648", "#f0605a", "#ffa592" }
local PEARL = { "#7c6a92", "#a894b4", "#cdbdd0", "#e8dce0", "#f8f0ec", "#fffaf2" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local gtok = { r = { name = "gold" } }

local CX, CY, RX, RY = 32, 34, 10.5, 12

-- locket body: ellipse, normals from a dome + raised rim
local body = c:ellipse(CX, CY, RX, RY)
local n = {}
body:each(function(x, y)
  local u, v = (x + 0.0 - CX) / (RX + 0.4), (y + 0.0 - CY) / (RY + 0.4)
  local rr = sqrt(u * u + v * v)
  local ux, uy = 0, 0
  if rr > 0.001 then ux, uy = u / rr, v / rr end
  local nx, ny, nz
  if rr > 0.8 then
    local t = min(1, (rr - 0.8) / 0.2)               -- 0 inner edge .. 1 outer edge
    local sl = cos(pi * t)                            -- +1 rising (faces inward) .. -1 falling (faces outward)
    local k = -sl * 1.1                               -- inward-facing slope pushes normal toward the centre
    nx, ny = ux * (-k), uy * (-k)
    -- rising part leans toward the centre (normal points inward = -u), falling part outward
    nx, ny = -ux * sl * 1.1, -uy * sl * 1.1
    nz = 0.8
  else
    nx, ny, nz = ux * rr * 0.35, uy * rr * 0.35, 1
  end
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  n[K(x, y)] = { nx / l, ny / l, nz / l }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local bias = {}
-- engraved sunburst rays on the plate (darker alternate rays), beaded rim dots
local PLATE = 0.8
body:each(function(x, y)
  local k = K(x, y)
  local u, vv = (x - CX) / (RX + 0.4), (y - CY) / (RY + 0.4)
  local rr = sqrt(u * u + vv * vv)
  local ang = atan(vv, u)
  if rr > 0.42 and rr < 0.74 then
    local ray = floor((ang + pi) / (2 * pi) * 24 + 0.5) % 2
    if ray == 0 then bias[k] = -1 end
    -- engraved lines are one-pixel wide: keep only near the ray centres
  end
  if rr >= 0.8 and rr < 0.9 then
    local bead = floor((ang + pi) / (2 * pi) * 34 + 0.5) % 2
    if bead == 1 then bias[k] = -1 end
  end
end)
X.tone(c, body, v, GOLD, { cuts = CUTS, bias = bias, tok = gtok })
-- specular arc on the lit rim (upper-left) + warm bounce on the lower-right rim
body:each(function(x, y)
  local u, vv = (x - CX) / (RX + 0.4), (y - CY) / (RY + 0.4)
  local rr = sqrt(u * u + vv * vv)
  local ang = atan(vv, u) / pi          -- -1 .. 1, upper-left is about -0.75
  if rr > 0.86 and rr < 0.98 and ang < -0.55 and ang > -0.9 and (floor((ang + 1) * 40) % 3 ~= 0) then c:put(x, y, GOLD[6], gtok) end
  if rr > 0.9 and ang > 0.25 and ang < 0.6 then c:put(x, y, "#e6743c", gtok) end
end)
-- inner groove between rim and plate: dark ring
body:each(function(x, y)
  local u, vv = (x - CX) / (RX + 0.4), (y - CY) / (RY + 0.4)
  local rr = sqrt(u * u + vv * vv)
  if rr > 0.77 and rr <= 0.81 then c:put(x, y, GOLD[2], gtok) end
end)

-- ruby: octagonal cut, table + crown facets by angle sector, set in 4 prongs
local gx, gy, gr = CX, CY, 6
local gem = HP.mask()
for y = gy - gr - 1, gy + gr + 1 do for x = gx - gr - 1, gx + gr + 1 do
  local dx, dy = x - gx, y - gy
  if abs(dx) + abs(dy) * 1.0 <= gr * 1.45 and abs(dx) <= gr and abs(dy) <= gr + 0 then gem:set(x, y) end
end end
-- shadow ring under the gem seat
gem:grow(1):cut(gem):each(function(x, y) if body:has(x, y) then c:put(x, y, GOLD[1], gtok) end end)
local gtk = { r = { name = "gem" } }
gem:each(function(x, y)
  local dx, dy = x - gx + 0.0, y - gy + 0.0
  local rr = max(abs(dx), abs(dy))
  local ang = atan(dy, dx)
  local lit = -(cos(ang - (-2.35)))                -- light from upper-left: sector facing it is bright
  local sector = floor((ang + pi) / (pi / 4))
  local i
  if rr <= 2 then i = 5 + ((dx + dy < 0) and 1 or 0) - ((dx + dy > 2) and 1 or 0)         -- table
  else
    local f = cos(ang - (-2.35))                    -- 1 facing the light
    i = 3 + floor(f * 2.2 + 0.5)
    if sector % 2 == 1 then i = i - 1 end
  end
  if rr >= 5 then i = i - 1 end
  c:put(x, y, RUBY[max(1, min(6, i))], gtk)
end)
-- table outline (one dark pixel ring between table and crown, lit side only) and glints
for _, p in ipairs{ { -3, 0 }, { 3, 0 }, { 0, -3 }, { 0, 3 }, { -2, -2 }, { 2, 2 }, { 2, -2 }, { -2, 2 } } do
  local x, y = gx + p[1], gy + p[2]
  c:put(x, y, RUBY[(p[1] + p[2] > 0) and 2 or 3], gtk)
end
c:put(gx - 2, gy - 2, A.CREAM, gtk) c:put(gx - 1, gy - 2, A.CREAM, gtk) c:put(gx - 2, gy - 1, A.CREAM, gtk)
c:put(gx + 3, gy + 3, RUBY[5], gtk)
-- prongs at the four diagonals
for _, p in ipairs{ { -5, -5 }, { 5, -5 }, { -5, 5 }, { 5, 5 } } do
  local x, y = gx + p[1], gy + p[2]
  c:put(x, y, GOLD[5], gtok) c:put(x + 1, y, GOLD[4], gtok) c:put(x, y + 1, GOLD[4], gtok) c:put(x + 1, y + 1, GOLD[3], gtok)
  c:put(x + (p[1] < 0 and 2 or -1), y + (p[2] < 0 and 2 or -1), GOLD[2], gtok)
end
c:put(gx - 5, gy - 5, GOLD[6], gtok)

-- bail ring (face-on) fixed to the top of the locket
local function ring(cx, cy, rx, ry, hx, hy, ramp, tok)
  local outer = c:ellipse(cx, cy, rx, ry)
  local hole = c:ellipse(cx, cy, hx, hy)
  outer:cut(hole)
  local nn = X.pillow(outer, 1.7)
  local vv = X.light(nn, { amb = 0.08, wrap = 0.3 })
  X.tone(c, outer, vv, ramp, { cuts = CUTS, tok = tok })
  return outer, hole
end
local btok = { r = { name = "bail" } }
local ltok = { r = { name = "link" } }
local stok = { r = { name = "silver" } }
-- eye under the locket + pearl drop
local eye = ring(CX, CY + RY + 1.5, 2.6, 2.3, 1.1, 1, GOLD, btok)
local py = CY + RY + 6
local pearl = c:ellipse(CX + 1, py, 3.6, 3.6)
local pn = X.sphere(CX + 0.3, py - 0.4, 3.6, pearl)
X.tone(c, pearl, X.light(pn, { amb = 0.1, wrap = 0.2 }), PEARL, { cuts = CUTS, tok = { r = { name = "pearl" } } })
c:put(CX + 0, py - 2, A.CREAM, { r = { name = "pearl" } }) c:put(CX - 1, py - 1, A.CREAM, { r = { name = "pearl" } })
-- thread from the eye to the pearl
c:put(CX, CY + RY + 3, GOLD[2], btok)
-- bail
local bail, bhole = ring(CX, CY - RY - 1.5, 3.2, 3.0, 1.5, 1.5, GOLD, btok)
-- edge-on link through the bail: a short pill
local lm = c:rrect(CX - 1, CY - RY - 10, CX + 1, CY - RY - 4, 1)
local ln = X.pillow(lm, 1.5)
X.tone(c, lm, X.light(ln, { amb = 0.08, wrap = 0.3 }), GOLD, { cuts = CUTS, tok = ltok })
-- shadow where the link passes in front of the bail's top bar
for x = CX - 1, CX + 1 do c:put(x, CY - RY - 4, GOLD[1], ltok) end
-- face-on silver mend link above, interlocked with the pill
local top, thole = ring(CX, CY - RY - 12, 3.4, 3.8, 1.6, 2.0, SIL, stok)
-- hook the pill into the hole: its upper end shows inside the hole
for y = CY - RY - 11, CY - RY - 10 do c:put(CX, y, GOLD[3], ltok) end
c:put(CX - 1, CY - RY - 10, GOLD[5], ltok)
-- locket hinge nub and a tiny clasp notch on the right edge
for _, p in ipairs{ { CX + RX - 1, CY - 1 }, { CX + RX - 1, CY } , { CX + RX - 1, CY + 1 } } do c:put(p[1], p[2], GOLD[1], gtok) end

A.save(c, "shiny-trinket")
