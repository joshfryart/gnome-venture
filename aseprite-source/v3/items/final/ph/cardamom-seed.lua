-- cardamom-seed (final, Opus single pass). A torn scrap of a long cardamom leaf lies flat (dark green, parallel
-- monocot veins, V-fold light, cool reflected lower edge, jagged torn ends). Angular dark red-brown cardamom seeds with
-- a crease and a glint spill across it (AO + contact shadow under each). The right seed has sprouted a ginger-family
-- shoot: pale sheath, one lanceolate parallel-veined blade leaning left and a still-rolled spike beside it.
-- quirk: an empty split husk half lies on the left like a little boat, one last seed still inside.
local NAME = "cardamom-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, pi = math.floor, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new(NAME)

local LEAF = { "#123528", "#1b4a33", "#266440", "#37824a", "#58a456", "#8cc66c" }
local COOL = "#336a6e"
local SEED = { "#1e1216", "#341c1e", "#522a24", "#74402e", "#9a5e3c", "#c88e5e" }
local HUSK = { "#3c4a26", "#5c6c34", "#82904a", "#a8b266", "#ccd28c", "#eef0bc" }
local SHOOT = { "#2e5e3a", "#4c8a48", "#78b25a", "#a8d27a", "#d4ecaa" }
local SHEATH = { "#6a6a3a", "#9a9a54", "#c8c47a", "#e8e2a8" }

-- leaf scrap, low and wide
local lw = 6.6
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 35, 58, 45, function(t) return lw * (1 - 0.22 * t) end, { fold = 0.32 })
A.tear(lm, LT, LS, len, lw, 0, 4, 5)
A.tear(lm, LT, LS, len, lw, 1, 5, 9)
-- a tear notch out of the lower edge
lm:each(function() end)
do local cut = {} lm:each(function(x, y) if (x - 30)^2 * 0.5 + (y - 49)^2 < 5 then cut[#cut + 1] = K(x, y) end end)
  for _, k in ipairs(cut) do lm.s[k] = nil end end

-- seeds {cx, cy, rx, ry, ang}; seed 1 sits in the husk
local S = { { 15, 45, 2.0, 1.6, 0.4 }, { 26, 40, 2.3, 1.8, -0.5 }, { 32, 44, 2.1, 1.7, 0.9 }, { 39, 39, 2.2, 1.7, 0.2 }, { 47, 42, 2.4, 1.9, -0.3 } }
for i, s in ipairs(S) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9)
  -- angular: knock off one corner per seed
  local kx, ky = s[1] + ((i % 2 == 0) and 2 or -2), s[2] + ((i % 3 == 0) and -2 or 2)
  s.m:each(function(x, y) if abs(x - kx) + abs(y - ky) < 1.5 then s.m.s[K(x, y)] = nil end end)
end

-- husk half (boat) on the left, opening up
local hm, hn, HU, HV, hg = A.pod(6, 49, 22, 42, 4.0, 0.7)
local cav = HP.mask()
hm:each(function(x, y) local k = K(x, y) if HV[k] < 0.05 and HV[k] > -0.75 and abs(HU[k]) < 0.78 then cav:set(x, y) end end)

-- sprout (from seed 5)
local stm, stn, STT, STS = A.tube({ { 47, 41 }, { 46, 35 }, { 45, 30 }, { 44, 24 } }, function(t) return 1.7 - 0.8 * t end)
local blm, bln, BT, BS, blen = A.blade(44, 25, 38, 11, 25, 9, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 3.6 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.8)
end, { fold = 0.4 })
local spm, spn = A.tube({ { 45, 25 }, { 46, 20 }, { 47, 16 }, { 48, 12 } }, function(t) return 1.1 * (1 - t) ^ 0.6 + 0.2 end)

