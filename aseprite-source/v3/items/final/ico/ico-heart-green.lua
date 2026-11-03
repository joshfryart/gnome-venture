-- ico-heart-green (final, Opus). A heart-shaped leaf, tilted a touch to the right: a pale midrib running from the
-- notch to the point, the blade folded along it in a soft V (left half lit, right half in shade), five pairs of
-- curved veins (dark groove + lit lip), a short thick stalk rising out of the notch and curling over.
-- Material: per-pixel light from a dome + fold normal field on a 6-tone leaf ramp, waxy specular on the left lobe,
-- cool reflected light on the lower-right edge, AO where the stalk meets the blade.
-- quirk: a caterpillar has taken a round bite out of the left edge.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin
local c = A.new("ico-heart-green")
local LF = { "#163d35", "#1f5a40", "#2c7a46", "#46a04c", "#72c25a", "#a8dc72" }
local ST = { "#2a4a2c", "#4f7a36", "#7ea44a", "#a9c866" }
local SPEC, BOUNCE = "#e8f7b0", "#3f7f86"
local tok, stok = A.tok("leaf"), A.tok("stalk")

local TILT = 0.1
local CX, CY = 32, 33
local h = A.heart(CX, CY, 18.5, 1.05, TILT)
-- quirk: round caterpillar bite on the left edge
local bite = A.ell(12.2, 36, 4.2, 3.8)
h:cut(bite)

-- midrib axis: from the notch (top) to the point; frame u along, v across (+v = right of axis)
local ax, ay = sin(-TILT), cos(TILT)                     -- down the heart, rotated by tilt
local nx0, ny0 = CX + (-(CY - 13) * sin(TILT)), 13     -- approx top of the midrib
local fr = A.frame(CX, CY, -ax, ay)
-- notch: lowest top-edge pixel near the axis
local nx, ny = CX, 0
do local best = -1
  for x = CX - 5, CX + 5 do local y = 0 while y < 63 and not h:has(x, y) do y = y + 1 end
    if y > best then best, nx, ny = y, x, y end end end

local nd, d = A.dome(h, 13, 0.9, 2)
local n = {}
h:each(function(x, y) local k = K(x, y)
  local v = (x - CX) * cos(TILT) + (y - CY) * sin(TILT)
  local f = max(-1, min(1, v / 2.5))
  local q = nd[k]
  -- V fold: each half tilts away from the midrib
  local fx, fy = -ay * f * 0.55, -ax * f * 0.55
  -- frame across vector is (-uy, ux) -> world; approximate with rotated x
  local px, py = cos(TILT), sin(TILT)
  n[k] = { A.norm(q[1] + px * f * 0.42, q[2] + py * f * 0.42, q[3]) }
end)
local v = A.val(n, { amb = 0.04, wrap = 0.2 })
local bias = {}
local idx = X.tone(c, h, v, LF, { cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, tok = tok })

-- veins: from the midrib, curving outward and up toward the edge
local function axisPt(t) -- t px down from the notch along the axis
  return nx + sin(TILT) * -t * -1, ny + t
end
local vein = HP.mask()
local lip = HP.mask()
for i, t in ipairs{ 7, 15, 23 } do
  for _, side in ipairs{ -1, 1 } do
    local bx, by = nx - t * sin(TILT), ny + t * cos(TILT)
    local L = ({ 13, 13, 9 })[i]
    for s = 1, floor(L) do
      local f = s / L
      local x = bx + side * s * cos(TILT) - (s * 0.12) * sin(TILT)
      local y = by - s * (0.35 + 0.5 * f) + side * s * sin(TILT)
      local xi, yi = floor(x + 0.5), floor(y + 0.5)
      if h:has(xi, yi) and d[K(xi, yi)] and d[K(xi, yi)] > 1.6 then
        vein:set(xi, yi)
        lip:set(xi, yi + 1)
      end
    end
  end
end
lip:cut(vein)
lip:each(function(x, y) if h:has(x, y) then A.step(c, idx, LF, x, y, 1, tok) end end)
vein:each(function(x, y) A.step(c, idx, LF, x, y, -2, tok) end)

-- midrib: 2 px near the notch, 1 px toward the point; pale on the lit side, dark seam on the shade side
for t = 0, 40 do
  local x, y = nx - t * sin(TILT), ny + t * cos(TILT)
  local xi, yi = floor(x + 0.5), floor(y + 0.5)
  if h:has(xi, yi) and d[K(xi, yi)] > 0.8 then
    c:put(xi, yi, t < 26 and LF[6] or LF[5], tok)
    if t < 16 and h:has(xi - 1, yi) then c:put(xi - 1, yi, LF[5], tok) end
    if h:has(xi + 1, yi) then c:put(xi + 1, yi, LF[2], tok) end
  end
end

-- bite edge: brown dried rim on the cut
local brim = A.touch(h, bite)
brim:each(function(x, y) c:put(x, y, "#8a7a36", tok) end)

-- cool reflected light on the lower-right edge
local rim = X.rim(n)
h:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.5 and y > CY + 2 and x > CX + 2 then c:put(x, y, BOUNCE, tok) end end)
-- waxy specular on the left lobe
for _, p in ipairs{ { 19, 19 }, { 20, 19 }, { 18, 20 } } do if h:has(p[1], p[2]) then c:put(p[1], p[2], SPEC, tok) end end
c:put(22, 18, LF[6], tok) c:put(23, 18, LF[6], tok)

-- stalk: thick 3 px stub out of the notch, curling up and over to the right
local pts = {}
do local P0, P1, P2 = { nx + 0.3, ny + 2 }, { nx + 1, ny - 8 }, { nx + 8, ny - 8.5 }
  for i = 0, 24 do local t = i / 24 local u = 1 - t
    pts[#pts + 1] = { u*u*P0[1] + 2*u*t*P1[1] + t*t*P2[1], u*u*P0[2] + 2*u*t*P1[2] + t*t*P2[2] } end end
local sm = HP.mask()
for i, p in ipairs(pts) do
  local r = 1.6 - (i / #pts) * 0.6
  sm:add(A.ell(p[1], p[2], r, r))
end
sm:cut(h:copy():cut(A.ell(nx, ny + 1, 2, 2)))
local sn = X.pillow(sm, 1.5)
local sidx = A.shade(c, sm, sn, ST, { cuts = { 0.25, 0.5, 0.75 }, tok = stok, amb = 0.1 })
-- AO where the stalk enters the notch
for x = nx - 2, nx + 3 do for y = ny, ny + 2 do if h:has(x, y) and not sm:has(x, y) then A.step(c, idx, LF, x, y, -2, tok) end end end
-- cut tip end grain
local tp = pts[#pts]
c:put(floor(tp[1] + 0.5), floor(tp[2] + 0.5), "#c8d98a", stok)
A.save(c, "ico-heart-green")
