-- worn-trowel (lean D3o_15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan2 or function(y,x) return math.atan(y,x) end
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local TOK = { r = { name = "p" } }
local c
local function paint(m, n, ramp, tex, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  m:each(function(x, y)
    local k = K(x, y)
    local val = v[k] or 0.5
    local i = 1
    for _, ct in ipairs(CUTS) do if val > ct then i = i + 1 end end
    if tex then i = i + (tex(x, y, k, i) or 0) end
    c:put(x, y, ramp[max(1, min(#ramp, i))], TOK)
  end)
  return v
end
local function hline(pts, hex) G.line(c, pts, hex) end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "worn-trowel" }
local STEEL = { "#3a3f5c", "#5b6482", "#8590a8", "#aab5c6", "#cfd8e2", "#f0f4f6" }
local BRASS = { "#5a3320", "#8a5224", "#b87a2c", "#dca64a", "#f2cf7a", "#fff0b0" }
local WOOD  = { "#3e2218", "#5e3520", "#82502c", "#a86f3c", "#c99058", "#e2b57a" }
c:groundShadow(36, 56, 14, 2)
-- blade: scooped teardrop
local bm, bn, bT, bS = G.tube({ {10,10},{18,20},{28,30},{38,38} }, function(t)
  if t < 0.75 then return 0.4 + 6.2 * sin(t / 0.75 * pi / 2) ^ 0.75 end
  return 6.6 - (t - 0.75) / 0.25 * 3.4
end)
paint(bm, bn, STEEL, function(x, y, k, i)
  local s, t = bS[k], bT[k]
  if abs(s) < 0.16 and t > 0.12 and t < 0.92 then return 2 end
  if abs(s - 0.14) < 0.1 and t > 0.12 and t < 0.9 then return -1 end
  if s > 0.8 and G.X.hash(x, y, 3) > 0.5 then return -1 end   -- worn edge
  if G.X.hash(x, y, 8) > 0.96 then return -2 end                -- pitting
end)
-- rust specks and worn nicks
for _, p in ipairs{ {27,27},{22,25},{30,32},{19,22} } do if bm:has(p[1], p[2]) then c:px(p[1], p[2], "#a8602c") end end
c:px(25, 28, "#7a3c20") c:px(23, 27, "#a8602c")
-- neck
local nm, nn = G.tube({ {37,37},{39,39},{41,41},{43,43} }, function(t) return 1.8 end)
paint(nm:copy():cut(bm), nn, STEEL, function() return -1 end)
-- ferrule
local fm, fn, fT = G.tube({ {42,42},{44,44},{46,46},{48,48} }, function(t) return 3.0 end)
paint(fm, fn, BRASS, function(x, y, k) local b = floor(fT[k] * 9) if b == 3 or b == 6 then return -1 end end)
-- handle
local hm, hn, hT, hS = G.tube({ {47,47},{50,50},{52,52},{55,55} }, function(t) if t > 0.9 then return 2.2 end return 3.1 end)
hm:cut(fm)
paint(hm, hn, WOOD, function(x, y, k)
  local s = hS[k]
  for _, g in ipairs{ -0.55, 0.0, 0.5 } do if abs(s - g) < 0.09 and G.X.hash(x, y, 5) > 0.3 then return -1 end end
  if abs(s + 0.7) < 0.1 then return 1 end
end)
c:px(54, 54, "#2a1218") c:px(53, 53, WOOD[1])
-- quirk: clump of garden soil stuck on the tip
for _, p in ipairs{ {11,11,"#5e3a26"},{12,12,"#7a4e30"},{11,12,"#46281f"},{13,11,"#7a4e30"},{12,13,"#5e3a26"},{13,13,"#46281f"} } do c:px(p[1], p[2], p[3]) end
c:px(13, 12, "#9a6a40")
c:px(17, 16, "#f6f9fa") c:px(18, 17, "#f6f9fa")
G.fin(c, "worn-trowel")
