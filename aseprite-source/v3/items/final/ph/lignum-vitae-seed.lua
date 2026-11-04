-- lignum-vitae-seed (final, Opus single pass). A heart-shaped orange-gold lignum vitae capsule, split open on the front
-- to show a glossy near-black seed in a scarlet aril, sits on a torn, leathery dark-green obovate leaflet scrap
-- (glossy specular streak, midrib, veins). A freed seed beside it has sprouted: a slim woody stem with two pairs of
-- rounded opposite leaflets (the lignum vitae leaf). quirk: a tiny blue five-petal blossom opens at the sprout tip.
local NAME = "lignum-vitae-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#13332e", "#1d4d3a", "#2a6a44", "#3d8a4c", "#62a85a", "#96c87a" }
local GLOSS = "#cfeaa6"
local TORN = "#bfe09a"
local CAP = { "#7a2c1e", "#b04a1c", "#e07a1e", "#f5a623", "#ffc94a", "#ffe89a" }
local ARIL = { "#5a1424", "#8e1c2a", "#c42a30", "#e84a3a", "#ff7a5a", "#ffb08a" }
local BLK = { "#1e161c", "#2e2328", "#45363c", "#66545a" }
local STEM = { "#4a3024", "#6e4a32", "#94683f", "#bf9058" }
local BLUE = { "#2a3f8a", "#4a64c8", "#7f9cf0", "#c4d2ff" }

-- leaf scrap: obovate leathery leaflet on a rising diagonal, torn at the lower-left base
local lm, ln, LT, LS, len = A.blade(8, 54, 30, 50, 55, 33, function(t)
  if t > 0.975 then return -1 end
  local u = min(1, t * 0.9 + 0.1)
  return max(0.5, 9.5 * sin(pi * u ^ 0.75) ^ 0.6)   -- widest past the middle (obovate), rounded tip
end, { fold = 0.25 })
local tornE = A.tear(lm, LT, LS, 0.06, 0.1, 2)

-- capsule: heart shape (two lobes + point down-left toward a short stalk)
local CX, CY = 25, 41
local cap = HP.mask()
cap:add(A.oval(CX - 4, CY - 2, 4.6, 4.8, 0, 1)):add(A.oval(CX + 4, CY - 2, 4.6, 4.8, 0, 1))
local tri = c:poly{ { CX - 8, CY }, { CX + 8, CY }, { CX, CY + 8 } }
cap:add(tri)
-- notch at the top between the lobes
for _, p in ipairs{ { CX, CY - 7 }, { CX, CY - 6 }, { CX - 1, CY - 7 }, { CX + 1, CY - 7 } } do cap.s[K(p[1], p[2])] = nil end
-- free seed + sprout
local FX, FY = 41, 41
local fsm, fsn = A.oval(FX, FY, 2.6, 2.1, -0.3, 0.8)

local bias = {}
X.ao(bias, lm, cap, 1, -1) A.cast(bias, lm, cap, 1, 2, -1) A.cast(bias, lm, cap, 2, 3, -1)
X.ao(bias, lm, fsm, 1, -1) A.cast(bias, lm, fsm, 1, 1, -1)
A.toneN(c, lm, ln, LEAF, { bias = bias, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.28 })
A.veins(c, lm, LT, LS, len, LEAF, { skip = bias, per = 6.5, sweep = 6, ribLit = LEAF[5] })
-- leathery gloss: a specular streak on the lit half
local sp = X.spec(ln, 30)
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] < -0.25 and LS[k] > -0.6 and LT[k] > 0.55 and LT[k] < 0.85 then c:put(x, y, GLOSS) end end)
tornE:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.65 and LT[k] > 0.15 and LT[k] < 0.92 then c:put(x, y, "#2f5f6a") end end)

