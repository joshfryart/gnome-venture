-- peach-chutney (aC32_3 final, Opus single pass). A low glazed earthenware crock (teal glaze over a bare terracotta foot,
-- cream rim band with a painted wave, glossy specular streak, per-pixel 6-tone light) heaped with chunky peach chutney:
-- glossy amber cubes with lit top faces and dark undersides, dark raisins, gold mustard seeds and red chilli flecks.
-- A slim wooden spoon leans out of the heap (grain lines, pale end grain, AO where it enters the chutney). Ground shadow.
-- History: Sonnet draft replaced.
-- quirk: a tiny dried red chilli rests on the crock's rim.
local NAME = "peach-chutney"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLAZE = { "#173a4a", "#1f5a6a", "#2a7e86", "#3fa29e", "#6cc4b4", "#aee6d4" }
local TERRA = { "#4e2420", "#7a3428", "#a8502e", "#cc7444" }
local RIM   = { "#8a7a72", "#c0b0a0", "#e6d8c0", "#fff2d8" }
local CHUT  = { "#5a1c22", "#8e2e26", "#c25a28", "#e6822e", "#f8a644", "#ffd07a" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#d89a62", "#e8b982", "#f4d4a4" }
local RAISIN, SEED, CHILI = { "#2a1424", "#4e2238", "#6e3650" }, { "#a86a1e", "#e8b232" }, { "#7a1a2a", "#c42e2e", "#f05a3a" }

c:groundShadow(32, 53, 20, 2)
-- spoon (behind/inside the heap): handle from the heap up to the right
local stok = { r = { name = "spoon" } }
local sm, sn, ST, SS = G.tube({ { 31, 33 }, { 37, 25 }, { 43, 18 }, { 49, 10 } }, function(t) return 1.5 end)
local sidx = A.shade(c, sm, sn, WOOD, { amb = 0.15, wrap = 0.3, tok = stok })
sm:each(function(x, y) local k = K(x, y)  -- grain: a long line just off centre
  if SS[k] > 0.1 and SS[k] < 0.5 and X.hash(floor(ST[k] * 14), 0, 5) > 0.3 then c:put(x, y, WOOD[max(1, (sidx[k] or 3) - 1)], stok) end end)
-- pale end grain cap
c:put(49, 9, WOOD[6], stok) c:put(50, 10, WOOD[5], stok) c:put(48, 9, WOOD[5], stok)

-- crock: bowl shape, flat-ish rim ellipse on top, foot ring
local CX = 31.5
local bowl = HP.mask()
for y = 31, 50 do
  local t = (y - 31) / 19
  local h = 19.5 * sqrt(max(0, 1 - t ^ 2.4)) + 0.2
  if y >= 48 then h = min(h, 12) end
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do bowl:set(x, y) end
end
local foot = c:rect(21, 48, 42, 51):cut(c:rect(21, 51, 22, 51)):cut(c:rect(41, 51, 42, 51))
local glaze = bowl:copy():cut(c:rect(0, 46, 63, 63))
local terra = bowl:copy():add(foot):cut(glaze)
local gn = A.body(bowl, CX - 2, 32, 20, 6, 0.5)
local fn = X.pillow(terra, 2)
for k, v in pairs(fn) do if not gn[k] then gn[k] = v end end
local btok = { r = { name = "crock" } }
local gb = {}
X.ao(gb, glaze, c:rect(0, 0, 63, 33), 1, -1)
local gidx = A.shade(c, glaze, gn, GLAZE, { amb = 0.06, wrap = 0.25, bias = gb, tok = btok })
-- glaze drip edge: scalloped bottom of the glaze over the terracotta
local tb = {}
X.ao(tb, terra, glaze, 1, -1)
A.shade(c, terra, gn, TERRA, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, bias = tb, tok = btok })
for _, x in ipairs{ 18, 19, 26, 27, 34, 35, 42, 43 } do if glaze:has(x, 45) then c:put(x, 46, GLAZE[2], btok) end end
-- painted wave band on the glaze
for x = 14, 49 do local y = floor(38.5 + 1.2 * sin(x * 0.8)) if glaze:has(x, y) then c:put(x, y, (x < 30) and RIM[3] or RIM[2], btok) end end
-- specular streak on the glaze (glossy: allowed a second glint)
for _, p in ipairs{ {16, 37}, {16, 38}, {17, 41}, {18, 42} } do c:put(p[1], p[2], GLAZE[6], btok) end
c:put(16, 36, "#f2fff8", btok)
-- rim band: cream lip across the top
local rim = HP.mask()
for x = 12, 51 do if bowl:has(x, 31) then rim:set(x, 31) rim:set(x, 32) end end
rim:set(12, 32) rim:set(51, 32)
rim:each(function(x, y) local i = (y == 31) and ((x < 32) and 4 or 3) or ((x < 24) and 3 or (x > 44) and 1 or 2) c:put(x, y, RIM[i], btok) end)

