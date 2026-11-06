-- ginseng-seed (pass B, final). One kidney-shaped ivory ginseng seed (hilum notch, two curved grooves following the
-- kidney, matte with one soft specular) resting on a palmate scrap of ginseng: three large obovate serrated leaflets
-- plus two small basal ones, midrib + side veins, V-fold, AO where leaflets overlap and a contact shadow under the seed.
-- History: ginseng-seed.pA (pass A).
-- quirk: the seed has sprouted two tiny forked roots like legs (ginseng's famous little-man root).
local NAME = "ginseng-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local LEAF = { "#21452f", "#2c6239", "#3f803e", "#5d9f44", "#86bd50", "#b4d96e" }
local VEIN = "#d4ec94"
local SEED = { "#7a5838", "#9d784e", "#bf9b6a", "#d9bd8a", "#ecd8ad", "#f9eed2" }
local ROOT = { "#7d5636", "#a87e50", "#d0ab78", "#ecd3a6" }

-- seed: kidney = rotated oval minus a bite on the upper edge, slightly flattened
local SA = -0.22
local scx, scy = 25, 42
local sm, sn = G.oval(scx, scy, 7.6, 5.3, SA, 0.7)
local bite = c:ellipse(scx + 1, scy - 5.8, 2.2, 1.8)
sm:cut(bite)
-- legs (forked roots): thigh 1 px, splayed, little root hairs
local legL = c:line({ { 22, 47 }, { 21, 50 }, { 20, 53 }, { 18, 56 } }, 1)
local legR = c:line({ { 28, 47 }, { 29, 50 }, { 30, 53 }, { 32, 56 } }, 1)
local legs = legL:copy():add(legR)

local hub = { 36, 45 }
local leaflets = {   -- ax, ay, ctrl x, ctrl y, tip x, tip y, half width
  { hub[1], hub[2], 46, 40, 53, 31, 7.6 },
  { hub[1], hub[2], 36, 34, 36, 21, 8.2 },
  { hub[1], hub[2], 26, 40, 19, 31, 7.6 },
  { hub[1], hub[2], 47, 47, 54, 49, 3.4 },
  { hub[1], hub[2], 25, 47, 18, 49, 3.2 },
}
local ltok = { r = { name = "leaf" } }
local allLeaf = HP.mask()
local front = sm:copy():add(legs)
for i, L in ipairs(leaflets) do
  local m, n, T, S, len = G.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.985 then return -1 end
    if t < 0.14 then return 0.55 end
    local u = (t - 0.14) / 0.86
    return math.max(0.5, L[7] * math.sin(math.pi * u ^ 1.15) ^ 0.5)
  end, { fold = 0.38 })
  -- serration: fine forward-pointing teeth, both margins
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > 0.3 and T[k] < 0.94 and (T[k] * len + (S[k] > 0 and 1 or 0)) % 4.2 < 0.7 then m.s[k] = nil end end)
  m:cut(allLeaf)
  local bias = {}
  X.ao(bias, m, front, 1, -1) G.cast(bias, m, sm, 2, 2, -1) G.cast(bias, m, sm, 1, 3, -1) G.cast(bias, m, legs, 1, 1, -1)
  X.ao(bias, m, allLeaf, 1, -1)
  local vis = m:copy():cut(front)
  G.toneN(c, vis, n, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.2 })
  vis:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] then return end
    if math.abs(s) < 0.13 and t > 0.06 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
    if L[7] > 4 then
      for _, vt in ipairs{ 9, 13.5, 18, 22.5, 27 } do
        local d = t * len - (vt + math.abs(s) * 3.6)
        if d > -0.5 and d < 0.5 and math.abs(s) > 0.2 and math.abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
      end
    end
  end)
  allLeaf:add(m)
