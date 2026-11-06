-- gathering-pouch (final, Opus single pass). A slim pear-shaped linen drawstring pouch, sitting upright. Gathered
-- ruffle at the top with a dark mouth, a twisted cord cinching the neck, tied off on the right with one end weighted by
-- a turned wooden bead and the other frayed. Cloth: per-pixel round light, diagonal weave, gather creases radiating
-- from the neck, AO under the cord, one gold stitched hem seam, cool reflected edge, small ground shadow.
-- quirk: a ladybird is walking up the side of the pouch.
local NAME = "gathering-pouch"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local CLOTH = { "#1c2440", "#2a3e62", "#3c5d82", "#5a83a0", "#86acba", "#bcd8d2" }
local CORD  = { "#5a3420", "#8e5a2a", "#c48a3a", "#ecc06a" }
local BEAD  = { "#3e2420", "#64402c", "#8e5e3a", "#b8844e", "#dcae72", "#f2d29a" }
local COOL  = "#6a6ea8"
local CX = 32

c:groundShadow(CX, 54, 13, 2)

-- body: pear, neck at y 23, bottom at y 53
local Y0, Y1 = 23, 53
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  local top = 4 + 9.6 * sin(min(1, t / 0.7) * pi / 2) ^ 1.3
  local bot = t > 0.7 and 13.6 * sqrt(max(0, 1 - ((t - 0.7) / 0.31) ^ 2.4)) or 99
  return min(top, bot)
end
local body = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end end
local bn = A.body(body, CX - 1, 42, 13, 6, 0.55)
local bias = {}
for x = CX - 8, CX + 8 do bias[K(x, Y0)] = -2 bias[K(x, Y0 + 1)] = -1 end
local btok = { r = { name = "body" } }
local bidx, bv = A.shade(c, body, bn, CLOTH, { bias = bias, tok = btok, amb = 0.1, wrap = 0.3, cuts = { 0.24, 0.4, 0.56, 0.71, 0.86 } })
-- gather creases radiating down from the neck
for _, dx in ipairs{ -9, -4, 2, 7 } do
  for i = 0, 18 do local t = i / 18
    local x = floor(CX + dx * (0.25 + 0.75 * t) + 0.5)
    local y = Y0 + 2 + floor(t * 17 + 0.5)
    if body:has(x, y) and body:has(x + 1, y) then
      A.step(c, bidx, CLOTH, x, y, -1, btok)
      if t < 0.7 then A.step(c, bidx, CLOTH, x - 1, y, 1, btok) end
    end
  end
