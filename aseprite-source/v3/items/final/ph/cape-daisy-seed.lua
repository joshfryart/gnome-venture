-- cape-daisy-seed (Opus single pass). Three curved cape-daisy achenes (dark, banana-shaped, warty ridge of pale bumps
-- along the back) on a torn, saw-toothed lanceolate leaf scrap (tip to the left, torn base on the right, midrib, swept
-- veins, cool reflected rim, AO + contact shadow under each seed). The right achene has sprouted: slim stem, two
-- spatulate cotyledons and a V of two toothed oblanceolate true leaves (the osteospermum leaf).
-- quirk: one fallen ray petal, white with a violet-blue base and underside, curls over the torn end of the scrap.
local NAME = "cape-daisy-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_2.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#1a3a30", "#24543c", "#336f44", "#4c8c4e", "#72aa5e", "#a2c97a" }
local SLEAF = { "#1e4436", "#2a6040", "#3c7c48", "#579a52", "#7eb862", "#b0d882" }
local SEED = { "#1e1218", "#33202a", "#4c3030", "#6a4636", "#8e6646", "#bc9668" }
local STEM = { "#3e6e4a", "#5c965a", "#8abc74", "#c0de9c" }
local PET = { "#2e2a6c", "#4a46a2", "#7a78cc", "#b0aee8", "#dcdaf6", "#f4f0fc" }

-- achenes: cubic bezier each
local seeds = {
  { { 12, 48 }, { 14, 45 }, { 18.5, 44 }, { 21.5, 46 } },
  { { 24, 54 }, { 25, 50 }, { 28, 48 }, { 32, 48.5 } },
  { { 37, 52.5 }, { 40, 50 }, { 44, 50 }, { 47, 52 } },
}
local SM = {}
for i, p in ipairs(seeds) do
  local m, n, T, S = G.tube(p, function(t) return 0.45 + 1.45 * sin(pi * t) ^ 0.6 end)
  SM[i] = { m = m, n = n, T = T, S = S, p = p }
end
local allSeed = HP.mask() for _, s in ipairs(SM) do allSeed:add(s.m) end

-- petal (quirk): thin curved strip with a notched tip, drawn over the scrap
local pp = { { 46, 57 }, { 50, 56 }, { 54, 52 }, { 57, 49 } }
local pm, pn, PT, PS = G.tube(pp, function(t) return 0.55 + 0.75 * sin(pi * min(1, 0.1 + t * 0.95)) ^ 0.5 end)

local lm, LT, LS, ltok = A.scrap(c, {
  a = { 55, 51 }, c = { 33, 60 }, b = { 8, 44 }, W = 6.6, fold = 0.45,
  prof = function(t) return sin(pi * (0.32 + 0.68 * t)) ^ 0.85 end,
  ramp = LEAF, vein = "#bfe08e", cool = "#3a6670", torn = "#d2e4a4", per = 5.6,
  tear = { t0 = 0.02, amp = 0.06, seed = 7 }, teeth = { per = 4.2, depth = 0.22 },
  casters = { allSeed, pm }, name = "leaf" })

-- sprout from the right achene
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 42, 50 }, { 43, 42 }, { 41, 34 }, { 42, 25 } }, function(t) return 1.05 - 0.15 * t end, STEM, stok)
local lt = { r = { name = "sleaf" } }
local spat = function(t) return (0.25 + 0.75 * sin(pi * min(1, t * 0.62 + 0.03))) * (t > 0.8 and sqrt(max(0, (1 - t) / 0.2)) or 1) end
A.leaflet(c, 41, 39, 37, 35, 31, 35, 2.2, spat, SLEAF, lt, { cutBy = { sm } })
A.leaflet(c, 43, 39, 47, 35, 53, 35, 2.2, spat, SLEAF, lt, { cutBy = { sm } })
local lanc = function(t) return sin(pi * min(1, 0.06 + t * 0.94)) ^ 0.8 * (0.5 + 0.5 * t) end
A.leaflet(c, 41, 27, 38, 20, 34, 14, 2.6, lanc, SLEAF, lt, { cutBy = { sm }, teeth = 2.6 })
A.leaflet(c, 43, 28, 47, 22, 50, 16, 2.4, lanc, SLEAF, lt, { cutBy = { sm }, teeth = 2.6 })
-- tiny curled heart leaf at the tip
do local m = G.rell(42, 23.5, 0, -1, 1.6, 1.1) m:cut(sm) G.toneN(c, m, X.pillow(m, 1.2), SLEAF, { tok = lt }) end

-- achenes: warty ridge, dark keel line, AO where they meet the stem
for i, s in ipairs(SM) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  local bias = {}
  if i == 3 then X.ao(bias, s.m, sm, 1, -1) end
  local idx = G.toneN(c, vis, s.n, SEED, { tok = tok, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1 })
  vis:each(function(x, y) local k = K(x, y) local t, v = s.T[k], s.S[k]
    if v > -0.15 and v < 0.25 and t > 0.12 and t < 0.88 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 1)], tok) end  -- keel
    if v < -0.35 and t > 0.12 and t < 0.9 and (floor(t * 9) % 2 == 0) then c:put(x, y, SEED[min(6, (idx[k] or 3) + 1)], tok) end  -- warts
    if t < 0.06 or t > 0.95 then c:put(x, y, SEED[2], tok) end   -- dark pointed ends
  end)
  local gx, gy = G.specAt(vis, s.n, 40)
  if gx then c:put(gx, gy, "#e2c495", tok) end
end

-- petal on top
local ptok = { r = { name = "petal" } }
local pidx = X.tone(c, pm, X.light(pn, { amb = 0.25, wrap = 0.4 }), PET, { cuts = { 0.15, 0.3, 0.45, 0.6, 0.78 }, tok = ptok })
pm:each(function(x, y) local k = K(x, y) local t, s = PT[k], PS[k]
  if t < 0.2 then c:put(x, y, PET[max(1, min(3, (pidx[k] or 3) - 2))], ptok)                 -- violet base
  elseif t > 0.6 and s > 0.3 then c:put(x, y, PET[max(2, (pidx[k] or 3) - 2)], ptok)       -- curled-up violet underside
  elseif abs(s) < 0.15 and t > 0.25 and t < 0.75 then c:put(x, y, PET[4], ptok) end        -- centre crease
end)

G.save2(c, NAME)
