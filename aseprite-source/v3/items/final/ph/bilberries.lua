-- bilberries (final, Opus single pass). A short arching woody twig with three small oval leaves; six dusky
-- bilberries hang on thin pedicels below it, each with air around it.
-- Material: per-pixel sphere light (6-tone dusky blue-violet), waxy bloom flecks on the mid tones, a crown navel,
-- one cream glint each, cool reflected light lower-right. Twig: lit tube with bark nicks and a pale snapped end.
-- Leaves: folded blades with midrib + side veins and a dark base where they meet the twig.
-- quirk: one berry has split and is weeping a single drop of crimson juice.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor = math.floor
local c = A.new("bilberries")
local BER  = { "#1a1438", "#2a2560", "#3d3f8a", "#5560a8", "#7d8cc6", "#b3c0e6" }
local LEAF = { "#173f36", "#22593f", "#2f7848", "#47984e", "#6cb858", "#a2d672" }
local BARK = { "#3a2424", "#5b3a2e", "#80553a", "#a87a4e", "#c9a070" }
local PED  = "#4f7a3a"

-- twig (behind everything)
local tm, tn, TT, TS = A.tube({ {10, 19}, {20, 12}, {36, 9}, {52, 14} }, function(t) return 1.6 - 0.7 * t end)
local ttok = { r = { name = "twig" } }
A.tone(c, tm, tn, BARK, { cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.15, wrap = 0.3, tok = ttok })
for _, p in ipairs{ {17, 14}, {27, 10}, {41, 10} } do c:put(p[1], p[2], BARK[1], ttok) c:put(p[1] + 1, p[2], BARK[4], ttok) end
c:put(9, 19, BARK[5], ttok) c:put(9, 20, BARK[4], ttok)               -- pale snapped end

-- leaves
A.leaf(c, 22, 12, 16, 5, 9, 3, 3.0, LEAF, { veins = { 0.35, 0.6 } })
A.leaf(c, 34, 10, 37, 3, 43, 1, 2.6, LEAF, { veins = { 0.4, 0.65 } })
A.leaf(c, 48, 13, 54, 9, 57, 3, 2.8, LEAF, { veins = { 0.35, 0.62 } })

-- berries {cx, cy, r, attach x on twig}
local bs = { {15, 30, 5, 15}, {28, 25, 5.5, 26}, {41, 27, 5, 39}, {21, 41, 5.5, 18}, {35, 41, 6, 33}, {48, 39, 4.5, 47} }
-- pedicels first (thin green stalks with a darker joint at the twig)
for _, b in ipairs(bs) do
  local ax = b[4]
  local ay
  for y = 0, 63 do if tm:has(ax, y) then ay = y end end
  ay = ay or 14
  A.line(c, ax, ay + 1, b[1] - 1, b[2] - b[3] + 1, PED)
  c:put(ax, ay + 1, "#2e5a34")
end
local split = 5
for i, b in ipairs(bs) do
  local m, n, idx, tok = A.berry(c, b[1], b[2], b[3], BER, { bloom = true, crown = true, bounce = "#5a6ab8", spec = "#f2f4ff" })
  -- little calyx collar where the pedicel enters
  local tx, ty = floor(b[1] - 1), floor(b[2] - b[3] + 1)
  c:put(tx, ty, "#2e5a34", tok) c:put(tx + 1, ty, BER[1], tok)
  if i == split then
    -- split: jagged crimson slit on the lower right, flesh lit on its upper lip
    local slit = { {37, 43}, {38, 44}, {38, 45}, {39, 46} }
    for _, p in ipairs(slit) do c:put(p[1], p[2], "#8a1a46", tok) c:put(p[1] - 1, p[2], "#c8336a", tok) end
    c:put(36, 43, "#e0608a", tok)
  end
end
-- the juice drop hanging under the split berry
local drop = { {38, 47, "#8a1a46"}, {38, 48, "#c8336a"}, {39, 48, "#8a1a46"}, {38, 49, "#a82456"}, {39, 49, "#6e1438"}, {38, 50, "#6e1438"} }
for _, d in ipairs(drop) do c:put(d[1], d[2], d[3]) end
c:put(37, 48, "#ff8ab0")
A.fin(c, "bilberries")
