-- hiking-staff (final, Opus single pass). A slim hazel thumb-stick on the diagonal: a gently bowed shaft (6-tone
-- polished wood, dashed grain on both sides of the cylinder, two knots with lit lips), a natural Y fork at the top
-- whose cut prongs show pale end grain, a leather grip with helical wrap seams and AO where it meets the wood, a
-- loose leather wrist strap, and a bevelled steel ferrule with a ringed collar and a spike tip (bright edge + streak).
-- quirk: an orange trail-marker ribbon is tied under the fork, its two tails fluttering in the wind.
local NAME = "hiking-staff"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local WOOD = { "#3a2220", "#5c3628", "#88532f", "#b07644", "#d29c63", "#efc98f" }
local LEA = { "#22101a", "#3d1a24", "#5e2630", "#843a3c", "#a8574c", "#cf8a6c" }
local STEEL = { "#2c2d40", "#46486a", "#6b6d88", "#9698ad", "#c4c6d4", "#eef0f5" }
local ORA = { "#7a2a24", "#b8452a", "#e8692e", "#ff9447", "#ffc27a" }
local wtok, ltok, stok, rtok = { r = { name = "wood" } }, { r = { name = "leather" } }, { r = { name = "steel" } }, { r = { name = "ribbon" } }

local MAIN = { { 16, 55 }, { 24, 43 }, { 35, 27 }, { 44, 15 } }
local PL = { { 44, 16 }, { 43, 14 }, { 43, 12 }, { 42, 10 } }
local PR = { { 44, 16 }, { 47, 14 }, { 49, 13 }, { 51, 12 } }
-- wood: prongs first (behind), then shaft
local woodM = HP.mask()
local function woodTube(pts, wfn, glen)
  local m, n, T, S = A.tube(pts, wfn)
  m:cut(woodM)
  local idx = A.shade(c, m, n, WOOD, { amb = 0.1, wrap = 0.3, tok = wtok })
  -- dashed grain: dark dash on the shade half, pale dash on the lit half
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    local a = t * glen
    if abs(s - 0.38) < 0.2 and (a + 1.5) % 6.5 < 3.6 then c:put(x, y, WOOD[max(1, idx[k] - 1)], wtok) end
    if abs(s + 0.42) < 0.17 and (a + 4.2) % 7.5 < 2.6 then c:put(x, y, WOOD[min(6, idx[k] + 1)], wtok) end
  end)
  woodM:add(m)
  return m, n, T, S, idx
end
local plm, _, PLT = woodTube(PL, function(t) return 1.35 - 0.2 * t end, 9)
local prm, _, PRT = woodTube(PR, function(t) return 1.35 - 0.2 * t end, 9)
-- pale end grain on the cut prong tips, darker heart
for _, q in ipairs{ { plm, PLT }, { prm, PRT } } do
  q[1]:each(function(x, y) local t = q[2][K(x, y)] if t and t > 0.88 then c:put(x, y, t > 0.95 and "#c99560" or "#f4dcae", wtok) end end)
end
local mm, mn, MT, MS, midx = woodTube(MAIN, function(t) return 1.75 - 0.35 * t end, 52)
-- fork crotch: dark notch + AO where prongs meet
c:put(44, 14, WOOD[1], wtok) c:put(45, 14, WOOD[2], wtok) c:put(43, 15, WOOD[2], wtok)
-- knots: dark eye with a lit lip above
for _, kt in ipairs{ { 0.36, 0.35 }, { 0.78, -0.2 } } do
  local x, y = A.bez(MAIN, kt[1])
  local xi, yi = floor(x + 0.5 + kt[2]), floor(y + 0.5)
  c:put(xi, yi, WOOD[1], wtok) c:put(xi + 1, yi, WOOD[2], wtok) c:put(xi, yi - 1, WOOD[6], wtok)
end

