-- snake-fang (lean D2o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, bias, o) local n = X.pillow(m, R) local v = X.light(n, o or { amb = 0.1, wrap = 0.25 }) local k = #ramp - 1 local cuts = {} for i = 1, k do cuts[i] = 0.12 + 0.76 * (i - 1) / max(1, k - 1) end if bias then for k, b in pairs(bias) do bias[k] = floor(b + 0.5) end end G.tone(c, m, v, ramp, cuts, bias) return n, v end
local function tube(c, p, wf, ramp, o) local m, n, T, S = G.tube(p, wf) G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp) return m, n, T, S end
local function disc(c, x, y, r, hex) c:fillMask(c:ellipse(x, y, r, r), hex) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "snake-fang" }
local IV = { "#6b5a63", "#9c8a8a", "#c9b8a4", "#e8dcc6", "#f8f0dc", "#fffaf0" }
local GM = { "#5a2a3a", "#8a3d4c", "#b85868", "#e0808c" }
local VN = { "#1f5a3a", "#3f9a3c", "#86d94a", "#d6ff8a" }
-- long curved fang
local m, n, T, S = tube(c, { {20,12}, {14,28}, {28,40}, {44,50} }, function(t) return 5.2 * (1 - t) ^ 0.8 + 0.5 end, IV)
-- growth rings
m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
  if t > 0.12 and abs(s) < 0.98 and (floor(t * 22) % 5 == 0) and s > 0.1 then c:px(x, y, IV[3]) end
  -- venom channel groove (inner curve side)
  if t > 0.3 and t < 0.93 and s > 0.38 and s < 0.62 then c:px(x, y, VN[2]) end
  if t > 0.3 and t < 0.9 and s > 0.38 and s < 0.5 then c:px(x, y, VN[3]) end
  if t > 0.93 and s > -0.2 and s < 0.4 and t < 0.99 then c:px(x, y, IV[1]) end
end)
-- gum root cap
local cap = c:ellipse(20, 11, 8, 3):add(c:ellipse(19, 9, 5, 2))
shade(c, cap, GM, 4)
c:px(17, 9, GM[4]) c:px(18, 9, GM[4])
c:px(24, 11, GM[1]) c:px(14, 12, GM[1])
-- dripping venom (quirk)
disc(c, 45, 55, 2, VN[2]) c:px(45, 53, VN[2]) c:px(44, 55, VN[3]) c:px(44, 54, VN[4])
c:px(46, 56, VN[1])
-- spec on the bend
c:px(17, 24, IV[6]) c:px(17, 25, IV[6]) c:px(18, 22, IV[5])
G.fin(c, "snake-fang")
