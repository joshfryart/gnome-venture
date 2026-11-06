-- ico-clock (final, Opus). Twin-bell alarm clock on two slim splayed legs: glossy red enamel case (sphere light,
-- 6 tones), polished steel bezel ring (bevel, bright upper-left edge, dark lower-right), cream dial with an inner
-- rim shadow, 4 bold hour bars + 8 dots, ink hands at 10:10 with a brass pin, glass glint across the dial.
-- Brass bells (domed, specular cap, dark mouth), steel hammer between them, AO where bells and legs meet the case.
-- quirk: the clock is fast asleep: a little cream "z" drifts up off the right bell.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, cos, sin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin, math.pi
local c = A.new("ico-clock")
local INK, CR = A.INK, A.CREAM
local RED   = { "#5c1a32", "#8f2537", "#c3333b", "#e8493b", "#ff7656", "#ffb48a" }
local STEEL = { "#353650", "#545872", "#7c7e96", "#a8aabd", "#d3d4df", "#f3f1f5" }
local BRASS = { "#6a361d", "#9a571d", "#cf8a24", "#f2b632", "#ffd963", "#fff0b4" }
local DIAL  = { "#b99a7a", "#d8bd97", "#ecd8b2", "#f8e9c8", "#fff4d6" }
local CX, CY, R = 32, 34, 16

A.gshadow(c, 32, 54, 14, 1.2)

-- legs (behind case): slim steel rods with ball feet
local tl = A.tok("leg")
for _, s in ipairs{ -1, 1 } do
  local lm, ln = X.cyl(CX + s * 9, CY + 10, CX + s * 14, 52.5, function() return 1.2 end)
  A.shade(c, lm, ln, STEEL, { tok = tl })
  local fm = A.ell(CX + s * 14, 53, 1.6, 1.4)
  local fi = A.shade(c, fm, X.sphere(CX + s * 14, 53, 1.8, fm), STEEL, { tok = tl })
end

-- bells (behind case): domes tilted outward
local tb = A.tok("bell")
local bellM = HP.mask()
for _, s in ipairs{ -1, 1 } do
  local bx, by = CX + s * 12, CY - 13
  local ang = s * 0.6
  local ux, uy = sin(ang), -cos(ang)        -- dome axis (up, tilted out)
  local m = HP.mask()
  for y = floor(by) - 9, floor(by) + 9 do for x = floor(bx) - 9, floor(bx) + 9 do
    local dx, dy = x - bx, y - by
    local a = dx * ux + dy * uy             -- along axis (+ = top of dome)
    local b = dx * uy - dy * ux             -- across
    if a >= -1.5 and (a / 6.2) ^ 2 + (b / 7.0) ^ 2 <= 1 then m:set(x, y) end
  end end
  local n = {}
  m:each(function(x, y)
    local dx, dy = (x - bx) / 7.2, (y - by + uy * 0.5) / 7.2
    local q = 1 - dx * dx - dy * dy
    local l = sqrt(dx * dx + dy * dy + max(q, 0.05))
    n[K(x, y)] = { dx / l, dy / l, sqrt(max(q, 0.05)) / l }
  end)
  local bias = {}
  -- dark mouth rim: pixels in the lowest 1.5 px of the dome (along axis)
  m:each(function(x, y) local a = (x - bx) * ux + (y - by) * uy if a < -0.2 then bias[K(x, y)] = -2 end end)
  A.shade(c, m, n, BRASS, { tok = tb, bias = bias, amb = 0.12 })
  -- specular cap
  local sx, sy = floor(bx + ux * 3.2 - 2 + .5), floor(by + uy * 3.2 + .5)
  c:put(sx, sy, BRASS[6], tb) c:put(sx + 1, sy, BRASS[6], tb) c:put(sx, sy + 1, BRASS[5], tb)
  -- knob on top
  local kx, ky = floor(bx + ux * 7.2 + .5), floor(by + uy * 7.2 + .5)
  c:put(kx, ky, BRASS[4], tb) c:put(kx + 1, ky, BRASS[3], tb) c:put(kx, ky - 1, BRASS[5], tb) c:put(kx + 1, ky - 1, BRASS[4], tb)
  bellM:add(m)
end

-- hammer: steel post between bells with a rounded head
local th = A.tok("hammer")
local hm = c:rect(31, 15, 33, 19)
A.shade(c, hm, X.pillow(hm, 1.4), STEEL, { tok = th })
local hh = A.ell(32, 14, 2.5, 1.5)
A.shade(c, hh, X.pillow(hh, 1.6), STEEL, { tok = th })
c:put(31, 13, STEEL[6], th)

