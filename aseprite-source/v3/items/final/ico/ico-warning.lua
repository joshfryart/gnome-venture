-- ico-warning (final pass, Opus aR1_0). A bold enamel-on-steel warning plate: rounded triangle, per-pixel
-- bevelled rim (6-tone sunflower enamel), one incised groove running round the face (dark upper-left wall,
-- lit lower-right lip), a steel rivet at the apex, and a raised dark-plum enamel "!" (tapered bar + round dot)
-- with its own bevel, a contact shadow on the plate and one glint.
-- quirk: the enamel has chipped off the lower-right corner, showing bare grey steel underneath.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-warning")

local YEL   = { "#7a3320", "#b75e1f", "#e48f27", "#f6b92f", "#ffd95c", "#fff0a6" }
local GLY   = { "#2e1525", "#3b1b2c", "#4f2536", "#683341", "#8f4f4e" }
local STEEL = { "#444663", "#74758c", "#aaa9b8", "#d6d5df" }
local CREAM = A.CREAM

-- signed distance to a convex polygon (negative inside)
local function sdPoly(P, x, y)
  local inside, dmin, emax = true, 1e9, -1e9
  for i = 1, #P do
    local a, b = P[i], P[i % #P + 1]
    local ex, ey = b[1] - a[1], b[2] - a[2]
    local l = sqrt(ex*ex + ey*ey)
    local nx, ny = ey / l, -ex / l               -- outward for clockwise-on-screen order
    local s = (x - a[1]) * nx + (y - a[2]) * ny
    emax = max(emax, s)
    local t = max(0, min(1, ((x - a[1]) * ex + (y - a[2]) * ey) / (l * l)))
    local qx, qy = a[1] + ex * t - x, a[2] + ey * t - y
    dmin = min(dmin, sqrt(qx*qx + qy*qy))
  end
  if emax <= 0 then return emax end
  return dmin
end
-- triangle listed so that the outward normal formula holds (top, bottom-right, bottom-left)
local function roundTri(P, r, inset)
  -- inset triangle: move vertices toward centroid until edges are r+inset in
  local cx = (P[1][1] + P[2][1] + P[3][1]) / 3
  local cy = (P[1][2] + P[2][2] + P[3][2]) / 3
  local d0 = -sdPoly(P, cx, cy)                  -- inradius
  local k = (d0 - r - inset) / d0
  local Q = {}
  for i, p in ipairs(P) do Q[i] = { cx + (p[1] - cx) * k, cy + (p[2] - cy) * k } end
  local m = HP.mask()
  for y = 0, 63 do for x = 0, 63 do
    if sdPoly(Q, x + 0.5, y + 0.5) <= r then m:set(x, y) end
  end end
  return m
end

local TRI = { { 32, 5.5 }, { 59, 56 }, { 5, 56 } }
local plate = roundTri(TRI, 4.5, 0)
local face  = roundTri(TRI, 3.5, 5)              -- groove sits on this face's border

-- "!" glyph: tapered bar + round dot
local bar = HP.mask()
for y = 20, 38 do
  local t = (y - 20) / 18
  local hw = 4.1 - 1.9 * t
  for x = 24, 40 do if abs(x + 0.5 - 32) <= hw then bar:set(x, y) end end
end
bar:add(c:ellipse(32, 20.5, 4, 1.6))
bar:add(c:ellipse(32, 38, 1.9, 1.2))
local dot = c:ellipse(32, 45, 3.4, 3.4)
local glyph = bar:copy():add(dot)

-- plate: bevel (pillow) + contact shadow of the glyph + groove
local n = X.pillow(plate, 3.2)
local bias = {}
A.cast(bias, plate, glyph, 1, 1, -1)
A.cast(bias, plate, glyph, 2, 2, -1)
local ytok = { r = { name = "enamel" } }
local idx = A.shade(c, plate, n, YEL, { tok = ytok, bias = bias, amb = 0.08, wrap = 0.25 })

-- incised groove: wall facing lower-right (on the upper-left side of the ring) is dark, lit lip outside it
local ring = face:edge()
local inner = face:shrink(1)
ring:each(function(x, y)
  -- which side of the triangle: compare against neighbours inside the face
  local up = not face:has(x, y - 1) or not face:has(x - 1, y)
  c:put(x, y, up and YEL[2] or YEL[3], ytok)
end)
-- lit lip just outside the groove on its lower-right run, and inside on the upper-left run
ring:each(function(x, y)
  if not face:has(x, y + 1) and plate:has(x, y + 1) and not ring:has(x, y + 1) then c:put(x, y + 1, YEL[5], ytok) end
  if not face:has(x + 1, y) and plate:has(x + 1, y) and not ring:has(x + 1, y) and y > 20 then c:put(x + 1, y, YEL[5], ytok) end
end)

-- enamel pop on the upper-left bevel + one cream glint
c:put(21, 24, YEL[6], ytok) c:put(22, 22, YEL[6], ytok) c:put(23, 20, YEL[6], ytok) c:put(24, 19, YEL[6], ytok)
c:put(20, 26, CREAM, ytok)

-- steel rivet at the apex
local rv = c:ellipse(32, 14, 2, 2)
local rn = X.sphere(32, 14, 2, rv)
local stok = { r = { name = "steel" } }
A.shade(c, rv, rn, STEEL, { tok = stok, cuts = { 0.25, 0.5, 0.78 } })
c:put(31, 13, CREAM, stok)
c:put(33, 16, YEL[2], ytok) c:put(34, 15, YEL[2], ytok)         -- tiny AO under the rivet

-- raised glyph with its own bevel
local gn = X.pillow(glyph, 1.8)
local gtok = { r = { name = "glyph" } }
local gi = A.shade(c, glyph, gn, GLY, { tok = gtok, cuts = { 0.25, 0.45, 0.62, 0.8 }, amb = 0.05 })
c:put(30, 20, GLY[5], gtok) c:put(31, 20, GLY[5], gtok)          -- 2x1 hi on the bar
c:put(30, 43, GLY[5], gtok)
c:put(30, 21, "#d9937a", gtok)                                   -- wet enamel glint

-- quirk: chipped corner -> bare steel, with a dark broken edge on its upper-left and a lit lower lip
local chip = A.map
local CH = {
  "....dd.",
  "..ddSsd",
  ".dsSSss",
  "dsSSsss",
  ".dsssss",
}
local CP = { d = YEL[1], s = STEEL[2], S = STEEL[3] }
for yy, row in ipairs(CH) do for xx = 1, #row do local ch = row:sub(xx, xx)
  local x, y = 48 + xx, 48 + yy
  if CP[ch] and plate:shrink(1):has(x, y) then c:put(x, y, CP[ch], stok) end end end
c:put(52, 51, STEEL[4], stok)
c:put(48, 49, YEL[1], ytok) c:put(49, 50, YEL[2], ytok)          -- hairline crack running off the chip

A.save(c, "ico-warning")