end
-- red berry cluster (ginseng's signature), clear of the leaf fan
local SK = { "#2f6a3c", "#62a845" }
for _, pt in ipairs{ {40,22},{41,21},{42,20},{43,19},{44,18},{45,17},{46,16},{47,15},{48,16},{49,17},{50,18},{51,18} } do c:put(pt[1], pt[2], SK[1], { r = { name = "stalk" } }) end
local BR = { "#7a1424", "#b52434", "#e0484a", "#ff9a86" }
local btok = { r = { name = "berry" } }
for _, b in ipairs{ { 47, 14 }, { 52, 17 }, { 43, 18 } } do
  for dy = -1, 1 do for dx = -1, 1 do
    if math.abs(dx) + math.abs(dy) < 3 then c:put(b[1] + dx, b[2] + dy, (dx + dy > 0) and BR[1] or BR[3], btok) end
  end end
  c:put(b[1], b[2] + 1, BR[2], btok) c:put(b[1] - 1, b[2] - 1, BR[4], btok)
end

-- petiole: rounded stalk, pale lit edge, dark joint at the hub
local pet = c:line({ { 37, 46 }, { 39, 50 }, { 41, 54 }, { 42, 56 } }, 2)
pet:cut(allLeaf)
local ptok = { r = { name = "pet" } }
pet:each(function(x, y) c:put(x, y, pet:has(x - 1, y) and LEAF[3] or LEAF[5], ptok) end)
pet:each(function(x, y) if allLeaf:has(x, y - 1) or allLeaf:has(x - 1, y - 1) then c:put(x, y, LEAF[2], ptok) end end)

-- seed: light, then two grooves that follow the kidney curve
local tok = { r = { name = "seed" } }
local sb = {}
local ca, sa = math.cos(SA), math.sin(SA)
local groove = {}
sm:each(function(x, y)
  local u = (x - scx) * ca + (y - scy) * sa
  local v = -(x - scx) * sa + (y - scy) * ca
  local bend = v - (u * u) * 0.045               -- curves like the kidney
  if math.abs(bend - 0.6) < 0.5 and math.abs(u) < 5.2 then groove[K(x, y)] = 1 end
  if math.abs(bend - 3.4) < 0.5 and math.abs(u) < 3.6 then groove[K(x, y)] = 1 end
end)
G.toneN(c, sm, sn, SEED, { bias = sb, tok = tok, amb = 0.06, wrap = 0.2, cuts = { 0.22, 0.4, 0.56, 0.7, 0.85 } })
for k in pairs(groove) do local x, y = k % 1024 - 256, k // 1024 - 256
  local cur = c:get(x, y)
  for i = 2, 6 do if cur == SEED[i] then c:put(x, y, SEED[math.max(1, i - 2)], tok) break end end
end
-- groove lip: pixel above each groove pixel one step lighter (ridge catches the light)
for k in pairs(groove) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if sm:has(x, y - 1) and not groove[K(x, y - 1)] then
    local cur = c:get(x, y - 1)
    for i = 1, 5 do if cur == SEED[i] then c:put(x, y - 1, SEED[i + 1], tok) break end end
  end
end
local rim = X.rim(sn)
sm:edge():each(function(x, y) if rim[K(x, y)] > 0.72 then c:put(x, y, "#a88c78", tok) end end)   -- cool bounce
local bx, by = G.specAt(sm, sn, 24)
c:put(bx, by, "#fffaf0", tok)
-- hilum scar in the notch
c:put(scx + 1, scy - 3, SEED[1], tok) c:put(scx + 2, scy - 3, SEED[2], tok)

-- legs: lit left edge, shade right; root hairs and tiny feet
local rtok = { r = { name = "root" } }
legL:each(function(x, y) if not sm:has(x, y) then c:put(x, y, ROOT[3], rtok) end end)
legR:each(function(x, y) if not sm:has(x, y) then c:put(x, y, ROOT[2], rtok) end end)
c:put(21, 49, ROOT[4], rtok) c:put(29, 49, ROOT[3], rtok)
c:put(17, 56, ROOT[3], rtok) c:put(33, 56, ROOT[2], rtok)        -- feet
c:put(22, 52, ROOT[2], rtok) c:put(31, 51, ROOT[1], rtok)        -- root hairs (knees)
G.save(c, NAME)
