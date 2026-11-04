-- ico-flatbread (final pass, Opus). A slim teardrop naan lying on the diagonal, wide end lower-left.
-- Material: per-pixel light from a height field (puffy rim, slightly sunken middle, blistered bubbles with
-- charred crowns, finger dimples), 6-tone golden crust with cool-violet shade, nigella + sesame seeds,
-- coriander flecks, butter gloss streak, cool reflected light on the lower-right rim.
-- quirk: the tip has been torn off and sits just beside it, its soft holey crumb showing.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, exp = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.exp
local c = A.new("ico-flatbread")
local BREAD = { "#5e2c2a", "#8f4630", "#bd6d36", "#dd9848", "#efbf6a", "#fbe0a0" }
local CRUMB = { "#c98a58", "#e8bf88", "#f8dfb0" }
local CHAR, CHAR2 = "#4a2426", "#7a3a28"
local GLOSS, BOUNCE = "#fff1cf", "#a8606a"
local tok = A.tok("bread")

-- teardrop in local frame: u along axis (-1 wide end .. 1 tip), half width tapers to the tip
local CX, CY, ANG, L, W = 31, 33, -0.42, 25, 13.5
local ca, sa = cos(ANG), sin(ANG)
local function loc(x, y) local dx, dy = x - CX, y - CY return (dx * ca + dy * sa) / L, (-dx * sa + dy * ca) / W end
local function inside(x, y)
  local u, v = loc(x, y)
  if u < -1 or u > 1 then return false end
  local hw = sqrt(max(0, 1 - u * u)) * (1 - 0.32 * (u + 1) / 2) * (u < -0.2 and 1 or 1 + 0.06 * (u + 0.2))
  -- gentle wobble so the edge looks hand-stretched
  hw = hw * (1 + 0.05 * sin(u * 9.0 + 1.3))
  return abs(v) <= hw
end
local all = HP.mask()
for y = 0, 63 do for x = 0, 63 do if inside(x + 0.0, y + 0.0) then all:set(x, y) end end end
-- ragged tear across the tip: u > ~0.66 with a zig-zag
local bread, tip = HP.mask(), HP.mask()
all:each(function(x, y)
  local u, v = loc(x, y)
  local cut = 0.6 + 0.05 * sin(v * 5.0 + 0.6) + 0.025 * ((x * 7 + y * 3) % 3 - 1)
  if u > cut then tip:set(x, y) else bread:set(x, y) end
end)
local TDX, TDY = 4, -4
tip = tip:shift(TDX, TDY)

local function heightField(m, seed)
  local d = X.dist(m)
  local bubbles = {
    { 19, 38, 3.4, 2.2 }, { 27, 30, 2.8, 1.9 }, { 34, 37, 3.4, 2.3 }, { 41, 29, 2.6, 1.7 }, { 25, 44, 2.0, 1.3 },
  }
  local dimples = { { 24, 36 }, { 38, 33 } }
  local function h(x, y)
    local v = d[K(x, y)]
    if not v then return 0 end
    local t = min(v + 0.5, 4) / 4
    local z = 3.2 * sqrt(1 - (1 - t) ^ 2)
    if v > 4 then z = z - 0.9 * min(1, (v - 4) / 4) end
    for _, b in ipairs(bubbles) do
      local q = ((x - b[1]) ^ 2 + (y - b[2]) ^ 2) / (b[3] * b[3])
      if q < 1 then z = z + b[4] * sqrt(1 - q) end
    end
    for _, p in ipairs(dimples) do
      local q = ((x - p[1]) ^ 2 + (y - p[2]) ^ 2) / 2.2
      if q < 1 then z = z - 1.1 * (1 - q) end
    end
    return z
  end
  return h, bubbles, d
end

