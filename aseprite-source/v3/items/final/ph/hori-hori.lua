-- hori-hori (final, Opus single pass). Japanese soil knife standing nearly upright, point down: rosewood handle with
-- a lanyard hole and two brass rivets, a ribbed steel bolster, then a long dished spear blade. Material: cylinder light
-- on handle and bolster, wavy grain; the blade is concave (dished: the left half faces right, the right half faces
-- left), both edges bevelled, saw teeth down the right edge, etched depth ticks on the left half, a dark centre
-- groove, specular streak and one glint; AO under the bolster.
-- quirk: a clod of garden soil clings to the point, and a small pink earthworm peeks out of it.
local NAME = "hori-hori"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local WOOD  = { "#32181e", "#52262a", "#7a3a32", "#9c5338", "#c07648", "#e3a466" }
local STEEL = { "#2c2f45", "#45496a", "#636a8e", "#8c94b4", "#bcc4da", "#e8eef8" }
local BRASS = { "#4e2c16", "#8a5420", "#bd8128", "#dea53a", "#f5cd62", "#fff0a8" }
local SOIL  = { "#2e1c1c", "#4a2c26", "#6a4230", "#8c5c3c", "#b07e52" }
local WORM  = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

-- handle
local hp = { { 35.5, 8 }, { 35, 13 }, { 34.5, 18 }, { 34, 23 } }
local hm, hn, HT, HS = A.tube(hp, function(t)
  if t < 0.05 then return 1.8 + t / 0.05 * 0.8 end
  return 2.6 - 0.25 * sin(pi * t)
end)
local htok = { r = { name = "wood" } }
local hidx = A.tone(c, hm, hn, WOOD, { tok = htok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
hm:each(function(x, y) local k = K(x, y) local t, s = HT[k], HS[k]
  local g = (s + 1) * 2.2 + 0.7 * sin(t * 13)
  if t > 0.06 and abs(g - floor(g) - 0.5) < 0.13 and (hidx[k] or 3) > 2 then c:put(x, y, WOOD[(hidx[k] or 3) - 1], htok) end
end)
-- lanyard hole near the top, two rivets
c:put(35, 10, WOOD[1], htok) c:put(35, 11, WOOD[2], htok) c:put(36, 11, WOOD[4], htok)
for _, y in ipairs{ 15, 19 } do local x = floor(35.6 - (y - 8) * 0.1)
  c:put(x, y, BRASS[6], htok) c:put(x + 1, y, BRASS[4], htok) c:put(x, y + 1, BRASS[3], htok) c:put(x + 1, y + 1, BRASS[2], htok) end

-- bolster: steel collar with two ribs
local bp = { { 34.1, 22.6 }, { 33.95, 23.8 }, { 33.8, 25 }, { 33.65, 26.4 } }
local bm, bn, BT = A.tube(bp, function(t) return 3.1 end)
local btok = { r = { name = "bolster" } }
local bidx = A.tone(c, bm, bn, STEEL, { tok = btok, cuts = { 0.14, 0.3, 0.48, 0.64, 0.82 } })
bm:each(function(x, y) local k = K(x, y) local t = BT[k]
  if t > 0.4 and t < 0.58 then c:put(x, y, STEEL[max(1, (bidx[k] or 3) - 2)], btok) end end)
hm:each(function(x, y) if not bm:has(x, y) and bm:has(x, y + 1) then c:put(x, y, WOOD[1], htok) end end)

-- blade: long dished spear, point down
local lp = { { 33.6, 26.5 }, { 32.6, 36 }, { 31.4, 46 }, { 30.5, 56.5 } }
local lm, LT, LS, LSM, ls, llen = A.ribbon(lp, function(t)
  local w
  if t < 0.6 then w = 4.3 - t * 0.6 else w = 3.95 * ((1 - t) / 0.4) ^ 0.85 end
  return w, w
end)
lm:cut(bm)
-- saw teeth on the right edge (-A side when pointing down is the right): notch every 2 px
local cut = {}
lm:each(function(x, y) local k = K(x, y) local s, sm, t = LS[k], LSM[k], LT[k]
  if s < -sm.wa + 1.0 and t > 0.06 and t < 0.66 and floor(t * llen / 2) % 2 == 0 then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local ln, bias = {}, {}
lm:each(function(x, y) local k = K(x, y) local s, sm, t = LS[k], LSM[k], LT[k]
  local w = max(0.6, (s < 0) and sm.wa or sm.wb)
  local u = s / w
  local nx, ny, nz
  if abs(u) > 0.74 then local sg = u > 0 and 1 or -1 nx, ny, nz = A.norm(sm.ax * sg * 0.7, sm.ay * sg * 0.7, 1)  -- edge bevel
  else nx, ny, nz = A.norm(-sm.ax * u * 0.7, -sm.ay * u * 0.7, 1) end                                          -- concave dish
  ln[k] = { nx, ny, nz }
  if t < 0.04 then bias[k] = -1 end
  if abs(s) < 0.5 and t > 0.04 and t < 0.85 then bias[k] = (bias[k] or 0) - 1 end
end)
local ltok = { r = { name = "blade" } }
local lidx = A.tone(c, lm, ln, STEEL, { tok = ltok, bias = bias, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
-- depth ticks: etched on the left half (+A side), dark tick with a lit lip below
for i = 1, 6 do
  local t = 0.1 + i * 0.075
  local s = ls[floor(t * 200) + 1]
  local L = (i % 2 == 0) and 2.4 or 1.4
  for d = 0.9, 0.9 + L, 0.5 do
    local x, y = floor(s.x + s.ax * d + .5), floor(s.y + s.ay * d + .5)
    if lm:has(x, y) then c:put(x, y, STEEL[2], ltok) if lm:has(x, y + 1) then c:put(x, y + 1, STEEL[5], ltok) end end
  end
end
-- specular streak down the lit (right-facing-left) slope + glint
for _, t in ipairs{ 0.12, 0.16, 0.2, 0.24, 0.28, 0.33, 0.38 } do
  local s = ls[floor(t * 200) + 1]
  local x, y = floor(s.x - s.ax * 1.6 + .5), floor(s.y - s.ay * 1.6 + .5)
  if lm:has(x, y) then c:put(x, y, STEEL[6], ltok) end
end
do local s = ls[floor(0.2 * 200) + 1] c:put(floor(s.x - s.ax * 1.6 + .5) , floor(s.y - s.ay * 1.6 + .5), A.CREAM, ltok) end

-- quirk: soil clod on the point with a little earthworm
local stok = { r = { name = "soil" } }
local sm = A.rell(31, 54.5, 1, 0, 3.4, 2.6):add(A.rell(29, 56, 1, 0.3, 2.2, 1.8)):add(A.rell(33, 56.5, 1, 0, 1.6, 1.4))
local sn = X.pillow(sm, 2)
local sidx = A.tone(c, sm, sn, SOIL, { tok = stok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
for _, p in ipairs{ { 30, 53 }, { 32, 55 }, { 29, 56 } } do c:put(p[1], p[2], SOIL[5], stok) end
c:put(31, 54, SOIL[1], stok) c:put(33, 57, SOIL[1], stok)
-- AO on blade just above the clod
lm:each(function(x, y) if not sm:has(x, y) and sm:has(x, y + 1) then c:put(x, y, STEEL[1], ltok) end end)
local wtok = { r = { name = "worm" } }
for _, q in ipairs{ { 35, 56, 2 }, { 36, 55, 3 }, { 37, 54, 3 }, { 38, 54, 2 }, { 38, 53, 4 }, { 39, 53, 3 }, { 36, 56, 1 } } do
  c:put(q[1], q[2], WORM[q[3]], wtok) end
A.save2(c, NAME)
