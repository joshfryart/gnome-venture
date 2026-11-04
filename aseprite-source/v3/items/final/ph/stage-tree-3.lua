-- stage-tree-3 (lean W2_25)
-- young tree: forked trunk with bark grain, lumpy three-lobe canopy with light clumps, flared roots, one red apple (quirk) and a bird nest gap
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local sin, cos, pi, abs, max, min, sqrt = math.sin, math.cos, math.pi, math.abs, math.max, math.min, math.sqrt
local DIRT = { "#2f1f22", "#4a2f2a", "#6b4533", "#8c5e3c", "#ae7e4c", "#cfa166" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a4d36c" }
local STEM = { "#2e5a42", "#4a8450", "#78ad5e", "#aed36f" }
local function leaf(c, ax, ay, cx, cy, bx, by, w, lob, tok)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) return w * sin(pi * min(1, t * 0.95 + 0.04)) ^ 0.7 * (1 + lob * sin(t * pi * 5)) end)
  G.toneN(c, m, n, LEAF, { tok = tok })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.92 then c:px(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end end)
  return m
end
local function mound(c, cx, cy, rx, ry)
  c:groundShadow(cx + 1, cy + ry, rx + 2, 2)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = X.pillow(m, ry)
  G.toneN(c, m, n, DIRT, {})
  m:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:px(x, y, DIRT[2]) elseif h < 0.05 then c:px(x, y, DIRT[6]) end end)
  return m
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-tree-3" }
local BARK = { "#2a1a1e", "#4a2e2a", "#6d4a36", "#8f6642", "#b08650", "#d0a868" }
mound(c, 32, 55, 17, 4)
-- trunk + fork
local tm, tn = G.tube({ {32, 55}, {32, 48}, {31, 42}, {32, 34} }, function(t) return 3.2 - 1.6 * t end)
G.toneN(c, tm, tn, BARK, {})
local b1, n1 = G.tube({ {32, 40}, {28, 37}, {24, 34}, {22, 30} }, function(t) return 1.5 - 0.5 * t end)
local b2, n2 = G.tube({ {32, 38}, {36, 35}, {40, 32}, {43, 29} }, function(t) return 1.5 - 0.5 * t end)
G.toneN(c, b1, n1, BARK, {}) G.toneN(c, b2, n2, BARK, {})
tm:each(function(x, y) if (x == 31 or x == 33) and y % 3 == 0 and y > 40 then c:px(x, y, BARK[2]) end end)
c:px(32, 47, BARK[1]) c:px(32, 48, BARK[1])
-- root flare
for _, p in ipairs{ {28,55},{29,54},{27,56},{36,55},{35,54},{37,56} } do c:px(p[1], p[2], BARK[3]) end
-- canopy
local can = HP.mask()
can:add(c:ellipse(22, 27, 11, 9)):add(c:ellipse(42, 25, 11, 9)):add(c:ellipse(32, 17, 12, 9)):add(c:ellipse(32, 28, 13, 8))
local n = X.pillow(can, 10)
local bias = {}
for _, L in ipairs{ {22,27,5},{42,25,5},{32,17,5} } do
  local cm = c:ellipse(L[1], L[2], L[3] + 4, L[3] + 2)
  cm:each(function(x, y) if y > L[2] + 3 then bias[K(x, y)] = -1 end end)
end
G.toneN(c, can, n, LEAF, { bias = bias })
can:each(function(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.93 then c:px(x, y, LEAF[6]) elseif h < 0.06 then c:px(x, y, LEAF[1]) end
end)
-- shade seams between lobes
for _, p in ipairs{ {32,27},{32,26},{31,28},{32,29},{33,28} } do c:px(p[1], p[2], LEAF[2]) end
-- apple
local ap = c:ellipse(40, 31, 2, 2)
G.toneN(c, ap, X.pillow(ap, 2), { "#5a1428", "#8a1e30", "#c0322e", "#e0503a", "#f27a52", "#ffb08a" }, {})
c:px(40, 28, "#4a3020") c:px(41, 28, LEAF[5])
c:px(26, 20, "#f4ffd0") c:px(27, 20, "#f4ffd0") c:px(26, 21, LEAF[6])
G.save(c, "stage-tree-3")
