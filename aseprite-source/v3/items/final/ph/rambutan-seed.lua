-- rambutan-seed (Opus single pass, final). Two glossy chestnut rambutan stones lie on a torn, glossy rambutan leaflet
-- (elliptic, entire margin, red midrib + arched veins, jagged torn end, cool bounce on the shade edge, AO + contact
-- shadow under each stone). The right stone has germinated: a slim copper-to-green stalk carries a pinnate seedling
-- leaf with three pairs of elliptic leaflets, the young top pair still bronze-red, and a little red bud.
-- Stones: ivory hilum scar, curved sheen band, one cream glint.
-- quirk: a shred of crimson hairy rind with pearly flesh still clings to the left stone.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_3.lua")
local G, X, HP, K = A.G, A.X, A.HP, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = G.new2("rambutan-seed")
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#a8d874" }
local COPPER = { "#4a1730", "#7a2638", "#a63a3c", "#cc5a44", "#e8805a", "#f8b088" }
local SEED = { "#2a1410", "#4a2618", "#6e3a20", "#92562c", "#b97c44", "#e6b278" }
local STEM = { "#5a2a2a", "#8a3f35", "#b8574a", "#d97a5e" }
local VEIN, COOL = "#c8e68e", "#3a6c72"
local ltok = { r = { name = "scrap" } }

-- seeds geometry
local seeds = { { 21, 48, 5.6, 4.0, -0.25 }, { 38, 45, 5.4, 3.9, -0.5 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], .9) end

-- leaf scrap
local ax, ay, cx, cy, bx, by = 7, 51, 30, 55, 58, 45
local lm, ln, LT, LS, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  return max(0.5, 9 * sin(pi * u ^ 1.0) ^ 0.65)
end, { fold = .38 })
-- torn left end: jagged diagonal
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local tear = 12 + ((y * 5) % 7) * .6 + (y - 50) * .55
  if x < tear and LT[k] < .3 then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { .14, .3, .46, .62, .8 }, amb = .18, wrap = .3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < .14 and t > .03 and t < .93 then c:put(x, y, s <= 0 and "#e0605a" or "#8a2f40", ltok) return end
  for vt = 6, 46, 5.2 do
    local d = t * len - (vt + abs(s) * 4.2)
    if d > -.5 and d < .5 and abs(s) > .2 and abs(s) < .85 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > .62 and LT[k] > .1 and LT[k] < .9 then c:put(x, y, COOL, ltok) end
  if LT[k] < .32 and x < 22 and not bias[k] and LS[k] < .5 then end end)
-- torn edge: pale cut rim on the tear
lm:each(function(x, y) if not lm:has(x - 1, y) and LT[K(x, y)] < .3 then c:px(x, y, "#d8e8a0") end end)
-- gloss on the leaf
c:px(33, 49, "#e6f6c0") c:px(34, 49, "#e6f6c0") c:px(35, 50, "#c8e68e")

-- sprout from stone 2: stalk and pinnate leaf (drawn before seeds so the coat covers its foot)
local pet = { { 38, 42 }, { 37, 36 }, { 39, 27 }, { 38, 14 } }
local sm, sn = G.tube(pet, function(t) return 1.15 - .15 * t end)
sm:cut(seeds[2].m)
local stok = { r = { name = "stalk" } }
X.tone(c, sm, X.light(sn, { amb = .15, wrap = .3 }), STEM, { cuts = { .3, .55, .8 }, tok = stok })
local function px(t) local x, y = G.bez(pet, t) return x, y end
local pairsDef = {
  { .38, 1.15, 13.5, 3.5, LEAF, 1 }, { .62, .98, 12, 3.3, LEAF, 1 }, { .84, .74, 9.5, 2.9, COPPER, 1 },
}
for _, p in ipairs(pairsDef) do
  local x, y = px(p[1])
  for _, side in ipairs{ -1, 1 } do
    A.leaflet_dir(c, x, y, side * p[2], p[3], side * -1.3, p[4], p[5], { veins = { 3, 5.5, 8, 10.5 }, slant = 1.8, name = "lf", rib = p[5][6], pw = .8 })
  end
end
-- bud
local bm = G.oval(38.5, 11.5, 1.7, 2.6, 0, 1)
local bn = select(2, G.oval(38.5, 11.5, 1.7, 2.6, 0, 1))
G.toneN(c, bm, bn, COPPER, { amb = .12, wrap = .3 })
for i = 0, 30 do local x, y = G.bez(pet, i / 30) c:px(floor(x + .5), floor(y + .5), i < 6 and STEM[2] or STEM[3]) end

-- seeds
for i, s in ipairs(seeds) do
  c:fillMask(G.oval(s[1] + 1, s[2] + 1.6, s[3] + .3, s[4] + .2, s[5], 1), "#173f36")
end
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  local b = {}
  for j = i + 1, #seeds do X.ao(b, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "stone" .. i } }
  local idx = G.toneN(c, s.m, s.n, SEED, { bias = b, tok = tok, cuts = { .22, .4, .56, .72, .88 }, amb = .08, wrap = .25 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local ix = idx[k] or 3
    -- sheen band (curved) on the lit shoulder
    if v < -.25 and v > -.62 and u > -.6 and u < .35 then ix = min(6, ix + 1) end
    -- faint longitudinal grain
    if X.hash(floor(u * 5), floor(v * 3), i) > .84 and ix > 2 and ix < 6 then ix = ix - 1 end
    -- hilum scar at the right end: ivory patch with a dark rim
    if u > .72 and abs(v) < .55 then
      ix = nil
      c:put(x, y, (u > .86) and "#b89868" or ((v < -.1) and "#f0dcae" or "#d8bf8c"), tok)
    end
    if ix then c:put(x, y, SEED[max(1, ix)], tok) end
  end)
  -- dark rim around the scar
  local hx, hy = s[1] + (s[3] - 1.2) * ca, s[2] + (s[3] - 1.2) * sa
  c:px(floor(s[1] - s[3] * .4 + .5), floor(s[2] - s[4] * .5 + .5), "#fff4d6")   -- glint
end
-- quirk: clinging shred of crimson hairy rind with pearl pulp on the left stone
local RIND = { "#3a0e2c", "#621533", "#a3263d", "#d9404a", "#f2685e" }
local sx, sy = 16, 45
for _, p in ipairs{ { 0, 0, 3 }, { 1, 0, 4 }, { 2, 0, 3 }, { -1, 1, 2 }, { 0, 1, 3 }, { 1, 1, 3 }, { 2, 1, 2 }, { 0, 2, 2 }, { 1, 2, 1 } } do c:px(sx + p[1], sy + p[2], RIND[p[3]]) end
c:px(sx - 1, sy - 1, "#7fb54a") c:px(sx + 1, sy - 1, "#bfe06c") c:px(sx + 3, sy, "#7fb54a") c:px(sx - 2, sy + 2, "#bfe06c") c:px(sx + 2, sy - 1, "#d23e46")
c:px(sx + 3, sy + 1, "#ebeee9") c:px(sx + 3, sy + 2, "#cfd5dc") c:px(sx + 2, sy + 2, "#fbf9f0")
G.save2(c, "rambutan-seed")
