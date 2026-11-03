-- blackcurrant (aR20_4, Opus single pass). A hanging strig of six blackcurrants: thin green-brown stalk with a woody
-- snapped top, 1 px pedicels to each berry, berries near-black violet with waxy dusty bloom, one glossy spec each, cool
-- reflected rim and the dried calyx tuft at the bottom of each berry; a small serrated three-lobed currant leaf with
-- palmate veins at the top. Air between all berries.
-- quirk: a tiny ladybird is walking on the leaf.
local NAME = "blackcurrant"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = R.new2(NAME)
local BC = { "#120c1e", "#1c1430", "#2a1e44", "#3c2c5a", "#5a4680", "#8f7db4" }
local BLOOM, RIM = "#6d6a94", "#363c6a"
local STEM = { "#3b4128", "#5a6530", "#7f8c42", "#acb866" }
local WOOD = { "#4a2e26", "#7a5034", "#a8774a" }
local LEAF = { "#183f33", "#225a3b", "#307643", "#47954b", "#6eb455", "#a2d06e" }
local CAL = { "#2e1d18", "#6b4a32", "#a07a52" }

-- leaf: three lobes from the petiole point, serrated edge
local PX, PY = 31, 15
local tips = { { 11, 13 }, { 17, 6 }, { 28, 7 } }
local lm = HP.mask()
for _, t in ipairs(tips) do
  local dx, dy = t[1] - PX, t[2] - PY
  local L = sqrt(dx * dx + dy * dy)
  lm:add(R.rell(PX + dx * 0.55, PY + dy * 0.55, dx / L, dy / L, L * 0.55, 3.9))
end
lm:add(c:ellipse(27, 12, 3, 2))
local teeth = {}
lm:edge():each(function(x, y) if X.hash(x, y, 4) > 0.55 and (x - PX) ^ 2 + (y - PY) ^ 2 > 20 then teeth[#teeth + 1] = K(x, y) end end)
for _, k in ipairs(teeth) do lm.s[k] = nil end
local ln = X.pillow(lm, 3)
local ltok = { r = { name = "leaf" } }
R.toneN(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.14, wrap = 0.3 })
local edge = lm:edge()
for i, t in ipairs(tips) do
  R.line(c, PX - 1, PY - 1, t[1] + (PX > t[1] and 2 or -2), t[2] + (PY > t[2] and 1 or -1), function(j, x, y)
    if not lm:has(x, y) or edge:has(x, y) then return c:get(x, y) end
    return (i == 3) and LEAF[3] or LEAF[6]
  end, ltok)
end
-- side veins on the middle lobe
for _, q in ipairs{ { 21, 10, 19, 7 }, { 22, 11, 19, 12 }, { 26, 9, 26, 6 } } do
  R.line(c, q[1], q[2], q[3], q[4], function(j, x, y)
    if not lm:has(x, y) or edge:has(x, y) then return c:get(x, y) end return LEAF[5] end, ltok)
end
edge:each(function(x, y) if x > 22 and y > 14 then c:put(x, y, LEAF[2], ltok) end end)

-- stalk (strig)
local stok = { r = { name = "stalk" } }
local sp = { { 34, 10 }, { 37, 23 }, { 33, 37 }, { 36, 50 } }
local sm, sn, ST = R.tube(sp, function(t) return 1.15 - 0.35 * t end)
-- petiole from the stalk top to the leaf
local pm, pn = R.tube({ { 34, 12 }, { 33, 13 }, { 32, 14 }, { PX, PY } }, function() return 0.8 end)
pm:cut(lm)
X.tone(c, pm, X.light(pn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- woody snapped top
for _, q in ipairs{ { 33, 8, 3 }, { 34, 8, 2 }, { 33, 9, 2 }, { 34, 9, 1 } } do c:put(q[1], q[2], WOOD[q[3]], stok) end

-- berries: cx, cy, r, stalk t
local berries = { { 26, 22, 4.6, 0.22 }, { 44, 25, 4.5, 0.3 }, { 25, 35, 4.4, 0.5 }, { 43, 38, 4.2, 0.62 }, { 28, 47, 4.0, 0.82 }, { 38, 51, 3.6, 1.0 } }
-- pedicels
for _, b in ipairs(berries) do
  local sx, sy = R.bez(sp, b[4])
  local dx, dy = sx - b[1], sy - b[2]
  local L = sqrt(dx * dx + dy * dy)
  local ex, ey = b[1] + dx / L * (b[3] - 0.5), b[2] + dy / L * (b[3] - 0.5)
  R.line(c, ex, ey - 1, sx, sy, function(j) return j < 1 and STEM[2] or STEM[3] end, stok)
end
-- berries with AO on the stalk and leaf where they sit
for i, b in ipairs(berries) do
  local tok = { r = { name = "berry" .. i } }
  local m = R.berry(c, b[1], b[2], b[3], BC, { tok = tok, bloom = BLOOM, rim = RIM, seed = i })
  -- dried calyx tuft at the bottom, nudged toward the viewer
  local x, y = floor(b[1] + 0.5), floor(b[2] + b[3] - 1.2)
  c:put(x, y, CAL[1], tok) c:put(x - 1, y, CAL[2], tok) c:put(x + 1, y, CAL[1], tok) c:put(x, y - 1, CAL[3], tok)
  -- ambient dark row on the stalk right under each berry rim
  m:grow(1):cut(m):each(function(xx, yy) if sm:has(xx, yy) and yy > b[2] then c:put(xx, yy, STEM[1], stok) end end)
end

-- quirk: ladybird on the leaf
local lt = { r = { name = "ladybird" } }
c:paint({
  ".kk.",
  "rrhr",
  "rkrd",
  ".dd.",
}, 34, 30, { k = "#2b1c26", r = "#e0443a", h = "#ff9a7a", d = "#9c2a34" })

R.save2(c, NAME)
