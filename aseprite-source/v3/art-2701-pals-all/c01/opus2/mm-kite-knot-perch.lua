-- Kite Knot (mm-kite-knot), perch sprite 36x36. Opus second pass (c01/opus2), hand-built at this size.
-- Tilted diamond kite in four panels (ember / gold, two tones each plus a hem), spars as dark creases,
-- pill eyes under bold ink cross brows, a pout; tail swinging down. Huff puff as one 4 px cloud.
-- quirk: the pink bow tied in the tail.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mm-kite-knot-perch", 36)

local EMB  = { "#4a1a2e", "#7e2238", "#b8343c", "#e0533e", "#f4864e", "#fbc07a" }
local GOLD = { "#5e3a1c", "#9a5d1e", "#d08a2a", "#f0b440", "#f8d670", "#fdf0b0" }
local PINK = { "#7a2a4a", "#c94f6d", "#ef7a8a", "#f7a8a8" }
local CLD  = { "#8696b4", "#b2c0d6", "#d9e3ee", "#eef3f8" }

local cx, cy, ang = 20, 13.5, math.rad(14)
local ca, sa = math.cos(ang), math.sin(ang)
local function rot(lx, ly) return cx + lx * ca - ly * sa, cy + lx * sa + ly * ca end
local function unrot(x, y) local dx, dy = x + .5 - cx, y + .5 - cy return dx * ca + dy * sa, -dx * sa + dy * ca end
local pts = {}
for _, p in ipairs({ { 0, -11 }, { 11, -3 }, { 0, 11 }, { -11, -3 } }) do local x, y = rot(p[1], p[2]) pts[#pts+1] = { x, y } end
local kite = c:poly(pts)
local bx, by = rot(0, 11)
local tail = { { bx, by }, { bx - 4, by + 2 }, { bx + 2, by + 5 }, { bx - 2, by + 8 } }
O.tube(tail, function() return .5 end):each(function(x, y) c:put(x, y, "#d8ccb8", { r = { name = "string" } }) end)
local ktok = { r = { name = "kite" } }
kite:each(function(x, y)
  local lx, ly = unrot(x, y)
  local red = (lx < 0) == (ly < -3)
  local R = red and EMB or GOLD
  local i = (lx + ly < -6) and 5 or ((lx + ly < 4) and 4 or 3)
  c:put(x, y, R[i], ktok)
end)
kite:edge():each(function(x, y) local lx, ly = unrot(x, y) c:put(x, y, ((lx < 0) == (ly < -3)) and EMB[2] or GOLD[2], ktok) end)
local function crease(a, b)
  local x0, y0 = rot(a[1], a[2]) local x1, y1 = rot(b[1], b[2])
  local nn = math.floor(math.max(math.abs(x1 - x0), math.abs(y1 - y0)))
  for t = 0, nn do
    local x, y = math.floor(x0 + (x1 - x0) * t / nn + .5), math.floor(y0 + (y1 - y0) * t / nn + .5)
    if c.own[y * 36 + x] == ktok then local lx, ly = unrot(x, y) c:put(x, y, ((lx < 0) == (ly < -3)) and EMB[2] or GOLD[2], ktok) end
  end
end
crease({ 0, -10 }, { 0, -3 }) crease({ -10, -3 }, { 10, -3 }) crease({ 0, 8 }, { 0, 10 })
-- face
local fx, fy = rot(0, 2)
fx, fy = math.floor(fx), math.floor(fy)
c:eyeSmall(fx - 4, fy - 2)
c:eyeSmall(fx + 2, fy - 1)
O.dots(c, { { fx - 5, fy - 4 }, { fx - 4, fy - 4 }, { fx - 3, fy - 3 } }, P.ink)
O.dots(c, { { fx + 4, fy - 3 }, { fx + 3, fy - 3 }, { fx + 2, fy - 2 } }, P.ink)
O.dots(c, { { fx - 2, fy + 4 }, { fx - 1, fy + 3 }, { fx, fy + 3 }, { fx + 1, fy + 4 } }, P.ink)
-- bow
local qx, qy = O.bez(tail, .45)
qx, qy = math.floor(qx), math.floor(qy)
local bow = c:poly{ { qx, qy }, { qx - 3, qy - 2 }, { qx - 3, qy + 2 } }:add(c:poly{ { qx, qy }, { qx + 3, qy - 2 }, { qx + 3, qy + 2 } })
O.shade(c, bow, PINK, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
O.dot(c, qx, qy, PINK[2]) O.dot(c, qx - 2, qy - 1, PINK[4])
-- huff
O.shade(c, O.unionCircles{ { 5, 13, 2, 1.5 }, { 7, 12, 1.5, 1.2 } }, CLD, { R = 1, amb = .4, cuts = { .35, .6, .85 } })
O.done(c, "mm-kite-knot-perch")
