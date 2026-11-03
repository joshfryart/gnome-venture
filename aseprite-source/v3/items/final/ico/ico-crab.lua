-- ico-crab (final, Opus). A shore crab seen from the front and above: a slim oval carapace with two small side
-- spines, eyes up on short stalks, two raised arms ending in big notched pincers, and three jointed walking legs a
-- side splayed out with air between them.
-- Material: pillow/dome normals snapped to a 6-tone ember shell ramp, a pebbly shell (lit bumps with dark
-- undersides), a groove line marking the face region, a waxy specular on the upper-left of the shell and on each
-- pincer, darker chitin pincer tips, cool reflected light along the lower-right edges, AO at every joint and where
-- the legs tuck under the shell.
-- quirk: it is proudly holding a tiny pearl in its left pincer.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-crab")
local SH  = { "#5e1a32", "#8f2335", "#c23a36", "#e8583e", "#ff8a5c", "#ffc09a" }
local LEG = { "#541a30", "#7e2333", "#ab3434", "#d44d3a", "#f07650" }
local TIP = "#4a1a2a"
local BOUNCE = "#9a4a7a"
local PRL = { "#9b8fb8", "#d8d0e8", "#f4efff", "#fff4d6" }
local EYE = { "#c9b8b0", "#fff4d6" }
local tS, tL, tP, tE = A.tok("shell"), A.tok("leg"), A.tok("pearl"), A.tok("eye")
local CX = 31.5
local function mir(x) return 63 - x end

-- legs (behind everything)
local legs = {
  { { 23, 36 }, { 14, 34 }, { 9, 40 } },
  { { 23, 39 }, { 15, 41 }, { 12, 48 } },
  { { 25, 42 }, { 20, 46 }, { 19, 52 } },
}
local legM, legN, knees = HP.mask(), {}, {}
for _, L in ipairs(legs) do
  for side = 0, 1 do
    local p = {}
    for i, q in ipairs(L) do p[i] = { side == 1 and mir(q[1]) or q[1], q[2] } end
    local m1, n1 = A.seg(p[1][1], p[1][2], p[2][1], p[2][2], 1.75, 1.55)
    local m2, n2 = A.seg(p[2][1], p[2][2], p[3][1], p[3][2], 1.55, 0.9)
    legM:add(m1):add(m2) A.merge(legN, n1) A.merge(legN, n2)
    knees[#knees + 1] = { floor(p[2][1] + 0.5), floor(p[2][2] + 0.5) }
  end
end
-- carapace mask (needed now for leg AO)
local SCY = 37
local body = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = (x - CX) / 12.0, (y - SCY) / (y < SCY and 8.4 or 7.2)
  local r = dx * dx + dy * dy
  -- side spines: a small point at the widest part
  local sp = (abs(abs(x - CX) - 12.6) < 1.1 and abs(y - (SCY - 2)) < 1.0) and abs(x - CX) < 13.6
  if r <= 1 or sp then body:set(x, y) end
end end
local lb = {}
X.ao(lb, legM, body, 2, -1)
for _, kp in ipairs(knees) do for dy = -1, 1 do for dx = -1, 1 do
  local k = K(kp[1] + dx, kp[2] + dy) if legM:has(kp[1] + dx, kp[2] + dy) and abs(dx) + abs(dy) <= 1 then lb[k] = (lb[k] or 0) - 1 end end end end
local lidx = A.shade(c, legM, legN, LEG, { tok = tL, bias = lb, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.4, 0.6, 0.8 } })
-- knee glint (lit pixel just above each joint)
for _, kp in ipairs(knees) do if legM:has(kp[1] - 1, kp[2] - 1) then c:put(kp[1] - 1, kp[2] - 1, LEG[5], tL) end end

-- arms
local arms = { { { 21, 33 }, { 17, 29 }, { 14, 25 } } }
local armM, armN = HP.mask(), {}
for side = 0, 1 do
  local p = {}
  for i, q in ipairs(arms[1]) do p[i] = { side == 1 and mir(q[1]) or q[1], q[2] } end
  local m1, n1 = A.seg(p[1][1], p[1][2], p[2][1], p[2][2], 1.9, 1.7)
  local m2, n2 = A.seg(p[2][1], p[2][2], p[3][1], p[3][2], 1.7, 1.9)
  armM:add(m1):add(m2) A.merge(armN, n1) A.merge(armN, n2)
end
local ab = {}
X.ao(ab, armM, body, 2, -1)
A.shade(c, armM, armN, LEG, { tok = tL, bias = ab, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.4, 0.6, 0.8 } })

-- carapace
local function domeH(x, y)
  if not body:has(x, y) then return 0 end
  local dx, dy = (x - CX) / 12.5, (y - SCY + 1) / 8.5
  return 4.2 * sqrt(max(0, 1 - dx * dx - dy * dy)) + 0.8
