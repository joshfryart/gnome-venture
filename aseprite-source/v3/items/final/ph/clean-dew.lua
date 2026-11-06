-- clean-dew (Opus single pass). A slim grass blade arching over, with one big clear dewdrop hanging from its tip
-- and two tiny beads sitting on the blade. Blade: tube normals, 6-tone green, lit keel line, cool reflected edge,
-- AO where the drop clings. Drop: water lens read: dark refractive rim on the upper left, glowing caustic crescent
-- lower right, pale core, an upside-down refracted sliver of the blade inside, window specular + one sparkle.
-- quirk: a tiny ant on the blade leans down to drink from the drop.
local NAME = "clean-dew"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SEA = { "#2a4a7a", "#3a78a8", "#56aac4", "#8ad8d6", "#bff2e6", "#ecfff8" }

-- main blade
local bp = { { 16, 59 }, { 13, 34 }, { 26, 9 }, { 46, 19 } }
local bm, bn, BT, BS = A.tube(bp, function(t) return 1.9 * (1 - t) ^ 0.55 + 0.35 end, 220)
-- second short blade (behind, darker)
local bp2 = { { 18, 59 }, { 22, 48 }, { 28, 42 }, { 35, 40 } }
local b2m, b2n, B2T, B2S = A.tube(bp2, function(t) return 1.5 * (1 - t) ^ 0.6 + 0.3 end, 120)
b2m:cut(bm)

-- drop geometry: teardrop hanging from the tip
local DC, DY, DR = 46.5, 33.5, 7.6
local dm = HP.mask()
for y = 19, 43 do for x = 36, 57 do
  local dx, dy = x + 0.5 - DC, y + 0.5 - DY
  local inC = dx * dx + dy * dy <= DR * DR
  local top = DY - DR * 0.55
  local inCone = y + 0.5 < top and y + 0.5 > 20.5 and abs(dx) <= (y + 0.5 - 20.5) / (top - 20.5) * DR * 0.84
  if inC or inCone then dm:set(x, y) end
end end
bm:cut(dm)

local bias = {}
X.ao(bias, bm, dm, 1, -1)
local btok, b2tok = { r = { name = "blade" } }, { r = { name = "blade2" } }
local b2idx = A.shade(c, b2m, b2n, LEAF, { tok = b2tok, bias = {}, cuts = { 0.25, 0.42, 0.6, 0.78, 0.95 } })
-- short blade: AO where it tucks behind the main blade
X.ao(bias, b2m, bm, 1, -1)
b2m:each(function(x, y) local k = K(x, y) if bias[k] then c:put(x, y, LEAF[max(1, (b2idx[k] or 3) - 1)], b2tok) end end)
local bidx = A.shade(c, bm, bn, LEAF, { tok = btok, bias = bias, rim = "#3a6c72", rimT = 0.6, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
-- keel / midrib: pale line on the lit half along the blade
bm:each(function(x, y) local k = K(x, y)
  if not bias[k] and BS[k] > -0.25 and BS[k] < 0.12 and BT[k] > 0.05 and BT[k] < 0.88 then c:put(x, y, LEAF[min(6, (bidx[k] or 4) + 1)], btok) end
  if BT[k] > 0.3 and BT[k] < 0.7 and BS[k] > 0.55 and X.hash(x, y, 3) > 0.6 then c:put(x, y, LEAF[2], btok) end  -- parallel vein flecks
end)

-- drop shading
local dtok = { r = { name = "drop" } }
local edge = dm:edge()
dm:each(function(x, y)
  local dx, dy = (x + 0.5 - DC) / DR, (y + 0.5 - DY) / DR
  local d = sqrt(dx * dx + dy * dy)
  local diag = (dx + dy) * 0.707
  local i
  if diag > 0.35 and d > 0.5 then i = 6 elseif diag > 0.1 and d > 0.35 then i = 5
  elseif dy < -0.2 then i = 3 else i = 4 end
  if d < 0.42 and diag > -0.3 then i = 5 end                 -- pale core
  if edge:has(x, y) then i = (diag < 0.2) and 2 or 4 end
  if y < DY - DR * 0.6 then i = edge:has(x, y) and 2 or ((x + 0.5 < DC) and 3 or 4) end
  c:put(x, y, SEA[i], dtok)
end)
-- refraction: upside-down sliver of the green blade inside the lower drop
for _, p in ipairs{ {41, 36, 3}, {42, 37, 3}, {43, 38, 4}, {44, 38, 4}, {45, 39, 4}, {42, 36, 4}, {46, 39, 5} } do c:put(p[1], p[2], LEAF[p[3]], dtok) end
-- window specular + glints
for _, p in ipairs{ {42, 29}, {43, 29}, {42, 30}, {43, 30} } do c:put(p[1], p[2], "#fffaf0", dtok) end
c:put(44, 29, SEA[5], dtok) c:put(42, 31, SEA[5], dtok) c:put(45, 31, "#fffaf0", dtok)
c:put(50, 38, "#fffaf0", dtok) c:put(51, 37, SEA[6], dtok)
c:sparkle(54, 26)
-- contact: dark meniscus row where the drop hangs from the tip
c:put(46, 21, SEA[1], dtok) c:put(47, 21, SEA[1], dtok)

-- tiny dew beads on the blade
local function bead(x, y)
  c:put(x, y, SEA[3], dtok) c:put(x + 1, y, SEA[4], dtok) c:put(x, y + 1, SEA[4], dtok) c:put(x + 1, y + 1, SEA[6], dtok)
  c:put(x, y, "#fffaf0", dtok)
end
bead(14, 43) bead(17, 30)

-- quirk: ant on the blade's crest, head down toward the drop
local AN = { "#3a1a24", "#6a2a30", "#a4504a" }
local atok = { r = { name = "ant" } }
for _, p in ipairs{ {33, 9, 2}, {34, 9, 1}, {35, 10, 2}, {36, 10, 1}, {37, 11, 2}, {38, 12, 1}, {38, 11, 3}, {35, 9, 3} } do c:put(p[1], p[2] + 5, AN[p[3]], atok) end
-- legs + antenna
for _, p in ipairs{ {34, 8}, {36, 8}, {37, 9}, {39, 13}, {40, 13} } do c:put(p[1], p[2] + 5, AN[1], atok) end

A.run(c, NAME)
