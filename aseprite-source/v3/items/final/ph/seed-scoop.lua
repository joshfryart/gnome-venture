-- seed-scoop (D15 artist pass). A tinned-steel hand scoop tipped to pour: rolled rim with rivets, concave interior in shadow,
-- a heap of mixed seeds (striped, dark bean, millet, pea, red) heaped over the lip, exterior wall with specular and a dark
-- shade under the rim, a brass ferrule and a slim curved ash handle with grain, ending in a knob with a thong and a bead.
-- quirk: the thong hanging from the handle knob ends in a bead and a frayed tip; seeds tumble from the lip.
local NAME = "seed-scoop"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_1.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local CX, CY, RX, RY, ANG = 23, 42, 12.5, 7.8, -0.45

-- handle first (behind the ferrule)
local hp = { {33, 37}, {39, 34}, {45, 27}, {50, 16} }
local hm, hn, HT, HS = A.tube(hp, function(t) return t > 0.9 and 1.9 or 1.45 end)
A.toneN(c, hm, hn, R.tan, { cuts = { 0.2, 0.38, 0.56, 0.72, 0.88 }, amb = 0.08, wrap = 0.28 })
-- grain dashes and a darker knot
hm:each(function(x, y) local k = K(x, y) local t, s = HT[k], HS[k]
  if abs(s) < 0.2 and t > 0.12 and t < 0.86 and floor(t * 40) % 3 ~= 1 then c:px(x, y, R.tan[2]) end
  if s < -0.5 and floor(t * 30) % 4 == 0 and t > 0.1 then c:px(x, y, R.tan[6]) end
end)
c:px(floor(44.6), floor(30), R.brown[2]); c:px(45, 30, R.brown[2])
-- end knob with hole
local kx, ky = 50.4, 15.4
local knob = A.ell(kx, ky, 2.6, 2.6, 0)
A.lit2(c, knob, R.tan, 2.2)
c:px(50, 15, R.brown[1]); c:px(51, 15, R.brown[1]); c:px(50, 14, R.brown[2])
-- thong loop, bead and frayed tip
local thong = { {52, 16}, {54, 18}, {54, 20}, {52, 22}, {51, 23} }
for i = 1, #thong - 1 do A.ln(c, thong[i][1], thong[i][2], thong[i+1][1], thong[i+1][2], R.brown[3]) end
c:px(54, 18, R.brown[5]); c:px(54, 19, R.brown[4])
local bead = A.ell(51.2, 24.6, 1.9, 1.9, 0)
A.lit2(c, bead, R.red, 1.6)
c:px(50, 24, A.CREAM)
c:px(51, 27, R.brown[4]); c:px(50, 27, R.brown[5]); c:px(52, 27, R.brown[3]); c:px(51, 28, R.brown[3])

