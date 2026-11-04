-- snake-skin (lean D2o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, bias, o) local n = X.pillow(m, R) local v = X.light(n, o or { amb = 0.1, wrap = 0.25 }) local k = #ramp - 1 local cuts = {} for i = 1, k do cuts[i] = 0.12 + 0.76 * (i - 1) / max(1, k - 1) end if bias then for k, b in pairs(bias) do bias[k] = floor(b + 0.5) end end G.tone(c, m, v, ramp, cuts, bias) return n, v end
local function tube(c, p, wf, ramp, o) local m, n, T, S = G.tube(p, wf) G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp) return m, n, T, S end
local function disc(c, x, y, r, hex) c:fillMask(c:ellipse(x, y, r, r), hex) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "snake-skin" }
local SK = { "#4a6a5a", "#7a9a7e", "#a8c49a", "#cfe0b4", "#ecf3cc", "#fbfbe6" }
local DM = "#5a7a60"
local function seg(p, wf, off)
  local m, n, T, S = G.tube(p, wf)
  local v = X.light(n, { amb = 0.16, wrap = 0.35 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local ph = (T[k] * 70 / 4.2 + S[k] * 0.9 + off) % 1
    if ph < 0.2 then bias[k] = -1.4 elseif ph > 0.55 and ph < 0.7 then bias[k] = 0.5 end
  end)
  for k, b in pairs(bias) do bias[k] = floor(b + 0.5) end
  G.tone(c, m, v, SK, nil, bias)
  return m, T, S
end
c:groundShadow(32, 56, 22, 2)
local a, Ta = seg({ {17,19}, {28,5}, {52,13}, {47,28} }, function(t) return 3.4 + 0.5 * (1 - t) end, 0)
local b, Tb = seg({ {47,28}, {42,42}, {16,36}, {18,50} }, function(t) return 3.9 - 1.0 * t end, 0.3)
local b2, Tb2 = seg({ {18,50}, {19,56}, {30,55}, {44,57} }, function(t) return 2.9 - 2.1 * t end, 0.6)
-- head: empty hood with hollow eye sockets
local head = c:ellipse(14, 22, 6, 5):add(c:ellipse(11, 24, 4, 3))
shade(c, head, SK, 5)
c:px(13, 20, SK[1]) c:px(14, 20, SK[1]) c:px(14, 21, SK[1])
c:px(10, 22, SK[1]) c:px(9, 22, SK[1])
for x = 7, 9 do c:px(x, 25, SK[1]) end
c:px(17, 25, SK[6]) c:px(16, 20, SK[6])
-- spec streaks on coils
G.line(c, { {30,6}, {38,6} }, SK[6]) G.line(c, { {22,36}, {30,36} }, SK[6])
G.fin(c, "snake-skin")
