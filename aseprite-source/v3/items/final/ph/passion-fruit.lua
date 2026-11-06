-- passion-fruit (final, Opus single pass aC32_1). A whole purple passion fruit (egg-shaped, wrinkled dimpled skin,
-- pale lenticel freckles, waxy lilac bloom, one cream spec, cool reflected rim) with a short woody stem, a glossy
-- three-lobed passion-vine leaf and a curled tendril, and in front a halved fruit cut face up: thin purple rind,
-- cream pith ring, golden jelly pulp packed with black seeds in bright arils, contact shadow where it meets the whole one.
-- quirk: a bead of golden juice runs down the half's rind.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "passion-fruit"
local c = A.new(NAME)
local SKIN = { "#2a1838", "#41204f", "#5e2c6a", "#7c3d84", "#9e58a0", "#c788c2" }
local BLOOM, RIM, FRECK = "#d6bfe0", "#56588e", "#e6cfe4"
local LEAF = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local WOOD = { "#3e2622", "#5e3a2a", "#84552f", "#a87240" }
local PITH = { "#b9a07e", "#e0cfa6", "#f6ead0" }
local PULP = { "#9a4a10", "#c8700f", "#e8981a", "#f9c43a", "#ffe58a" }
local SEEDC = "#2b1c26"

-- masks: whole fruit (back left), half fruit (front right)
local wm, wn = A.oval(25, 31, 12.0, 13.5, -0.2, 1.0)
local hcx, hcy = 40, 42
local face = HP.mask()
local bowl = HP.mask()
for y = hcy - 8, hcy + 14 do for x = hcx - 13, hcx + 13 do
  local dx, dy = x - hcx, y - hcy
  if (dx / 11.5) ^ 2 + (dy / 6.0) ^ 2 <= 1 then face:set(x, y) end
  if dy >= 0 and (dx / 11.5) ^ 2 + (dy / 10.5) ^ 2 <= 1 then bowl:set(x, y) end
end end
local half = bowl:copy():add(face)
wm:cut(half)

-- whole fruit skin
local wb = {}
A.cast(wb, wm, half, -1, -1, -1)
X.ao(wb, wm, half, 1, -1)
local wtok = { r = { name = "whole" } }
-- wrinkle dimples: low-frequency hash patches pushed one tone down
wm:each(function(x, y) local k = K(x, y)
  local h = X.hash(floor(x / 3), floor(y / 3), 9)
  if h > 0.78 and X.hash(x, y, 3) > 0.35 then wb[k] = (wb[k] or 0) - 1 end
end)
local widx = A.tone(c, wm, wn, SKIN, { bias = wb, tok = wtok, amb = 0.1, wrap = 0.3 })
local rim = X.rim(wn)
wm:each(function(x, y) local k = K(x, y)
  if not wb[k] and rim[k] > 0.62 and widx[k] <= 3 then c:put(x, y, RIM, wtok) end
  if widx[k] >= 3 and X.hash(x, y, 21) > 0.955 then c:put(x, y, FRECK, wtok) end
end)
-- waxy bloom patch upper-left, then the single spec
for _, p in ipairs{ {18,23},{20,22},{17,26},{21,24},{19,27},{22,21} } do if wm:has(p[1], p[2]) then c:put(p[1], p[2], BLOOM, wtok) end end
c:put(19, 24, A.CREAM, wtok) c:put(20, 24, A.CREAM, wtok) c:put(19, 25, BLOOM, wtok)

