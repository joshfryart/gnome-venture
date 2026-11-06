-- owl-pellet (final pass, Opus). A slim lumpy oblong pellet of matted grey-brown fur lying on the diagonal,
-- a little rodent skull pressed into its lit face (orange incisors), a thin femur poking out of the upper-right end
-- and a fine rib arc showing low on the belly.
-- Material: per-pixel pillow light on a 6-tone mouse-grey ramp, short directional fur strands (lit flecks on the
-- light side, dark flecks in the shade), cool reflected light on the lower-right rim, AO rings where bone enters fur,
-- bone on a 6-tone cream ramp with a bevel and dark eye sockets.
-- quirk: a single downy owl feather is stuck to the left end, curling up.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "owl-pellet"
local c = A.new(NAME)
local FUR  = { "#2c2229", "#463a3e", "#64554f", "#837160", "#a48f78", "#c6b398" }
local BONE = { "#6a5146", "#9b8070", "#c4ab92", "#e2cfb2", "#f4e6cc", "#fff4d6" }
local TOOTH = { "#b85a1e", "#ea9a32" }
local COOL = "#6d6a86"
local ftok = { r = { name = "fur" } }
local btok = { r = { name = "bone" } }

-- femur first (pellet paints over its buried end)
local fem = { { 40, 27 }, { 45, 22 }, { 49, 18 }, { 53, 14 } }
local bm, bn, BT, BS = G.tube(fem, function(t) return t > 0.86 and 2.3 or 1.2 end, 80)
local knob = A.oval(53.5, 13.5, 2.2, 1.6, -0.78)
local kn = select(2, A.oval(53.5, 13.5, 2.2, 1.6, -0.78))
local k2m, k2n = A.oval(51.5, 12.2, 1.4, 1.4, 0)
for k, v in pairs(kn) do bn[k] = v end for k, v in pairs(k2n) do bn[k] = v end
bm:add(knob) bm:add(k2m)

-- pellet body: slim tapered capsule + lumps
local p = { { 12, 44 }, { 22, 38 }, { 34, 33 }, { 46, 25 } }
local function hw(t) return 2.4 + 6.4 * sin(pi * min(1, t * 0.96 + 0.02)) ^ 0.62 end
local m, n, T, S, samp = G.tube(p, hw)
local lumps = { { 0.2, -1, 2.6 }, { 0.45, -1, 2.2 }, { 0.62, 1, 3.0 }, { 0.32, 1, 2.4 }, { 0.82, -1, 2.0 } }
for _, q in ipairs(lumps) do
  local s = samp[floor(q[1] * 160) + 1]
  local cx, cy = s.x + s.px * s.w * 0.72 * q[2], s.y + s.py * s.w * 0.72 * q[2]
  m:add(A.oval(cx, cy, q[3], q[3] * 0.8, 0.4))
end
local np = X.pillow(m, 6)
-- blend pillow with tube (rounded across the long axis)
local nn = {}
m:each(function(x, y) local k = K(x, y) local a = np[k] local b = n[k] or a
  nn[k] = { A.norm(a[1] * 0.55 + b[1] * 0.45, a[2] * 0.55 + b[2] * 0.45, a[3] * 0.55 + b[3] * 0.45) } end)
local bias = {}
X.ao(bias, m, bm, 2, -1)
local idx = A.shade(c, m, nn, FUR, { amb = 0.05, wrap = 0.2, bias = bias, tok = ftok })
-- fur strands: short 2px strokes along the pellet axis
local ax, ay = 34 / 37, -11 / 37
m:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 7)
  local i = idx[k]
  if h < 0.09 and i >= 3 then
    c:put(x, y, FUR[min(6, i + 1)], ftok)
    local x2, y2 = floor(x + ax * 1.4 + .5), floor(y + ay * 1.4 + .5)
    if m:has(x2, y2) and idx[K(x2, y2)] >= 3 then c:put(x2, y2, FUR[min(6, idx[K(x2, y2)] + 1)], ftok) end
  elseif h > 0.86 and i >= 2 then
    c:put(x, y, FUR[i - 1], ftok)
    local x2, y2 = floor(x - ax * 1.4 + .5), floor(y - ay * 1.4 + .5)
    if m:has(x2, y2) and h > 0.93 then c:put(x2, y2, FUR[max(1, idx[K(x2, y2)] - 1)], ftok) end
  end
end)
-- cool reflected light lower-right rim
local rim = X.rim(nn)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and X.hash(x, y, 3) < 0.7 then c:put(x, y, COOL, ftok) end end)

-- femur visible part: tone, bevel, AO dark ring at fur exit
local bvis = bm:copy():cut(m)
local bb = {}
local bidx = A.shade(c, bvis, bn, BONE, { amb = 0.12, wrap = 0.3, tok = btok, bias = bb })
bvis:each(function(x, y) if m:grow(1):has(x, y) then c:put(x, y, BONE[2], btok) end end)
c:put(52, 12, BONE[6], btok)

-- skull pressed into the lit face (hand placed, snout pointing left)
local SK = { K = "#2b1c26", o = BONE[1], d = BONE[2], s = BONE[3], b = BONE[4], h = BONE[5], c = BONE[6], t = TOOTH[2], r = TOOTH[1] }
A.map(c, {
  "...shhhs..",
  "..shcchbs.",
  ".shhhbbbbd",
  "shKKbhbKKd",
  "bbKobbbKod",
  ".bbbbbbbd.",
  "..sbbsdd..",
  "..tr......",
  "..t.......",
}, 21, 31, SK, btok)
-- AO under the skull in the fur
for _, q in ipairs{ { 23, 40 }, { 24, 39 }, { 25, 39 }, { 26, 38 }, { 27, 38 }, { 28, 38 }, { 29, 37 }, { 31, 34 }, { 31, 35 } } do
  if m:has(q[1], q[2]) then c:put(q[1], q[2], FUR[1], ftok) end
end

-- rib arc low on the belly
for _, q in ipairs{ { 33, 39, 4 }, { 34, 40, 5 }, { 35, 40, 5 }, { 36, 40, 4 }, { 37, 39, 3 } } do
  c:put(q[1], q[2], BONE[q[3]], btok)
  if m:has(q[1], q[2] + 1) then c:put(q[1], q[2] + 1, FUR[1], ftok) end
end
-- second rib stub
for _, q in ipairs{ { 39, 37, 4 }, { 40, 37, 3 }, { 41, 36, 3 } } do
  c:put(q[1], q[2], BONE[q[3]], btok)
  if m:has(q[1], q[2] + 1) then c:put(q[1], q[2] + 1, FUR[2], ftok) end
end

-- quirk: a downy owl feather stuck to the left end, curling up
local FE = { "#7a5a44", "#b88e66", "#e2c39a", "#fbeccd" }
local ttok = { r = { name = "feather" } }
A.map(c, {
  "....hh.",
  "...hlh.",
  "..hlmh.",
  ".hlmmd.",
  ".lmmd..",
  "lmmd...",
  ".dq....",
  ".q.....",
}, 8, 35, { h = FE[4], l = FE[3], m = FE[2], d = FE[1], q = FE[1] }, ttok)
A.save(c, NAME)