-- sprout (behind the free seed): slim woody stem
local spt = { { 42, 40 }, { 44, 32 }, { 41, 26 }, { 43, 18 } }
local stm, stn = A.tube(spt, function(t) return 1.0 - t * 0.3 end)
stm:cut(fsm)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 } })
-- two pairs of rounded opposite leaflets (obovate, short stalked)
local lfm = HP.mask()
for _, q in ipairs{ { 0.5, 4.2, 2.6 }, { 0.8, 3.6, 2.3 } } do
  local x, y = A.bez(spt, q[1])
  for _, side in ipairs{ -1, 1 } do
    local ux, uy = A.rot(0, -1, side * 1.2)
    lfm:add(A.leaflet(c, x + ux * (q[2] + 0.4), y + uy * (q[2] + 0.4), ux, uy, q[2], q[3], LEAF, { cut = stm, R = 1.8 }))
  end
end
stm:each(function(x, y) if lfm:has(x, y) then c:put(x, y, STEM[3]) end end)
-- quirk: blue five-petal blossom at the tip
local BX, BY = 43, 15
for _, p in ipairs{ { 0, -2, 3 }, { -2, -1, 3 }, { 2, -1, 2 }, { -1, 1, 2 }, { 1, 1, 1 }, { -1, -1, 3 }, { 1, -1, 2 },
  { 0, -1, 3 }, { -1, 0, 3 }, { 1, 0, 2 }, { 0, 1, 2 }, { -2, 0, 2 }, { 2, 0, 1 } } do
  c:put(BX + p[1], BY + p[2], BLUE[p[3]])
end
c:put(BX - 1, BY - 2, BLUE[4])
c:put(BX, BY, "#ffd34a")
c:put(BX, BY + 2, STEM[2])

-- capsule body: pillow + sphere-ish light, five-angled ridges, split-open front
local cn = X.pillow(cap, 4)
local cb = {}
local OPEN = A.oval(CX, CY - 1, 4.2, 3.6, 0, 1)
X.ao(cb, cap, OPEN, 1, 1) -- lifted lip around the opening
A.toneN(c, cap, cn, CAP, { cuts = A.CUTS, amb = 0.1, wrap = 0.3, bias = cb })
-- ridge lines (sutures) from the point up each lobe
A.pline(c, { { CX, CY + 7 }, { CX - 3, CY + 3 }, { CX - 6, CY - 2 } }, CAP[2])
A.pline(c, { { CX, CY + 7 }, { CX + 4, CY + 3 }, { CX + 7, CY - 1 } }, CAP[3])
-- opening: aril with seed, deep shade under the top lip
OPEN:each(function(x, y)
  local dy = y - (CY - 1)
  local i = dy < -2 and 2 or (dy < 0 and 3 or 4)
  if x - CX > 2 then i = i - 1 end
  c:put(x, y, ARIL[max(1, i)])
end)
for _, p in ipairs{ { CX - 2, CY + 2 }, { CX - 1, CY + 2 }, { CX - 3, CY + 1 } } do c:put(p[1], p[2], ARIL[5]) end
local sd = A.oval(CX, CY, 2.4, 1.9, 0.2, 1)
sd:each(function(x, y) local d = (x - CX) + (y - CY) c:put(x, y, d > 1 and BLK[1] or (d > -1 and BLK[2] or BLK[3])) end)
c:put(CX - 1, CY - 1, A.CREAM) c:put(CX - 2, CY, BLK[4])
-- capsule specular
c:put(CX - 6, CY - 4, CAP[6]) c:put(CX - 5, CY - 5, CAP[6]) c:put(CX + 2, CY - 5, CAP[6])
-- stalk from the point
A.pline(c, { { CX, CY + 8 }, { CX - 2, CY + 10 } }, STEM[2])

-- free seed: black in a scarlet aril cap (aril on the upper-left half)
local fv = X.light(fsn, { amb = 0.1, wrap = 0.3 })
fsm:each(function(x, y) local k = K(x, y)
  local d = (x - FX) + (y - FY)
  if d < -0.5 then
    local i = fv[k] > 0.7 and 5 or (fv[k] > 0.45 and 4 or 3)
    c:put(x, y, ARIL[i])
  else
    c:put(x, y, d > 2 and BLK[1] or BLK[2])
  end
end)
c:put(FX + 1, FY, BLK[4]) c:put(FX - 2, FY - 1, ARIL[6])

A.save(c, NAME)
