-- ico-strength (Opus artist pass): a flexed arm, rolled blue sleeve at the shoulder, slim upper arm with a round
-- bicep peak, elbow bend, forearm rising to a clenched fist.
-- Material: the arm is one height field (max of tubes, the bicep dome, the elbow and the fist), lit per pixel into
-- a 6-tone warm skin ramp; creases where two forms meet get ambient shading (bicep/forearm fold, wrist, knuckles).
-- Fist: finger rolls split by dark grooves, lit knuckle row, thumb lapping across with its nail. Sleeve: 5-tone cloth
-- with diagonal weave lines, a rolled cuff with a dark roll line and a contact shadow on the skin.
-- quirk: a little sticking plaster on the forearm.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = D.new("ico-strength")
local SK, CL = D.SKIN, D.CLOTH
local atok, ctok, ptok = { r = { name = "skin" } }, { r = { name = "cloth" } }, { r = { name = "plaster" } }

-- part height functions
local function seg(ax, ay, bx, by, w0, w1, hs)
  local vx, vy = bx - ax, by - ay
  local L2 = vx * vx + vy * vy
  return function(x, y)
    local t = max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / L2))
    local qx, qy = ax + vx * t - x, ay + vy * t - y
    local d = sqrt(qx * qx + qy * qy)
    local w = w0 + (w1 - w0) * t
    if d > w then return -1 end
    return (hs or 1) * sqrt(w * w - d * d)
  end
end
local function dome(cx, cy, rx, ry, hz)
  return function(x, y)
    local q = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
    if q > 1 then return -1 end
    return hz * sqrt(1 - q)
  end
end
local function sbox(cx, cy, rx, ry, hz, p)
  return function(x, y)
    local q = (abs(x - cx) / rx) ^ p + (abs(y - cy) / ry) ^ p
    if q > 1 then return -1 end
    return hz * (1 - q) ^ 0.35
  end
end
local parts = {
  seg(12, 46, 40, 46, 4.6, 4.4),            -- upper arm
  dome(27, 40.5, 9.5, 6.2, 6.0),            -- bicep peak
  seg(41, 45, 46, 26, 5.0, 4.0),            -- forearm
  dome(41.5, 46, 5.2, 4.6, 4.6),            -- elbow
  sbox(48, 17.5, 6.6, 6.6, 6.0, 3.2),       -- fist (palm block)
  dome(43, 13, 3.4, 1.9, 5.2),              -- curled fingers, stacked rolls facing left
  dome(42.6, 16.3, 3.4, 1.9, 5.2),
  dome(42.6, 19.6, 3.4, 1.9, 5.2),
  dome(43.2, 22.6, 3.0, 1.7, 4.6),
}
local function H(x, y)
  local a, b = -1, -1
  for _, f in ipairs(parts) do
    local v = f(x, y)
    if v > a then a, b = v, a elseif v > b then b = v end
  end
  return a, b
end
local am = HP.mask()
for y = 0, 63 do for x = 0, 63 do if H(x, y) >= 0 then am:set(x, y) end end end
local function h1(x, y) local a = H(x, y) return max(0, a) * 1.3 end
local an = D.hnorm(am, h1)
local bias = {}
am:each(function(x, y) local a, b = H(x, y)
  if b >= 0 and a - b < 1.3 then bias[K(x, y)] = -1 end
end)
-- wrist crease
am:each(function(x, y) if y == 24 and x >= 42 and x <= 50 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end end)
local aidx = D.tone(c, am, an, SK, { amb = 0.05, wrap = 0.18, bias = bias, tok = atok, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 } })

-- fist detail: finger rolls on the left face (horizontal grooves), knuckle row on top, thumb across the front
-- fingertips tucked into the palm: a dark slot right of each finger roll
for _, fy in ipairs{ 13, 16, 20 } do c:put(46, fy, SK[2], atok) c:put(47, fy, SK[3], atok) end
-- knuckle bumps: lit pixels along the top edge
for _, kx in ipairs{ 46, 49 } do c:put(kx, 12, SK[6], atok) c:put(kx + 1, 12, SK[5], atok) D.shift(c, kx + 2, 12, SK, -1) end
-- thumb: small lit tube lapping across the lower front of the fist
local tm, tn = G.tube({ { 53, 21.5 }, { 51, 20.5 }, { 48.5, 19.5 }, { 45.5, 18.2 } }, function(t) return 1.75 - t * 0.25 end)
local tb = {}
D.tone(c, tm, tn, SK, { amb = 0.12, wrap = 0.3, tok = atok, bias = tb, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
tm:grow(1):cut(tm):each(function(x, y) if am:has(x, y) and (y >= 20 or x < 46) then c:put(x, y, SK[2], atok) end end)
c:put(45, 18, SK[6], atok) c:put(46, 18, SK[6], atok) -- thumbnail glint
c:put(45, 19, SK[5], atok)
-- bicep specular and a lit edge on the forearm
c:put(23, 36, D.CREAM, atok) c:put(24, 36, SK[6], atok) c:put(22, 37, SK[6], atok)
-- cool reflected light under the upper arm
am:edge():each(function(x, y) if y >= 49 and x > 16 and x < 44 then c:put(x, y, "#a06a7a", atok) end end)

-- quirk: a crossed sticking plaster on the forearm (two pale strips, pink pad, pin holes)
local pl = {
  "aa...aa",
  "abb.bbc",
  ".bpPpc.",
  "..PpP..",
  ".bpPpc.",
  "abc.bcc",
  "ac...cc" }
local PM = { a = "#fff6ea", b = "#f4dcc0", c = "#c48c78", p = "#ec8e98", P = "#b85a70" }
for yy, row in ipairs(pl) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if PM[ch] then c:put(40 + xx, 27 + yy, PM[ch], ptok) end end end
-- sleeve: short cloth tube around the shoulder end, rolled cuff on its right
local sm = D.poly{ { 6.5, 39 }, { 9, 37 }, { 16, 38.2 }, { 17.6, 46 }, { 16, 54 }, { 9, 55.6 }, { 6.5, 53.5 }, { 5.6, 46 } }
local function sh(x, y) if not sm:has(x, y) then return 0 end local d = abs(y - 46) / 9 return 4 * sqrt(max(0, 1 - d * d)) end
local sn = D.hnorm(sm, sh)
local sidx = D.tone(c, sm, sn, CL, { amb = 0.1, wrap = 0.3, tok = ctok, cuts = { 0.22, 0.42, 0.62, 0.8 } })
-- weave: diagonal lines on the sleeve body
sm:each(function(x, y) if x < 13 and (x + y) % 4 == 0 then D.shift(c, x, y, CL, -1) end end)
-- cuff roll: dark roll line, lit roll top
for y = 37, 55 do
  if sm:has(12, y) then c:put(12, y, CL[1], ctok) end
  for x = 13, 15 do if sm:has(x, y) then D.shift(c, x, y, CL, 1) end end
  if sm:has(13, y) and y > 39 and y < 52 then D.shift(c, 13, y, CL, 1) end
end
-- contact shadow on the skin right of the cuff
for y = 38, 54 do for x = 17, 19 do if am:has(x, y) and not sm:has(x, y) and not sm:has(x - 1, y) == false then D.shift(c, x, y, SK, -1) end end end
for y = 38, 54 do if am:has(18, y) and not sm:has(18, y) and sm:has(17, y) then D.shift(c, 18, y, SK, -1) end end
D.save(c, "ico-strength")
