-- sea-buckthorn-seed (final, Opus-style single pass by artist aD14_5). Four glossy dark-brown flat seeds (narrow ovals,
-- central groove, pale tip) lie on a torn, narrow silver-green lanceolate leaf scrap (pale midrib, silvery scale
-- freckles, cool reflected edge, AO + contact shadow under each seed). The right seed has sprouted: a slim red-brown
-- stem with alternating narrow silvery leaves, a pair of seed leaves at the foot and two tiny thorns.
-- quirk: a flake of orange berry skin still clings to the second seed, with a juice bead.
local NAME = "sea-buckthorn-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local SIL = { "#2c4640", "#46695a", "#6f927c", "#9bb89a", "#c4d9bd", "#eaf3dc" }
local COOL, FRECK = "#4a7c86", "#f4f8e6"
local SEED = { "#1c1013", "#34191a", "#552d25", "#7c4a34", "#a8704a", "#dcab7a" }
local STEM = { "#4a1f2c", "#7d3329", "#b05635", "#dd8650" }
local OR = { "#8c2c1c", "#c9481c", "#f07a22", "#ffb04a", "#ffdc86" }
local ltok = { r = { name = "leaf" } }

-- scrap: lanceolate, rising to the right, torn at the foot
local ax, ay, cx, cy, bx, by = 6, 57, 30, 59, 58, 44
local lm, ln, LT, LS, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.2 * sin(pi * min(1, t * 0.97 + 0.04)) ^ 0.62)
end, { fold = 0.42 })
-- torn foot: ragged diagonal break, plus two nibbles on the lower edge
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local rag = floor(G.hash(x, y // 2, 3) * 2.2)
  if t < 0.1 + (s + 1) * 0.045 + rag * 0.012 and t < 0.16 then torn[#torn + 1] = k end
  if s > 0.55 and ((t > 0.47 and t < 0.51) or (t > 0.7 and t < 0.725)) then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end

-- seeds along the midrib: u = position 0..1, ang, rx, ry
local seeds = {}
for i, q in ipairs{ { 0.17, -0.08 }, { 0.36, -0.12 }, { 0.54, -0.24 }, { 0.78, -0.34 } } do
  local x, y = G.qb(ax, ay, cx, cy, bx, by, q[1])
  local s = { floor(x + 0.5), floor(y + 0.5) - 1, 3.9, 2.3, q[2] }
  s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.75)
  seeds[i] = s
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
G.toneN(c, lm, ln, SIL, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.2, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.15 and t > 0.12 and t < 0.95 then c:put(x, y, s <= 0 and SIL[6] or SIL[3], ltok) return end
  -- silvery scales: sparse pale freckles, denser on the lit half
  local h = G.hash(x, y, 11)
  if h > (s < 0 and 0.9 or 0.94) and t > 0.12 then c:put(x, y, FRECK, ltok)
  elseif h < 0.045 and s > 0.1 then c:put(x, y, SIL[2], ltok) end
  -- fine side veins, angled toward the tip
  local d = (t * len - abs(s) * 2.6) % 5.2
  if d < 0.9 and abs(s) > 0.3 and abs(s) < 0.72 and t > 0.15 and t < 0.9 then c:put(x, y, s < 0 and SIL[5] or SIL[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- sprout: stem from the right seed
local sx, sy = seeds[4][1] + 1, seeds[4][2] - 1
local sp = { { sx, sy }, { sx - 2, 40 }, { sx + 1, 28 }, { sx, 15 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.15 - 0.45 * t end)
sm:cut(seeds[4].m)
local stok = { r = { name = "stem" } }
G.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.12, wrap = 0.3 })
local function narrow(x0, y0, x1, y1, bend, w)
  local mx, my = (x0 + x1) / 2, (y0 + y1) / 2
  local ddx, ddy = x1 - x0, y1 - y0
  local l = sqrt(ddx * ddx + ddy * ddy)
  local m, n, T, S = G.blade(x0, y0, mx - ddy / l * bend, my + ddx / l * bend, x1, y1, function(t)
    if t > 0.985 then return -1 end
    return max(0.45, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.55)
  end, { fold = 0.38 })
  m:cut(sm)
  G.toneN(c, m, n, SIL, { tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and SIL[6] or SIL[3], ltok)
    elseif G.hash(x, y, 5) > 0.93 then c:put(x, y, FRECK, ltok) end end)
  return m
end
-- seed leaves at the foot (short, fat) then alternating narrow leaves
narrow(sx - 1, sy - 5, sx - 9, sy - 9, -1.5, 2.1)
narrow(sx + 1, sy - 6, sx + 9, sy - 11, 1.5, 2.1)
narrow(sx - 2, 36, sx - 14, 31, -2.2, 1.8)
narrow(sx + 1, 32, sx + 10, 26, 2.0, 1.8)
narrow(sx, 28, sx - 12, 21, -1.8, 1.6)
narrow(sx, 23, sx + 8, 17, 1.4, 1.5)
narrow(sx, 18, sx - 3, 10, -0.6, 1.2)
-- thorns on the stem (two lit-tip pixels)
for _, p in ipairs{ { sx + 2, 34 }, { sx - 2, 24 } } do
  c:put(p[1], p[2], STEM[3], stok) c:put(p[1] + (p[1] > sx and 1 or -1), p[2] - 1, STEM[4], stok)
end
-- AO where the stem leaves the seed
c:put(sx - 1, sy - 1, STEM[1], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = G.paintSeed(c, s, vis, s.n, { ramp = SEED, groove = true, tip = SEED[5], bias = sb, cuts = { 0.22, 0.4, 0.58, 0.75, 0.9 }, tok = { r = { name = "seed" .. i } } })
  -- glossy specular: bright 2x1 on the lit shoulder, a second dot on the tip
  local sxx, syy = G.specAt(vis, s.n, 30)
  if sxx then c:put(sxx, syy, SEED[6], tok) c:put(sxx + 1, syy, SEED[6], tok) end
  -- cool reflected light along the lower rim
  vis:each(function(x, y) if not vis:has(x, y + 1) and x > s[1] - 2 then c:put(x, y, "#5b4a5a", tok) end end)
end
-- quirk: orange berry skin flake clinging on seed 2, with a juice bead
do
  local s = seeds[2]
  local fx, fy = s[1] - 1, s[2] - 1
  local flake = { { 0, 0, 2 }, { 1, 0, 3 }, { 2, 0, 2 }, { 3, 1, 1 }, { 0, 1, 3 }, { 1, 1, 4 }, { 2, 1, 3 }, { 1, 2, 2 }, { 2, 2, 1 } }
  local ftok = { r = { name = "skin" } }
  for _, q in ipairs(flake) do c:put(fx + q[1], fy + q[2], OR[q[3]], ftok) end
  c:put(fx + 1, fy + 1, OR[5], ftok)
  -- juice bead on the leaf below
  c:put(s[1] + 3, s[2] + 3, OR[3], ftok) c:put(s[1] + 3, s[2] + 4, OR[2], ftok) c:put(s[1] + 4, s[2] + 3, OR[4], ftok)
end
G.save2(c, NAME)
