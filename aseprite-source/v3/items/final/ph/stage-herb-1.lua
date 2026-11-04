-- stage-herb-1 (lean D2o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "stage-herb-1"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local SOIL = { "#2e1a1f", "#4a2a26", "#6b3d2e", "#8a5537", "#ab7243", "#cc935a" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a3d070" }
local LIGHT = { amb = 0.1, wrap = 0.25 }
local function R(v) return floor(v + 0.5) end
local function mound()
  local m = c:ellipse(32, 51, 22, 6)
  local n = X.pillow(m, 7)
  G.tone(c, m, X.light(n, { amb = 0.18, wrap = 0.3 }), SOIL)
  m:each(function(x, y)
    local h = X.hash(x, y, 7)
    if h > 0.93 then c:px(x, y, SOIL[5]) elseif h < 0.07 then c:px(x, y, SOIL[2]) end
  end)
  for x = 14, 50, 4 do local y = 53 + R(sin(x * 0.7)) if m:has(x, y) then c:px(x, y, SOIL[2]) c:px(x + 1, y, SOIL[2]) end end
  return m
end
local function stem(p, w, ramp)
  local m, n, T, S = G.tube(p, function() return w end)
  G.tone(c, m, X.light(n, LIGHT), ramp or LEAF)
  return m
end
local function blade(p, wmax, ramp, rib)
  ramp = ramp or LEAF
  local m, n, T, S = G.tube(p, function(t) return wmax * (1 - t ^ 1.6) ^ 0.8 * (0.5 + 0.5 * min(1, t * 4)) end)
  G.tone(c, m, X.light(n, LIGHT), ramp)
  if rib ~= false then m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.15 and T[k] < 0.92 then c:px(x, y, S[k] <= 0 and ramp[6] or ramp[3]) end end) end
  return m
end
local function oval(cx, cy, ux, uy, ra, rb, ramp, veins)
  local m = G.rell(cx, cy, ux, uy, ra, rb)
  local n = X.pillow(m, rb + 0.6)
  G.tone(c, m, X.light(n, LIGHT), ramp)
  if veins then
    for a = -ra + 1, ra - 1.5, 0.5 do c:px(R(cx + ux * a), R(cy + uy * a), ramp[6]) end
    for a = -ra + 2.5, ra - 2.5, 2.2 do for _, s in ipairs{ -1, 1 } do
      local b = (rb - 0.9) * (1 - abs(a) / ra)
      c:px(R(cx + ux * (a + 0.8) - uy * s * b * 0.5), R(cy + uy * (a + 0.8) + ux * s * b * 0.5), s < 0 and ramp[5] or ramp[2])
    end end
  end
  return m
end
-- herb seedling: pale stem, two fat round seed leaves, a tiny true-leaf pair on top; seed husk cap on a leaf (quirk)
mound()
local CO = { "#235a3a","#2f7c44","#45a050","#68c260","#92dc74","#c4f098" }
stem({ {32,51},{31,42},{33,32},{32,22} }, 1.2, { "#4a8a4a","#70b060","#9cd080","#c8ec9c" })
oval(21, 38, -0.96, 0.28, 8, 5.4, CO, true)
oval(43, 36, 0.96, 0.28, 8, 5.4, CO, true)
oval(27, 21, -0.7, -0.7, 4.6, 2.9, LEAF, true)
oval(37, 21, 0.7, -0.7, 4.6, 2.9, LEAF, true)
c:fillMask(c:ellipse(32, 18, 1.5, 1.7), "#a3d070") c:px(31, 17, "#d4f4a0")
-- husk cap
local hk = c:ellipse(15, 33, 3.2, 2.2)
G.tone(c, hk, X.light(X.pillow(hk, 3), LIGHT), { "#5a3a1c","#7a5628","#a07c3c","#c8a458","#e2c880","#f2e4a8" })
c:px(14, 33, "#5a3a1c") c:px(16, 34, "#5a3a1c")
G.fin(c, NAME)
