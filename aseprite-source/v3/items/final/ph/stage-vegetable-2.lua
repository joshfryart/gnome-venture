-- stage-vegetable-2 (lean W2_26)
-- Young leafy veg (chard-like) in a furrowed soil bed: fan of five broad ribbed leaves with pale midribs and crinkled edges. Quirk: a ladybird on a leaf.
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-vegetable-2" }
c:groundShadow(32, 56, 26, 3)
local bed = soil(c, 32, 52, 26, 7, 6)
-- furrow lines
for x = 10, 54 do if X.hash(x, 3, 1) > 0.15 then c:px(x, 52, SOIL[2]) c:px(x, 53, SOIL[1]) end end
local RIB = { "#a9c85c", "#d3e48a" }
local function rleaf(ax, ay, bx, by, w)
  local m = blade(c, ax, ay, bx, by, w)
  local len = sqrt((bx-ax)^2 + (by-ay)^2)
  local ux, uy = (bx-ax)/len, (by-ay)/len
  for i = 1, floor(len / 3) - 1 do
    local t = i * 3 / len local px, py = ax + (bx-ax) * t, ay + (by-ay) * t
    local lw = w * sin(pi * min(1, t * 0.93 + 0.07)) ^ 0.7 * 0.55
    for _, sd in ipairs{ -1, 1 } do
      for k = 1, floor(lw) do
        local x, y = floor(px - uy * sd * k + ux * k * 0.8 + 0.5), floor(py + ux * sd * k + uy * k * 0.8 + 0.5)
        if m:has(x, y) then c:px(x, y, sd < 0 and LEAF[5] or LEAF[2]) end
      end
    end
  end
  return m
end
rleaf(32, 50, 8, 38, 5.2) rleaf(33, 50, 56, 37, 5.2)
rleaf(31, 50, 15, 22, 5.4) rleaf(34, 50, 50, 21, 5.4)
local mid = rleaf(32, 50, 32, 9, 6.0)
-- pale stalk bases
local sm, sn = G.tube({ {32, 53}, {32, 50}, {32, 48}, {32, 46} }, function(t) return 2.4 end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), { "#b87a8c", "#d89aa6", "#efc0c4", "#fde4dc" }, { 0.3, 0.55, 0.8 })
c:px(31, 52, "#fff6f2")
-- ladybird quirk on right leaf
c:fillMask(c:ellipse(46, 27, 2.2, 1.8), "#d6322e")
c:px(45, 26, "#ff8a7a") c:px(47, 28, "#8a1c26") c:px(44, 27, "#2b1c26") c:px(46, 27, "#2b1c26") c:px(47, 26, "#2b1c26")
G.fin(c, "stage-vegetable-2")