-- leaf: AO + contact shadows
local lbias = {}
for _, s in ipairs(S) do X.ao(lbias, lm, s.m, 1, -1) A.cast(lbias, lm, s.m, 1, 1, -1) end
X.ao(lbias, lm, hm, 1, -1) A.cast(lbias, lm, hm, 1, 2, -1)
A.cast(lbias, lm, stm, 1, 1, -1)
local ltok = A.tok("leaf")
local lvis = lm:copy():cut(hm):cut(stm)
for _, s in ipairs(S) do lvis:cut(s.m) end
local lidx = A.shade(c, lvis, ln, LEAF, { bias = lbias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lvis:each(function(x, y) local k = K(x, y)
  if lbias[k] then return end
  local d = abs(LS[k]) * (lw + 0.6)
  if abs(LS[k]) < 0.1 then c:put(x, y, LS[k] <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif floor(d + 0.5) % 3 == 0 and d > 1.5 and d < lw - 0.5 then
    c:put(x, y, LEAF[max(1, min(6, (lidx[k] or 3) + (LS[k] < 0 and 1 or -1)))], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if lvis:has(x, y) and not lbias[k] and LS[k] > 0.7 then c:put(x, y, COOL, ltok) end end)

-- husk
local htok = A.tok("husk")
local hidx = A.shade(c, hm, hn, HUSK, { tok = htok, amb = 0.12, wrap = 0.3 })
cav:each(function(x, y) local k = K(x, y)
  -- inner wall: dark at the far (lit-side) wall, paler pith towards the near rim
  local v = HV[k]
  c:put(x, y, v < -0.5 and HUSK[1] or (v < -0.2 and HUSK[2] or HUSK[4]), htok)
end)
-- near rim lip highlight, ribs on the outer belly
for s = -70, 70 do local u = s / 100
  local x, y = A.podAt(hg, u, 0.12, 0.7) if hm:has(x, y) then c:put(x, y, HUSK[6], htok) end
  local x2, y2 = A.podAt(hg, u, 0.6, 0.7) if hm:has(x2, y2) and not cav:has(x2, y2) then c:put(x2, y2, HUSK[2], htok) end
end
local ex, ey = A.podAt(hg, 1.08, 0, 0.7) c:put(ex, ey, HUSK[2], htok)

-- shoot: sheath stem, rolled spike, blade
local shtok = A.tok("shoot")
local spv = spm:copy():cut(stm)
A.shade(c, spv, spn, SHOOT, { tok = shtok, cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.15, wrap = 0.3 })
local blv = blm:copy():cut(spm)
local bbias = {} X.ao(bbias, blm, stm, 1, -1)
local bidx = A.shade(c, blv, bln, LEAF, { tok = shtok, bias = bbias, cuts = { 0.12, 0.28, 0.44, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
blv:each(function(x, y) local k = K(x, y)
  if abs(BS[k]) < 0.12 and BT[k] > 0.04 and BT[k] < 0.9 then c:put(x, y, BS[k] <= 0 and LEAF[6] or LEAF[3], shtok)
  elseif abs(abs(BS[k]) - 0.55) < 0.1 and BT[k] > 0.15 and BT[k] < 0.8 then c:put(x, y, LEAF[max(1, min(6, (bidx[k] or 3) + (BS[k] < 0 and 1 or -1)))], shtok) end
end)
local sv = stm:copy()
local sbias = {} X.ao(sbias, stm, S[5].m, 1, 0)
A.shade(c, sv, stn, SHEATH, { tok = shtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
sv:each(function(x, y) local k = K(x, y) if STS[k] < -0.3 and STS[k] > -0.7 and STT[k] > 0.2 and STT[k] < 0.85 then c:put(x, y, SHEATH[4], shtok) end end)
-- sheath collar where the blade leaves
for _, q in ipairs{ { 44, 25 }, { 45, 25 }, { 43, 25 } } do if sv:has(q[1], q[2]) then c:put(q[1], q[2], SHEATH[1], shtok) end end

-- seeds last
for i, s in ipairs(S) do
  local tok = A.tok("seed" .. i)
  local vis = s.m:copy()
  if i == 5 then vis:cut(HP.mask()) end
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.2 })
  -- crease line across the seed
  local cx, cy = floor(s[1] + 0.5), floor(s[2] + 0.5)
  for _, q in ipairs{ { cx, cy }, { cx + 1, cy - 1 } } do
    if vis:has(q[1], q[2]) then local k = K(q[1], q[2]) c:put(q[1], q[2], SEED[max(1, (idx[k] or 3) - 2)], tok) end end
  -- glint
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) end
end
-- seed 1 sits inside the husk: shadow the cavity around it
S[1].m:grow(1):cut(S[1].m):each(function(x, y) if cav:has(x, y) then c:put(x, y, HUSK[1], htok) end end)
-- seed 5 seed coat split where the shoot comes out
for _, q in ipairs{ { 47, 40 }, { 46, 40 } } do if S[5].m:has(q[1], q[2]) then c:put(q[1], q[2], SHEATH[3], shtok) end end

A.save(c, NAME)
