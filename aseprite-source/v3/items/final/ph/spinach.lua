-- spinach (lean D2o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spinach" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  local idx = G.tone(c, m, v, ramp)
  return v, idx, n
end
local LEAF = { "#17361f", "#1f5328", "#2c7a31", "#43a038", "#6fc24a", "#a0dc6c" }
local PINK = { "#5a1c33", "#8a2e4a", "#b8405c", "#dc6a7e", "#f09aa6" }
local function leaf(p, wm, bite)
  local len = 36
  local m, n, T, S = G.tube(p, function(t)
    if t < 0.28 then return 1.0 end
    local u = (t - 0.28) / 0.72
    return max(0.9, wm * sin(pi * u ^ 0.75) ^ 0.7 + 0.5 * sin(t * len * 1.3))
  end)
  if bite then m:cut(c:ellipse(bite[1], bite[2], 2, 2)) end
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  G.tone(c, m, v, LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 })
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if t < 0.3 then c:px(x, y, t < 0.1 and PINK[3] or (s <= 0 and "#cfe090" or "#8fb860"))
    elseif abs(s) < 0.17 and t < 0.93 then c:px(x, y, s <= 0 and LEAF[6] or LEAF[3]) end
    if t > 0.38 then for _, vt in ipairs{ 0.5, 0.62, 0.74, 0.85 } do
      local d = (t - vt) * len - abs(s) * 2.2
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.8 then c:px(x, y, s < 0 and LEAF[5] or LEAF[2]) end
    end end
  end)
end
leaf({ {30,50}, {22,43}, {13,35}, {11,20} }, 6.2)
leaf({ {34,50}, {42,43}, {51,37}, {54,23} }, 6.2, { 53, 28 })
leaf({ {32,50}, {31,36}, {30,22}, {32,7} }, 7.2)
-- crown
local crown = c:ellipse(32, 52, 4, 3)
shade(crown, PINK, 3)
c:fillMask(c:line({ {32,55}, {32,58} }, 1), PINK[2])
c:px(31, 51, PINK[5])
G.fin(c, "spinach")
