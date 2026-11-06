-- lemongrass (final pass, Opus). A slim bundle of three lemongrass stalks lying on the diagonal: pale, faintly pink
-- bulbous bases with blunt cut ends (pale end-grain rings), sheath nodes stepping up the stalk, turning green and
-- splitting into long narrow blades that fan to the upper right. Tied at the waist with twisted twine.
-- Material: stalks = per-pixel cylinder light on a 6-tone cream-rose ramp blending into a 6-tone grass ramp, darker
-- sheath edges, AO where stalks overlap; blades = V-fold light with a pale midrib; twine = 2-tone twist with a
-- loose tail.
-- History: Sonnet draft (_dC20) replaced.
-- quirk: one blade has been tied into a little loop, like a reminder knot.
local NAME = "lemongrass"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local BASE = { "#5c3446", "#8e5a68", "#bb8c90", "#dcbcae", "#efdcc4", "#fbf1dc" }
local GRASS = { "#1f4438", "#2c6643", "#468a47", "#6cac4f", "#9ccb62", "#cfe68e" }
local TW = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local ENDC = { "#c9a98e", "#f3e3c6", "#a9b06a" }

-- stalks (back to front): base point, top point
local st = {
  { 10, 46, 31, 21 },
  { 14, 51, 35, 26 },
  { 18, 55, 38, 31 },
}
for _, s in ipairs(st) do
  local ax, ay, bx, by = s[1], s[2], s[3], s[4]
  local p = { { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } }
  s.p = p
  s.m, s.n, s.T, s.S = A.tube(p, function(t) return 2.6 - 0.9 * t + 0.4 * sin(pi * min(1, t * 2.2)) * (t < 0.45 and 1 or 0) end)
end

-- blades: drawn first (they sit behind the stalk tops), from each top fanning up-right
local ltok = { r = { name = "blade" } }
local function blade(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, W * (1 - t) ^ 0.6)
  end, { fold = 0.45 })
  local idx = A.toneN(c, m, n, GRASS, { tok = ltok, cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.05 and T[k] < 0.8 and W > 1.2 then c:put(x, y, GRASS[6], ltok) end end)
  return m
end
local bl = {}
bl[#bl + 1] = blade(31, 21, 36, 10, 44, 7, 1.5)
bl[#bl + 1] = blade(32, 21, 43, 15, 55, 11, 1.4)
bl[#bl + 1] = blade(35, 26, 47, 20, 57, 21, 1.5)
bl[#bl + 1] = blade(36, 26, 42, 17, 50, 14, 1.2)
bl[#bl + 1] = blade(38, 31, 48, 30, 55, 34, 1.4)

-- quirk: a looped blade curling back over the top
local qp = { { 33, 23 }, { 30, 6 }, { 17, 12 }, { 25, 18 } }
local qm, qn = A.tube(qp, function(t) return 1.0 - 0.45 * t end, 220)
A.toneN(c, qm, qn, GRASS, { tok = ltok, cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
-- where the loop crosses itself: shade the under strand a step
local qp2 = { { 25, 18 }, { 28, 20 }, { 27, 22 }, { 25, 24 } }
local tm, tn = A.tube(qp2, function(t) return 0.6 - 0.3 * t end)
A.toneN(c, tm, tn, GRASS, { tok = ltok, cuts = { 0.3, 0.45, 0.6, 0.75, 0.9 }, amb = 0.1, wrap = 0.25 })

-- stalks with AO from those in front
local tie = 0.42
for i, s in ipairs(st) do
  local bias = {}
  for j = i + 1, #st do X.ao(bias, s.m, st[j].m, 1, -1) A.cast(bias, s.m, st[j].m, 1, 1, -1) end
  local v = X.light(s.n, { amb = 0.14, wrap = 0.3 })
  local tok = { r = { name = "stalk" .. i } }
  s.m:each(function(x, y) local k = K(x, y)
    local t = s.T[k]
    local ii = A.q(v[k]) + (bias[k] or 0)
    -- sheath nodes: a darker step across
    if (abs(t - 0.2) < 0.02 or abs(t - 0.33) < 0.02 or abs(t - 0.6) < 0.02) then ii = ii - 1 end
    ii = max(1, min(6, ii))
    local ramp = BASE
    if t > 0.55 or (t > 0.47 and (x + y) % 2 == 0 and s.S[k] > 0) then ramp = GRASS end
    if t > 0.47 and t <= 0.55 and s.S[k] <= 0 then ramp = GRASS end
    c:put(x, y, ramp[ii], tok)
  end)
  -- pink blush low on the lit side
  s.m:each(function(x, y) local k = K(x, y)
    if s.T[k] > 0.08 and s.T[k] < 0.18 and s.S[k] > -0.2 and s.S[k] < 0.4 and not bias[k] then c:put(x, y, "#d79a9c", tok) end end)
  -- cut end: pale disc with a darker centre ring
  local ax, ay = s.p[1][1], s.p[1][2]
  for _, d in ipairs{ { -1, 0, 2 }, { -1, -1, 2 }, { 0, -1, 2 }, { -2, 1, 1 }, { 1, -2, 1 }, { 0, 0, 3 }, { -1, 1, 2 }, { 1, -1, 2 } } do
    local x, y = ax + d[1] - 1, ay + d[2] + 1
    if s.m:has(x, y) then c:put(x, y, ENDC[d[3]], tok) end
  end
end

-- twine tie across the bundle, perpendicular to the stalks
local tx, ty = 14 + tie * 21, 51 - tie * 25
local tp = { { tx - 7, ty - 6 }, { tx - 2, ty - 1 }, { tx + 2, ty + 2 }, { tx + 7, ty + 6 } }
local twm, twn, TT, TS = A.tube(tp, function(t) return 1.1 end)
local ttok = { r = { name = "twine" } }
local tv = X.light(twn, { amb = 0.2, wrap = 0.3 })
twm:each(function(x, y) local k = K(x, y)
  local ph = (TT[k] * 18 + TS[k] * 1.2)
  local i = ((floor(ph) % 2) == 0) and 3 or 2
  if tv[k] > 0.7 and i == 3 then i = 4 end
  if TS[k] > 0.55 then i = i - 1 end
  c:put(x, y, TW[max(1, i)], ttok)
end)
-- AO row on stalks just above/below the tie
twm:grow(1):each(function(x, y) if not twm:has(x, y) then
  for _, s in ipairs(st) do if s.m:has(x, y) and (x + y) % 3 ~= 0 then c:put(x, y, BASE[2]) end end end end)
-- loose tail
for _, q in ipairs{ { 7, 6, 2 }, { 8, 7, 3 }, { 8, 8, 2 }, { 9, 9, 3 }, { 9, 10, 2 } } do
  c:put(floor(tx + q[1]), floor(ty + q[2]), TW[q[3]], ttok) end

A.save(c, "ph", NAME)
