-- ico-hand-wave (final, Opus). A hand mid-wave, seen from the back and tipped to the right: four slim fingers fanned
-- apart with air between them, a thumb swinging out to the left, a rounded back of the hand on a slim wrist, a red
-- cloth sleeve, and two bold motion arcs either side of the fingertips.
-- Material: skin = per-part pillow light snapped to a 6-tone warm ramp; pale fingernails with a lit tip, a glint and
-- a dark cuticle; lit knuckle bumps with a dimple shadow between them; two short tendon highlights on the back of the
-- hand; AO where fingers and thumb leave the hand and under the sleeve. Sleeve = 6-tone ember cloth with fold creases
-- and a rolled cuff. Arcs = 4-tone sky, lit on the inner edge.
-- quirk: a red thread is tied round the index finger in a little bow (so the gnome won't forget to wave).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, rad, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.rad, math.pi
local c = A.new("ico-hand-wave")
local SK = { "#7a4036", "#a95f48", "#cf8566", "#eaa883", "#f7caa3", "#ffe6c6" }
local NAIL = { "#c98478", "#f0b8aa", "#ffdcd0", "#fff4ea" }
local RD = { "#5e1a30", "#8a2438", "#b8333c", "#e04b3e", "#f57a55", "#ffab7e" }
local SKY = { "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local stok, ntok, rtok, atok = A.tok("skin"), A.tok("nail"), A.tok("sleeve"), A.tok("arc")

local TILT = 13
local function dir(deg) local a = rad(deg + TILT) return sin(a), -cos(a) end
local PX, PY = 30.5, 42
-- fingers: angle (deg from up), knuckle distance, length, radius
local FING = { { -27, 7.4, 14.0, 2.3 }, { -9, 8.0, 16.0, 2.35 }, { 9, 7.8, 15.0, 2.3 }, { 27, 7.0, 11.5, 2.05 } }

-- back of the hand + wrist
local back = A.ell(PX, PY, 8.2, 8.4)
local wx, wy = dir(180)
local wrist = A.caps(PX + wx * 3, PY + wy * 3, PX + wx * 13, PY + wy * 13, 5.2)
local bm = back:copy():add(wrist)
local bidx = A.pill(c, bm, 5, SK, { tok = stok, amb = 0.12, wrap = 0.32, tilt = { PX, PY, 12, 0.06 } })
-- tendon highlights fanning from the wrist toward the index and middle knuckles
for _, f in ipairs{ FING[1], FING[2], FING[3] } do
  local ux, uy = dir(f[1] * 0.6)
  for s = -1, 4 do
    local x, y = floor(PX + ux * s + wx * 2 + .5), floor(PY + uy * s + wy * 2 + .5)
    if s % 2 == 0 then A.step(c, bidx, SK, x, y, 1, stok) end
  end
end

-- thumb swings out to the left from the lower side of the hand
local tax, tay
do local dx, dy = dir(-95) tax, tay = PX + dx * 5.5, PY + dy * 5.5 + 2.5 end
local tdx, tdy = dir(-62)
local thumb = A.caps(tax, tay, tax + tdx * 11, tay + tdy * 11, 2.6)
local tidx = A.pill(c, thumb, 2.4, SK, { tok = stok, amb = 0.12, wrap = 0.32 })
A.touch(bm:copy():cut(thumb), thumb):each(function(x, y) A.step(c, bidx, SK, x, y, -1, stok) end)

-- fingers
local fall = HP.mask()
local fidx = {}
local tips = {}
for i, f in ipairs(FING) do
  local ux, uy = dir(f[1])
  local kx, ky = PX + ux * f[2], PY + uy * f[2]
  local ex, ey = kx + ux * f[3], ky + uy * f[3]
  local m = A.caps(kx - ux * 2, ky - uy * 2, ex, ey, f[4])
  local idx = A.pill(c, m, 2.2, SK, { tok = stok, amb = 0.12, wrap = 0.32 })
  for k, v in pairs(idx) do fidx[k] = v end
  fall:add(m)
  tips[i] = { ex, ey, ux, uy, kx, ky, m }
end
-- air between fingers: unpaint 1 px where two neighbouring fingers touch, above the knuckle line
for i = 1, #FING - 1 do
  local a, b = tips[i][7], tips[i + 1][7]
  a:each(function(x, y)
    if b:has(x + 1, y) or b:has(x, y) or b:has(x + 1, y - 1) then
      local d = sqrt((x - PX) ^ 2 + (y - PY) ^ 2)
      if d > 9.5 then A.unpaint(c, x, y) end
    end
  end)
end
for i, t in ipairs(tips) do
  local ex, ey, ux, uy, kx, ky = t[1], t[2], t[3], t[4], t[5], t[6]
  local px, py = -uy, ux
  -- nail: a short rounded pale plate near the tip
  local nail = A.caps(ex - ux * 0.9, ey - uy * 0.9, ex - ux * 2.6, ey - uy * 2.6, 1.05)
  nail:clip(t[7]:shrink(1))
  nail:each(function(x, y)
    local s = (x - ex) * px + (y - ey) * py
    local a = (x - ex) * ux + (y - ey) * uy
    c:put(x, y, (s < -0.2 and a > -2.4) and NAIL[3] or NAIL[2], ntok)
  end)
  -- cuticle (dark row under the nail) + glint
  local cx, cy = floor(ex - ux * 3.9 + .5), floor(ey - uy * 3.9 + .5)
  if t[7]:has(cx, cy) and not nail:has(cx, cy) then A.step(c, fidx, SK, cx, cy, -1, stok) end
  local gx, gy = floor(ex - ux * 1.8 - px * 0.7 + .5), floor(ey - uy * 1.8 - py * 0.7 + .5)
  if nail:has(gx, gy) then c:put(gx, gy, NAIL[4], ntok) end
  -- middle joint crease (2 px)
  do local jx, jy = floor(kx + ux * (FING[i][3] * 0.42) + px * 0.6 + .5), floor(ky + uy * (FING[i][3] * 0.42) + py * 0.6 + .5)
    A.step(c, fidx, SK, jx, jy, -1, stok) end
  -- knuckle bump: lit pixel at the knuckle, dimple shadow next to it
  local bx, by = floor(kx - ux * 0.5 - px * 0.6 + .5), floor(ky - uy * 0.5 - py * 0.6 + .5)
  A.step(c, fidx, SK, bx, by, 2, stok)
  local dx_, dy_ = floor(kx - ux * 1.5 + px * 2.2 + .5), floor(ky - uy * 1.5 + py * 2.2 + .5)
  if i < #tips then A.step(c, bidx, SK, dx_, dy_, -1, stok) A.step(c, fidx, SK, dx_, dy_, -1, stok) end
end
-- AO where the fingers leave the back of the hand (back pixels touching the finger roots, lower side)
A.touch(bm:copy():cut(fall), fall):each(function(x, y) if y < PY - 3 then A.step(c, bidx, SK, x, y, -1, stok) end end)

-- sleeve: ember cloth on the wrist, rolled cuff at the top
local sax, say = PX + wx * 11, PY + wy * 11
local sbx, sby = PX + wx * 20, PY + wy * 20
local sleeve = A.caps(sax, say, sbx, sby, 6.6)
local uvf = A.frame(sax, say, wx, wy)
sleeve = A.pred(0, 0, 63, 63, function(x, y) local u, v = uvf(x, y) return sleeve:has(x, y) and u >= 0 and u <= 6.5 end)
local sn = {}
sleeve:each(function(x, y) local u, v = uvf(x, y)
  local s = max(-0.97, min(0.97, v / 7.2))
  local nx, ny = -wy * s, wx * s                               -- across the sleeve
  local tz = u < 2 and -0.5 or 0.15                             -- rolled cuff faces up
  local l = sqrt(nx * nx + ny * ny + (1 - s * s) + tz * tz)
  sn[K(x, y)] = { (nx + wx * tz) / l, (ny + wy * tz) / l, sqrt(1 - s * s) / l }
end)
local sidx = A.shade(c, sleeve, sn, RD, { tok = rtok, amb = 0.1, wrap = 0.3 })
sleeve:each(function(x, y) local u, v = uvf(x, y)
  if u >= 2 and u < 2.9 then A.step(c, sidx, RD, x, y, -2, rtok) end            -- under the rolled cuff
  if u > 3.5 and (abs(v - u * 0.5 + 1) < 0.5 or abs(v + 3.6 - u * 0.3) < 0.45) then A.step(c, sidx, RD, x, y, -1, rtok) end  -- fold creases
  if u > 3.5 and abs(v - u * 0.5 + 2) < 0.45 then A.step(c, sidx, RD, x, y, 1, rtok) end
end)
-- AO on the wrist just above the sleeve
A.touch(bm:copy():cut(sleeve), sleeve):each(function(x, y) A.step(c, bidx, SK, x, y, -1, stok) end)
-- one glint on the back of the hand
c:put(floor(PX - 4), floor(PY - 4), SK[6], stok) c:put(floor(PX - 3), floor(PY - 4), SK[6], stok)
c:put(floor(PX - 4), floor(PY - 5), "#fff4d6", stok)

-- motion arcs: two bold curved swooshes either side of the fingertips
local function arc(cx, cy, r, a0, a1)
  local m = HP.mask()
  A.ring(cx, cy, r, r + 1.6):each(function(x, y)
    local _, a = A.polar(x, y, cx, cy)
    if a >= a0 and a <= a1 then m:set(x, y) end end)
  m:cut(fall:grow(2)):cut(bm:grow(2)):cut(thumb:grow(2))
  m:each(function(x, y) local d = A.polar(x, y, cx, cy) c:put(x, y, d < r + 0.8 and SKY[3] or SKY[2], atok) end)
  return m
end
arc(PX + 1, PY - 8, 21, rad(-62), rad(-28))
arc(PX + 1, PY - 8, 21, rad(-160), rad(-128))

-- quirk: a red thread tied round the index finger with a tiny bow
do local t = tips[1]
  local ux, uy = t[3], t[4] local px, py = -uy, ux
  local bx, by = t[5] + ux * 4.2, t[6] + uy * 4.2
  t[7]:each(function(x, y)
    local a = (x - bx) * ux + (y - by) * uy
    if a > -0.5 and a < 0.5 then c:put(x, y, (x - bx) * px + (y - by) * py < 0 and RD[5] or RD[3], A.tok("thread")) end end)
  -- bow on the thumb side: two tiny loops and a tail
  local ox, oy = floor(bx - px * 3.0 + .5), floor(by - py * 3.0 + .5)
  local th = A.tok("thread")
  for _, q in ipairs{ { 0, 0, 3 }, { -1, -1, 4 }, { -1, 1, 4 }, { -2, -1, 3 }, { -2, 1, 3 }, { -1, 2, 2 } } do
    c:put(ox + q[1], oy + q[2], RD[q[3]], th) end
end
A.save(c, "ico-hand-wave")
