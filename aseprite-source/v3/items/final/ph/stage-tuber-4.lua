-- stage-tuber-4 (lean W2_26)
-- Mature potato plant: tall stem with pinnate compound leaves and a pale-violet flower cluster, big tuber bulging out of a hill, stolon with baby tuber.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local SOIL  = { "#2e1d24", "#4a2d2c", "#6b4330", "#8c5c3a", "#aa7a4c", "#c79a64" }
local SPOT  = { "#2e1d24", "#4a2d2c", "#6b4330" }
local CUTS  = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local ltok = { r = { name = "leaf" } }
local function blade(c, ax, ay, bx, by, wmax, ramp)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.6, wmax * sin(pi * min(1, t * 0.93 + 0.07)) ^ 0.7)
  end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), ramp or LEAF, CUTS, nil, ltok)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.2 and t < 0.93 and t > 0.1 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) end
  end)
  return m
end
local function soil(c, cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  local v = X.light(X.pillow(m, ry), { amb = 0.1, wrap = 0.3 })
  G.tone(c, m, v, SOIL, { 0.2, 0.36, 0.52, 0.68, 0.84 })
  m:copy():shrink(1):each(function(x, y) local h = X.hash(x, y, seed)
    if h > 0.9 then c:px(x, y, SOIL[6]) elseif h < 0.08 then c:px(x, y, SOIL[1]) end end)
  return m
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-tuber-4" }
local PO = { "#4b2f2a", "#6e4630", "#93633e", "#b78350", "#d4a468", "#ecc88a" }
local STALK = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
c:groundShadow(32, 57, 24, 3)
soil(c, 32, 53, 25, 6, 9)
-- big tuber bulging forward
local pm = HP.mask()
pm:add(c:ellipse(28, 50, 15, 7)) pm:add(c:ellipse(40, 52, 10, 6))
pm:cut(c:rect(0, 55, 63, 63))
G.tone(c, pm, X.light(X.pillow(pm, 7), { amb = 0.08, wrap = 0.25 }), PO, { 0.2, 0.38, 0.54, 0.7, 0.86 })
for _, e in ipairs{ {21,50},{31,48},{38,53},{27,53} } do c:px(e[1], e[2], PO[1]) c:px(e[1]+1, e[2]-1, PO[6]) end
pm:copy():shrink(1):each(function(x, y) if X.hash(x, y, 2) > 0.92 then c:px(x, y, PO[2]) end end)
c:px(20, 47, "#fff3dc") c:px(21, 47, "#fff3dc")
-- stem, slightly bent
local sm, sn = G.tube({ {32, 47}, {31, 38}, {33, 28}, {32, 14} }, function(t) return 1.7 - 0.7 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), STALK, { 0.3, 0.55, 0.8 })
-- compound leaves: rachis + leaflet ovals
local function comp(ax, ay, bx, by, n, r)
  local len = sqrt((bx-ax)^2 + (by-ay)^2) local ux, uy = (bx-ax)/len, (by-ay)/len
  for i = 1, n do
    local t = i / (n + 0.6) local px, py = ax + (bx-ax) * t, ay + (by-ay) * t
    local rr = r * (1 - 0.35 * t)
    for _, side in ipairs{ -1, 1 } do
      local cx, cy = px - uy * side * (rr + 0.8), py + ux * side * (rr + 0.8)
      local lm = G.rell(cx, cy, -uy * side, ux * side, rr + 0.8, rr)
      G.tone(c, lm, X.light(X.pillow(lm, 1.6), { amb = 0.15, wrap = 0.3 }), LEAF, CUTS, nil, ltok)
      c:px(floor(cx + 0.5), floor(cy + 0.5), LEAF[6])
    end
  end
  G.line(c, { {ax, ay}, {bx, by} }, STALK[2])
  local tm = G.rell(bx, by, ux, uy, r + 0.8, r)
  G.tone(c, tm, X.light(X.pillow(tm, 1.8), { amb = 0.15, wrap = 0.3 }), LEAF, CUTS, nil, ltok)
end
comp(31, 40, 12, 38, 3, 2.6) comp(32, 41, 53, 37, 3, 2.6)
comp(32, 31, 15, 22, 3, 2.3) comp(33, 30, 50, 21, 3, 2.3)
-- flower cluster at top
local FL = { "#5d3f86", "#8a68b4", "#b898d8", "#e2d0ee", "#fff8ee" }
for _, f in ipairs{ {29,11},{35,10},{32,7},{26,15},{38,14} } do
  local fx, fy = f[1], f[2]
  c:fillMask(c:ellipse(fx, fy, 2.4, 2.4), FL[3])
  c:px(fx - 2, fy, FL[2]) c:px(fx + 2, fy, FL[2]) c:px(fx, fy + 2, FL[1]) c:px(fx + 1, fy + 1, FL[2])
  c:px(fx - 1, fy - 1, FL[4]) c:px(fx, fy, "#f2c23c") c:px(fx + 1, fy, "#d99a22")
end
c:px(31, 8, FL[5]) c:px(28, 10, FL[5])
-- stolon with baby tuber (quirk), left
G.line(c, { {14, 54}, {10, 55}, {8, 55} }, STALK[2])
local bm = c:ellipse(7, 56, 3.2, 2.6)
G.tone(c, bm, X.light(X.pillow(bm, 3), { amb = 0.1, wrap = 0.25 }), PO, { 0.2, 0.38, 0.54, 0.7, 0.86 })
G.fin(c, "stage-tuber-4")
