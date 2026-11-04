-- stage-grain-4 (lean D2o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "stage-grain-4"
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
-- ripe wheat: three golden ears nodding on arching stalks; one touches the soil with a fallen kernel (quirk)
mound()
local GOLD = { "#6a3a14","#9a5a1c","#c98a26","#e8b038","#f6cf5a","#fde88c" }
local AWN = "#e8c060"
blade({ {34,51},{36,40},{44,32},{54,30} }, 2.4)
local function ear(cx, cy, ux, uy, ra, rb)
  local tx, ty = cx - ux * ra, cy - uy * ra
  local ex, ey = cx + ux * ra, cy + uy * ra
  for _, s in ipairs{ -2, 0, 2 } do G.line(c, { {R(ex), R(ey)}, {R(ex + s * 1.5 + ux * 3), R(ey + 1 + uy * 2)} }, AWN) end
  oval(cx, cy, ux, uy, ra, rb, GOLD)
  for a = -ra + 1.2, ra - 1, 2.0 do
    for _, s in ipairs{ -1, 1 } do c:px(R(cx + ux * a - uy * s * rb * 0.55), R(cy + uy * a + ux * s * rb * 0.55), GOLD[2]) end
    c:px(R(cx + ux * a + uy * rb * 0.2), R(cy + uy * a - ux * rb * 0.2), GOLD[6])
  end
end
local ST = { "#7a5a24","#a07a30","#c8a448","#e6cc70" }
stem({ {22,51},{20,32},{26,16},{36,14} }, 1.0, ST)
stem({ {32,51},{33,34},{40,26},{48,27} }, 1.0, ST)
stem({ {27,51},{22,40},{14,33},{11,37} }, 1.0, ST)
ear(40, 20, 0.35, 0.94, 7.5, 3.4)
ear(50, 34, 0.2, 0.98, 7.5, 3.4)
ear(11.5, 44, -0.1, 1, 7, 3.2)
-- fallen kernel
c:fillMask(c:ellipse(18, 51, 1.6, 1.0), GOLD[4]) c:px(17, 51, GOLD[6]) c:px(19, 51, GOLD[2])
G.fin(c, NAME)