-- leather grip with helical seams
local gm, gn, GT, GS = A.tube(MAIN, function(t) return (t > 0.5 and t < 0.68) and 2.4 or 0 end)
local gbias = {}
local gidx = A.shade(c, gm, gn, LEA, { amb = 0.08, wrap = 0.28, tok = ltok })
gm:each(function(x, y) local k = K(x, y)
  local a = GT[k] * 52 + GS[k] * 2.4
  local f = a % 2.6
  if f < 0.85 then c:put(x, y, LEA[max(1, gidx[k] - 2)], ltok)
  elseif f < 1.6 and GS[k] < 0 then c:put(x, y, LEA[min(6, gidx[k] + 1)], ltok) end
end)
-- AO on the wood just outside the grip
local wb = {}
X.ao(wb, mm, gm, 1, -1)
for k in pairs(wb) do local x, y = k % 1024 - 256, k // 1024 - 256 A.step(c, midx, WOOD, x, y, -2, wtok) end
-- wrist strap: loose loop hanging from the top of the grip
local s0x, s0y = A.bez(MAIN, 0.67)
local strap = { { floor(s0x) + 2, floor(s0y) + 1 }, { floor(s0x) + 4, floor(s0y) + 4 }, { floor(s0x) + 4, floor(s0y) + 7 }, { floor(s0x) + 2, floor(s0y) + 9 }, { floor(s0x), floor(s0y) + 8 } }
for i = 1, #strap - 1 do
  A.line(c, { strap[i], strap[i + 1] }, i < 3 and LEA[5] or (i < 5 and LEA[4] or LEA[3]), ltok)
end


-- steel ferrule: collar on the foot of the shaft + spike
local fm, fn, FT, FS = A.tube(MAIN, function(t) return t < 0.075 and 2.05 or 0 end)
local fidx = A.shade(c, fm, fn, STEEL, { amb = 0.08, wrap = 0.2, tok = stok })
fm:each(function(x, y) local k = K(x, y)
  if FT[k] > 0.058 then c:put(x, y, STEEL[max(1, fidx[k] - 2)], stok)
  elseif FT[k] > 0.045 then c:put(x, y, STEEL[min(6, fidx[k] + 1)], stok) end
end)
local km, kn, KT, KS = A.tube({ { 16, 55 }, { 15, 56 }, { 14, 57 }, { 13, 59 } }, function(t) return 1.8 * (1 - t) ^ 0.9 + 0.3 end)
km:cut(fm)
local kidx = A.shade(c, km, kn, STEEL, { amb = 0.08, wrap = 0.2, tok = stok })
km:each(function(x, y) local k = K(x, y) if abs(KS[k] + 0.35) < 0.18 and KT[k] < 0.7 then c:put(x, y, STEEL[6], stok) end end)

-- quirk: trail ribbon knot under the fork + two fluttering tails
local rx, ry = A.bez(MAIN, 0.8)
rx, ry = floor(rx + 0.5), floor(ry + 0.5)
local knot = c:rect(rx - 1, ry - 1, rx + 1, ry + 1)
local function tail(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return w * (1 - 0.25 * t)
  end, { fold = 0.2 })
  m:cut(woodM)
  local idx = A.toneN(c, m, n, ORA, { tok = rtok, cuts = { 0.25, 0.45, 0.65, 0.82 }, amb = 0.15, wrap = 0.3 })
  -- forked (swallow-tail) cut at the end
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.86 and abs(S[k]) < 0.3 then m.s[k] = nil c.pix[y * 64 + x] = nil c.own[y * 64 + x] = nil end end)
  -- a fold line
  m:each(function(x, y) local k = K(x, y) if abs(T[k] - 0.45) < 0.06 then c:put(x, y, ORA[max(1, idx[k] - 1)], rtok) end end)
  return m
end
tail(rx + 1, ry, rx + 4, ry - 2, rx + 8, ry - 1, 1.2)
tail(rx + 1, ry + 1, rx + 3, ry + 3, rx + 6, ry + 4, 1.1)
local kn2 = {}
knot:each(function(x, y) kn2[#kn2 + 1] = { x, y } end)
for _, p in ipairs(kn2) do local d = (p[1] - rx) + (p[2] - ry)
  c:put(p[1], p[2], d < 0 and ORA[4] or (d == 0 and ORA[3] or ORA[2]), rtok) end
c:put(rx - 1, ry - 1, ORA[5], rtok)
A.save(c, NAME)
