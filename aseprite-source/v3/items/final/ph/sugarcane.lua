-- sugarcane (lean D2o_16)
local NAME = "sugarcane"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function blob(m, ramp, R, o, cuts, bias)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, cuts, bias)
  return v, n
end
local function lines(pts, hex) G.line(c, pts, hex) end
local function hits(m, fn) m:each(fn) end

-- sugarcane: slim diagonal jointed stalk, banded nodes with purple blush, fan of sword leaves; quirk: fresh-cut pale end with ring
local CANE = { "#3e3d1e", "#6b6a2a", "#9a9438", "#c4be52", "#e4dc76", "#fbf4a6" }
local BLUSH = { "#3a1d3a", "#5c2a52", "#7f3d6a", "#a85a80" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local c0 = { { 14, 54 }, { 24, 42 }, { 33, 30 }, { 42, 18 } }
-- leaves first (behind)
local blades = {
  { { 42, 18 }, { 40, 10 }, { 30, 8 }, { 20, 9 } },
  { { 42, 18 }, { 46, 6 }, { 54, 4 }, { 58, 12 } },
  { { 42, 18 }, { 50, 12 }, { 56, 18 }, { 58, 28 } },
  { { 42, 18 }, { 36, 12 }, { 34, 8 }, { 38, 6 } },
}
for i, b in ipairs(blades) do
  local m, n, T, S = G.tube(b, function(t) return 0.5 + 2.6 * sin(pi * min(1, t * 1.15)) ^ 0.8 * (1 - 0.5 * t) end)
  blob(m, LEAF, 2, { amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local s = S[K(x, y)] if abs(s) < 0.22 and T[K(x, y)] > 0.1 and T[K(x, y)] < 0.92 then c:px(x, y, s < 0 and LEAF[6] or LEAF[4]) end end)
end
local m, n, T, S = G.tube(c0, function(t) return 3.6 end)
local bias = {}
local v = X.light(n, { amb = 0.08, wrap = 0.2 })
G.tone(c, m, v, CANE, { 0.2, 0.38, 0.55, 0.72, 0.87 })
m:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  for _, nt in ipairs{ 0.22, 0.42, 0.62, 0.82 } do
    local d = (t - nt) * 52
    if d > -1.2 and d < 0.2 then c:px(x, y, d < -0.6 and BLUSH[2] or BLUSH[1])
    elseif d >= 0.2 and d < 1.6 then c:px(x, y, s > 0.3 and CANE[2] or CANE[5]) end
    if d > -3.4 and d < -1.2 and X.hash(x, y, 7) > 0.35 then c:px(x, y, s > 0.2 and BLUSH[2] or BLUSH[3]) end
  end
  if abs(s - 0.1) < 0.1 and X.hash(x, y, 3) > 0.5 then c:px(x, y, CANE[6]) end
end)
-- fresh-cut base: pale oval end with ring
local cap = c:ellipse(14, 54, 3.4, 3.4)
c:fillMask(cap, "#f4e6b8") c:fillMask(c:ellipse(14, 54, 1.8, 1.8), "#d8c38a") c:px(14, 54, "#a8925c") c:px(13, 53, "#fffaf0")
-- sprout buds at nodes
c:px(28, 40, LEAF[4]) c:px(29, 39, LEAF[5]) c:px(19, 49, LEAF[3])

G.fin(c, NAME)
