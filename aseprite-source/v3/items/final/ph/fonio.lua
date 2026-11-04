-- fonio (final, Opus single pass). A slim fonio stalk: a 2 px green culm with darker node rings, two narrow grass
-- blades with midribs leaving the nodes, and at the top a digitate head of three arching racemes, each a hairline
-- rachis lined with tiny lit grains (gold 6-tone ramp, every few grains purple-flushed as fonio spikelets are),
-- AO where the racemes meet, and a pale cut end on the culm.
-- quirk: one ripe grain has just dropped off the right raceme and is falling.
local NAME = "fonio"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_1.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sqrt, sin, cos, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.atan
local c = B.new(NAME)
local GR = { "#5a3220", "#8a5a28", "#b9852e", "#dcae46", "#f2d27a", "#fff0b4" }
local PU = { "#3c1c38", "#62304c", "#8a465c", "#ad6672", "#cc9088", "#ecc0a6" }
local STEM = { "#22433a", "#2e5f40", "#43804a", "#64a052", "#90c46a", "#c6e290" }
local LEAF = { "#1c4638", "#28603f", "#3c8048", "#5aa052", "#86c266", "#bcdf8c" }
local RACH = "#9a7a3a"

-- culm
local stok = { r = { name = "culm" } }
local cm, cn, CT = B.stem(c, { { 30, 53 }, { 31, 43 }, { 33, 33 }, { 33, 25 } }, function() return 1.0 end, STEM, { tok = stok })
-- node rings
cm:each(function(x, y) if y == 43 or y == 36 then c:put(x, y, STEM[1], stok) elseif y == 42 or y == 35 then c:put(x, y, STEM[5], stok) end end)
-- cut end
cm:each(function(x, y) if y >= 53 then c:put(x, y, (x <= 30) and "#e2eeb0" or "#b8cc86", stok) end end)

-- blades from the nodes
local ltok = { r = { name = "leaf" } }
local l1 = B.leaf(c, 31, 44, 23, 38, 14, 42, 2.0, LEAF, { cut = cm, tok = ltok, vs = 2.8, pw = 0.55, fold = 0.35 })
local l2 = B.leaf(c, 34, 37, 42, 31, 51, 34, 1.8, LEAF, { cut = cm, tok = ltok, vs = 2.8, pw = 0.55, fold = 0.35 })
-- sheath AO on the culm just under each blade
for _, p in ipairs{ { 30, 45 }, { 31, 45 }, { 33, 38 }, { 34, 38 } } do if cm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[2], stok) end end

-- racemes: quadratic arcs from the head node
local NX, NY = 33, 24
local arms = { { 25, 12, 18, 13 }, { 32, 12, 33, 5 }, { 41, 12, 47, 11 } }   -- control x,y ; end x,y
local function q(a, t) local u = 1 - t
  return u*u*NX + 2*u*t*a[1] + t*t*a[3], u*u*NY + 2*u*t*a[2] + t*t*a[4] end
local rtok = { r = { name = "rachis" } }
local grainsAll = HP.mask()
local glist = {}
for ai, a in ipairs(arms) do
  for i = 0, 40 do local x, y = q(a, i / 40) c:put(floor(x + .5), floor(y + .5), RACH, rtok) end
  local nG = 7
  for gi = 1, nG do
    local t = 0.22 + (gi - 1) * (0.76 / (nG - 1))
    local x, y = q(a, t)
    local x2, y2 = q(a, min(1, t + 0.02))
    local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local side = (gi % 2 == 0) and 1 or -1
    if gi == nG then side = 0 end
    local gx, gy = x + (-ty) * side * 1.25 + tx * 0.6, y + tx * side * 1.25 + ty * 0.6
    local ang = atan(ty, tx) + side * 0.35
    glist[#glist + 1] = { gx, gy, ang, (gi + ai) % 3 == 0 }
  end
end
-- quirk grain (falling), below the right raceme tip
glist[#glist + 1] = { 50, 18, 0.9, false, true }
for gi, g in ipairs(glist) do
  local m, n = B.oval(g[1], g[2], 1.5, 0.95, g[3], 0.8)
  local tok = { r = { name = "grain" .. gi } }
  local bias = {}
  -- AO: grains near the head node sit in shadow
  if sqrt((g[1] - NX)^2 + (g[2] - NY)^2) < 6 then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  local idx = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), g[4] and PU or GR, { cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, bias = bias, tok = tok })
  grainsAll:add(m)
end
-- head node AO + glume knot
for _, p in ipairs{ { 32, 24 }, { 33, 24 }, { 33, 25 }, { 32, 25 } } do c:put(p[1], p[2], STEM[2], stok) end
c:put(32, 24, STEM[4], stok)
B.save(c, NAME)