end
local bn = A.hnorm(body, domeH, 1.0)
local pn = X.pillow(body, 2.2)
for k, n in pairs(bn) do local q = pn[k] bn[k] = { A.norm(n[1] + q[1] * 0.6, n[2] + q[2] * 0.6, n[3] + q[3] * 0.4) } end
local bb = {}
-- under-edge darker toward the front (belly shadow)
body:each(function(x, y) if not body:has(x, y + 1) or not body:has(x, y + 2) then bb[K(x, y)] = -1 end end)
local bidx = A.shade(c, body, bn, SH, { tok = tS, bias = bb, amb = 0.05, wrap = 0.2, tilt = { CX, SCY, 12, 0.22 }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
-- face groove: a shallow M-shaped line across the front of the shell
for x = floor(CX - 7), floor(CX + 8) do
  local dx = x - CX
  local y = floor(SCY + 1.5 - 0.06 * dx * dx + 0.5)
  if abs(dx) < 2 then y = floor(SCY + 1.5 + 0.5) - 1 end
  if body:has(x, y) then A.step(c, bidx, SH, x, y, -1, tS) if body:has(x, y - 1) then A.step(c, bidx, SH, x, y - 1, 1, tS) end end
end
-- pebbly bumps: lit pixel with a dark one below-right
local bumps = { { -6, -4 }, { -3, -6 }, { 1, -5 }, { 5, -5 }, { 8, -2 }, { -9, -1 }, { 3, -2 }, { -4, -2 } }
for _, b in ipairs(bumps) do
  local x, y = floor(CX + b[1] + 0.5), SCY + b[2]
  if body:has(x, y) and body:has(x + 1, y + 1) then A.step(c, bidx, SH, x, y, 1, tS) A.step(c, bidx, SH, x + 1, y + 1, -1, tS) end
end
-- cool reflected light on the lower-right edge
body:edge():each(function(x, y) if (x - CX) > 4 and y > SCY and (x - CX) + (y - SCY) * 1.4 > 10 then c:put(x, y, BOUNCE, tS) end end)
-- specular streak + glint on the upper-left of the shell
for _, p in ipairs{ { -6, -6 }, { -5, -6 }, { -4, -7 }, { -3, -7 } } do local x, y = floor(CX + p[1] + 0.5), SCY + p[2] if body:has(x, y) then c:put(x, y, SH[6], tS) end end
c:put(floor(CX - 6.5), SCY - 5, A.CREAM, tS)
-- mouth: a small content smile on the front rim
local mx, my = floor(CX + 0.5), SCY + 2
c:put(mx - 2, my, A.INK, tS) c:put(mx - 1, my + 1, A.INK, tS) c:put(mx, my + 1, A.INK, tS) c:put(mx + 1, my, A.INK, tS)

-- eye stalks + eyes
for side = 0, 1 do
  local bx = side == 1 and mir(27.5) or 27.5
  local sm, sn = A.seg(bx, SCY - 7, bx + (side == 1 and 0.6 or -0.6), SCY - 12, 1.1, 1.0)
  local sb = {}
  X.ao(sb, sm, body, 1, -1)
  A.shade(c, sm, sn, LEG, { tok = tE, bias = sb, cuts = { 0.2, 0.4, 0.6, 0.8 } })
  -- bulb: 4x5 cream with a 2x3 ink pill and glint
  local ex0 = floor(bx + (side == 1 and 0.6 or -0.6) + 0.5) - 2
  local ey0 = SCY - 17
  local rows = { ".cc.", "cccc", "cccc", "cccc", ".ss." }
  for j, row in ipairs(rows) do for i = 1, 4 do local ch = row:sub(i, i)
    if ch == "c" then c:put(ex0 + i - 1, ey0 + j - 1, EYE[2], tE) elseif ch == "s" then c:put(ex0 + i - 1, ey0 + j - 1, EYE[1], tE) end end end
  c:put(ex0 + 3, ey0 + 3, EYE[1], tE) c:put(ex0 + 3, ey0 + 2, EYE[1], tE)
  local px = ex0 + 1
  for j = 1, 3 do c:put(px, ey0 + j, A.INK, tE) c:put(px + 1, ey0 + j, A.INK, tE) end
  c:put(px, ey0 + 1, A.CREAM, tE)
end

-- pincers
local function claw(cx, cy, flip)
  local m = A.ell(cx, cy, 5.2, 5.8)
  -- notch between the two fingers (opens upward, slightly outward)
  local ox = flip and 0.8 or -0.8
  m:cut(c:poly{ { cx + ox * 0.5, cy + 1.5 }, { cx + ox * 2 - 3.3, cy - 7 }, { cx + ox * 2 + 3.1, cy - 7 } })
  return m
end
for side = 0, 1 do
  local cx, cy = side == 1 and mir(13.5) or 13.5, 19
  local m = claw(cx, cy, side == 1)
  local n = X.pillow(m, 2.6)
  local cb = {}
  local idx = A.shade(c, m, n, SH, { tok = tS, bias = cb, amb = 0.05, wrap = 0.2, tilt = { cx, cy, 6, 0.2 }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
  -- dark chitin tips on both fingers
  m:each(function(x, y) if y <= cy - 4 and not m:has(x, y - 1) then c:put(x, y, TIP, tS) end end)
  -- inner finger edge one tone darker (bite edge)
  m:each(function(x, y) if y < cy and y > cy - 4 and (not m:has(x - 1, y) or not m:has(x + 1, y)) and abs(x - cx) < 2.6 then A.step(c, idx, SH, x, y, -1, tS) end end)
  -- AO where the arm enters the claw
  m:each(function(x, y) if armM:has(x, y + 1) and not m:has(x, y + 1) then A.step(c, idx, SH, x, y, -1, tS) end end)
  -- glint
  local gx, gy = floor(cx - 2), cy - 1
  if m:has(gx, gy) then c:put(gx, gy, SH[6], tS) c:put(gx + 1, gy, SH[6], tS) end
  -- cool bounce on the lower-right
  m:edge():each(function(x, y) if (x - cx) + (y - cy) > 5.2 then c:put(x, y, BOUNCE, tS) end end)
end
-- quirk: a tiny pearl held in the left pincer's notch
do
  local px, py = 13, 15
  local pm = A.ell(px, py, 1.5, 1.5)
  local pn2 = X.sphere(px, py, 1.6, pm)
  A.shade(c, pm, pn2, PRL, { tok = tP, amb = 0.25, wrap = 0.4, cuts = { 0.3, 0.6, 0.85 } })
  c:put(px - 1, py - 1, A.CREAM, tP)
end

A.save(c, "ico-crab")
