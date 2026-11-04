-- stage-tuber-1 (lean W2_25)
-- potato sprout: half-buried lumpy tuber with eyes and a pale bud (quirk), purple-green shoot with pinnate leaflet leaves
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-tuber-1" }
local POT = { "#4a3226", "#6e4a34", "#946a46", "#b98d5a", "#d8b078", "#efd09a" }
mound(c, 32, 54, 20, 4)
-- tuber lumpy
local tb = HP.mask()
tb:add(c:ellipse(30, 50, 14, 6)):add(c:ellipse(40, 51, 7, 5)):add(c:ellipse(21, 52, 6, 4))
G.toneN(c, tb, X.pillow(tb, 6), POT, {})
tb:each(function(x, y) if X.hash(x, y, 3) > 0.93 then c:px(x, y, POT[2]) end end)
for _, e in ipairs{ {22,49},{34,52},{41,50},{27,53} } do c:px(e[1], e[2], POT[1]) c:px(e[1]+1, e[2], POT[1]) c:px(e[1], e[2]-1, POT[5]) end
-- shoot
local sm, sn = G.tube({ {30, 46}, {29, 38}, {34, 30}, {33, 20} }, function(t) return 1.4 - 0.4 * t end)
G.toneN(c, sm, sn, STEM, {})
sm:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#7a4a8a") end end)
-- pinnate leaves: rachis + 3 pairs of leaflets
local function pin(ax, ay, bx, by, s)
  local dx, dy = bx - ax, by - ay
  local len = sqrt(dx*dx + dy*dy)
  local ux, uy = dx / len, dy / len
  local px, py = -uy, ux
  c:line({ {ax, ay}, {bx, by} }, 1):each(function(x, y) c:px(x, y, STEM[2]) end)
  for i, t in ipairs{ 0.35, 0.65, 0.9 } do
    local r = s * (1.15 - 0.25 * i)
    for _, sd in ipairs{ -1, 1 } do
      local cx, cy = ax + dx * t + px * sd * (r + 1), ay + dy * t + py * sd * (r + 1)
      local m = c:ellipse(cx, cy, r, r * 0.7)
      G.toneN(c, m, X.pillow(m, r), LEAF, {})
    end
  end
  local tip = c:ellipse(bx + ux, by + uy, s * 0.5, s * 0.5)
  G.toneN(c, tip, X.pillow(tip, 2), LEAF, {})
end
pin(33, 30, 51, 24, 3.4)
pin(29, 36, 11, 31, 3.4)
pin(33, 21, 36, 9, 3.0)
-- pale second bud quirk
c:px(44, 46, "#f4ecc8") c:px(45, 45, "#f4ecc8") c:px(44, 45, "#c9d890") c:px(45, 44, "#c9d890")
c:sparkle(14, 18)
G.save(c, "stage-tuber-1")
