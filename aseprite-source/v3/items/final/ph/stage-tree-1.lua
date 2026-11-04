-- stage-tree-1 (lean W2_25)
-- oak seedling: curved stem, three lobed oak leaves, fallen acorn half-buried (quirk: acorn still wears its cap, tiny root peeks out)
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-tree-1" }
mound(c, 32, 52, 19, 5)
-- acorn
local ac = c:ellipse(16, 49, 4, 3)
G.toneN(c, ac, X.pillow(ac, 3), { "#5a3a1c", "#7d5224", "#a8742f", "#cf9a48", "#e8c070", "#f6dc98" }, {})
local cap = c:ellipse(16, 46, 4, 2)
G.toneN(c, cap, X.pillow(cap, 2), { "#3a2a22", "#563c2e", "#745038", "#926a46", "#b08a5c", "#c8a678" }, {})
c:px(14,46,DIRT[2]) c:px(17,45,DIRT[2]) c:px(16,43,"#5a3a1c") c:px(16,42,"#5a3a1c")
-- stem
local sm, sn = G.tube({ {32, 51}, {30, 43}, {34, 34}, {32, 24} }, function(t) return 1.5 - 0.5 * t end)
G.toneN(c, sm, sn, STEM, {})
leaf(c, 31, 36, 22, 30, 12, 33, 4.5, 0.3)
leaf(c, 33, 29, 44, 24, 53, 26, 4.5, 0.3)
leaf(c, 32, 25, 28, 16, 33, 8, 4.0, 0.3)
c:sparkle(50, 14)
G.save(c, "stage-tree-1")
