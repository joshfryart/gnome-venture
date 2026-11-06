-- crowberries (final, Opus single pass). A slim reddish crowberry twig on the diagonal, densely set with short
-- rolled needle leaves (each with a pale groove line), carrying six glossy blue-black berries with 1-2 px air.
-- Material: per-pixel sphere light on the berries (6 tones), dusty waxy bloom on the lit half, one cream
-- specular + 2x1 hi, cool reflected light lower-right, dark calyx dot; bark with leaf-scar flecks and a pale cut
-- end grain; contact shadow of each berry on the twig.
-- quirk: the top berry still wears three tiny purple stamens from its flower, like a feather in a cap.
local NAME = "crowberries"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local BER  = { "#15111e", "#231a36", "#352852", "#4c3b74", "#6c579a", "#a08ec8" }
local NEED = { "#10261f", "#183a2c", "#235236", "#326b3d", "#4c8a46", "#7aad5a" }
local BARK = { "#2b181b", "#472824", "#68382c", "#8b4f34", "#ad6c3d", "#d29a60" }
local BLOOM, BLOOM2, COOL, SPEC = "#8784ad", "#5d5886", "#3f5a88", "#fff1dc"

local berries = { { 34, 26 }, { 45, 25 }, { 24, 37 }, { 38, 37 }, { 20, 48 }, { 31, 47 } }
local R = 4.1
local bm = {}
local allB = HP.mask()
for i, b in ipairs(berries) do local m, n = A.oval(b[1], b[2], R, R, 0, 1.0) bm[i] = { m = m, n = n } allB:add(m) end

-- twig
local tw = { { 9, 56 }, { 22, 45 }, { 38, 25 }, { 55, 10 } }
local tm, tn, TT, TS, samp = A.tube(tw, function(t) return 1.55 - 0.65 * t end)
-- needles along the twig (alternating, pointing forward)
local nm = HP.mask()
local ntok = { r = { name = "needle" } }
local needles = {}
local side = 1
local t = 0.1
while t < 0.97 do
  local x, y = A.bez(tw, t)
  local x2, y2 = A.bez(tw, min(1, t + 0.01))
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local ang = side * (0.95 - 0.35 * t)
  local ux, uy = A.rot(tx, ty, ang)
  local L = 6.2 - 1.6 * t
  local bx, by = x + ux * L, y + uy * L
  local cx, cy = x + ux * L * 0.5 + tx * 0.8, y + uy * L * 0.5 + ty * 0.8
  needles[#needles + 1] = { x, y, cx, cy, bx, by }
  side = -side
  t = t + 0.058
end
-- tip tuft
do local x, y = A.bez(tw, 1)
  needles[#needles + 1] = { x - 1, y + 1, x + 1, y - 2, x + 2, y - 5 }
  needles[#needles + 1] = { x - 1, y + 1, x + 3, y - 1, x + 5, y - 1 } end

local bias = {}
-- paint needles (each: tiny blade, pale groove)
for i, q in ipairs(needles) do
  local m, n, T, S = A.blade(q[1], q[2], q[3], q[4], q[5], q[6], function(tt)
    if tt > 0.97 then return -1 end
    return 0.55 + 0.45 * math.sin(math.pi * min(1, tt * 0.85 + 0.15))
  end, { fold = 0.25 })
  m:cut(tm)
  local b = {}
  X.ao(b, m, allB, 1, -1) A.cast(b, m, allB, 1, 2, -1)
  local idx = A.toneN(c, m, n, NEED, { tok = ntok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3, bias = b })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.2 and T[k] < 0.8 and not b[k] then c:put(x, y, NEED[min(6, (idx[k] or 3) + 2)], ntok) end end)
  nm:add(m)
end
-- twig over the needle bases
X.ao(bias, tm, allB, 1, -1) A.cast(bias, tm, allB, 1, 2, -1)
local ttok = { r = { name = "twig" } }
local tidx = A.shade(c, tm, tn, BARK, { tok = ttok, bias = bias, amb = 0.12, wrap = 0.3 })
-- leaf scars / bark flecks
tm:each(function(x, y) local k = K(x, y)
  if not bias[k] and abs(TS[k]) < 0.5 and X.hash(x, y, 7) < 0.14 then c:put(x, y, BARK[max(1, tidx[k] - 2)], ttok) end end)
-- cut end grain at the base (pale disc with a dark ring)
do local s = samp[1]
  for _, d in ipairs{ { 0, 0, 6 }, { -1, 0, 5 }, { 0, 1, 4 }, { -1, 1, 3 } } do
    local x, y = floor(s.x + d[1] + .5), floor(s.y + d[2] + .5)
    c:put(x, y, BARK[d[3]], ttok) end end

-- berries (top first)
for i, b in ipairs(berries) do
  local m, n = bm[i].m, bm[i].n
  local tok = { r = { name = "berry" .. i } }
  local idx, v = A.shade(c, m, n, BER, { tok = tok, amb = 0.04, wrap = 0.18, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  -- waxy bloom on the lit half
  m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, i * 13)
    if idx[k] >= 4 and idx[k] <= 5 and h < 0.24 then c:put(x, y, BLOOM, tok)
    elseif idx[k] == 3 and h < 0.12 then c:put(x, y, BLOOM2, tok) end end)
  -- cool reflected light
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.5 and idx[k] <= 2 then c:put(x, y, COOL, tok) end end)
  -- specular: cream + one hi beside it
  local gx, gy = A.specAt(m, n, 40)
  c:put(gx, gy, SPEC, tok) c:put(gx + 1, gy, BER[6], tok) c:put(gx, gy + 1, BER[6], tok)
  -- calyx dot (blossom end faces the viewer, slightly lower-right)
  local cx, cy = b[1] + 1, b[2] + 1
  c:put(cx, cy, BER[1], tok) c:put(cx - 1, cy, BER[2], tok) c:put(cx, cy + 1, BER[2], tok) c:put(cx + 1, cy - 1, BER[3], tok)
end
-- quirk: three purple stamens on the top berry (berries[2])
do local bx, by = berries[2][1], berries[2][2] - 5
  local STA, ANT = "#9a5aa8", "#5a2a62"
  local tok = { r = { name = "stamen" } }
  for _, q in ipairs{ { 0, 0, STA }, { 0, -1, STA }, { -1, -2, STA }, { -2, -3, ANT },
                      { 1, -1, STA }, { 2, -2, STA }, { 3, -3, ANT }, { 0, -2, STA }, { 0, -3, ANT } } do
    c:put(bx + q[1], by + q[2], q[3], tok) end end

A.save(c, NAME)
