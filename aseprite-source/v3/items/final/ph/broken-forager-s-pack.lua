-- broken-forager-s-pack (aB11_2, Opus single pass). Upright canvas rucksack: soft pillowed body in moss-green duck with a
-- diagonal weave, leather carry loop and a rounded leather flap with a gold stitched hem, a centre strap with a brass
-- buckle, and a side pocket. AO under the flap, under the pocket and along the base.
-- broken: the lower-right corner has torn open (dark gap, frayed threads, a bite out of the silhouette) and a scrap of
-- canvas flies off. quirk: a little red toadstool is tumbling out of the tear.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_2.lua")
local HP, X, K = H.HP, H.X, H.K
local C, L, B = H.CANVAS, H.LEATHER, H.BRASS
local floor = math.floor
local c = H.new("broken-forager-s-pack")
local ctok = { r = { name = "canvas" } }

-- carry loop
local lm, ln = H.tube({ { 27, 17 }, { 27, 9 }, { 37, 9 }, { 37, 17 } }, function() return 1.3 end)
H.shade(c, lm, ln, L, { spec = 24, specThr = 0.9 })

-- body
local body = c:poly{ { 19, 16 }, { 45, 16 }, { 47, 52 }, { 17, 52 } }
body = body:shrink(1):grow(1)
local corners = HP.mask()
for _, p in ipairs{ { 19, 16 }, { 20, 16 }, { 19, 17 }, { 45, 16 }, { 44, 16 }, { 45, 17 }, { 17, 52 }, { 18, 52 }, { 17, 51 }, { 47, 52 }, { 46, 52 }, { 47, 51 } } do corners:set(p[1], p[2]) end
body:cut(corners)
-- tear bite out of the lower-right corner
local bite = c:poly{ { 47, 43 }, { 43, 46 }, { 45, 48 }, { 42, 52 }, { 48, 53 } }
body:cut(bite)
local bb = {}
body:each(function(x, y) if y >= 50 then bb[K(x, y)] = -1 end end)
local bidx = H.slab(c, body, 5, C, { tok = ctok, bias = bb, h = 0.9 })
-- diagonal weave
body:each(function(x, y) local k = K(x, y) local i = bidx[k]
  if (x + y) % 4 == 0 and i and i > 1 and i < 6 then c:put(x, y, C[i - 1], ctok)
  elseif (x - y) % 4 == 0 and i and i > 2 and i < 5 and (x + y) % 2 == 1 then c:put(x, y, C[i + 1], ctok) end end)

-- side pocket
local pk = c:rrect(19, 38, 27, 49, 2)
local pkb = {}
pk:each(function(x, y) if y <= 39 then pkb[K(x, y)] = -1 end end)
H.slab(c, pk, 2.5, C, { tok = { r = { name = "pocket" } }, bias = pkb })
for x = 20, 26 do c:put(x, 37, C[1], ctok) end
for x = 20, 26 do c:put(x, 50, C[2], ctok) end

-- tear: dark gap with frayed threads
local hole = c:poly{ { 41, 42 }, { 44, 43 }, { 42, 46 }, { 44, 48 }, { 40, 51 }, { 38, 47 } }
hole:clip(body)
c:fillMask(hole, H.VOID)
for _, p in ipairs{ { 40, 43 }, { 43, 44 }, { 41, 48 }, { 39, 50 }, { 42, 45 } } do c:put(p[1], p[2], C[6]) end
hole:grow(1):cut(hole):clip(body):each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, C[2], ctok) end end)
-- flying scrap
local sc = c:poly{ { 52, 41 }, { 55, 42 }, { 54, 45 }, { 51, 44 } }
H.slab(c, sc, 1.2, C, {})
c:put(55, 46, C[5])

-- quirk: toadstool tumbling out of the tear
local cap = c:ellipse(48.5, 50, 2.5, 1.5)
local capn = X.sphere(48.5, 50, 2.5, cap)
H.shade(c, cap, capn, { "#6e2038", "#a3263a", "#d83c33", "#f2683a", "#ffa070" }, { cuts = { 0.15, 0.35, 0.55, 0.78 } })
c:put(47, 49, "#fff1cf") c:put(50, 50, "#fff1cf")
c:put(48, 52, "#e8d8b0") c:put(49, 52, "#c4b090") c:put(48, 53, "#e8d8b0") c:put(49, 53, "#a89070")

-- flap
local flap = c:rrect(18, 15, 46, 28, 3):add(c:ellipse(32, 28, 13, 5))
local fb = {}
local fidx = H.slab(c, flap, 3, L, { bias = fb, spec = 30, specThr = 0.95 })
-- AO under flap
flap:shift(0, 1):cut(flap):clip(body):each(function(x, y) c:put(x, y, C[1], ctok) end)
flap:shift(0, 2):cut(flap):clip(body):each(function(x, y) local i = bidx[K(x, y)] if i then c:put(x, y, C[math.max(1, i - 2)], ctok) end end)
-- stitched hem
c:stitch{ { 21, 26 }, { 26, 30 }, { 32, 31 }, { 38, 30 }, { 43, 26 } }

-- centre strap + buckle
local st = c:rect(30, 26, 34, 44)
H.slab(c, st, 1.5, L, { tok = { r = { name = "strap" } } })
for y = 27, 44 do c:put(35, y, C[1], ctok) end
local bk = c:rect(29, 34, 35, 39)
H.slab(c, bk, 1.2, B, { spec = 30, specThr = 0.85 })
c:fillMask(c:rect(31, 36, 33, 37), L[1])
c:put(32, 35, B[2]) c:put(32, 36, B[5]) c:put(32, 37, B[4])
c:put(30, 34, B[6])
c:put(32, 41, L[1]) c:put(32, 43, L[1]) -- strap holes
H.fin(c, debug.getinfo(1, "S").source)
