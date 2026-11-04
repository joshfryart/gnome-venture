-- mixed-berry-cordial (final, Opus single pass). A slim glass cordial bottle: long neck, round shoulder, deep berry
-- syrup lit as a cylinder with a pale glass core, bright left rim streak and cool violet bounce on the right; clear glass
-- above the meniscus, glass lip ring, a pored cork with twisted twine round the neck, a kraft label with a berry sprig
-- and hand-lettered lines. A raspberry (drupelets, calyx) and a waxy blueberry (bloom, crown) sit at its foot.
-- quirk: a sticky drip of cordial has run down the neck and hangs as a glossy bead.
local NAME = "mixed-berry-cordial"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SYR = { "#2a0c26", "#4a1036", "#701640", "#98204a", "#c23a5c", "#e86c88" }
local GLS = { "#44546a", "#62788a", "#86a0ac", "#acc6c8", "#d2e6e0", "#eef8f0" }
local CORK = { "#5a3a22", "#86582e", "#a8783e", "#c89a58", "#e0bc7c", "#f4dca8" }
local TW = { "#5a4630", "#8a7048", "#b49a68", "#d8c08c" }
local PAP = { "#6a4c38", "#9a7856", "#c4a278", "#dec496", "#f0deb4", "#fcf0d4" }
local RAS = { "#4a0c22", "#7a1430", "#a8203a", "#d03848", "#ec6468", "#ffa4a0" }
local BLU = { "#141a3a", "#1e2c5c", "#2c4482", "#3e62a6", "#6a8ec8", "#a8c4e8" }
local CX = 32

c:groundShadow(CX, 57, 13, 1)

local function hw(y)
  if y <= 16 then return 3.5 end
  if y <= 26 then return 2.5 end
  if y <= 34 then return 2.5 + 5 * sin(pi / 2 * (y - 26) / 8) ^ 1.4 end
  if y <= 55 then return 7.5 end
  return 6.5
end
local LIQ = 23   -- meniscus row in the neck

-- glass body (lip ring separate)
local body, lip, bn, U = HP.mask(), HP.mask(), {}, {}
for y = 15, 56 do for x = 20, 44 do
  local w = hw(y)
  if abs(x - CX) <= w then
    local u = max(-0.96, min(0.96, (x - CX) / (w + 0.5)))
    local ny = (y > 26 and y <= 34) and -0.55 * cos(pi / 2 * (y - 26) / 8) or 0
    if y >= 55 then ny = 0.3 end
    local k = K(x, y)
    bn[k] = { A.norm(u, ny, sqrt(max(0.03, 1 - u * u - ny * ny))) } U[k] = u
    if y <= 16 then lip:set(x, y) else body:set(x, y) end
  end
end end
local liq, air = HP.mask(), HP.mask()
body:each(function(x, y) if y >= LIQ then liq:set(x, y) else air:set(x, y) end end)

-- cork, twine
local cork = HP.mask()
for y = 9, 14 do for x = 30, 34 do if not (y == 9 and (x == 30 or x == 34)) then cork:set(x, y) end end end
local twine = HP.mask()
for y = 17, 18 do for x = 29, 35 do twine:set(x, y) end end
local tail = { { 36, 18 }, { 36, 19 }, { 37, 20 }, { 37, 21 }, { 38, 22 } }

-- label
local label = HP.mask()
body:each(function(x, y) if y >= 39 and y <= 49 then label:set(x, y) end end)

-- syrup: lit cylinder, pale core, rim streak, cool bounce, AO under label edges and the shoulder base
local sb = {}
X.ao(sb, liq, label, 1, -1)
local stok = { r = { name = "syrup" } }
local sidx = A.shade(c, liq, bn, SYR, { amb = 0.05, wrap = 0.2, bias = sb, tok = stok })
liq:each(function(x, y) local k = K(x, y) local u = U[k] local w = hw(y)
  if label:has(x, y) then return end
  if x == floor(CX - w + 1.5) and y > 30 and y < 53 then c:put(x, y, "#f6c4d4", stok)        -- bright rim streak
  elseif x == floor(CX - w + 2.5) and y > 31 and y < 52 and y % 7 ~= 3 then c:put(x, y, SYR[6], stok)
  elseif abs(u - 0.1) < 0.16 and y > 50 and y < 55 then c:put(x, y, SYR[5], stok)          -- pale glass core (caustic)
  elseif u > 0.82 and y > 33 and y < 55 then c:put(x, y, "#6a4a9a", stok) end               -- cool violet bounce
  if y == LIQ then c:put(x, y, x < CX and SYR[6] or SYR[5], stok) end                       -- meniscus
  if y == 55 then c:put(x, y, SYR[2], stok) end                                              -- thick glass base
end)
-- clear glass above the syrup
local gtok = { r = { name = "glass" } }
local gidx = A.shade(c, air, bn, GLS, { amb = 0.2, wrap = 0.3, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, tok = gtok })
air:each(function(x, y) if x == CX - 2 then c:put(x, y, GLS[6], gtok) end end)
-- lip ring
local ltok = { r = { name = "lip" } }
A.shade(c, lip, bn, GLS, { amb = 0.12, wrap = 0.3, tok = ltok })
c:put(29, 15, GLS[6], ltok) c:put(30, 15, GLS[6], ltok) c:put(29, 16, GLS[4], ltok) c:put(35, 16, GLS[1], ltok)
for x = 30, 34 do c:put(x, 16, GLS[2], ltok) end                  -- dark row where cork meets lip (contact)

