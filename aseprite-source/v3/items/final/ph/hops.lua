-- hops (final, Opus single pass). One hop cone hanging from a short twisted strig, with a single three-lobed serrated
-- hop leaf rising to the right. The cone is built from staggered rows of papery bracts, each pointed downward and
-- shingled (upper bracts lie over the bases of lower ones). Material: per-pixel light = whole-cone ellipsoid blended
-- with each bract's own pillow; dark cast row under every overlapping bract edge, paler papery tips, cool reflected
-- light on the lower-right bracts, one specular. Leaf: midribs, swept veins, AO where lobes overlap. Strig: twist marks.
-- quirk: one bract on the right has peeled open, showing golden lupulin that is dusting down below the cone.
local NAME = "hops"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CONE = { "#294430", "#3c6638", "#5a8c40", "#82ae4c", "#b2d066", "#e2ee9c" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#2a5038", "#477a42", "#74a452", "#a6cc72" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local COOL = "#4a7a78"

-- leaf first (cone and strig paint over its base)
local ltok = { r = { name = "leaf" } }
local leafm = A.hopLeaf(c, 33, 15, -0.62, 15, LEAF, ltok, { w = 0.38, bend = 0.6, vein = "#c2e48c" })
-- petiole
for _, p in ipairs{ { 33, 15 }, { 34, 15 }, { 32, 16 } } do c:put(p[1], p[2], STEM[2], ltok) end

-- strig: short stem up from the cone top, hooked cut end, twist marks
local sp = { { 31, 23 }, { 31.5, 18 }, { 30, 13 }, { 28, 11 } }
local stm, stn, STT, STS = A.tube(sp, function(t) return 1.15 end)
local stok = { r = { name = "stem" } }
local sidx = A.tone(c, stm, stn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.78 } })
stm:each(function(x, y) local k = K(x, y) if floor(STT[k] * 14 + STS[k] * 1.2) % 3 == 0 then c:put(x, y, STEM[max(1, (sidx[k] or 2) - 1)], stok) end end)
c:put(27, 10, STEM[4], stok) c:put(28, 10, STEM[3], stok)

-- cone
local Y0, Y1, CXc = 22, 52, 31.5
local function hwc(y) local u = (y - Y0) / (Y1 - Y0) if u <= 0 or u >= 1 then return 0 end return 10.2 * sin(pi * u ^ 0.78) ^ 0.75 end
local bracts = {}
local row = 0
for y = 26.5, 50, 4.8 do
  row = row + 1
  local hw = hwc(y)
  local n = max(1, floor((hw * 2) / 6.6 + 0.5))
  for i = 0, n - 1 do
    local f = (n == 1) and 0 or (i / (n - 1) - 0.5) * 2
    local off = (row % 2 == 0) and 1.3 or -1.3
    if n == 1 then off = 0 end
    bracts[#bracts + 1] = { x = CXc + f * (hw - 2.6) + off * (1 - abs(f)), y = y, rw = min(4.2, max(2.6, hw / n + 1.3)), row = row }
  end
end
-- ownership: bottom rows first, upper rows overwrite (shingled)
local own = {}
local cm = HP.mask()
for bi = #bracts, 1, -1 do local b = bracts[bi]
  for y = floor(b.y - 5), floor(b.y + 7) do for x = floor(b.x - 5), floor(b.x + 5) do
    local v = (y - b.y) / 4.8
    local w
    if v < 0 then w = b.rw * sqrt(max(0, 1 - v * v)) else w = b.rw * max(0, 1 - v / 1.35) ^ 0.8 end
    if v > -1 and v < 1.35 and abs(x - b.x) <= w then own[K(x, y)] = bi cm:set(x, y) end
  end end
end
local cn, cbias = {}, {}
cm:each(function(x, y) local k = K(x, y) local b = bracts[own[k]]
  local hw = max(2, hwc(y))
  local dx = max(-0.95, min(0.95, (x - CXc) / (hw + 1)))
  local ex, ey, ez = dx, (y - 36) / 40, sqrt(1 - dx * dx)
  local v = (y - b.y) / 4.8
  local lx = (x - b.x) / (b.rw + 0.5)
  local fx, fy, fz = A.norm(ex * 0.8 + lx * 0.3, ey * 0.8 + v * 0.3, ez * 0.75 + 0.6)
  cn[k] = { fx, fy, fz }
  -- cast row under an overlapping upper bract edge
  local up = own[K(x, y - 1)]
  if up and up ~= own[k] and bracts[up].row < b.row then cbias[k] = -3
  elseif own[K(x, y - 2)] and own[K(x, y - 2)] ~= own[k] and bracts[own[K(x, y - 2)]].row < b.row then cbias[k] = -1 end
  -- side separation between neighbours in the same row
  local lf = own[K(x - 1, y)]
  if lf and lf ~= own[k] and bracts[lf].row == b.row then cbias[k] = (cbias[k] or 0) - 1 end
  -- papery pale tip
  if v > 0.85 and not cbias[k] then cbias[k] = 1 end
end)
local ctok = { r = { name = "cone" } }
local cidx = A.tone(c, cm, cn, CONE, { tok = ctok, bias = cbias, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
-- cool reflected light on the lower-right rim
cm:edge():each(function(x, y) local k = K(x, y) if x > CXc + 3 and y > 34 and y < 50 and (cidx[k] or 1) <= 2 and not cbias[k] then c:put(x, y, COOL, ctok) end end)
-- specular on an upper-left bract
c:put(27, 29, CONE[6], ctok) c:put(28, 29, CONE[6], ctok) c:put(27, 30, A.CREAM, ctok)
-- AO where the strig enters the cone top
for _, p in ipairs{ { 30, 22 }, { 31, 22 }, { 32, 22 }, { 31, 23 } } do if cm:has(p[1], p[2]) then c:put(p[1], p[2], CONE[1], ctok) end end
c:put(31, 22, STEM[2], stok)

-- quirk: a peeled-open bract with golden lupulin, dust falling below
local gx, gy = 37, 42
for _, q in ipairs{ { 0, 0, 3 }, { 1, 0, 4 }, { 0, 1, 2 }, { 1, 1, 3 }, { 2, 1, 2 } } do c:put(gx + q[1], gy + q[2], GOLD[q[3]], ctok) end
for _, q in ipairs{ { 2, -1, 6 }, { 3, -1, 5 }, { 3, 0, 4 }, { 4, 0, 3 } } do c:put(gx + q[1], gy + q[2], CONE[q[3]], ctok) end
local dtok = { r = { name = "dust" } }
for _, q in ipairs{ { 41, 49, 3 }, { 43, 52, 4 }, { 40, 55, 3 } } do c:put(q[1], q[2], GOLD[q[3]], dtok) end
A.save2(c, NAME)
