-- jujube-seed (final pass, Opus aC13_2). Two jujube stones (spindle-shaped, both ends pointed, red-tan, deeply
-- furrowed lengthwise with pitted ridges) on a torn ovate jujube-leaf scrap (three base-nerves, glossy fold light,
-- ragged tear on the right, AO + contact shadow under each stone). The upper stone has split at its tip: a pale stem
-- rises with two round cotyledons and a first true leaf that already shows the jujube's three nerves.
-- quirk: a curl of dried red fruit skin still clings to the lower stone's end.
local NAME = "jujube-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#163c30", "#205638", "#2e7242", "#46904a", "#6aae56", "#a2cc70" }
local STONE = { "#321620", "#562828", "#80402e", "#a65c38", "#cc864c", "#f0b878" }
local STEM = { "#3e6a40", "#5e9050", "#8cbc6c", "#c4e09a" }
local SKIN = { "#4a1620", "#7a2228", "#ac3a2e", "#d86a42" }
local COOL = "#3a6a72"

-- stones: cx, cy, half-length, half-width, angle
local stones = { { 23, 48, 8.6, 3.7, -0.3 }, { 39, 42, 8.2, 3.5, -0.85 } }
local function spindle(s)
  local m, n = HP.mask(), {}
  local ca, sa = cos(s[5]), sin(s[5])
  for y = floor(s[2]) - 10, floor(s[2]) + 10 do for x = floor(s[1]) - 10, floor(s[1]) + 10 do
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + 0.4)
    local v = (-dx * sa + dy * ca) / (s[4] + 0.45)
    -- pointed ends: width profile (1-u^2)^0.85
    local w = (1 - u * u)
    if w > 0 then w = w ^ 0.85 end
    if abs(u) <= 1 and abs(v) <= w then
      m:set(x, y)
      local vn = max(-0.97, min(0.97, v / max(w, 0.15)))
      local ux, uy = ca, sa
      local px, py = -sa, ca
      local nz = sqrt(1 - vn * vn) * (0.75 + 0.25 * w)
      local du = u * 0.6
      local nx, ny = px * vn + ux * du, py * vn + uy * du
      n[K(x, y)] = { A.norm(nx, ny, nz) }
    end
  end end
  return m, n
end
for _, s in ipairs(stones) do s.m, s.n = spindle(s) end

