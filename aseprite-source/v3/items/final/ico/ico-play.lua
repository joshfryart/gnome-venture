-- ico-play (Opus single pass, aA8_2). Chunky right-pointing play triangle with soft rounded corners, cast in glossy
-- green enamel. Material: per-pixel light from a custom height field (rounded bevel rim, a sunk groove inset 6 px that
-- frames a slightly domed face), 6-tone green ramp with cool-violet deeps, one big glaze specular streak along the
-- upper-left bevel, a cream glint, cool teal reflected light on the lower-right edge, AO in the groove.
-- quirk: a tiny bumblebee has landed on the top slope and is walking toward the tip.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("ico-play")

local GRN = { "#1c3b44", "#23604a", "#2f8352", "#46a65a", "#72c866", "#b2e68a" }
local SPEC, BOUNCE = "#f3ffd9", "#3f9c96"

-- rounded triangle: all pixels within RC of an inner triangle
local RC = 5
local T = { { 16, 13 }, { 16, 51 }, { 49, 32 } }
local function segd(px, py, a, b)
  local vx, vy = b[1] - a[1], b[2] - a[2]
  local t = max(0, min(1, ((px - a[1]) * vx + (py - a[2]) * vy) / (vx*vx + vy*vy)))
  local dx, dy = px - a[1] - vx * t, py - a[2] - vy * t
  return sqrt(dx*dx + dy*dy)
end
local function inside(px, py)
  local pos, neg = false, false
  for i = 1, 3 do
    local a, b = T[i], T[i % 3 + 1]
    local cr = (b[1] - a[1]) * (py - a[2]) - (b[2] - a[2]) * (px - a[1])
    if cr > 0 then pos = true elseif cr < 0 then neg = true end
  end
  return not (pos and neg)
end
local m = A.fmask(0, 0, 63, 63, function(x, y)
  local px, py = x + .5, y + .5
  if inside(px, py) then return true end
  return min(segd(px, py, T[1], T[2]), segd(px, py, T[2], T[3]), segd(px, py, T[3], T[1])) <= RC
end)

-- height: bevel rise over 4 px, groove dip at d ~ 6.5, gentle dome on the face
local d = X.dist(m)
local cx, cy = 28, 32
local function h(x, y)
  local v = d[K(x, y)]
  if not v then return 0 end
  local e = v + 0.5
  local hb = 4 * sqrt(1 - (1 - min(e, 4) / 4) ^ 2)
  local g = abs(e - 6.6)
  if g < 1.1 then hb = hb - 1.7 * (1 - g / 1.1) end
  if e > 7.7 then local r2 = ((x - cx)^2 + (y - cy)^2) / 400 hb = hb + 0.4 + 1.4 * max(0, 1 - r2) end
  return hb
end
local n = {}
m:each(function(x, y)
  local gx = (h(x + 1, y) - h(x - 1, y)) / 2
  local gy = (h(x, y + 1) - h(x, y - 1)) / 2
  n[K(x, y)] = { A.norm(-gx, -gy, 1) }
end)
local v = A.lightV(n, 0.1, 0.3)
local bias = {}
-- AO at the bottom of the groove
m:each(function(x, y) local e = d[K(x, y)] + 0.5 if e > 6.1 and e < 7.1 then bias[K(x, y)] = -1 end end)
local tok = { r = { name = "enamel" } }
local idx = A.toneV(m, v, GRN, { 0.2, 0.38, 0.55, 0.7, 0.86 }, bias, tok)

-- cool reflected light on the lower-right edge (outer bevel only)
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.45 and x + y > 62 then A.px(x, y, BOUNCE, tok) end end)
-- glaze specular streak along the upper-left bevel (left edge, high up) + glint
for yy = 17, 25 do A.px(14, yy, GRN[6], tok) end
for yy = 18, 22 do A.px(15, yy, SPEC, tok) end
A.px(16, 15, GRN[6], tok) A.px(17, 14, GRN[6], tok) A.px(18, 14, GRN[6], tok)
-- face highlight: one 3x1 lit mark near the upper left of the dome
A.pts({ { 23, 24 }, { 24, 24 }, { 23, 25 } }, GRN[6], tok)

-- quirk: bumblebee on the top slope (top edge y ~ 13 + (x-16)*19/33 - RC)
local bx, by = 33, 13
A.bmp({
  "..cs...",
  ".csc...",
  "kYkYkYk",
  "YkYkYkh",
  ".k.k...",
}, bx, by, { c = "#e4f6ff", s = "#b9e2f5", Y = "#f5b82e", k = "#2b1c26", h = "#3a2430" }, { r = { name = "bee" } })
A.px(bx + 6, by + 2, "#fff4d6") -- eye glint on the head
A.done()
