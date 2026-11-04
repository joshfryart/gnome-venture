-- grains-of-paradise (B3, Opus single pass aB35_3). A slim spindle pod of Aframomum melegueta on the diagonal: red-orange
-- husk with longitudinal ribs and fine cross wrinkles, a woody stalk with a leaf scar, a papery calyx crown at the tip. The
-- husk is split along the upper side: cream pulp packed with glossy, angular red-brown seeds; pale cut husk edge on the far
-- lip, ambient shadow under the near lip. One spec on the husk.
-- quirk: a seed is hopping out of the slit, with a tiny cream bounce arc.
local NAME = "grains-of-paradise"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local POD = { "#4a1a24", "#7a2a28", "#a8402c", "#d0602e", "#ec8a3e", "#ffbc6a" }
local PULP = { "#8a5048", "#c48a72", "#f0d2b0", "#fff0d4" }
local SD = { "#2e1016", "#561c1e", "#7e2c22", "#a8442a", "#d06c3e", "#f2a066" }
local WOOD = { "#3e2622", "#5e3a2a", "#86583a", "#b07e52", "#d6a874" }
local CAL = { "#5a3a2c", "#8a6044", "#b88c62", "#e0bd8a" }
local CREAM = "#fff4d6"

-- pod body
local pts = { { 14, 47 }, { 23, 36 }, { 37, 24 }, { 49, 19 } }
local WF = function(t) return 0.6 + 7.0 * sin(pi * min(1, t)) ^ 0.6 end
local pm, pn, PT, PS, samp = A.tube(pts, WF)
local LEN = 0 for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- the slit (opening) on the upper-left side, t 0.3..0.72
local open = HP.mask()
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  if ((t - 0.5) / 0.27) ^ 2 + ((s + 0.26) / 0.62) ^ 2 <= 1 then open:set(x, y) end
end)
local husk = pm:copy():cut(open)
local bias = {}
-- near lip (upper side, beyond the slit) is drawn; far lip = pixels of husk bordering the slit on the lower side
local ptok = { r = { name = "pod" } }
local idx = A.shade(c, husk, pn, POD, { amb = 0.08, wrap = 0.3, bias = bias, tok = ptok })
-- ribs along the pod, fine cross wrinkles
husk:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local r = abs(((s * 3.2 + 0.5) % 1) - 0.5)
  if r < 0.11 and t > 0.06 and t < 0.94 then c:put(x, y, POD[max(1, idx[k] - 1)], ptok)
  elseif (floor(t * 60) % 7 == 0) and r > 0.3 and s > 0.1 and X.hash(x, y, 3) > 0.45 then c:put(x, y, POD[max(1, idx[k] - 1)], ptok) end
end)
-- spec on the lit shoulder near the base
c:put(19, 40, POD[6], ptok) c:put(20, 39, CREAM, ptok)

-- inside the slit: pulp, AO under near lip, pale cut edge on far lip
local otok = { r = { name = "pulp" } }
open:each(function(x, y) local k = K(x, y)
  local s = PS[k]
  local i = s < -0.62 and 1 or (s < -0.45 and 2 or (s < 0 and 3 or 4))
  c:put(x, y, PULP[i], otok)
end)
-- far (lower) lip: pale cut husk edge, 1px
open:grow(1):cut(open):each(function(x, y) if husk:has(x, y) and PS[K(x, y)] > -0.36 then c:put(x, y, "#f6c487", ptok) end end)
-- near lip rim: dark rolled edge
open:grow(1):cut(open):each(function(x, y) if husk:has(x, y) and PS[K(x, y)] <= -0.36 then c:put(x, y, POD[2], ptok) end end)

-- seeds packed in the slit: small angular 3x3 grains, lit upper-left, glossy
local function grain(x, y, tok, shape)
  local rows = shape or { "abc", "bcd", "cde" }
  local map = { a = SD[6], b = SD[5], c = SD[4], d = SD[3], e = SD[2] }
  for j, r in ipairs(rows) do for i = 1, #r do local ch = r:sub(i, i)
    if map[ch] then c:put(x + i - 1, y + j - 1, map[ch], tok) end end end
