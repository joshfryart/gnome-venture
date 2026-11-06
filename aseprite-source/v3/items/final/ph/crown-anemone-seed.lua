-- crown-anemone-seed (final, Opus single pass). Anemone coronaria seeds are flat brown achenes wrapped in thick
-- cotton wool. Two woolly seeds lie on a torn, lobed anemone-leaf scrap (net veins, V-fold light, cool reflected
-- edge, AO + contact shadow under each seed). A third seed has split its wool and sprouted: a slim reddish stem,
-- two oval cotyledons and a first true leaf, three-parted and deeply toothed like the parsley-cut anemone leaf.
-- Material: wool by pillow light (5 tones) with curly fibre flecks and a tufted silhouette; seed coat peeking out
-- with a glossy lit dot; leaf midribs + veins.
-- quirk: one tuft of wool has come loose and is drifting off to the upper left on a single thread.
local NAME = "crown-anemone-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)
local SCRAP = { "#14392f", "#1d5238", "#2a6c41", "#3f8a48", "#62a852", "#97c66a" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM  = { "#5a2a3a", "#8a4a4e", "#b8786a", "#e0b090" }
local WOOL  = { "#7a6e84", "#a399ac", "#c9bfca", "#e6ddde", "#fbf3e4" }
local COAT  = { "#3a2220", "#5e3828", "#8a5634", "#bb8350" }

-- woolly seed masks: union of tufts round a centre, bumpy silhouette
local function woolMask(cx, cy, rx, ry, seed)
  local m = HP.mask()
  m:add(A.rell(cx, cy, 1, 0, rx, ry))
  for i = 0, 9 do
    local a = i / 10 * 2 * pi + X.hash(i, seed, 1) * 0.5
    local rr = 1.4 + X.hash(i, seed, 2) * 1.0
    m:add(A.rell(cx + cos(a) * (rx - 0.6), cy + sin(a) * (ry - 0.6), 1, 0, rr, rr))
  end
  return m
end
local seeds = { { 18, 44, 5.2, 4.0, 3 }, { 30, 49, 5.0, 3.8, 8 }, { 44, 44, 4.4, 3.6, 13 } }
for _, s in ipairs(seeds) do s.m = woolMask(s[1], s[2], s[3], s[4], s[5]) end
local casters = {}
for _, s in ipairs(seeds) do casters[#casters + 1] = s.m end

-- sprout (mask first so the scrap gets its contact shadow)
local sp = { { 44, 42 }, { 45, 33 }, { 41, 25 }, { 42, 17 } }
-- leaf scrap: lobed edge, torn base and tip
local sm_, _, ST, SS, slen
sm_, ST, SS = A.scrap(c, SCRAP, 6, 50, 30, 36, 58, 48, 10.5, {
  casters = casters, tear0 = 0.05, tear1 = 0.07, seed = 21, veins = "net", vs = 4.5, sweep = 1.0,
  wfn = function(t)
    if t > 0.985 then return -1 end
    local base = 10.5 * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.5
    local lobe = 1.6 * abs(sin(t * pi * 5.5))           -- coarse anemone teeth
    return max(0.5, base - 2.2 + lobe)
  end })

-- sprout stem
local stok, ltok = { r = { name = "stem" } }, { r = { name = "leaf" } }
local stm, _, _, _, sidx = A.stem(c, sp, function(t) return 1.15 - 0.2 * t end, STEM, { tok = stok, cut = seeds[3].m })
-- cotyledons
local cl = A.leaf(c, 43, 31, 38, 29, 33, 31, 2.0, LEAF, { tok = ltok, vs = 99, pw = 0.55, cut = stm })
local cr = A.leaf(c, 45, 30, 50, 27, 55, 28, 2.0, LEAF, { tok = ltok, vs = 99, pw = 0.55, cut = stm })
-- true leaf: three leaflets, each a fan of three toothed lobes
local tl = HP.mask()
local function leaflet(x, y, ang, L)
  local ux, uy = A.rot(0, -1, ang)
  tl:add(A.rell(x + ux * L * 0.35, y + uy * L * 0.35, ux, uy, L * 0.42, 1.4))
  for _, d in ipairs{ -0.62, 0, 0.62 } do
    local vx, vy = A.rot(ux, uy, d)
    local cx, cy = x + ux * L * 0.55 + vx * L * 0.3, y + uy * L * 0.55 + vy * L * 0.3
    tl:add(A.rell(cx, cy, vx, vy, L * 0.3, 1.25))
  end
end
local tx, ty = 42, 17
leaflet(tx, ty, -1.05, 8.5)
leaflet(tx, ty, 0.05, 9)
leaflet(tx, ty, 1.1, 8.5)
tl:cut(cl):cut(cr)
local tn = X.pillow(tl, 1.4)
local tidx = A.shade(c, tl, tn, LEAF, { tok = ltok, amb = 0.12, wrap = 0.3 })
-- midribs of the three leaflets
for _, ang in ipairs{ -1.05, 0.05, 1.1 } do
  local ux, uy = A.rot(0, -1, ang)
  for i = 1, 6 do local x, y = floor(tx + ux * i + .5), floor(ty + uy * i + .5)
    if tl:has(x, y) then c:put(x, y, LEAF[min(6, (tidx[K(x, y)] or 3) + 2)], ltok) end end
end
-- dark heart where the leaflets meet
c:put(tx, ty, LEAF[1], ltok) c:put(tx, ty + 1, STEM[2], stok)

-- woolly seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "wool" .. i } }
  local vis = s.m:copy()
  if i == 3 then vis:cut(stm) end
  local n = X.pillow(vis, 3)
  local bias = {}
  for j, o in ipairs(seeds) do if j > i then X.ao(bias, vis, o.m, 1, -1) end end
  local idx = A.shade(c, vis, n, WOOL, { tok = tok, bias = bias, amb = 0.15, wrap = 0.35, cuts = { 0.3, 0.5, 0.68, 0.85 } })
  -- curly fibres: short dark commas in the shade, bright curls in the light
  vis:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 40 + i)
    if h < 0.16 and idx[k] >= 2 then c:put(x, y, WOOL[idx[k] - 1], tok)
    elseif h > 0.9 and idx[k] >= 3 and idx[k] < 5 then c:put(x, y, WOOL[idx[k] + 1], tok) end end)
  -- seed coat peeking out of the wool (lower-right of centre)
  local cx, cy = s[1] + 1, s[2]
  local coat = (i == 3) and { "..ab.", ".abcd", "abccd", ".bcd." } or { ".ab.", "abcd", ".bd." }
  A.map(c, coat, cx - 1, cy - 1, { a = COAT[2], b = COAT[3], c = COAT[1], d = COAT[1] }, tok)
  c:put(cx, cy, COAT[4], tok)
end
-- sprouted seed: stem foot coming out of the split wool, with a dark split line
c:put(44, 41, STEM[1], stok) c:put(43, 41, COAT[1], stok)

-- quirk: a loose tuft drifting up-left on a single thread
local fl = HP.mask()
fl:add(A.rell(12, 26, 1, 0, 2.6, 1.9)) fl:add(A.rell(10, 25, 1, 0, 1.4, 1.4)) fl:add(A.rell(14, 25, 1, 0, 1.3, 1.3))
local fn = X.pillow(fl, 2)
local ftok = { r = { name = "tuft" } }
A.shade(c, fl, fn, WOOL, { tok = ftok, amb = 0.2, wrap = 0.4, cuts = { 0.3, 0.5, 0.68, 0.85 } })
for _, q in ipairs{ { 14, 28 }, { 15, 29 }, { 15, 30 }, { 16, 31 }, { 16, 32 }, { 16, 33 }, { 17, 34 }, { 17, 35 }, { 17, 36 }, { 18, 37 }, { 18, 38 } } do
  c:put(q[1], q[2], WOOL[2], ftok) end

A.save(c, NAME)
