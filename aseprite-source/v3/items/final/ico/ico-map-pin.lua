-- ico-map-pin (Opus single pass, replaces the Sonnet draft). A slim glossy teardrop pin standing on its point:
-- a sphere head that flows into a long tangent cone, lit per pixel as a solid of revolution (6-tone red, cool
-- violet bounce on the lower right), a curved wet specular streak on the head, an inset cream bead in a bevelled
-- socket (dark wall upper-left, lit lip lower-right), a dark ambient ring where the point meets the ground and a
-- 2-tone ground shadow.
-- quirk: a two-leaf seedling has sprouted right beside the spot the pin marks.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-map-pin")
local RED = A.RED
local BOUNCE = "#a8487a"
local tok = A.tok("pin")

local CX, CY, R, TIP = 32, 20, 11, 53
c:groundShadow(CX, TIP + 1, 7, 1.5)

-- teardrop mask + normals (sphere above the tangent line, cone below)
local d = TIP - CY
local sa = R / d
local ca = sqrt(1 - sa * sa)
local yT = CY + R * sa                -- tangent row
local m, n = HP.mask(), {}
for y = CY - R - 1, TIP do for x = CX - R - 1, CX + R + 1 do
  local dx = x - CX
  if y <= yT then
    local q = (dx / (R + 0.5))^2 + ((y - CY) / (R + 0.5))^2
    if q <= 1 then
      m:set(x, y)
      n[K(x, y)] = { A.norm(dx / (R + .5), (y - CY) / (R + .5), sqrt(max(1 - q, 0.03))) }
    end
  else
    local r = max(0.55, (TIP - y) * sa / ca)
    if abs(dx) <= r then
      m:set(x, y)
      local u = max(-0.96, min(0.96, dx / (r + 0.5)))
      n[K(x, y)] = { A.norm(u * ca, sa, sqrt(1 - u * u) * ca) }
    end
  end
end end
local bias = {}
-- ambient: point darkens where it meets the ground
m:each(function(x, y) if y >= TIP - 2 then bias[K(x, y)] = -1 end end)
local idx = A.shade(c, m, n, RED, { tok = tok, bias = bias, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.06, wrap = 0.2 })

-- cool reflected light: lower-right edge of the head and upper cone
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and y > CY - 2 and y < TIP - 8 and x > CX then c:put(x, y, BOUNCE, tok) end end)

-- socket + inset cream bead
local BX, BY = CX, CY - 1
local sock = c:ellipse(BX, BY, 5.5, 5.5)
sock:each(function(x, y)
  local dx, dy = x - BX, y - BY
  local g = -(dx + dy)
  c:put(x, y, g > 1 and RED[1] or (g < -1 and RED[5] or RED[2]), tok)
end)
local bead = c:ellipse(BX + 0.5, BY + 0.5, 3.6, 3.6)
local BEAD = { "#b98a7a", "#dcbfa6", "#f2dcbc", "#fff4d6" }
local bn = X.sphere(BX - 0.5, BY - 0.5, 4, bead)
A.shade(c, bead, bn, BEAD, { tok = tok, cuts = { 0.3, 0.55, 0.78 }, amb = 0.15 })
c:put(BX - 1, BY - 1, A.CREAM, tok)

-- wet specular streak on the upper-left shoulder of the head (curved, 2 px wide at its middle)
for _, p in ipairs{ { -7, -3 }, { -7, -4 }, { -6, -5 }, { -6, -6 }, { -5, -7 }, { -4, -7 }, { -6, -4 }, { -5, -6 } } do
  c:put(CX + p[1], CY + p[2], RED[6], tok)
end
c:put(CX - 6, CY - 5, A.CREAM, tok)
-- small secondary glint on the cone
c:put(CX - 4, CY + 13, RED[5], tok) c:put(CX - 3, CY + 15, RED[5], tok)

-- quirk: seedling beside the point
local LEAF = { "#21593f", "#3f9150", "#7cc35a", "#b8e07a" }
local st = A.tok("sprout")
for y = TIP - 4, TIP do c:put(CX + 8, y, y > TIP - 2 and LEAF[1] or LEAF[2], st) end
c:put(CX + 6, TIP - 5, LEAF[3], st) c:put(CX + 7, TIP - 5, LEAF[3], st) c:put(CX + 7, TIP - 4, LEAF[2], st)
c:put(CX + 6, TIP - 6, LEAF[4], st)
c:put(CX + 9, TIP - 6, LEAF[3], st) c:put(CX + 10, TIP - 6, LEAF[3], st) c:put(CX + 9, TIP - 5, LEAF[2], st)
c:put(CX + 10, TIP - 7, LEAF[4], st) c:put(CX + 11, TIP - 7, LEAF[3], st)
A.save(c, "ico-map-pin")