-- leaf scrap: an ovate jujube leaf on the diagonal, its tip torn off along a ragged line
local ltok = { r = { name = "leaf" } }
local bias = {}
local lm0 = A.blade(10, 53, 28, 49, 55, 33, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 10.6 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6)
end, { fold = 0.4 })
-- tear: drop everything beyond a jagged line across the blade near the tip
local tear = {}
lm0:each(function(x, y)
  local d = x * 0.78 + y * 0.62          -- along-blade-ish coordinate
  local jag = 1.5 * sin(y * 1.2 + x * 0.5) + (X.hash(floor(x / 2), floor(y / 2), 5) - 0.5) * 1.6
  if d > 58.5 + jag then tear[#tear + 1] = K(x, y) end
end)
for _, k in ipairs(tear) do lm0.s[k] = nil end
-- re-run the blade for normals/T/S on the kept mask via A.leaf with a cut mask
local cutM = HP.mask() for _, k in ipairs(tear) do cutM.s[k] = true end
for _, s in ipairs(stones) do X.ao(bias, lm0, s.m, 1, -1) A.cast(bias, lm0, s.m, 1, 2, -1) end
local lm, LT, LS, lidx = A.leaf(c, 10, 53, 28, 49, 55, 33, 10.6, LEAF, {
  wfn = function(t) if t > 0.985 then return -1 end return max(0.6, 10.6 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6) end,
  fold = 0.3, tri = true, vdark = 2, triw = 0.66, cut = cutM, cuts = { 0.24, 0.4, 0.56, 0.72, 0.88 }, bias = bias, tok = ltok, cool = COOL })
-- torn edge: pale bruised fibre line (lit side of the tear)
lm:edge():each(function(x, y) if cutM:grow(1):has(x, y) and not bias[K(x, y)] then c:put(x, y, (y < 38) and "#d8e49a" or "#a8bc6a", ltok) end end)
-- petiole stub
for _, q in ipairs{ { 9, 54, 4 }, { 8, 55, 3 }, { 7, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from the upper stone's tip (drawn before stones so the coat sits over the stem foot)
local s2 = stones[2]
local tipx, tipy = s2[1] + cos(s2[5]) * s2[3], s2[2] + sin(s2[5]) * s2[3]
local stok = { r = { name = "stem" } }
local sp = { { tipx, tipy + 0.5 }, { tipx + 2, tipy - 4 }, { tipx - 1, tipy - 7 }, { tipx, tipy - 12 } }
local sm = A.stem(c, sp, function(t) return 1.05 - 0.2 * t end, STEM, { tok = stok, cut = s2.m })
local topx, topy = A.bez(sp, 1)
-- cotyledons: round-oval pads
local cotM = HP.mask()
for _, q in ipairs{ { topx - 5.2, topy + 1.2, -0.35 }, { topx + 5.4, topy + 1.4, 0.35 } } do
  local m, n = A.oval(q[1], q[2], 4.0, 2.2, q[3], 0.6)
  m:cut(sm)
  A.shade(c, m, n, LEAF, { amb = 0.12, wrap = 0.3, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  -- midline
  local ca, sa = cos(q[3]), sin(q[3])
  for i = -2, 2 do c:put(floor(q[1] + ca * i + .5), floor(q[2] + sa * i + .5), i < 0 and LEAF[5] or LEAF[3], ltok) end
  cotM:add(m)
end
-- first true leaf: ovate, three nerves, on a short petiole
A.leaf(c, topx, topy, topx + 1, topy - 5, topx + 3, topy - 11, 3.4, LEAF, { tri = true, tok = ltok, pw = 0.6, fold = 0.5, cut = cotM })
for i = 0, 2 do c:put(floor(topx + .5), floor(topy + .5) - i, STEM[3], stok) end

-- stones
for i, s in ipairs(stones) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #stones do vis:cut(stones[j].m) X.ao(sb, s.m, stones[j].m, 1, -1) end
  local tok = { r = { name = "stone" .. i } }
  local idx = A.shade(c, vis, s.n, STONE, { amb = 0.08, wrap = 0.25, tok = tok, bias = sb, cuts = { 0.26, 0.42, 0.58, 0.74, 0.9 } })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / s[3]
    local v = (-dx * sa + dy * ca) / s[4]
    local wv = (1 - u * u) ^ 0.85
    local vv = v / max(0.2, wv)
    -- furrows: two lengthwise grooves (dark) with a lit ridge beside each, broken by pits
    local i0 = idx[k] or 3
    if abs(u) < 0.8 then
      if abs(vv + 0.1) < 0.2 or abs(vv - 0.6) < 0.16 then
        if X.hash(x, y, 9) > 0.15 then c:put(x, y, STONE[i0 >= 4 and 2 or 1], tok) end
      elseif abs(vv + 0.42) < 0.13 and i0 >= 3 then c:put(x, y, STONE[min(6, i0 + 2)], tok)
      end
    end
    if X.hash(x, y, 21 + i) > 0.9 and i0 >= 3 then c:put(x, y, STONE[i0 - 1], tok) end
  end)
  -- pointed tips: darkest pixel at each point
  for _, e in ipairs{ -1, 1 } do
    local ex, ey = floor(s[1] + ca * s[3] * e + .5), floor(s[2] + sa * s[3] * e + .5)
    if vis:has(ex, ey) then c:put(ex, ey, STONE[2], tok) end
  end
  -- glint on the ridge
  local gx, gy = A.specAt(vis, s.n, 30)
  c:put(gx, gy, STONE[6], tok)
end
-- split at the sprouting tip: dark crack + pale inner seed showing
do
  local ca, sa = cos(s2[5]), sin(s2[5])
  for t = 4.0, 6.6, 0.6 do c:put(floor(s2[1] + ca * t + .5), floor(s2[2] + sa * t + .5), STONE[1], { r = { name = "stone2" } }) end
end
-- quirk: dried fruit skin curl on the lower stone's left end
local s1 = stones[1]
local ex, ey = floor(s1[1] - cos(s1[5]) * s1[3] + .5), floor(s1[2] - sin(s1[5]) * s1[3] + .5)
local ktok = { r = { name = "skin" } }
for _, q in ipairs{ { 0, -1, 3 }, { 1, -1, 4 }, { -1, -1, 2 }, { -1, 0, 2 }, { -2, 0, 1 }, { -2, -1, 3 }, { -3, -1, 2 }, { -3, 0, 1 }, { 0, -2, 2 } } do
  c:put(ex + 1 + q[1], ey + q[2], SKIN[q[3]], ktok)
end
A.save(c, NAME)