-- stem + leaf + tendril on top of the whole fruit
local stok = { r = { name = "stem" } }
local stem = A.pline{ { 27, 18 }, { 28, 15 }, { 30, 13 } }
stem:each(function(x, y) c:put(x, y, WOOD[3], stok) c:put(x + 1, y, WOOD[1], stok) end)
c:put(26, 18, WOOD[2], stok) c:put(27, 18, WOOD[4], stok) c:put(28, 18, WOOD[3], stok) c:put(29, 18, WOOD[1], stok)
-- three-lobed leaf
local ltok = { r = { name = "leaf" } }
local lmask, lnorm, LT, LS = HP.mask(), {}, {}, {}
for _, q in ipairs{ { 31, 13, 38, 6, 44, 8, 3.0 }, { 31, 13, 37, 9, 47, 14, 2.8 }, { 31, 13, 36, 4, 37, 1, 2.6 } } do
  local m, n, T, S = A.blade(q[1], q[2], q[3], q[4], q[5], q[6], function(t)
    if t > 0.985 then return -1 end
    return max(0.5, q[7] * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
  end, { fold = 0.4 })
  m:each(function(x, y) local k = K(x, y) if not lmask:has(x, y) then lmask:set(x, y) lnorm[k], LT[k], LS[k] = n[k], T[k], S[k] end end)
end
A.toneN(c, lmask, lnorm, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.15, wrap = 0.3 })
lmask:each(function(x, y) local k = K(x, y) if abs(LS[k]) < 0.13 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, LS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
local lx, ly = A.specAt(lmask, lnorm, 30) c:put(lx, ly, "#d8f0a8", ltok)
-- tendril: thin curl to the upper left
local ttok = { r = { name = "tendril" } }
local tp = A.pline{ { 27, 15 }, { 24, 13 }, { 21, 12 } }
tp:each(function(x, y) c:put(x, y, LEAF[5], ttok) end)
for i = 0, 18 do local a = pi * 0.1 - i * 0.36 local r = 2.6 - i * 0.07
  c:put(floor(19 + cos(a) * r + .5), floor(10 + sin(a) * r + .5), (i % 4 == 0) and LEAF[3] or LEAF[5], ttok) end

-- half fruit: bowl rind (lit as the lower half of a sphere), then the cut face
local htok = { r = { name = "half" } }
local bn = {}
bowl:each(function(x, y)
  local dx, dy = (x - hcx) / 12, (y - hcy) / 11
  local z = sqrt(max(0.03, 1 - dx * dx - dy * dy))
  bn[K(x, y)] = { A.norm(dx, dy * 0.8 + 0.2, z) }
end)
local bvis = bowl:copy():cut(face)
local bidx = A.tone(c, bvis, bn, SKIN, { tok = htok, amb = 0.12, wrap = 0.35 })
local brim = X.rim(bn)
bvis:each(function(x, y) local k = K(x, y)
  if brim[k] > 0.6 and bidx[k] <= 3 then c:put(x, y, RIM, htok) end
  if X.hash(x, y, 17) > 0.95 then c:put(x, y, FRECK, htok) end
end)
-- dark ambient row right under the face lip
face:grow(1):each(function(x, y) if bvis:has(x, y) and not face:has(x, y) and y > hcy then c:put(x, y, SKIN[1], htok) end end)
-- cut face: rind ring, pith, pulp
local ftok = { r = { name = "face" } }
face:each(function(x, y)
  local dx, dy = (x - hcx) / 11.5, (y - hcy) / 6.0
  local r = sqrt(dx * dx + dy * dy)
  local col
  if r > 0.9 then col = (dx + dy < 0) and SKIN[4] or SKIN[3]
  elseif r > 0.72 then col = (dy < -0.2) and PITH[3] or ((dy > 0.3) and PITH[1] or PITH[2])
  else
    -- jelly pulp: darker toward the lower-right inner wall (it is a hollow), bright upper-left
    local v = 0.55 - dx * 0.25 - dy * 0.35 + (X.hash(x, y, 2) - 0.5) * 0.25
    local i = 1 + floor(max(0, min(0.99, v)) * 5)
    col = PULP[i]
  end
  c:put(x, y, col, ftok)
end)
-- seeds in arils: ink seed with a bright aril pixel upper-left
local seedpts = { {35,40},{38,38},{42,38},{45,40},{33,43},{37,42},{41,41},{44,43},{36,45},{40,45},{47,42},{39,40} }
for i, p in ipairs(seedpts) do
  local x, y = p[1], p[2]
  if face:has(x, y) then
    c:put(x - 1, y - 1, PULP[5], ftok)
    c:put(x, y, SEEDC, ftok)
    if i % 2 == 0 then c:put(x + 1, y, "#4a2c3c", ftok) end
  end
end
c:put(36, 39, A.CREAM, ftok) -- wet glint on the jelly
-- quirk: juice bead running down the rind
local jtok = { r = { name = "juice" } }
for _, p in ipairs{ {48,46,4},{48,47,3},{48,48,4},{48,49,3},{47,50,4},{48,50,3},{47,51,2},{48,51,2} } do c:put(p[1], p[2], PULP[p[3]], jtok) end
c:put(47, 50, PULP[5], jtok)
A.save(c, NAME)
