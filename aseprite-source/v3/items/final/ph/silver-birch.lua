-- silver-birch (lean P1b_O9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local NAME = "silver-birch"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local BARK = { "#6d6c92", "#9a9bbb", "#c5c7d9", "#e4e5ee", "#f6f4ef", "#fffdf4" }
local LEAF = { "#2f5a2e", "#47792f", "#69993a", "#8fb843", "#b9d452", "#e2ea7c" }
local MARK = { "#2e2230", "#4a3a4a" }
c:groundShadow(32, 56, 11, 2)
-- drooping branches first (behind trunk)
local function branch(p, lv)
  local m, n = G.tube(p, function(t) return 1.1 - 0.5 * t end)
  G.toneN(c, m, n, BARK)
  for _, L in ipairs(lv) do
    local lm, ln = G.oval(L[1], L[2], 2.4, 3.3, L[3], 0.9)
    G.toneN(c, lm, ln, LEAF, { amb = 0.1 })
    c:px(L[1], L[2], LEAF[2])
  end
end
branch({ {31, 24}, {24, 16}, {14, 18}, {10, 28} }, { {18, 17, 1.2}, {12, 21, 0.5}, {10, 27, 0.1}, {22, 14, 0.3}, {14, 14, 1.0}, {9, 33, 0.0} })
branch({ {33, 22}, {42, 12}, {52, 16}, {54, 26} }, { {44, 13, 0.6}, {51, 17, 1.4}, {54, 24, 0.1}, {48, 10, 0.3}, {55, 30, 0.0}, {38, 16, 1.0} })
branch({ {32, 16}, {30, 9}, {36, 6}, {38, 11} }, { {30, 7, 0.4}, {36, 5, 0.9}, {38, 10, 0.1}, {33, 9, 0.5}, {27, 12, 1.0} })
-- trunk
local tm, tn, T, S = G.tube({ {30, 54}, {31, 40}, {33, 28}, {32, 14} }, function(t) return 3.6 - 1.4 * t end)
G.toneN(c, tm, tn, BARK, { amb = 0.1, wrap = 0.2 })
-- black chevron lenticels
tm:each(function(x, y)
  local k = K(x, y)
  local row = (y + floor(x * 0.5)) % 6
  if row == 0 and abs(S[k]) < 0.8 and T[k] < 0.9 and X.hash(floor(x / 2), floor(y / 6), 5) > 0.35 then
    c:px(x, y, S[k] > 0.2 and MARK[1] or MARK[2])
  end
end)
-- root flare + basal dark band
for _, p in ipairs{ {26, 55}, {27, 55}, {37, 55}, {36, 55}, {25, 56}, {38, 56} } do c:px(p[1], p[2], BARK[2]) end
tm:each(function(x, y) if y >= 52 then c:px(x, y, S[K(x, y)] > 0 and MARK[2] or BARK[1]) end end)
-- quirk: peeling bark curl
local pm, pn = G.tube({ {33, 33}, {39, 32}, {41, 36}, {37, 38} }, function(t) return 1.5 - 0.5 * t end)
G.toneN(c, pm, pn, { "#8a6b52", "#b48a5c", "#d9b080", "#f0d4a4", "#fbe9c4", "#fff6dc" }, { amb = 0.1 })
c:px(34, 33, "#fff6dc") c:px(35, 33, "#fff6dc")
c:px(30, 24, BARK[6]) c:px(30, 25, BARK[6])
G.save(c, NAME)
