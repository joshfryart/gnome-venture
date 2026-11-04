-- peachcot (final pass, Opus aC32_4). A slim, slightly tilted peach-apricot: apricot-orange body with a ragged rosy
-- peach blush over the right shoulder, a curved suture crease (dark groove + lit lip), velvet fuzz flecks, one wet
-- specular, cool violet reflected light on the shade edge. Short woody stem with lenticels, two lance leaves with
-- serrated margins, midrib and veins; AO where stem enters the cavity, leaf cast shadow on the shoulder.
-- quirk: the big leaf has a round caterpillar bite taken out of its edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "peachcot"
local c = A.new(NAME)
local APR = { "#73283a", "#b4422e", "#e0702c", "#f59b38", "#fcc25a", "#ffe496" }
local BLU = { "#561c3c", "#8e2646", "#c43c55", "#e6646a", "#f7948a", "#ffc4a6" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local WOOD = { "#3e2422", "#5e3a2a", "#84552f", "#a87240", "#cc9c5e" }
local COOL = "#9a5a8c"

-- body: tilted oval, a little narrower at the top, stem cavity dip, tiny tip at the bottom
local CX, CY = 31, 37
local ang = 0.16
local ca, sa = cos(ang), sin(ang)
local body = HP.mask()
for y = CY - 18, CY + 18 do for x = CX - 16, CX + 16 do
  local dx, dy = x - CX, y - CY
  local u = dx * ca + dy * sa      -- across
  local v = -dx * sa + dy * ca     -- down the fruit
  local rx = 12.6 + 1.0 * (v / 15)  -- slimmer shoulders
  local q = (u / (rx + .45))^2 + (v / 15.5)^2
  if q <= 1 then body:set(x, y) end
end end
-- cavity dip at the top and a 1 px tip at the bottom
for _, p in ipairs{ {33, 22}, {34, 22}, {32, 22} } do body.s[K(p[1], p[2])] = nil end
body:set(29, 53)
local n = A.body(body, CX - 1, CY - 1, 15, 6, 0.65)

-- suture: curve from the cavity down to the tip, right of centre (fruit is turned slightly)
local function sut(y) local t = (y - 22) / 31 return 33.6 + 3.2 * sin(pi * t) - 4.6 * t end
local bias = {}
local blush = {}
body:each(function(x, y) local k = K(x, y)
  local d = x - sut(y)
  -- crease shading: groove pixel dark, the lip left of it lit
  if abs(d) < 0.55 and y > 23 and y < 51 then bias[k] = -2
  elseif d > -1.6 and d <= -0.55 and y > 24 and y < 50 then bias[k] = 1 end
  -- blush: right of the suture and upper body, ragged rim from hash noise
  local e = d + 2.5 * X.hash(x, y, 7) - 0.6 * (y - 22) / 4 + 2
  if e > 0 and y < 50 then blush[k] = true end
end)
-- stem and leaves (masks first for AO / cast)
local stemPts = { { 33, 23 }, { 33, 20 }, { 34, 18 }, { 36, 15 } }
local sm = select(1, A.tube(stemPts, function(t) return 1.15 - 0.25 * t end))
X.ao(bias, body, sm, 2, -1)

local tok = { r = { name = "fruit" } }
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local idx = {}
body:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs(A.CUTS) do if v[k] >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  idx[k] = i
  c:put(x, y, (blush[k] and BLU or APR)[i], tok)
end)
local function ramp(x, y) return blush[K(x, y)] and BLU or APR end
local function step(x, y, d) local k = K(x, y) if not idx[k] then return end
  idx[k] = max(1, min(6, idx[k] + d)) c:put(x, y, ramp(x, y)[idx[k]], tok) end
-- velvet fuzz: sparse flecks one tone lighter in the mid tones, darker specks on the blush (peach freckles)
body:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 3)
  if idx[k] >= 3 and idx[k] <= 5 and h < 0.07 then step(x, y, 1)
  elseif blush[k] and idx[k] >= 3 and h > 0.955 then step(x, y, -1) end
end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and idx[k] <= 2 and y > CY - 2 then c:put(x, y, COOL, tok) end end)
-- waxy bloom patch + one specular
for _, p in ipairs{ {22, 29}, {23, 28}, {24, 28}, {22, 30} } do step(p[1], p[2], 1) end
c:put(23, 29, "#fff4d6", tok) c:put(24, 29, "#fff4d6", tok)

-- stem: woody, lenticel specks, paler cut end
local stok = { r = { name = "stem" } }
local _, _, _, _, sidx = A.stem(c, stemPts, function(t) return 1.15 - 0.25 * t end, WOOD, { cuts = { 0.2, 0.42, 0.62, 0.82 }, tok = stok })
c:put(35, 18, WOOD[2], stok)
c:put(36, 15, WOOD[5], stok) c:put(37, 15, WOOD[4], stok)

-- leaves: serrated lance leaves
local function serr(ax, ay, cx, cy, bx, by, w, bite)
  local m, _, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.98 + 0.04)) ^ 0.75) end, { fold = 0.45 })
  local cut = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) > 0.8 and (floor(T[k] * 22) % 3 == 0) and T[k] > 0.15 and T[k] < 0.9 then cut:set(x, y) end end)
  if bite then cut:add(c:ellipse(bite[1], bite[2], bite[3], bite[3])) end
  cut:add(sm)
  return A.leaf(c, ax, ay, cx, cy, bx, by, w, LEAF, { cut = cut, vs = 3.0, pw = 0.75 })
end
local l1 = serr(35, 17, 43, 9, 53, 10, 4.6, { 47, 6.5, 2.2 })
local l2 = serr(34, 18, 29, 12, 21, 13, 3.4)
-- leaf cast shadow on the shoulder under the leaves
for _, lm in ipairs{ l1, l2 } do
  lm:shift(1, 2):each(function(x, y) if body:has(x, y) and not lm:has(x, y) and not sm:has(x, y) then step(x, y, -1) end end)
end

A.save(c, NAME)
