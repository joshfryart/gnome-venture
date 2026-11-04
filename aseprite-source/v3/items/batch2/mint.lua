-- mint (crop, Opus single pass). A slim, slightly leaning spearmint sprig: square purple-flushed stem with node
-- rings, three opposite pairs of ovate serrated leaves (each pair turned 90 degrees reads as the next pair being
-- smaller and steeper) and a tight top tuft. Material: per-pixel light on V-folded blades, impressed side veins with
-- lit ridges (the rugose mint texture), pale midrib, cool bounce on the lower-right edges, AO + cast shadow on the
-- stem under each leaf base, pale cut end at the foot. One wet glint on the top-left leaf.
-- History: replaces the Sonnet draft (sat low-left, flat leaves).
-- quirk: a caterpillar nibble bite out of the lower right leaf, with a dry brown rim.
local NAME = "mint"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_mint.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local floor = math.floor

local LEAF = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" }
local TOP  = { "#16443e", "#22684e", "#2f8a58", "#4cad62", "#7fcd72", "#b8e894" }
local STEM = { "#2a1f3e", "#432c54", "#5f3f69", "#7d5a7c", "#9e7f92", "#c0a6ac" }
local COOL, GLINT, DRY = "#3d7a86", "#effbd2", "#a08f4c"

-- stem axis: foot (33,58) to top (30,12), slight lean
local function sx(y) return 33 - (58 - y) * 3 / 46 end
local stem, sn, ST, SS = G.tube({ { 33, 56 }, { 33.2, 44 }, { 31.2, 26 }, { 30.4, 12 } }, function(t) return 1.45 - t * 0.4 end)

-- leaves: { ax, ay, cx, cy, bx, by, w, opts }
local leaves = {}
local function add(ax, ay, cx, cy, bx, by, w, o) leaves[#leaves + 1] = G.mintGeom(ax, ay, cx, cy, bx, by, w, o) return leaves[#leaves] end
local n1, n2, n3 = 43, 28, 16
add(sx(n1) - 1, n1, sx(n1) - 9, n1 - 8, sx(n1) - 20, n1 + 1, 6.6, { tooth = 3.6, tcut = 0.25 })
add(sx(n1) + 1, n1, sx(n1) + 9, n1 - 8, sx(n1) + 20, n1, 6.4, { tooth = 3.6, tcut = 0.25, notch = { 46, 35.4, 2.6 } })
add(sx(n2) - 1, n2, sx(n2) - 8, n2 - 6, sx(n2) - 15, n2 - 7, 5.2, { tooth = 3.3, tcut = 0.25 })
add(sx(n2) + 1, n2, sx(n2) + 8, n2 - 6, sx(n2) + 15, n2 - 8, 5.0, { tooth = 3.3, tcut = 0.25 })
-- top tuft: two folded young leaves + centre bud
local tl = G.mintGeom(sx(n3) - 0.5, n3, sx(n3) - 4, n3 - 4, sx(n3) - 7, n3 - 8, 2.7, { tooth = 2.8, fold = 0.5 })
local tr = G.mintGeom(sx(n3) + 0.5, n3, sx(n3) + 4, n3 - 4, sx(n3) + 7, n3 - 9, 2.6, { tooth = 2.8, fold = 0.5 })
local bud = G.mintGeom(sx(n3), n3, sx(n3) - 0.3, n3 - 6, sx(n3) + 0.5, 6, 2.0, { tooth = 9, fold = 0.6 })

-- leaves (lower right first, so overlaps sit right)
for i, L in ipairs(leaves) do
  local b = {}
  X.ao(b, L.m, stem, 1, -1) G.cast(b, L.m, stem, 1, 1, -1)
  G.mintPaint(c, L, LEAF, b, { cool = COOL, name = "leaf" .. i, slant = 3.6, veins = i <= 2 and { 0.24, 0.44, 0.64 } or { 0.3, 0.56 } })
end
-- stem in front of the leaf bases (leaves get its AO + cast); only shadowed where the tuft overlaps
local sb = {}
local all = HP.mask()
all:add(tl.m) all:add(tr.m) all:add(bud.m)
stem:cut(all)
X.ao(sb, stem, all, 1, -1)
local stok = { r = { name = "stem" } }
G.toneN(c, stem, sn, STEM, { bias = sb, tok = stok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, amb = 0.1, wrap = 0.3 })
-- square stem: a crisp lit ridge line down the left face
stem:each(function(x, y) local k = K(x, y)
  if SS[k] < -0.25 and SS[k] > -0.6 and not sb[k] and y > 14 and y < 56 then c:put(x, y, STEM[5], stok) end end)
-- node rings (dark row just under each node) + cut end at the foot
for _, ny in ipairs{ n1 + 2, n2 + 2 } do
  local x0 = floor(sx(ny) + .5)
  for x = x0 - 1, x0 + 1 do if stem:has(x, ny) then c:put(x, ny, STEM[2], stok) end end
end
for x = 31, 35 do if stem:has(x, 56) then c:put(x, 56, x <= 32 and "#c9d9a8" or "#93b07c", stok) end end

-- tuft: side leaves, then the bud on top; AO where they meet
local tb = {} X.ao(tb, tl.m, bud.m, 1, -1)
G.mintPaint(c, tl, TOP, tb, { veins = { 0.4, 0.68 }, slant = 1.6, name = "tl" })
tb = {} X.ao(tb, tr.m, bud.m, 1, -1)
G.mintPaint(c, tr, TOP, tb, { veins = { 0.4, 0.68 }, slant = 1.6, name = "tr", cool = COOL })
G.mintPaint(c, bud, TOP, nil, { veins = {}, name = "bud" })
-- separation lines where the tuft parts touch (darker neighbour tone)
local function seam(back, front, hex)
  back.m:each(function(x, y) if not front.m:has(x, y) and (front.m:has(x + 1, y) or front.m:has(x - 1, y) or front.m:has(x, y + 1)) then c:put(x, y, hex) end end)
end
seam(tl, bud, TOP[1]) seam(tr, bud, TOP[1])

-- quirk: nibble rim (dry brown edge round the bite)
local L2 = leaves[2]
L2.m:each(function(x, y) local d = math.sqrt((x - 46) ^ 2 + (y - 35.4) ^ 2) if d <= 3.6 then c:put(x, y, DRY) end end)
-- wet glint on the upper-left leaf
local L3, gx, gy, gb = leaves[3]
local sp = X.spec(L3.n, 40)
L3.m:each(function(x, y) local k = K(x, y)
  if L3.T[k] > 0.3 and L3.T[k] < 0.6 and L3.S[k] < -0.2 and L3.m:has(x + 1, y) and (not gb or sp[k] > gb) then gb, gx, gy = sp[k], x, y end end)
if gx then c:put(gx, gy, GLINT) c:put(gx + 1, gy, GLINT) end
G.save(c, NAME)