-- scoop exterior (opening plus a deeper wall below)
local open = A.ell(CX, CY, RX, RY, ANG)
local wall = A.ell(CX + 1.2, CY + 4.4, RX - 1, RY - .3, ANG)
local outer = open:copy():add(wall)
A.lit2(c, outer, R.steel, 3.4, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- steel streaks on the wall
for _, p in ipairs{ {15,48}, {16,49}, {17,50}, {18,51}, {16,47} } do if outer:has(p[1], p[2]) then c:px(p[1], p[2], R.steel[6]) end end
for _, p in ipairs{ {30,48}, {31,47}, {32,46}, {26,51}, {27,51} } do if outer:has(p[1], p[2]) then c:px(p[1], p[2], R.steel[2]) end end
-- interior (concave: light flipped)
local inner = A.ell(CX - .3, CY - .3, RX - 2.3, RY - 2.1, ANG)
local rim = open:copy():cut(inner)
local pn = X.pillow(inner, 3.5)
for k, n in pairs(pn) do pn[k] = { -n[1], -n[2], n[3] } end
A.toneN(c, inner, pn, R.steel, { cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 }, amb = 0.0, wrap = 0.1 })
-- rim: back and front halves
local ca, sa = cos(ANG), sin(ANG)
local rimBack, rimFront = HP.mask(), HP.mask()
rim:each(function(x, y) local v = -(x - CX) * sa + (y - CY) * ca if v <= -1.5 then rimBack:set(x, y) else rimFront:set(x, y) end end)
A.lit2(c, rimBack, R.steel, 1.4)
-- seed heap
local TYPES = {
  { R.tan, 2.7, 1.7, "stripe" }, { R.brown, 2.4, 1.6 }, { R.gold, 1.9, 1.6 }, { R.fresh, 2.0, 2.0 }, { R.red, 2.1, 1.8 }, { R.cream or R.gold, 1.9, 1.5 }, { R.red, 2.0, 1.7 },
}
local dome = A.ell(22.5, 39.2, 11, 7.6, ANG * 0.5)
local n = 0
for yy = 32, 46, 2.45 do
  local rowi = floor((yy - 32) / 2.45)
  for xx = 11 + (rowi % 2) * 1.9, 35, 3.8 do
    local jx, jy = (X.hash(floor(xx), floor(yy), 3) - .5) * 1.4, (X.hash(floor(xx), floor(yy), 8) - .5) * 1.0
    local sx, sy = xx + jx, yy + jy
    if dome:has(floor(sx + .5), floor(sy + .5)) then
      n = n + 1
      local T = TYPES[1 + floor(X.hash(floor(xx), floor(yy), 5) * 7) % 7]
      local ang = (X.hash(floor(xx), floor(yy), 11) - .5) * 1.7
      local m = A.ell(sx, sy, T[2], T[3], ang)
      m:cut(rimFront)
      A.lit2(c, m, T[1], min(T[2], T[3]) + .5)
      if T[4] == "stripe" then
        local cs, sn = cos(ang), sin(ang)
        A.ln(c, sx - cs * (T[2] - 1.2), sy - sn * (T[2] - 1.2), sx + cs * (T[2] - 1.2), sy + sn * (T[2] - 1.2), R.brown[3], m)
      end
      if T[1] == R.red or T[1] == R.fresh or T[1] == R.gold then c:px(floor(sx - T[2] * .4), floor(sy - T[3] * .5), A.CREAM) end
    end
  end
end
-- front rim over the heap
A.lit2(c, rimFront, R.steel, 1.5)
-- shade under the rim on the wall
A.seam(c, outer:copy():cut(open), open, R.steel[1])
-- rivets
for _, p in ipairs{ {31, 41}, {28, 46}, {15, 47} } do if rimFront:has(p[1], p[2]) then c:px(p[1], p[2], R.steel[6]) c:px(p[1] + 1, p[2] + 1, R.steel[1]) end end

-- brass ferrule over the socket
A.cyl(c, 31.5, 38, 36.5, 34.6, function(t) return 2.5 - t * 0.5 end, R.gold, { amb = 0.08 })
A.ln(c, 31, 37, 35, 34, R.gold[6])
A.ln(c, 36, 36, 37, 33, R.gold[1])

-- seeds tumbling from the lip
for _, q in ipairs{ {10, 51, 1, 0.5}, {14, 55, 2, -0.4}, {20.5, 56.5, 4, 0.2}, {8, 57, 3, 0.9} } do
  local T = TYPES[q[3]]
  c:fillMask(A.ell(q[1] + 1, q[2] + 1.3, T[2] * .8, T[3] * .7, q[4]), R.soil[1])
  local m = A.ell(q[1], q[2], T[2], T[3], q[4])
  A.lit2(c, m, T[1], min(T[2], T[3]) + .5)
  if T[4] == "stripe" then A.ln(c, q[1] - 1, q[2], q[1] + 1, q[2], R.brown[3], m) end
end
A.save2(c, NAME)
