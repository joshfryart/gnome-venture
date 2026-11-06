-- chickpea-seed (final, Opus single pass). Two wrinkled ram-head chickpeas (beaked, matte cream-tan) on a torn,
-- glaucous blue-green leaf scrap (broad, untoothed, midrib + veins, pale torn fibres, AO + contact shadow).
-- The right pea has sprouted (chickpeas keep their cotyledons underground): a pale stem carrying one pinnate
-- chickpea leaf of small oval leaflets. quirk: a single dewdrop balanced on the top leaflet.
local NAME = "chickpea-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1c3a3e", "#28524c", "#3a6e5a", "#58905f", "#80b070", "#b4d494" }
local CP = { "#6a4a30", "#94703f", "#bc9558", "#d9b678", "#efd59c", "#fff0c4" }
local STEM = { "#5a8a5c", "#8cb878", "#bcdca0", "#e6f4c4" }

local s1 = c:ellipse(21, 44, 5, 4.6)
local s2 = c:ellipse(32, 47, 4.8, 4.4)

A.leaf(c, 8, 51, 28, 56, 55, 40, { w = 8.5, pow = 0.4, tear = 0.13, ramp = LEAF, vein = "#d4ecb0", cool = "#3a6680",
  edge = "#e2f0c0", casters = { s1, s2 }, period = 4.6, fold = 0.32, seed = 11 })

-- sprout: stem rises out of the right pea, top part is the rachis of a pinnate leaf
local stok = { r = { name = "stem" } }
local SP = { { 34, 43 }, { 33, 34 }, { 39, 28 }, { 37, 15 } }
local sm, sn = A.tube(SP, function() return 1.0 end)
sm:cut(s2)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local ltok = { r = { name = "leaflets" } }
local lm = HP.mask()
local tops = {}
for i, q in ipairs{ { 0.5, -1, 4.6 }, { 0.58, 1, 4.6 }, { 0.68, -1, 4.4 }, { 0.76, 1, 4.2 }, { 0.86, -1, 3.8 }, { 0.92, 1, 3.6 } } do
  local x, y = A.bez(SP, q[1])
  local ux, uy = A.rot(0, -1, q[2] * 1.15)
  lm:add(A.leaflet(x + ux * 0.8, y + uy * 0.8, ux, uy, q[3], 1.8))
end
do local x, y = A.bez(SP, 1) lm:add(A.leaflet(x, y + 0.5, 0, -1, 4.2, 1.6)) end
lm:cut(sm)
local n = X.pillow(lm, 1.5)
A.toneN(c, lm, n, LEAF, { tok = ltok, cuts = A.LCUTS, amb = 0.2, wrap = 0.3 })
-- tiny tooth notches on leaflet tips (serrate) : darken outermost tip px
lm:edge():each(function(x, y) if A.X.hash(x, y, 4) > 0.82 then c:put(x, y, LEAF[2], ltok) end end)
-- rachis over leaflets
for i = 0, 40 do local t = 0.45 + 0.55 * i / 40 local x, y = A.bez(SP, t) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end
-- quirk: dewdrop on the top leaflet
A.dew(c, 37, 13)

-- peas last (left pea sits behind the right one)
A.chickpea(c, 21, 44, 5, -2.3, CP, { clip = s2, name = "p1", ph = 0.7 })
local b2 = {}
A.chickpea(c, 32, 47, 4.8, -0.9, CP, { name = "p2", ph = 2.1, bias = b2 })
A.save(c, NAME)
