-- ico-hammer (final, Opus). A claw hammer lying on the diagonal: slim ash handle from lower-left to upper-right with a
-- slight waist and a flared butt; a forged steel head across the top, round striking face to the upper-left, a narrow
-- neck, a thick cheek block round the eye, and a curved split claw sweeping down to the lower-right.
-- Material: steel = pillow-bevel light on a 6-tone cool ramp, a bright lit bevel edge, a specular streak along the
-- crown, a dark chamfer groove on the cheeks, a polished pale ring on the striking face, the dark slot of the claw.
-- Wood = per-pixel cylinder light on a 6-tone ramp, wavy grain lines, pale end grain with a wedge slot showing above
-- the head, AO where the handle disappears into the head.
-- quirk: a red-and-cream twisted cord loop is tied through the butt (so it can hang on a gnome's nail).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("ico-hammer")
local ST = { "#2b2c44", "#45475f", "#666984", "#8f92ad", "#babdd2", "#e6e8f2" }
local WD = { "#4a2a22", "#6e4430", "#935f3c", "#b97a4a", "#d9a46a", "#f0cd94" }
local stok, wtok = A.tok("steel"), A.tok("wood")
local R2 = sqrt(2)
local OX, OY = 38, 23
-- u: along the handle (up-right +), v: along the head (lower-right +)
local function uv(x, y) local dx, dy = x - OX, y - OY return (dx - dy) / R2, (dx + dy) / R2 end
local DU = { 1 / R2, -1 / R2 }   -- screen dir of +u
local DV = { 1 / R2, 1 / R2 }    -- screen dir of +v

-- handle half-width along u
local function hw(u)
  if u < -33 then return 2.7 end                         -- flared butt
  if u < -29 then return 2.7 - (u + 33) / 4 * 0.6 end
  return 2.1 + 0.15 * sin((u + 29) / 34 * 3.14159)        -- gentle belly
end
local handle = A.pred(0, 0, 63, 63, function(x, y) local u, v = uv(x, y) return u >= -36 and u <= 6.4 and abs(v) <= hw(u) end)

-- head shape
local function claw(v) local t = (v - 3.6) / 13 return 0.6 - t * t * 7.5, 4.4 * (1 - t * 0.45) end
local function inHead(u, v)
  if v >= -15.5 and v < -9.6 then return abs(u) <= (v < -14.6 and 4.2 or 4.9) end             -- striking face (round poll)
  if v >= -9.6 and v < -4.6 then return abs(u) <= 2.5 end               -- neck
  if v >= -4.6 and v <= 3.6 then return abs(u) <= 4.6 end             -- cheek block round the eye
  if v > 3.6 and v <= 16.6 then local uc, w = claw(v) return abs(u - uc) <= w end
  return false
end
local head = A.pred(0, 0, 63, 63, function(x, y) local u, v = uv(x, y) return inHead(u, v) end)

-- wood first
local hn, hb = {}, {}
handle:each(function(x, y) local u, v = uv(x, y)
  local s = max(-0.97, min(0.97, v / (hw(u) + 0.5)))
  local nz = sqrt(1 - s * s)
  hn[K(x, y)] = { DV[1] * s, DV[2] * s, nz }
  if u > -8.6 and u < -4.1 then hb[K(x, y)] = -1 end      -- AO under the head
  if u > -6.1 and u < -4.1 then hb[K(x, y)] = -2 end
end)
local widx = A.shade(c, handle, hn, WD, { tok = wtok, amb = 0.1, wrap = 0.32, bias = hb })
-- grain: wavy lines running along the handle
handle:each(function(x, y) local u, v = uv(x, y)
  if u < 4 and u > -33 then
    local g1 = v - 0.55 * sin(u * 0.33 + 1.1)
    local g2 = v + 0.9 + 0.5 * sin(u * 0.27)
    if (abs(g1 - 0.5) < 0.38 or abs(g2 + 0.1) < 0.3) and X.hash(x, y, 2) < 0.8 then A.step(c, widx, WD, x, y, -1, wtok) end
  end end)
-- pale end grain at the butt: two rings
handle:each(function(x, y) local u, v = uv(x, y)
  if u < -34.4 then local r = sqrt((u + 36) ^ 2 * 0.3 + v * v)
    c:put(x, y, (r > 0.9 and r < 1.5) and WD[4] or WD[6], wtok) end end)
-- handle top: pale end grain showing above the head + a dark wedge slot across it
handle:each(function(x, y) local u, v = uv(x, y)
  if u > 5.6 then c:put(x, y, abs(v) < 0.6 and WD[2] or WD[6], wtok)
  elseif u > 4.6 then c:put(x, y, abs(v) < 0.6 and WD[3] or WD[5], wtok) end end)

-- steel head
local sn = X.pillow(head, 2.6)
local hbias = {}
head:each(function(x, y) local u, v = uv(x, y)
  -- the claw's underside sits in shadow
  if v > 6.5 then local uc, w = claw(v) if u - uc < -w * 0.35 then hbias[K(x, y)] = -1 end end
end)
local sidx = A.shade(c, head, sn, ST, { tok = stok, amb = 0.1, wrap = 0.25, bias = hbias, tilt = { OX, OY, 14, 0.12 }, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 } })
-- neck: darker, it is narrower and sits back
head:each(function(x, y) local u, v = uv(x, y)
  if v >= -9.6 and v < -4.6 then A.step(c, sidx, ST, x, y, -1, stok) end
  -- dark ring where the face meets the neck, and where the neck meets the cheeks
  if (v >= -10.2 and v < -9.5) or (v >= -4.9 and v < -4.2) then A.step(c, sidx, ST, x, y, -1, stok) end
  -- polished bright ring on the striking face end
  if v < -14.6 then c:put(x, y, u > 1.6 and ST[5] or (u < -2.2 and ST[3] or ST[6]), stok) elseif v < -13.7 and abs(u) < 4.4 then A.step(c, sidx, ST, x, y, -1, stok) end
  -- chamfer groove along the cheek block
  if v > -3.8 and v < 3 and abs(u - 2.9) < 0.42 then A.step(c, sidx, ST, x, y, -1, stok) end
  if v > -3.8 and v < 3 and abs(u + 2.9) < 0.42 then A.step(c, sidx, ST, x, y, -1, stok) end
end)
-- claw slot: the V split near the tip (becomes ink)
head:each(function(x, y) local u, v = uv(x, y)
  if v > 9.5 then local uc = claw(v) if abs(u - uc) < 0.75 then A.unpaint(c, x, y) end end end)
