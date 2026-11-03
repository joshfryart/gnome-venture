-- ico-sprout (final, Opus). A seedling just up out of a small soil mound: slim 3 px stem with a lit edge,
-- two broad V-folded seed leaves (midrib, paired veins, pale lit half, cool shade half) and a tiny true-leaf bud
-- between them. Soil: pillow-lit crumbly mound with lit crumbs, dark pores and a pebble; dark AO collar where the
-- stem enters the soil, and a contact shadow under the leaves on the stem.
-- quirk: the split seed coat is still stuck on the tip of the right leaf like a little cap.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("ico-sprout")
local LF = { "#1d4a3c", "#2a6b45", "#3d8a4a", "#5aab4f", "#86c95c", "#bfe57e" }
local SM = { "#2a5f40", "#4c8f4a", "#78b85a", "#a6d873" }
local SO = { "#3a2226", "#5a3329", "#7d4a33", "#a0663f", "#c48955", "#e2b07a" }
local PB = { "#4a4a66", "#74758c", "#aaa9b8", "#d6d5df" }
local HU = { "#5a3a2a", "#8a5c3a", "#c08a52", "#e8c088" }
local ltok, stok, otok = { r = { name = "leaf" } }, { r = { name = "stem" } }, { r = { name = "soil" } }

-- soil mound (drawn first; stem over it)
local soil = c:ellipse(32, 51, 19, 6):cut(c:rect(0, 56, 63, 63))
soil:add(c:ellipse(32, 49, 12, 5))
local sn = A.slab(soil, 4)
local sb = {}
-- AO collar around the stem foot
soil:each(function(x, y) local d = sqrt(((x - 32) / 3.2) ^ 2 + ((y - 46) / 1.6) ^ 2)
  if d < 1.6 then sb[K(x, y)] = -2 elseif d < 2.6 then sb[K(x, y)] = -1 end end)
local sidx = A.shade(c, soil, sn, SO, { amb = 0.06, wrap = 0.2, bias = sb, tok = otok })
-- crumbs: lit grain on top half, pores in the shade
soil:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 7)
  local i = sidx[k]
  if i and i >= 3 and h < 0.13 and soil:has(x, y - 1) then c:put(x, y, SO[min(6, i + 2)], otok) c:put(x, y + 1, SO[max(1, i - 1)], otok)
  elseif i and i <= 3 and h > 0.9 then c:put(x, y, SO[1], otok) end
end)
-- pebble on the lower right
local pm = c:ellipse(43, 53, 2.5, 1.5)
local pidx = A.shade(c, pm, X.sphere(42.6, 52.6, 2.5, pm), PB, { cuts = { 0.3, 0.55, 0.8 }, tok = otok })
c:put(42, 52, PB[4], otok)
-- a broken husk half on the soil, left
A.map(c, { ".hh.", "hHHh", ".dd." }, 18, 48, { h = HU[3], H = HU[4], d = HU[1] }, otok)

-- stem: 3 px, gentle S
local sm, snm, ST, SS = X.cyl(32, 47, 31, 27, function(t) return 1.45 end)
local stb = {}
sm:each(function(x, y) local k = K(x, y) if ST[k] > 0.72 then stb[k] = -1 end end)  -- contact shadow under leaves
A.shade(c, sm, snm, SM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.1, bias = stb, tok = stok })
-- leaves: quadratic blades with a V fold
local function leaf(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.6, W * sin(math.pi * min(1, t * 0.9 + 0.1)) ^ 0.75)
  end, { fold = 0.6 })
  local b = {}
  X.ao(b, m, sm, 1, -1)
  local idx = A.shade(c, m, n, LF, { amb = 0.12, wrap = 0.3, bias = b, tok = ltok })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.08 and t < 0.9 then c:put(x, y, s <= 0 and LF[3] or LF[2], ltok) end
    for _, vt in ipairs{ 0.3, 0.5, 0.7 } do
      local d = (t - vt) * len - abs(s) * 3.2
      if d > -0.5 and d < 0.5 and abs(s) > 0.22 and abs(s) < 0.78 then
        local i = idx[k] or 3
        c:put(x, y, LF[max(1, i - 1)], ltok)
      end
    end
  end)
  return m, n, idx
end
local lm, ln, lidx = leaf(30, 29, 20, 16, 7, 21, 7.2)
local rm, rn, ridx = leaf(33, 27, 42, 13, 56, 15, 7.2)
-- waxy specular on each leaf (lit half, near the base)
c:put(19, 20, LF[6], ltok) c:put(20, 20, A.CREAM, ltok)
c:put(41, 17, LF[6], ltok) c:put(42, 17, LF[6], ltok)
-- cool reflected edge on leaf undersides (lower-right rim)
for _, mm in ipairs{ lm, rm } do
  mm:each(function(x, y) if not mm:has(x, y + 1) and not mm:has(x + 1, y + 1) and X.hash(x, y, 3) < 0.6 then
    local cur = c:get(x, y) if cur == LF[2]:lower() or cur == LF[1]:lower() then c:put(x, y, "#3a6f72", ltok) end end end)
end
-- true-leaf bud between the seed leaves
local bw = function(t) if t > 0.96 then return -1 end return 1.3 * sin(math.pi * min(1, t + 0.15)) + 0.4 end
local bm, bn = A.blade(31, 28, 30, 24, 33, 21, bw, { fold = 0.5 })
A.shade(c, bm, bn, SM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- quirk: split seed coat cap on the right leaf tip
A.map(c, { ".hhh.", "hHHhd", "Hhhdd", ".d.d." }, 53, 10, { h = HU[3], H = HU[4], d = HU[2] }, otok)
c:put(54, 11, A.CREAM, otok)
A.save(c, "ico-sprout")
