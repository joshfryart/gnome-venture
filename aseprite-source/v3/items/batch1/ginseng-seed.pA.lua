-- ginseng-seed pass A. One kidney-shaped, ridged cream ginseng seed resting on a fan of three serrated ginseng leaflets.
-- quirk: the seed has sprouted two tiny forked roots like legs (ginseng's famous little-man root).
local NAME = "ginseng-seed.pA"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local LEAF = { "#244a33", "#2f6a3c", "#43893f", "#62a845", "#8bc552", "#b9df72" }
local VEIN = "#d2ec92"
local SEED = { "#7d5a3c", "#a07a52", "#c29e70", "#dcbf8e", "#eed9b0", "#faefd2" }
local ROOT = { "#8a6440", "#b88d5c", "#dcb98a", "#f2deb8" }

-- seed: kidney = oval minus a bite on the upper edge
local scx, scy = 25, 43
local sm, sn = G.oval(scx, scy, 7.5, 5.6, -0.25, 0.8)
local bite = c:ellipse(scx + 1.5, scy - 7.2, 2.6, 2.4)
sm:cut(bite)
-- legs
local legL = c:line({ { 22, 48 }, { 21, 52 }, { 19, 56 } }, 1):add(c:line({ { 23, 48 }, { 22, 51 } }, 1))
local legR = c:line({ { 27, 49 }, { 28, 53 }, { 30, 56 } }, 1):add(c:line({ { 26, 49 }, { 27, 52 } }, 1))
local legs = legL:add(legR)

-- leaflets (obovate, serrated)
local hub = { 35, 46 }
local leaflets = {
  { hub[1], hub[2], 24, 36, 12, 25, 6.0 },
  { hub[1], hub[2], 35, 28, 32, 8, 6.6 },
  { hub[1], hub[2], 47, 37, 56, 24, 6.0 },
}
local ltok = { r = { name = "leaf" } }
local allLeaf = HP.mask()
for i, L in ipairs(leaflets) do
  local m, n, T, S, len = G.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.985 then return -1 end
    if t < 0.14 then return 0.6 end
    local u = (t - 0.14) / 0.86
    return math.max(0.5, L[7] * math.sin(math.pi * u ^ 1.7) ^ 0.55)
  end, { fold = 0.35 })
  -- serration: notch edge pixels every 3 px along the blade
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > 0.25 and T[k] < 0.95 and (T[k] * len) % 2.5 < 0.8 then m.s[k] = nil end end)
  m:cut(allLeaf)          -- later leaflets sit under earlier ones? no: earlier painted first; keep visible area
  local bias = {}
  X.ao(bias, m, sm, 1, -1) G.cast(bias, m, sm, 2, 2, -1) G.cast(bias, m, legs, 1, 1, -1)
  X.ao(bias, m, allLeaf, 1, -1)
  G.toneN(c, m, n, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] then return end
    if math.abs(s) < 0.14 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) end
    for _, vt in ipairs{ 9, 14, 19, 24, 29 } do
      local d = t * len - (vt + math.abs(s) * 3.5)
      if d > -0.55 and d < 0.55 and math.abs(s) > 0.22 and math.abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
    end
  end)
  allLeaf:add(m)
end
-- petiole
local pet = c:line({ { 35, 46 }, { 39, 52 }, { 41, 57 } }, 2)
pet:cut(allLeaf)
local ptok = { r = { name = "pet" } }
pet:each(function(x, y) c:put(x, y, (x - y) % 3 == 0 and LEAF[5] or LEAF[4], ptok) end)

-- seed
local bias = {}
local tok = { r = { name = "seed" } }
-- ridges: wavy lines along the long axis
sm:each(function(x, y)
  local u = (x - scx) * math.cos(-0.25) + (y - scy) * math.sin(-0.25)
  local v = -(x - scx) * math.sin(-0.25) + (y - scy) * math.cos(-0.25)
  local w = v + math.sin(u * 0.7) * 0.8
  if math.abs(w % 3 - 1.5) < 0.5 and math.abs(v) < 4.6 then bias[K(x, y)] = -1 end
end)
G.toneN(c, sm, sn, SEED, { bias = bias, tok = tok, amb = 0.08, wrap = 0.2 })
local bx, by = G.specAt(sm, sn, 30)
c:put(bx, by, "#fffaf0", tok) c:put(bx + 1, by, SEED[6], tok)
-- hilum scar in the bite
c:put(scx + 1, scy - 4, SEED[1], tok) c:put(scx + 2, scy - 4, SEED[2], tok)
-- legs
local rtok = { r = { name = "root" } }
legL:each(function(x, y) if not sm:has(x, y) then c:put(x, y, ROOT[3], rtok) end end)
legR:each(function(x, y) if not sm:has(x, y) then c:put(x, y, ROOT[2], rtok) end end)
c:put(18, 56, ROOT[3], rtok) c:put(31, 56, ROOT[2], rtok)   -- little feet
G.save(c, NAME)