-- cork: pored, lit from the left
local ctok = { r = { name = "cork" } }
local cn = A.vcylN(cork, 30, 34)
cork:each(function(x, y) if y == 9 or y == 10 then local q = cn[K(x, y)] cn[K(x, y)] = { A.norm(q[1], -0.7, q[3]) } end end)
local cidx = A.shade(c, cork, cn, CORK, { amb = 0.1, wrap = 0.3, tok = ctok })
cork:each(function(x, y) local h = X.hash(x, y, 77) if h > 0.78 and y > 10 then A.step(c, cidx, CORK, x, y, -2, ctok) end end)

-- twine with twist + loose tail
local ttok = { r = { name = "twine" } }
twine:each(function(x, y) local p = (x + y) % 3
  local i = p == 0 and 1 or (p == 1 and 3 or 4)
  if x >= 34 then i = max(1, i - 1) end
  c:put(x, y, TW[i], ttok) end)
for i, q in ipairs(tail) do c:put(q[1], q[2], TW[(i % 2 == 0) and 2 or 3], ttok) end

-- label: kraft paper wrapped round the bottle, berry sprig + lettering
local ptok = { r = { name = "label" } }
local pb = {}
label:each(function(x, y) if y == 39 or y == 49 then pb[K(x, y)] = -1 end end)
local pidx = A.shade(c, label, bn, PAP, { amb = 0.2, wrap = 0.35, bias = pb, tok = ptok })
for _, q in ipairs{ { 30, 42, SYR[4] }, { 31, 42, SYR[5] }, { 33, 42, BLU[4] }, { 34, 42, BLU[5] }, { 31, 43, SYR[3] }, { 34, 43, BLU[3] },
  { 32, 41, "#4f8a3a" }, { 32, 40, "#6aa848" }, { 33, 40, "#4f8a3a" } } do c:put(q[1], q[2], q[3], ptok) end
for x = 28, 36 do if x ~= 31 then c:put(x, 45, PAP[1], ptok) end end
for x = 29, 35 do if x ~= 33 then c:put(x, 47, PAP[2], ptok) end end

-- quirk: drip of cordial down the left of the neck with a bead
local dtok = { r = { name = "drip" } }
for y = 17, 22 do c:put(29, y, y < 19 and SYR[3] or SYR[4], dtok) end
for _, q in ipairs{ { 28, 23, SYR[5] }, { 29, 23, SYR[4] }, { 28, 24, SYR[3] }, { 29, 24, SYR[2] } } do c:put(q[1], q[2], q[3], dtok) end
c:put(28, 23, "#ffe0ea", dtok)

-- raspberry (left), drupelets + calyx
local rm, rn = A.oval(19, 52.5, 3.4, 3.6, 0, 1)
local rtok = { r = { name = "raspberry" } }
local ridx = A.shade(c, rm, rn, RAS, { amb = 0.06, wrap = 0.22, tok = rtok })
rm:each(function(x, y) local p = (x + 2 * y) % 3
  if p == 0 then A.step(c, ridx, RAS, x, y, -1, rtok) elseif p == 1 and (ridx[K(x, y)] or 1) >= 4 then A.step(c, ridx, RAS, x, y, 1, rtok) end end)
c:put(17, 50, "#ffd8d0", rtok)
for _, q in ipairs{ { 18, 48, "#3e7a34" }, { 19, 48, "#6aa848" }, { 20, 48, "#2e5a2e" }, { 19, 47, "#4f8a3a" } } do c:put(q[1], q[2], q[3], rtok) end
-- blueberry (right), waxy bloom + crown
local um, un = A.oval(45, 53, 3.5, 3.4, 0, 1)
local utok = { r = { name = "blueberry" } }
local uidx = A.shade(c, um, un, BLU, { amb = 0.06, wrap = 0.22, tok = utok })
um:each(function(x, y) local i = uidx[K(x, y)] or 1
  if i >= 3 and i <= 5 and X.hash(x, y, 12) > 0.6 then c:put(x, y, "#8ea6cc", utok) end end)
for _, q in ipairs{ { 45, 51, BLU[1] }, { 44, 51, BLU[2] }, { 46, 51, BLU[2] }, { 45, 50, BLU[2] } } do c:put(q[1], q[2], q[3], utok) end
c:put(43, 52, "#e2eefa", utok)

A.save(c, NAME)
