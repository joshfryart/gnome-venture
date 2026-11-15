-- bond (Opus second pass). Tag "bond" (Bond: charm works better afterwards). Keeps Haiku's two linked rings (they
-- read as "joined") but makes them two twisted wool cords, like friendship bracelets: round torus lighting with a
-- 6-tone ramp each (ember red, honey gold), diagonal twist grooves, and a real over/under link (red over gold at the
-- top crossing, gold over red at the bottom) with a contact shadow on the cord underneath. The loose floating heart
-- is dropped.
-- quirk: a tiny acorn charm dangles from the gold bracelet on a short thread.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.atan
local c = O.new("bond")

local RED  = { "#4a1630", "#7a1f3a", "#b52e3f", "#e04a3c", "#ff7a58", "#ffc0a0" }
local GLD  = { "#5a2e18", "#8f4a1f", "#c87820", "#f0aa2a", "#ffd65e", "#fff0b0" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local NUT  = { "#6e3a1c", "#a8601e", "#d98322", "#f5b82e" }
local INK  = "#2b1c26"

local R, HW = 11.5, 2.4
local A = { x = 23.5, y = 29, ramp = RED, seed = 0 }
local B = { x = 39.5, y = 34, ramp = GLD, seed = 1.3 }

local function ring(o)
  local m, n, th = HP.mask(), {}, {}
  for y = floor(o.y - R - HW - 1), floor(o.y + R + HW + 1) do for x = floor(o.x - R - HW - 1), floor(o.x + R + HW + 1) do
    local dx, dy = x - o.x, y - o.y
    local d = sqrt(dx * dx + dy * dy)
    local s = (d - R) / (HW + 0.45)
    if abs(s) <= 1 then
      m:set(x, y)
      local ux, uy = dx / d, dy / d
      n[K(x, y)] = { ux * s, uy * s, sqrt(max(0.03, 1 - s * s)) }
      th[K(x, y)] = { atan(dy, dx), s }
    end
  end end
  o.m, o.n, o.th = m, n, th
  return o
end
ring(A) ring(B)

local function paint(o, clip)
  local tok = O.tok("ring" .. o.seed)
  local m = clip and o.m:copy():clip(clip) or o.m
  local n = {}
  m:each(function(x, y) n[K(x, y)] = o.n[K(x, y)] end)
  local idx = O.shade(c, m, n, o.ramp, { tok = tok, amb = 0.1, wrap = 0.3 })
  -- twist grooves: diagonal across the cord, every ~4 px along it
  m:each(function(x, y)
    local t = o.th[K(x, y)]
    local along = t[1] * R + t[2] * 2.2 + o.seed
    local f = (along / 4.5) % 1
    if f < 0.2 then O.step(c, idx, o.ramp, x, y, -1, tok)
    elseif f < 0.4 and t[2] < 0.3 then O.step(c, idx, o.ramp, x, y, 1, tok) end
  end)
  return idx, tok
end

-- the link: gold ring first, red ring over it, then the lower crossing of gold repainted over red
local gIdx = paint(B)
local rIdx = paint(A)
local front = B.m:copy():clip(A.m)
local lower = HP.mask()
front:each(function(x, y) if y > (A.y + B.y) / 2 then lower:set(x, y) end end)
-- widen a touch so the crossing is clean
local lowerB = lower:grow(1):clip(B.m)
paint(B, lowerB)
-- contact shadows on the cord that passes underneath
do
  -- top crossing: red over gold -> darken gold just outside red
  A.m:each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 }, { -1, 0 }, { 0, -1 } } do
      local nx, ny = x + d[1], y + d[2]
      if B.m:has(nx, ny) and not A.m:has(nx, ny) and ny <= (A.y + B.y) / 2 + 1 then c:put(nx, ny, GLD[1], O.tok("sh1")) end
    end
  end)
  lowerB:each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 }, { -1, 0 }, { 0, -1 } } do
      local nx, ny = x + d[1], y + d[2]
      if A.m:has(nx, ny) and not lowerB:has(nx, ny) then c:put(nx, ny, RED[1], O.tok("sh2")) end
    end
  end)
end
-- one hard specular on each ring, upper-left of the top
c:put(17, 19, RED[6], O.tok("sp")) c:put(18, 19, RED[6], O.tok("sp")) c:put(17, 20, RED[5], O.tok("sp"))
c:put(33, 24, GLD[6], O.tok("sp")) c:put(34, 24, GLD[6], O.tok("sp"))

-- quirk: acorn charm on a short thread from the bottom of the gold ring
do
  local tok = O.tok("acorn")
  for y = 48, 50 do c:put(43, y, "#c9b2a0", tok) end
  local nut, nn = O.oval(43, 55.5, 2.6, 3.2)
  O.shade(c, nut, nn, NUT, { tok = tok, amb = 0.2, cuts = { 0.3, 0.55, 0.8 } })
  c:put(43, 59, NUT[1], tok)
  local cap = c:rrect(40, 51, 46, 53, 1)
  cap:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and WOOD[2] or WOOD[3], tok) end)
  for x = 40, 46 do c:put(x, 53, WOOD[1], tok) end
  c:put(41, 51, WOOD[4], tok) c:put(42, 51, WOOD[4], tok)
  c:put(42, 55, NUT[4], tok)
end

O.save(c, "bond")