end
local stok = { r = { name = "seeds" } }
local inner = open:copy():cut(open:edge())
local sidx = {}
inner:each(function(x, y) local k = K(x, y)
  local u, v = PT[k] * LEN, PS[k] * (WF(PT[k]) + 0.5) + 20
  local j = floor(v / 3.6)
  local uu = u + (j % 2) * 2.2
  local fu, fv = uu % 4.4, v % 3.6
  if fu < 3.1 and fv < 2.7 then
    local i = 3
    if fu < 1 and fv < 1 then i = 5 elseif fu < 2 and fv < 1 then i = 4 elseif fu > 2.1 and fv > 1.7 then i = 1 elseif fu > 2.1 or fv > 1.7 then i = 2 end
    c:put(x, y, SD[i], stok) sidx[k] = i
  end
end)
-- glints on two seeds (glossy)
do local n = 0 inner:each(function(x, y) if sidx[K(x, y)] == 5 and n < 3 and X.hash(x, y, 9) > 0.6 then c:put(x, y, CREAM, stok) n = n + 1 end end) end

-- stalk at the base, woody, with a leaf scar
local wm, wn, WT, WS = A.tube({ { 15, 46 }, { 12, 49 }, { 10, 51 }, { 9, 54 } }, function(t) return 1.5 - 0.3 * t end)
wm:cut(pm)
local wtok = { r = { name = "stalk" } }
local widx = A.shade(c, wm, wn, WOOD, { cuts = { 0.24, 0.46, 0.66, 0.84 }, amb = 0.12, wrap = 0.3, tok = wtok })
c:put(10, 52, WOOD[1], wtok) c:put(9, 54, WOOD[4], wtok)
-- AO where the stalk meets the pod
pm:each(function(x, y) local k = K(x, y) if PT[k] < 0.05 then c:put(x, y, POD[1], ptok) end end)

-- calyx crown at the tip: papery tube with a frayed rim
local cm, cn = A.tube({ { 48, 19 }, { 50, 18 }, { 52, 17 }, { 54, 16 } }, function(t) return 1.6 + 0.9 * t end)
cm:cut(pm)
cm:set(55, 13):set(56, 15):set(56, 17):set(55, 19)
local ctok = { r = { name = "calyx" } }
local cn2 = {}
cm:each(function(x, y) cn2[K(x, y)] = cn[K(x, y)] or { 0.3, 0.3, 0.9 } end)
A.shade(c, cm, cn2, CAL, { cuts = { 0.24, 0.46, 0.66, 0.84 }, tok = ctok })
for _, p in ipairs{ { 55, 15 }, { 55, 17 }, { 54, 16 } } do c:put(p[1], p[2], CAL[1], ctok) end
pm:each(function(x, y) local k = K(x, y) if PT[k] > 0.965 then c:put(x, y, POD[2], ptok) end end)

-- quirk: one seed hopping out of the slit, cream bounce arc; a second seed already landed
do
  local x, y = A.bez(pts, 0.42)
  local x2, y2 = A.bez(pts, 0.43) local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
  local w = WF(0.42)
  local hx, hy = floor(x - px * (w + 7) + 0.5), floor(y - py * (w + 7) + 0.5)
  grain(hx - 1, hy - 1, stok, { "abc", "bcd", "cd." })
  c:put(hx - 1, hy - 1, CREAM, stok)
  local atok = { r = { name = "arc" } }
  for _, f in ipairs{ 0.35, 0.55, 0.75 } do
    local ax = x - px * (w + 1.5) * 1 + (hx - (x - px * (w + 1.5))) * f + tx * 3 * sin(pi * f)
    local ay = y - py * (w + 1.5) * 1 + (hy - (y - py * (w + 1.5))) * f + ty * 3 * sin(pi * f)
    c:put(floor(ax + 3.5), floor(ay + 0.5), CREAM, atok)
  end
end
A.save(c, NAME)