-- chutney heap above the rim: lumpy dome
local heap = HP.mask()
for x = 13, 50 do
  local t = (x - 31.5) / 18.5
  local top = 30 - 7.2 * sqrt(max(0, 1 - t * t)) - 1.1 * sin(x * 1.3) * (1 - abs(t))
  for y = floor(top + 0.5), 30 do heap:set(x, y) end
end
heap:cut(sm)
local hn = X.pillow(heap, 3)
local htok = { r = { name = "chutney" } }
local hb = {}
X.ao(hb, heap, sm, 1, -1)
local hidx, hv = A.shade(c, heap, hn, CHUT, { amb = 0.12, wrap = 0.3, bias = hb, tok = htok })
-- cubes: lit top face + dark underside, scattered
for _, p in ipairs{ {18, 27}, {23, 25}, {28, 23}, {36, 24}, {41, 26}, {46, 28}, {21, 29}, {32, 27}, {39, 29}, {26, 28}, {44, 25} } do
  local x, y = p[1], p[2]
  if heap:has(x, y) and heap:has(x + 1, y + 1) then
    c:put(x, y, CHUT[6], htok) c:put(x + 1, y, CHUT[5], htok)
    c:put(x, y + 1, CHUT[4], htok) c:put(x + 1, y + 1, CHUT[3], htok)
    if heap:has(x, y + 2) then c:put(x, y + 2, CHUT[1], htok) c:put(x + 1, y + 2, CHUT[2], htok) end
  end
end
-- raisins, mustard seeds, chilli flecks
for _, p in ipairs{ {25, 26}, {34, 25}, {43, 28}, {30, 29}, {17, 29} } do if heap:has(p[1], p[2]) then
  c:put(p[1], p[2], RAISIN[2], htok) if heap:has(p[1] + 1, p[2]) then c:put(p[1] + 1, p[2], RAISIN[1], htok) end end end
for _, p in ipairs{ {20, 26}, {30, 25}, {38, 27}, {47, 27}, {27, 30}, {35, 29} } do if heap:has(p[1], p[2]) then c:put(p[1], p[2], SEED[2], htok) end end
for _, p in ipairs{ {24, 29}, {33, 22}, {40, 24}, {45, 30} } do if heap:has(p[1], p[2]) then c:put(p[1], p[2], CHILI[2], htok) end end
-- gloss on the heap
c:put(24, 23, "#fff0c8", htok) c:put(25, 23, CHUT[6], htok)
-- AO where heap meets the rim
for x = 13, 50 do if heap:has(x, 30) and not sm:has(x, 30) then c:put(x, 30, CHUT[max(1, (hidx[K(x, 30)] or 3) - 2)], htok) end end
-- spoon AO where it enters the heap
for _, p in ipairs{ {33, 30}, {34, 29}, {35, 28} } do if heap:has(p[1], p[2]) then c:put(p[1], p[2], CHUT[1], htok) end end

-- quirk: dried red chilli on the rim (left), with green cap
local qtok = { r = { name = "chilli" } }
local cm = A.stem(c, { { 9, 33 }, { 11, 31 }, { 14, 30 }, { 18, 31 } }, function(t) return 1.4 * (1 - t) + 0.4 end, CHILI, { cuts = { 0.3, 0.6 }, tok = qtok })
c:put(9, 32, "#3f9150", qtok) c:put(8, 33, "#24544a", qtok) c:put(8, 32, "#7cc35a", qtok)
c:put(11, 30, "#ffb08a", qtok)
A.save(c, NAME)
