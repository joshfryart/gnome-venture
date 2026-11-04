-- marble-cascade (final, Opus single pass). A two-tier fountain carved from white marble: plinth and pedestal, a wide
-- basin with a bevelled lip and filled with water, a slim baluster column, a small upper bowl and a ball finial with
-- a jet. Water spills off the upper bowl in two thin glassy arcs into the basin. Marble: cool 6-tone ramp, cylinder lit,
-- faint grey-violet veins, bright bevel edge on every lip, AO where column meets bowl and water. Ground shadow.
-- quirk: a green glass marble has rolled into the basin and bobs at the waterline.
local NAME = "marble-cascade"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, max, min = math.floor, math.abs, math.sin, math.max, math.min
local c = A.new(NAME)

local MAR = { "#4a4864", "#6e6c8a", "#9696ae", "#bdbccc", "#dddbe4", "#f4f0ee" }
local VEIN = "#8a86a6"
local SEA = { "#2a4a7a", "#3a76a8", "#5aa6c8", "#8ad0d8", "#c4f0e8" }
local GL = { "#1e5a48", "#2f8a5e", "#5cc07a", "#a8e8a0" }
local CUTS = { 0.16, 0.32, 0.5, 0.68, 0.86 }

c:groundShadow(32, 57, 21, 2)

local function marble(m, n, o)
  o = o or {}
  local tok = o.tok or { r = { name = "marble" } }
  local idx = A.tone(c, m, n, MAR, { tok = tok, bias = o.bias, amb = 0.14, wrap = 0.35, cuts = o.cuts or CUTS })
  -- veins: thin meandering lines, sparse
  m:each(function(x, y) local k = K(x, y)
    local v = sin(x * 0.42 + y * 0.9 + 2.2 * sin(y * 0.31 + x * 0.12) + (o.seed or 0))
    if abs(v) < 0.09 and idx[k] and idx[k] >= 3 then c:put(x, y, VEIN, tok) end
  end)
  return idx, tok
end

-- plinth and pedestal
local plm = HP.rrect(23, 53, 41, 56, 1)
marble(plm, A.vcyl(plm, 23, 41), { seed = 1 })
for x = 24, 40 do c:put(x, 53, MAR[6]) end
local pdm = HP.poly{ { 27, 47 }, { 37, 47 }, { 35.5, 53 }, { 28.5, 53 } }
local pdb = {} X.ao(pdb, pdm, plm, 1, -1)
marble(pdm, A.vcyl(pdm, 27, 37), { seed = 2, bias = pdb })

-- basin body (bowl wall) + lip
local bwm = HP.poly{ { 10, 43 }, { 54, 43 }, { 51, 47 }, { 45, 50 }, { 19, 50 }, { 13, 47 } }
local bwb = {}
X.ao(bwb, bwm, pdm, 1, -1)
local bidx, btok = marble(bwm, A.vcyl(bwm, 10, 54, 0.25), { seed = 3, bias = bwb })
-- carved band line round the bowl
for x = 12, 52 do local y = 46 + floor(((x - 32) / 22) ^ 2 * 1.2 + .5) if bwm:has(x, y) then A.step(c, bidx, MAR, x, y, -2, btok) end end
for x = 13, 51 do local y = 47 + floor(((x - 32) / 22) ^ 2 * 1.2 + .5) if bwm:has(x, y) and x % 2 == 0 then A.step(c, bidx, MAR, x, y, 1, btok) end end
-- lip: top ring of the basin
local lip = HP.ellipse(32, 42, 22, 3.4)
local water = HP.ellipse(32, 42, 19.5, 2.1)
local lipR = lip:copy():cut(water)
local ltok = { r = { name = "lip" } }
lipR:each(function(x, y)
  local front = y >= 42
  local i = front and 5 or 4
  if not front and x > 40 then i = 3 end
  if front and x < 26 then i = 6 end
  if front and x > 44 then i = 4 end
  if not lip:has(x, y + 1) then i = 3 end                 -- outer bottom bevel
  if not front and not lip:has(x, y - 1) and x < 32 then i = 6 end -- bright back edge
  c:put(x, y, MAR[i], ltok)
end)
-- basin water: pale far side, deeper front under the lip (AO), ripple rings
local wtok = { r = { name = "water" } }
water:each(function(x, y)
  local i = 3
  if y <= 40 then i = 2 end                               -- shadowed under the far lip
  if y >= 43 then i = 3 end
  if y == 41 and x % 6 < 2 then i = 4 end
  if y == 42 and (x - 3) % 8 < 2 then i = 4 end
  c:put(x, y, SEA[i], wtok)
end)

