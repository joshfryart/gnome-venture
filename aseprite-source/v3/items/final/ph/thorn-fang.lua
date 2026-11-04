-- thorn-fang (lean D3o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function clampi(i, a, b) if not b then a, b = 1, a end return max(a, min(b, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "thorn-fang" }
local FANG = { "#3a2018", "#6a3a1e", "#9a5a28", "#c8863a", "#e8b45c", "#fff0a8" }
local BARK = { "#2a2018", "#4a3426", "#6e4e34", "#8f6a46", "#b08a5c" }
local CORD = { "#5a3a22", "#8a5a34", "#b88650", "#d9ad74" }
local MOSS = { "#2f5a3a", "#437a45", "#5f9a4e", "#88b95e" }
c:groundShadow(40, 58, 8, 1)
-- cord loop
local ring = c:ellipse(27, 9, 6, 4):cut(c:ellipse(27, 9, 4, 2))
ring:each(function(x, y) c:px(x, y, CORD[((x + y) % 2 == 0) and 3 or 2]) end)
for x = 24, 30 do c:px(x, 5, CORD[4]) end
-- fang
local P = { {27,17}, {42,17}, {49,36}, {39,56} }
local m, n, T, S = G.tube(P, function(t) return 6.2 * (1 - t) ^ 0.65 + 0.35 end)
local idx = G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), FANG, { 0.2, 0.36, 0.52, 0.7, 0.88 })
m:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  if abs(s + 0.4) < 0.12 and t > 0.12 and t < 0.85 then c:px(x, y, FANG[6]) end
  for _, rt in ipairs{ 0.24, 0.4, 0.56 } do
    if abs(t - rt) < 0.018 and s > -0.8 then c:px(x, y, FANG[clampi((idx[k] or 3) - 1, 6)]) end
  end
  if t > 0.88 then c:px(x, y, FANG[clampi((idx[k] or 3) + 1, 6)]) end
end)
-- bark collar
local col = c:rrect(23, 10, 31, 24, 2)
local cn = X.pillow(col, 5)
G.tone(c, col, X.light(cn, { amb = 0.15, wrap = 0.3 }), BARK, { 0.2, 0.4, 0.6, 0.8 })
col:each(function(x, y) if x % 3 == 1 and X.hash(x, y, 5) > 0.35 then c:px(x, y, BARK[1]) end end)
c:px(24, 12, BARK[5]) c:px(24, 13, BARK[5])
-- cord passes through a hole in the collar
c:px(26, 13, BARK[1]) c:px(27, 13, BARK[1]) c:px(27, 12, CORD[3])
-- quirk: moss tuft and a leaf-bud on the collar
for _, p in ipairs{ {24,22,3}, {25,22,2}, {26,23,3}, {29,23,2}, {25,23,1}, {23,21,4}, {30,22,3} } do c:px(p[1], p[2], MOSS[p[3]]) end
c:px(22, 20, MOSS[3]) c:px(21, 19, MOSS[4])
G.fin(c, "thorn-fang")
