-- broccoflower (Opus single pass, aB10_4). A romanesco-style head: pointed lime florets set in a golden-angle
-- spiral on a dome, shrinking toward the apex, cradled by two blue-green wrapper leaves on a short pale stalk.
-- Material: every floret is its own little cone (local light) blended with the dome's light, a deep row on each
-- floret's lower-right where it sits on its neighbour (AO), lit tips; leaves with waxy bloom specks, pale midrib
-- and veins, a cool reflected edge; contact shadow on the leaves under the head; stalk with a paler cut face.
-- quirk: a single dewdrop rolling on the right wrapper leaf.
local NAME = "broccoflower"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local HEAD = { "#1f4a2c", "#386f2e", "#5c9832", "#8cc03a", "#bcdf58", "#e9f7a2" }
local LEAF = { "#1a3640", "#255650", "#357462", "#4f9270", "#78b488", "#acd6a8" }
local STALK = { "#4a6a3a", "#6e9050", "#98b86c", "#c2d890", "#e2eebc" }
local VEIN, BLOOM, COOL = "#cfe8bc", "#9cc8c0", "#3c6c80"
local ltok = { r = { name = "leaf" } }

-- stalk
local sm, sn, ST, SS = X.cyl(32, 44, 32, 56, function(t) return 3.0 + 0.4 * t end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STALK, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = { r = { name = "stalk" } } })
-- cut face at the bottom (paler ring + darker core)
for x = 29, 35 do c:put(x, 56, (x == 31 or x == 32 or x == 33) and STALK[4] or STALK[5], { r = { name = "stalk" } }) end
c:put(32, 56, STALK[3], { r = { name = "stalk" } })

-- wrapper leaves (behind the head)
local head = c:ellipse(32, 29, 15, 13)
local leaves = {}
local function leaf(ax, ay, cx, cy, bx, by, wmax)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local w = wmax * sin(pi * min(1, t * 0.8 + 0.14)) ^ 0.55
    return max(0.8, w + 0.6 * sin(t * 25 * 1.3))     -- wavy brassica margin
  end, { fold = 0.35 })
  m:cut(sm)
  local bias = {}
  -- contact shadow / AO from the head above
  G.cast(bias, m, head, 1, 2, -1) X.ao(bias, m, head, 1, -1)
  G.toneN(c, m, n, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if bias[k] then return end
    if abs(s) < 0.13 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
    local ph = (t * len - abs(s) * 3.5) / 5
    if (ph - floor(ph)) < 0.17 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 and t < 0.85 then
      c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
    if s < -0.2 and X.hash(x, y, 5) > 0.9 then c:put(x, y, BLOOM, ltok) end   -- waxy bloom
  end)
  m:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and S[k] > 0.7 and T[k] > 0.2 and T[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
  leaves[#leaves + 1] = { m = m, T = T, S = S }
  return m
end
local L1 = leaf(30, 49, 18, 46, 11, 31, 6.0)
local L2 = leaf(34, 49, 46, 46, 53, 31, 6.0)

-- head: golden-angle florets on a dome
local GA = pi * (3 - sqrt(5))
local N = 34
local fl = {}
for i = 0, N - 1 do
  local r = sqrt((i + 0.5) / N)
  local a = i * GA
  local fx, fy = 32 + 13.2 * r * cos(a), 27 + 10.5 * r * sin(a) - (1 - r) * 3.5
  fl[#fl + 1] = { fx, fy, 1.5 + 2.3 * r, r }
end
table.sort(fl, function(a, b) return a[2] < b[2] end)
local hm = HP.mask()
local htok = { r = { name = "head" } }
local hn = {}
for _, f in ipairs(fl) do
  local fx, fy, s = f[1], f[2], f[3]
  local m = G.rell(fx, fy + 0.3 * s, 1, 0, s + 0.3, s * 0.8)
  -- pointed tip
  for y = floor(fy - 1.9 * s), floor(fy) do
    local hw = (y - (fy - 1.9 * s)) / (1.9 * s) * s * 0.75
    for x = floor(fx - hw + 0.5), floor(fx + hw + 0.5) do m:set(x, y) end
  end
  local ln = X.pillow(m, 1.6)
  local gn = X.sphere(32, 26, 16, m)
  local v = G.blend(X.light(ln, { amb = 0.1, wrap = 0.25 }), X.light(gn, { amb = 0.1, wrap = 0.3 }), 0.5)
  m:each(function(x, y) local k = K(x, y)
    local i = G.q(v[k], { 0.2, 0.36, 0.52, 0.68, 0.84 })
    -- AO: lower-right rim of each floret
    if not m:has(x + 1, y + 1) or not m:has(x, y + 1) then i = i - 2 end
    c:put(x, y, HEAD[max(1, min(6, i))], htok)
    hm:set(x, y)
  end)
  -- lit tip
  local tx, ty = floor(fx + 0.5), floor(fy - 1.9 * s + 0.5)
  if m:has(tx, ty + 1) then c:put(tx, ty + 1, HEAD[6], htok) end
end
-- one specular glint high on the dome
c:put(26, 19, "#fbffe0", htok)

-- quirk: dewdrop on the right leaf (bright rim, pale core, dark lower lip)
do
  local dx, dy = 47, 39
  local drop = { { 0, -1, "#d8f2ee" }, { -1, 0, "#f6fffc" }, { 0, 0, "#b6e0dc" }, { 1, 0, "#8cc4c8" },
                 { -1, 1, "#9fd0cc" }, { 0, 1, "#cdeee8" }, { 1, 1, "#5f9cac" } }
  for _, p in ipairs(drop) do c:put(dx + p[1], dy + p[2], p[3], ltok) end
  c:put(dx + 1, dy + 2, LEAF[1], ltok) c:put(dx, dy + 2, LEAF[2], ltok)
end

G.save2(c, NAME)
