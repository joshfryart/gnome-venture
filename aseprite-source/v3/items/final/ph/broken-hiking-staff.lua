-- broken-hiking-staff (aB11_5, Opus single pass). Long slim oak staff on the diagonal (knob upper-right, iron
-- ferrule + spike lower-left), gnarled burl knob with a knot hole, twisted cord grip wrap, leather wrist strap loop.
-- Material: per-pixel lit 6-tone oak/burl/iron/leather, grain lanes, cord twist bands, AO where wrap and ferrule meet wood.
-- broken: snapped clean through below the grip; both ends splintered, the lower half knocked out of line, a
-- splinter flying from the break.
-- quirk: a little blue jay feather tucked into the grip wrap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_5.lua")
local HP, X, c = A.new("broken-hiking-staff")
local K = A.K
local W, B, I, Lh, Cd = A.OAK, A.BURL, A.IRON, A.LEATH, A.CORD
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin

-- leather wrist strap first (hangs behind the staff, to the right)
local sp = { {41,17}, {52,17}, {53,28}, {44,24} }
local sm_, sn_, sT, sS = A.tubeGeo(sp, function(t) return 0.85 end)
local sidx = A.shade(c, sm_, sn_, Lh, { amb = 0.15 })
sm_:each(function(x, y) local k = K(x, y) if abs(sS[k]) < 0.2 and floor(sT[k] * 40) % 3 == 0 then A.bump(c, sidx, Lh, x, y, 1) end end)

-- upper piece: knob end down to the break
local up = A.seg(44, 14, 32, 33)
local um, un, uT, uS, usm = A.tubeGeo(up, function(t) return 1.7 end,
  function(t, s, x, y) return t < 0.93 + 0.07 * ((x + y) % 3 == 0 and 1 or 0) * (s > 0 and 1 or 0) end)
local ub = {}
local uidx = A.shade(c, um, un, W, { bias = ub })
A.grain(c, um, uT, uS, uidx, W, { -0.35, 0.35 }, 24, 7)
-- splinters at the bottom of the upper piece (pointing down-left)
for _, s in ipairs{ { {33,32},{33,34},{32,36} }, { {31,32},{30,34} } } do
  local m = c:line(s, 1) m:each(function(x, y) c:put(x, y, (x < 32) and W[5] or W[3]) end)
end
c:put(32, 32, W[6]) c:put(33, 31, W[2])

-- twisted cord grip wrap on the upper piece
um:each(function(x, y) local k = K(x, y) local t = uT[k]
  if t > 0.3 and t < 0.62 then
    local band = floor((t * 24 + uS[k] * 1.1) * 1.0)
    local lit = uidx[k] or 3
    local i = (band % 2 == 0) and lit or lit - 1
    if (t * 24 + uS[k] * 1.1) % 1 < 0.22 then i = 1 end
    c:put(x, y, Cd[A.clampI(i)])
  end
end)
-- AO on wood just outside the wrap
um:each(function(x, y) local k = K(x, y) local t = uT[k]
  if (t > 0.62 and t < 0.67) or (t > 0.25 and t < 0.3) then A.bump(c, uidx, W, x, y, -1) end end)

-- burl knob
local knob = c:ellipse(45, 11, 3.6, 3.4)
knob:add(c:ellipse(43, 13, 2.2, 2.2))
knob:add(c:ellipse(48, 9, 1.6, 1.4))
local kn = X.pillow(knob, 2.6)
local kidx = A.shade(c, knob, kn, B)
-- knot hole + growth swirl
A.set(c, kidx, B, 46, 11, 1) A.set(c, kidx, B, 47, 11, 2) A.set(c, kidx, B, 46, 12, 2)
A.set(c, kidx, B, 45, 10, 5)
for _, p in ipairs{ {44,12},{44,13},{45,14},{47,13},{48,12} } do A.bump(c, kidx, B, p[1], p[2], -1) end
A.set(c, kidx, B, 43, 9, 6) A.set(c, kidx, B, 44, 9, 6)
-- AO where knob meets the shaft
for _, p in ipairs{ {42,14},{43,14},{44,14},{41,13} } do A.bump(c, uidx, W, p[1], p[2], -1) end
-- strap ties onto the shaft: leather collar
for _, p in ipairs{ {40,16},{41,16},{42,16},{41,17},{42,17},{43,17},{40,17} } do
  if um:has(p[1], p[2]) then c:put(p[1], p[2], (p[2] == 16) and Lh[5] or Lh[2]) end end

-- lower piece: knocked out of line (rotated a touch), from break down to the ferrule
local lp = A.seg(30, 38, 15, 56)
local lm, ln, lT, lS, lsm = A.tubeGeo(lp, function(t) return 1.7 end,
  function(t, s, x, y) return t > 0.05 * ((x * 7 + y) % 3) * (s < 0 and 1 or 0.5) end)
local lidx = A.shade(c, lm, ln, W)
A.grain(c, lm, lT, lS, lidx, W, { -0.3, 0.4 }, 24, 11)
-- splinter on the lower piece (pointing up-right)
do local m = c:line({ {31,38},{32,36},{33,35} }, 1) m:each(function(x, y) c:put(x, y, (y < 37) and W[6] or W[4]) end) end
-- pale torn fibres on the break face
for _, p in ipairs{ {29,38},{30,38},{30,39} } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], W[6]) end end

-- iron ferrule + spike
local fm, fn, fT, fS = A.tubeGeo(A.seg(17.6, 52.5, 15, 56), function(t) return 1.95 end)
local fidx = A.shade(c, fm, fn, I)
fm:each(function(x, y) if fT[K(x, y)] < 0.18 then A.bump(c, fidx, I, x, y, -1) end end)
for _, p in ipairs{ {18,50},{19,50},{17,51},{19,51},{20,51} } do A.bump(c, lidx, W, p[1], p[2], -1) end
local spike = c:poly{ {13,56},{16,57},{12,60} }
local skidx = A.shade(c, spike, X.pillow(spike, 1), I, { amb = 0.2 })
c:put(14, 55, I[6])

-- flying splinter from the break
do local m = c:line({ {37,38},{39,37} }, 1) c:put(37, 38, W[4]) c:put(38, 37, W[6]) c:put(39, 37, W[5]) end

-- quirk: blue jay feather tucked into the wrap (left side)
local fe = {
  "ab....",
  "Bab...",
  ".Bcb..",
  "..Bcb.",
  "....dd",
}
A.map(c, fe, 31, 17, { a = "#3a86b0", b = "#5fc4c8", B = "#2a4a7a", c = "#b6f0e0", d = A.CREAM })
A.fin(c)