end
-- diagonal weave on the cloth
body:each(function(x, y) local k = K(x, y) local i = bidx[k]
  if i and i >= 3 and i <= 5 and (x - y) % 4 == 0 and X.hash(x, y, 5) > 0.45 then A.step(c, bidx, CLOTH, x, y, -1, btok) end
end)
-- cool reflected light on the lower right edge
body:edge():each(function(x, y) if x > CX + 5 and y > 36 and y < Y1 - 1 then c:px(x, y, COOL) end end)
-- hem seam stitch (the one stitch)
local pts = {}
for i = 0, 12 do local x = CX - 10 + i * (20 / 12) pts[#pts + 1] = { floor(x + 0.5), floor(48 + 0.05 * (x - CX) ^ 2 * 0.25 + 0.5) } end
local seam = {}
for _, p in ipairs(pts) do if body:has(p[1], p[2] + 1) then seam[#seam + 1] = p end end
for _, p in ipairs(seam) do A.step(c, bidx, CLOTH, p[1], p[2] + 1, -1, btok) end
c:stitch(seam)

-- ruffle: gathered fabric flaring above the cord, scalloped top edge
local ruf = HP.mask()
for y = 12, Y0 - 1 do
  local t = (Y0 - 1 - y) / (Y0 - 14)
  local h = 4.2 + 6 * t ^ 0.8
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do
    local top = 12 + ((x % 4 < 2) and 0 or 1) + ((abs(x - CX) > 6) and 1 or 0)
    if y >= top then ruf:set(x, y) end
  end
end
local rn = X.pillow(ruf, 3)
local rtok = { r = { name = "ruffle" } }
local ridx = A.shade(c, ruf, rn, CLOTH, { tok = rtok, amb = 0.14, wrap = 0.3 })
ruf:each(function(x, y) if (x - CX) % 3 == 0 and y > 14 then A.step(c, ridx, CLOTH, x, y, -1, rtok)
  elseif (x - CX) % 3 == 2 and y > 14 then A.step(c, ridx, CLOTH, x, y, 1, rtok) end end)
-- dark mouth at the top
local mouth = c:ellipse(CX, 13.5, 6, 1)
mouth:each(function(x, y) if ruf:has(x, y) then c:put(x, y, CLOTH[1], rtok) end end)
for x = CX - 3, CX + 3 do if ruf:has(x, 14) then c:put(x, 14, CLOTH[2], rtok) end end

-- cord: twisted band round the neck
local ctok = { r = { name = "cord" } }
local band = c:rect(CX - 6, 21, CX + 5, 23)
band:each(function(x, y)
  local ph = (x + (y - 21)) % 3
  local i = (ph == 0) and 1 or ((ph == 1) and 3 or 4)
  if x > CX + 2 and i > 2 then i = i - 1 end
  if y == 23 then i = max(1, i - 1) end
  c:put(x, y, CORD[i], ctok)
end)
-- knot on the right + two hanging ends
local knot = c:ellipse(CX + 6, 22, 2, 1.6)
local kidx = A.shade(c, knot, X.sphere(CX + 6, 22, 2, knot), CORD, { cuts = { 0.3, 0.55, 0.8 }, tok = ctok })
local e1 = A.stem(c, { {CX + 7, 24}, {CX + 9, 27}, {CX + 10, 30}, {CX + 10, 33} }, function() return 0.8 end, CORD, { cut = knot, tok = ctok })
e1:each(function(x, y) if (y % 2 == 0) then c:put(x, y, CORD[1], ctok) end end)
local e2 = A.stem(c, { {CX + 5, 24}, {CX + 5, 27}, {CX + 4, 29}, {CX + 4, 31} }, function() return 0.7 end, CORD, { cut = knot:copy():add(e1), tok = ctok })
-- frayed tip on the short end
c:px(CX + 3, 32, CORD[3]) c:px(CX + 5, 32, CORD[2]) c:px(CX + 4, 33, CORD[3])
-- contact shadow of the cord ends on the cloth
e1:copy():add(e2):shift(1, 1):each(function(x, y) if body:has(x, y) and not e1:has(x, y) and not e2:has(x, y) then
  A.step(c, bidx, CLOTH, x, y, -1, btok) end end)
-- turned wooden bead on the long end
local bead = c:ellipse(CX + 10, 35.5, 2.5, 2.5)
local bdn = X.sphere(CX + 10, 35.5, 2.5, bead)
local bdx = A.shade(c, bead, bdn, BEAD, { tok = { r = { name = "bead" } } })
c:px(CX + 10, 34, BEAD[1]) -- cord hole
c:px(CX + 9, 35, BEAD[6]) c:px(CX + 8, 36, BEAD[5])
bead:shift(1, 1):each(function(x, y) if body:has(x, y) and not bead:has(x, y) then A.step(c, bidx, CLOTH, x, y, -1, btok) end end)
-- grain ring on the bead
c:px(CX + 11, 36, BEAD[2]) c:px(CX + 11, 37, BEAD[2])

-- specular on the cloth shoulder
c:px(CX - 7, 31, CLOTH[6]) c:px(CX - 6, 31, CLOTH[6])

-- quirk: ladybird climbing the left side
A.map(c, {
  "..k..",
  ".hkr.",
  "hrkkR",
  "krkRd",
  ".RkR.",
}, CX - 10, 38, { k = "#2b1c26", r = "#e8493b", R = "#b52e3f", h = "#ff8a5c", d = "#6e2038" })

A.save(c, NAME)
