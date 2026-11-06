-- sorghum-seed (lean L1_1)
-- Four plump round sorghum grains (ruddy-orange, pale germ patch, one still hugged by papery glumes) on a long slim
-- grass blade with a bold white midrib; one grain has split and sends up a pale sheath with two arching grass blades.
-- quirk: a bit of papery chaff husk clings to one grain like a little cloak, and one grain is a pale cream variety.
local NAME = "sorghum-seed"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF  = { "#1c3a30", "#2c5a3a", "#44804a", "#68a455", "#93c468", "#c4e08c" }
local GRAIN = { "#4a1c14", "#7a2c1c", "#b04828", "#d46c34", "#ec9448", "#f8c880" }
local CREAM = { "#6a5030", "#a08454", "#cfb078", "#e8d09a", "#f6e6b8", "#fffadc" }
local HUSK  = { "#5a4224", "#8a6a3a", "#b8924e", "#dcb872" }
local SH    = { "#9aa060", "#bcc47c", "#dce49c" }
local MID, COOL = "#eef6c8", "#3c6a6a"

local function grain(cx, cy, r, a)   -- plump, nearly round, slight egg towards angle a
  local m = HP.mask()
  local ca, sa = cos(a), sin(a)
  for y = floor(cy) - 6, floor(cy) + 6 do for x = floor(cx) - 6, floor(cx) + 6 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / (r + 0.4)) ^ 2 + (v / (r - 0.3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local gr = {
  { 39, 52, 4.0, 0.3, GRAIN },
  { 49, 47, 3.8, -0.6, GRAIN },
  { 31, 47, 3.9, 2.4, GRAIN },   -- sprouts
  { 46, 56, 3.6, 0.0, CREAM },
}
for _, g in ipairs(gr) do g.m = grain(g[1], g[2], g[3], g[4]) g.n = X.pillow(g.m, 3.2) end

-- long slim grass blade, gently S-curved up the right side... runs low-left to right
local lm, ln, LT, LS, len = G.blade(6, 58, 30, 62, 58, 52, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 3.4 * (1 - t ^ 2.2) ^ 0.8 * min(1, 0.35 + t * 5))
end, { fold = 0.25 })
local bias = {}
for _, g in ipairs(gr) do X.ao(bias, lm, g.m, 1, -1) G.cast(bias, lm, g.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.2 and t > 0.01 and t < 0.97 then c:put(x, y, s <= 0 and MID or "#a8c880", ltok) return end
  if abs(s) > 0.5 and abs(s) < 0.62 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end   -- fine parallel veins
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 then c:put(x, y, COOL, ltok) end end)

-- sprout: pale sheath (coleoptile) with two arching narrow blades
local stm, stn, ST = G.tube({ {30, 44}, {28, 36}, {28, 30}, {27, 26} }, function(t) return 1.3 - 0.3 * t end)
local stok = { r = { name = "sheath" } }
local sv = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y) local lit = sv[k] > 0.5
  c:put(x, y, ST[k] < 0.4 and (lit and SH[2] or SH[1]) or (lit and SH[3] or SH[2]), stok) end)
local function blade(name, ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.5, w * (1 - t ^ 1.6) ^ 0.7 * min(1, 0.5 + t * 4))
  end, { fold = 0.4 })
  m:cut(stm)
  local tok = { r = { name = name } }
  G.toneN(c, m, n, LEAF, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.05 and T[k] < 0.95 then c:put(x, y, S[k] <= 0 and MID or LEAF[5], tok) end end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.2 then c:put(x, y, COOL, tok) end end)
end
blade("b1", 28, 28, 18, 24, 11, 8, 2.6)    -- arches up-left
blade("b2", 27, 26, 36, 18, 52, 12, 2.4)    -- arches right, drooping tip
for _, p in ipairs{ {27, 27}, {28, 27} } do if stm:has(p[1], p[2]) then c:put(p[1], p[2], HUSK[1], stok) end end

-- grains
for i, g in ipairs(gr) do
  local tok = { r = { name = "grain" .. i } }
  local ramp = g[5]
  local idx = X.tone(c, g.m, X.light(g.n, { amb = 0.05, wrap = 0.25 }), ramp, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  -- pale germ patch: a small crescent at the base on the lit-away side
  local gx, gy = floor(g[1] - cos(g[4]) * (g[3] - 1.6) + .5), floor(g[2] - sin(g[4]) * (g[3] - 1.6) + .5)
  for _, d in ipairs{ {0,0}, {1,0}, {0,1} } do
    if g.m:has(gx + d[1], gy + d[2]) then c:put(gx + d[1], gy + d[2], ramp == GRAIN and "#f0d8a8" or "#9a7a48", tok) end end
  local bx, by = G.specAt(g.m, g.n, 26)
  if bx then c:put(bx, by, "#fff4e0", tok) end
end
-- sprouting grain: split along the seam where the sheath leaves
for _, p in ipairs{ {30, 45}, {31, 45}, {32, 46} } do if gr[3].m:has(p[1], p[2]) then c:put(p[1], p[2], GRAIN[1], { r = { name = "grain3" } }) end end
-- quirk: papery glume chaff hugging the lower-left of the first grain like a cloak
local ch = HP.mask()
for _, p in ipairs{ {35,50},{35,51},{35,52},{35,53},{36,54},{36,55},{37,56},{38,56},{34,52},{34,53},{35,55} } do ch:set(p[1], p[2]) end
local ctok = { r = { name = "chaff" } }
ch:each(function(x, y) if not gr[2].m:has(x, y) then c:put(x, y, (x + y) % 2 == 0 and HUSK[3] or HUSK[4], ctok) end end)
c:put(35, 53, HUSK[2], ctok) c:put(36, 55, HUSK[1], ctok) c:put(35, 51, HUSK[1], ctok)
G.save(c, NAME)