-- column: baluster (thin shaft, knop in the middle), sits in the water
local col = HP.rect(30, 25, 34, 42):add(HP.ellipse(32, 34, 3.4, 2.2)):add(HP.rect(29, 40, 35, 42))
local cb = {}
for x = 29, 35 do for y = 40, 42 do local k = K(x, y) cb[k] = -1 end end   -- AO at the waterline
for x = 30, 34 do cb[K(x, 26)] = -1 end                                     -- AO under the upper bowl
local cidx, ctok = marble(col, A.vcyl(col, 29, 35), { seed = 4, bias = cb })
for x = 29, 35 do if col:has(x, 32) then A.step(c, cidx, MAR, x, 32, 1, ctok) end end  -- bevel on the knop
-- waterline ring where the column enters the basin water
for x = 29, 35 do c:put(x, 42, SEA[4], wtok) end

-- upper bowl
local ubw = HP.poly{ { 21, 23 }, { 43, 23 }, { 40, 26 }, { 36, 28 }, { 28, 28 }, { 24, 26 } }
local uidx, utok = marble(ubw, A.vcyl(ubw, 21, 43, 0.25), { seed = 5 })
local ulip = HP.ellipse(32, 22, 11, 1.8)
local uw = HP.ellipse(32, 22, 8.6, 0.9)
ulip:copy():cut(uw):each(function(x, y)
  local i = (y >= 22) and 5 or 4
  if y >= 22 and x < 28 then i = 6 end
  if y < 22 and x > 36 then i = 3 end
  if not ulip:has(x, y + 1) then i = 3 end
  c:put(x, y, MAR[i], ltok)
end)
uw:each(function(x, y) c:put(x, y, (y < 22) and SEA[2] or SEA[3], wtok) end)

-- finial: neck + ball, jet bubbling from the top
local fnk = HP.rect(31, 18, 33, 21)
marble(fnk, A.vcyl(fnk, 31, 33), { seed = 6 })
local fbm = HP.ellipse(32, 16, 2.4, 2.2)
A.tone(c, fbm, X.sphere(31.6, 15.6, 2.6, fbm), MAR, { amb = 0.14, wrap = 0.3 })
c:put(31, 15, MAR[6])

-- water: jet from the finial falls into the upper bowl; two arcs off the bowl lip into the basin
local function stream(pts, w, inner)
  local m, n, T, S = A.tube(pts, function() return w end)
  m:each(function(x, y) local k = K(x, y)
    local s = S[k]
    local i = (s < -0.3) and 5 or ((s > 0.4) and 3 or 4)
    if inner and T[k] > 0.85 then i = 4 end
    c:put(x, y, SEA[i], wtok)
  end)
  return m
end
stream({ { 32, 13 }, { 32, 9 }, { 28, 9 }, { 27, 20 } }, 0.6)
stream({ { 32, 13 }, { 32, 9 }, { 36, 9 }, { 37, 20 } }, 0.6)
c:put(32, 12, SEA[5], wtok) c:put(32, 11, A.CREAM, wtok)
stream({ { 21, 23 }, { 16, 24 }, { 14, 32 }, { 14, 41 } }, 0.9, true)
stream({ { 43, 23 }, { 48, 24 }, { 50, 32 }, { 50, 41 } }, 0.9, true)
-- splash marks where the arcs land
for _, p in ipairs{ { 12, 40 }, { 16, 40 }, { 48, 40 }, { 52, 40 } } do c:put(p[1], p[2], SEA[5], wtok) end
c:put(17, 41, SEA[4], wtok) c:put(47, 41, SEA[4], wtok)

-- quirk: a green glass marble bobbing in the basin, front right
local gm = HP.ellipse(40, 42, 2.4, 2.4)
local gtok = { r = { name = "marble-ball" } }
gm:each(function(x, y)
  local dx, dy = x - 40, y - 42
  local i = 3
  if dx + dy > 1.5 then i = 2 end
  if dx + dy > 3 then i = 1 end
  if dx + dy < -2.5 then i = 4 end
  if dy == 0 and dx >= -1 and dx <= 1 then i = (dx == 1) and 4 or i end  -- swirl
  c:put(x, y, GL[i], gtok)
end)
c:put(39, 41, A.CREAM, gtok)
c:put(41, 43, GL[4], gtok)                                         -- pale core / caustic
for x = 37, 43 do if not gm:has(x, 44) and water:has(x, 44) then c:put(x, 44, SEA[4], wtok) end end

A.fin(c, NAME)