-- main bread
local h, bubbles, d = heightField(bread)
local n = A.hnorm(bread, h, 1.25)
local bias = {}
for k, v in pairs(d) do if v > 4.5 then bias[k] = -1 end end
local idx = A.shade(c, bread, n, BREAD, { amb = 0.03, wrap = 0.18, tilt = { CX, CY, 24, 0.16 }, bias = bias, tok = tok,
  cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- charred crowns on the bigger bubbles (lit side of the top)
for i, b in ipairs(bubbles) do
  if b[3] >= 2.5 then
    local cx, cy = floor(b[1] - 0.4), floor(b[2] - 0.6)
    for yy = cy - 1, cy + 1 do for xx = cx - 1, cx + 2 do
      if bread:has(xx, yy) then
        local q = (xx - cx - 0.5) ^ 2 + (yy - cy) ^ 2
        if q <= 0.8 then c:put(xx, yy, i % 2 == 0 and CHAR2 or CHAR, tok) end
      end
    end end
  end
end
-- small char freckles on the rim
for _, p in ipairs{ { 11, 37 }, { 15, 47 }, { 47, 25 }, { 36, 46 }, { 20, 26 } } do
  if bread:has(p[1], p[2]) and bread:has(p[1] + 1, p[2]) then c:put(p[1], p[2], CHAR2, tok) c:put(p[1] + 1, p[2], BREAD[2], tok) end
end
-- seeds: nigella (dark 2x1 with a lit pixel) and sesame (cream 2x1 with a gold underside)
for _, s in ipairs{ { 21, 33 }, { 30, 39 }, { 16, 44 }, { 39, 38 }, { 33, 30 } } do
  if bread:has(s[1], s[2]) and bread:has(s[1] + 1, s[2]) then c:put(s[1], s[2], "#3a2630", tok) c:put(s[1] + 1, s[2], "#5d4450", tok) end
end
for _, s in ipairs{ { 27, 35 }, { 22, 42 }, { 44, 33 } } do
  if bread:has(s[1], s[2]) and bread:has(s[1] + 1, s[2]) then
    c:put(s[1], s[2], GLOSS, tok) c:put(s[1] + 1, s[2], "#f6d79a", tok)
    if bread:has(s[1], s[2] + 1) then c:put(s[1], s[2] + 1, BREAD[3], tok) end
  end
end
-- coriander flecks (2 px green with a dark pixel)
for _, s in ipairs{ { 22, 37 }, { 39, 33 }, { 28, 42 } } do
  c:put(s[1], s[2], "#6db552", tok) c:put(s[1] + 1, s[2], "#3f8448", tok) c:put(s[1], s[2] + 1, "#3f8448", tok)
end
-- butter gloss streak along the lit upper-left rim + one cream glint
for _, p in ipairs{ { 12, 33 }, { 13, 32 }, { 14, 31 }, { 16, 30 } } do if bread:has(p[1], p[2]) then c:put(p[1], p[2], BREAD[6], tok) end end
c:put(15, 31, GLOSS, tok) c:put(16, 31, GLOSS, tok)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
bread:edge():each(function(x, y) local k = K(x, y)
  local u, v = loc(x, y)
  if v > 0.5 and u > -0.75 and u < 0.55 and rim[k] and rim[k] > 0.35 and (idx[k] or 9) <= 3 then c:put(x, y, BOUNCE, tok) end end)
-- torn face on the main bread: pale crumb band with air holes
local tearEdge = HP.mask()
bread:each(function(x, y)
  for _, dd in ipairs{ { 1, 0 }, { 0, -1 }, { 1, -1 } } do
    if all:has(x + dd[1], y + dd[2]) and not bread:has(x + dd[1], y + dd[2]) then tearEdge:set(x, y) end
  end
end)
local tear2 = tearEdge:grow(1):clip(bread)
tear2:each(function(x, y)
  local e = tearEdge:has(x, y)
  local hole = X.hash(x, y, 3) > 0.78
  c:put(x, y, hole and CRUMB[1] or (e and CRUMB[3] or CRUMB[2]), tok)
end)

-- torn-off tip: same crust lighting, own height field, crumb on its torn (lower-left) face
local tm = tip
local ht = select(1, heightField(tm))
local nt = A.hnorm(tm, function(x, y) return ht(x, y) end, 1.25)
local ttok = A.tok("tip")
local tidx = A.shade(c, tm, nt, BREAD, { amb = 0.03, wrap = 0.18, tok = ttok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
local tipTear = HP.mask()
tm:each(function(x, y)
  local ox, oy = x - TDX, y - TDY
  for _, dd in ipairs{ { -1, 0 }, { 0, 1 }, { -1, 1 } } do
    if bread:has(ox + dd[1], oy + dd[2]) then tipTear:set(x, y) end
  end
end)
tipTear:grow(1):clip(tm):each(function(x, y)
  local hole = X.hash(x, y, 7) > 0.75
  c:put(x, y, hole and CRUMB[1] or (tipTear:has(x, y) and CRUMB[3] or CRUMB[2]), ttok)
end)
-- one seed + char freckle on the tip
local tb = { tm:bbox() }
do local sx, sy = floor((tb[1] + tb[3]) / 2) + 1, floor((tb[2] + tb[4]) / 2) - 1
  if tm:has(sx, sy) and tm:has(sx + 1, sy) then c:put(sx, sy, "#3a2630", ttok) c:put(sx + 1, sy, "#5d4450", ttok) end end
-- crumbs that fell between the pieces
A.save(c, "ico-flatbread")