-- specular streak along the crown of the head (upper-left facing bevel), plus one cream glint
head:each(function(x, y) local u, v = uv(x, y)
  if v > -13.6 and v < 2.5 and u > 3.1 and u < 3.8 and (sidx[K(x, y)] or 0) >= 4 then c:put(x, y, ST[6], stok) end end)
do local best, bx, by
  head:each(function(x, y) local u, v = uv(x, y) if v > -13.6 and v < -9.8 and (not best or (x + y) < best) then best, bx, by = x + y, x, y end end)
  if bx then c:put(bx + 1, by + 1, "#fff4d6", stok) end end

-- quirk: a twisted red/cream cord loop through the butt
local CORD = { "#8e2a36", "#d6453c", "#fff0cc", "#c9b08a" }
do
  local bx, by = OX - 36 * DU[1], OY - 36 * DU[2]      -- butt centre
  local cx, cy = bx - 3.2, by + 3.2
  local ring = A.ring(cx, cy, 2.0, 3.4)
  ring:cut(handle)
  local ctok = A.tok("cord")
  ring:each(function(x, y) local r, a = A.polar(x, y, cx, cy)
    local seg = floor((a + 3.1416) / (2 * 3.1416) * 14 + (r > 2.7 and 0.5 or 0))
    local lit = (x - cx) + (y - cy) < 0
    if seg % 2 == 0 then c:put(x, y, lit and CORD[3] or CORD[4], ctok) else c:put(x, y, lit and CORD[2] or CORD[1], ctok) end
  end)
  -- the knot where it passes through the butt
  c:put(floor(bx - 1 + .5), floor(by + 1 + .5), CORD[1], ctok)
end
A.save(c, "ico-hammer")
