-- palusami (final pass, Opus). A baked Samoan parcel of taro leaves, gathered up into pointed leaf tips around
-- an open top full of coconut cream, sitting on a torn banana-leaf plate with a small ground shadow.
-- Material: parcel per-pixel sphere/pillow light on a 6-tone deep taro green, leaf-fold seams running up to the
-- crown (dark crease + lit edge) with side veins, tips lit on the upper-left; coconut cream on a 6-tone warm cream
-- ramp, glossy specular, a drip running over the leaf and AO at the lip; banana leaf with a midrib, parallel veins
-- and a split edge; cool reflected light on the parcel's lower-right.
-- quirk: a ring of sweet onion is floating in the cream.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local NAME = "palusami"
local c = A.new(NAME)
local TARO = { "#132c2a", "#1d4436", "#2a6042", "#3d7e4c", "#5ea05a", "#8cc070" }
local BAN  = { "#3f7a3a", "#6aa24a", "#98c45e", "#c4e07a", "#e2f0a0" }
local CRM  = { "#a8784a", "#cfa070", "#e8c592", "#f6e0b4", "#fff0d2", "#fffaec" }
local ONI  = { "#9a5a8a", "#d08ab8", "#f4c8e2" }
local COOL = "#4a6a8a"
local ttok, btok, ctok = { r = { name = "taro" } }, { r = { name = "banana" } }, { r = { name = "cream" } }

-- ground shadow under the plate
c:groundShadow(32, 52, 19, 2)

-- banana-leaf plate: long flat leaf, slightly tilted, with a split
local pm = HP.mask()
local PCX, PCY = 32, 47
for y = 38, 56 do for x = 5, 59 do
  local u = (x - PCX) local v = (y - PCY) - u * 0.04
  local hw = 6.2 * (1 - (abs(u) / 24.5) ^ 3)
  if hw > 0 and abs(v) <= hw * 0.9 and abs(u) <= 24 then pm:set(x, y) end
end end
-- split in the edge (lower left) and torn end
for _, q in ipairs{ { 16, 52 }, { 16, 51 }, { 17, 51 }, { 17, 50 }, { 47, 52 }, { 48, 52 }, { 48, 51 } } do pm:cut(HP.mask():set(q[1], q[2])) end
local pn = X.pillow(pm, 4, 0.5)
local pidx = A.shade(c, pm, pn, BAN, { amb = 0.2, wrap = 0.35, tok = btok, cuts = { 0.3, 0.5, 0.68, 0.84 } })
pm:each(function(x, y)
  local u = x - PCX local v = (y - PCY) - u * 0.04
  if abs(v) < 0.55 then c:put(x, y, BAN[1], btok) elseif abs(v + 1) < 0.5 then c:put(x, y, BAN[5], btok)
  elseif (floor(v + 0.5) % 2 == 0) and abs(v) > 1.5 and ((u * 0.5 + v) % 7 < 3.5) then A.step(c, pidx, BAN, x, y, -1, btok) end
end)

-- parcel body
local bm, bn = A.oval(32, 36, 13.5, 10.5, 0)
-- leaf tips gathered at the crown
local tips = { { 20, 22, -0.75 }, { 26, 18, -0.3 }, { 33, 17, 0.05 }, { 40, 19, 0.45 }, { 45, 23, 0.85 } }
local tm = HP.mask()
for _, q in ipairs(tips) do
  local bx, by = 32 + (q[1] - 32) * 0.55, 28
  local m = G.blade(bx, by + 2, (bx + q[1]) / 2, (by + q[2]) / 2 + 1, q[1], q[2], function(t) return 2.9 * (1 - t) ^ 0.9 end)
  tm:add(m)
end
tm:cut(bm)
local all = bm:copy():add(tm)
local an = X.pillow(all, 6)
local sn = X.sphere(32, 36, 13, bm)
local nn = {}
all:each(function(x, y) local k = K(x, y) local a, b = an[k], sn[k] or an[k]
  nn[k] = { A.norm(a[1] * 0.4 + b[1] * 0.6, a[2] * 0.4 + b[2] * 0.6, a[3] * 0.4 + b[3] * 0.6) } end)
local bias = {}
-- AO along the base where it sits on the leaf
all:each(function(x, y) if y >= 45 then bias[K(x, y)] = -1 end end)
local idx = A.shade(c, all, nn, TARO, { amb = 0.06, wrap = 0.25, bias = bias, tok = ttok })
-- fold seams: meridians from the base up to each tip (crease + lit edge) and veins
for i, q in ipairs(tips) do
  local bx0 = 32 + (q[1] - 32) * 0.2
  for s = 0, 40 do
    local t = s / 40
    local x = floor(bx0 + (q[1] - bx0) * t + sin(t * pi) * (q[1] - 32) * 0.35 + .5)
    local y = floor(46 + (q[2] - 46) * t + .5)
    if all:has(x, y) and y < 45 then
      A.step(c, idx, TARO, x, y, -2, ttok)
      if all:has(x - 1, y) and idx[K(x - 1, y)] >= 3 then A.step(c, idx, TARO, x - 1, y, 1, ttok) end
      if s % 7 == 3 and t > 0.2 and t < 0.75 then
        for d = 1, 3 do if all:has(x + d, y - d + 1) and idx[K(x + d, y - d + 1)] then A.step(c, idx, TARO, x + d, y - d + 1, -1, ttok) end end
      end
    end
  end
end
-- cool reflected light lower-right
local rim = X.rim(nn)
bm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y < 45 then c:put(x, y, COOL, ttok) end end)
-- leaf specular (waxy taro)
c:put(24, 30, TARO[6], ttok) c:put(25, 30, "#c4e8a0", ttok)

-- cream pool in the open top
local cm = A.oval(32.5, 26, 8.2, 3.4, 0)
local cn = select(2, A.oval(32.5, 26, 8.2, 3.4, 0, 2.5))
local cb = {}
cm:each(function(x, y) if y >= 28 then cb[K(x, y)] = -1 end end)   -- AO at the front lip
local cidx = A.shade(c, cm, cn, CRM, { amb = 0.25, wrap = 0.4, tok = ctok, bias = cb })
-- leaf lip in front of the cream casts a dark line
for x = 26, 39 do if cm:has(x, 29) then c:put(x, 29, CRM[1], ctok) end end
-- drip over the front-right leaf
local drip = { { 37, 30, 4 }, { 37, 31, 4 }, { 38, 31, 3 }, { 37, 32, 5 }, { 37, 33, 4 }, { 37, 34, 3 }, { 37, 35, 4 }, { 36, 36, 5 }, { 37, 36, 3 }, { 37, 37, 2 } }
for _, q in ipairs(drip) do c:put(q[1], q[2], CRM[q[3]], ctok) end
for _, q in ipairs{ { 38, 33 }, { 38, 35 }, { 38, 37 }, { 36, 38 }, { 37, 38 } } do if all:has(q[1], q[2]) then c:put(q[1], q[2], TARO[1], ttok) end end
-- cream gloss
c:put(28, 25, CRM[6], ctok) c:put(29, 25, CRM[6], ctok) c:put(28, 24, "#fffaf0", ctok)

-- quirk: a sweet onion ring floating in the cream
A.map(c, {
  ".ab.",
  "a..c",
  ".bc.",
}, 33, 24, { a = ONI[3], b = ONI[2], c = ONI[1] }, { r = { name = "onion" } })
A.save(c, NAME)