-- case: red enamel sphere-lit disc
local tc = A.tok("case")
local cm = A.ell(CX, CY, R, R)
local cn = X.sphere(CX - 0.5, CY - 0.5, R, cm)
local cb = {}
X.ao(cb, cm, bellM, 2, -1)
local ci = A.shade(c, cm, cn, RED, { tok = tc, bias = cb, amb = 0.1, wrap = 0.3 })
-- cool reflected light lower-right on the enamel
local rim = X.rim(cn)
cm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and x > CX + 3 and y > CY + 3 then c:put(x, y, "#a83a5c", tc) end end)
-- enamel specular streak upper-left
for _, p in ipairs{ { 20, 25 }, { 21, 24 }, { 22, 23 }, { 23, 22 }, { 21, 25 }, { 22, 24 } } do c:put(p[1], p[2], RED[6], tc) end
c:put(22, 22, CR, tc) c:put(21, 23, CR, tc)

-- bezel: steel ring r 13.5 .. 11.5
local tz = A.tok("bezel")
local bz = A.ell(CX, CY, 13, 13):cut(A.ell(CX, CY, 10.6, 10.6))
local zn = {}
bz:each(function(x, y)
  local dx, dy = x - CX, y - CY
  local d = sqrt(dx * dx + dy * dy)
  local r = (d - 11.8) / 1.6                 -- -1 inner .. +1 outer: rounded torus profile
  r = max(-0.95, min(0.95, r))
  local nz = sqrt(1 - r * r)
  zn[K(x, y)] = { dx / max(d, 0.1) * r, dy / max(d, 0.1) * r, nz }
end)
A.shade(c, bz, zn, STEEL, { tok = tz, amb = 0.12, wrap = 0.2, cuts = { 0.18, 0.36, 0.54, 0.7, 0.86 } })

-- dial: cream, inner rim shadow on the upper-left (the bezel casts into the dish)
local td = A.tok("dial")
local dm = A.ell(CX, CY, 10.6, 10.6):cut(bz)
dm:each(function(x, y)
  local dx, dy = x - CX, y - CY
  local d = sqrt(dx * dx + dy * dy)
  local i = 4
  local lit = (dx * 0.6 + dy * 0.75) / max(d, 0.1)   -- + = lower-right
  if d > 9.2 and lit < -0.1 then i = 2 elseif d > 8.2 and lit < -0.3 then i = 3
  elseif lit > 0.2 and d > 8.6 then i = 5 end
  c:put(x, y, DIAL[i], td)
end)
-- hour marks: 4 bold bars, 8 dots
local MK, MD = "#51302b", "#8a5a48"
c:put(31, 25, MK, td) c:put(32, 25, MK, td) c:put(31, 26, MK, td) c:put(32, 26, MK, td) c:put(31, 27, MK, td) c:put(32, 27, MK, td)
c:put(31, 41, MK, td) c:put(32, 41, MK, td) c:put(31, 42, MK, td) c:put(32, 42, MK, td) c:put(31, 43, MK, td) c:put(32, 43, MK, td)
c:put(23, 33, MK, td) c:put(23, 34, MK, td) c:put(24, 33, MK, td) c:put(24, 34, MK, td) c:put(25, 33, MK, td) c:put(25, 34, MK, td)
c:put(39, 33, MK, td) c:put(39, 34, MK, td) c:put(40, 33, MK, td) c:put(40, 34, MK, td) c:put(41, 33, MK, td) c:put(41, 34, MK, td)
for h = 1, 12 do if h % 3 ~= 0 then
  local a = h / 12 * 2 * pi
  c:put(floor(CX - 0.5 + sin(a) * 7.6 + .5), floor(CY - 0.5 - cos(a) * 7.6 + .5), MD, td)
end end
-- hands at 10:10 (hour toward 10, minute toward 2)
local function hand(ang, L, w)
  local m = A.stroke({ { CX - 0.5, CY - 0.5 }, { CX - 0.5 + sin(ang) * L, CY - 0.5 - cos(ang) * L } }, w)
  m:each(function(x, y) if dm:has(x, y) then c:put(x, y, INK, td) end end)
end
hand(-2 * pi / 12 * 1.9, 5.6, 1.05)
hand(2 * pi * 10 / 60, 7.6, 0.75)
-- brass centre pin
for _, p in ipairs{ { 31, 33, 5 }, { 32, 33, 4 }, { 31, 34, 4 }, { 32, 34, 3 } } do c:put(p[1], p[2], BRASS[p[3]], td) end
-- glass glint across the dial (upper-left, short diagonal)
c:put(26, 29, "#fffbea", td) c:put(27, 28, "#fffbea", td) c:put(28, 27, "#fffbea", td) c:put(26, 30, DIAL[5], td)

-- quirk: sleepy "z" drifting off the right bell
local tq = A.tok("z")
A.map(c, { "cccc", "..c.", ".c..", "cccc" }, 51, 9, { c = CR }, tq)

A.save(c, "ico-clock")
