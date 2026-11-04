-- stage-grain-3 (lean D2o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "stage-grain-3"
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
-- green wheat: four stalks with plump green ears, long awns; ladybug on a stalk (quirk)
mound()
local EAR = { "#4a5a24","#6e8a2c","#93b038","#b4cc4a","#d0e068","#eaf08c" }
local AWN = "#c6dc7a"
local function ear(cx, cy, ux, uy, ra, rb)
  for _, s in ipairs{ -1.4, 0, 1.4 } do
    local tx, ty = cx + ux * ra, cy + uy * ra
    G.line(c, { {R(tx), R(ty)}, {R(tx + s * 2.4 + ux * 5), R(ty + uy * 6 - 0.0)} }, AWN)
  end
  oval(cx, cy, ux, uy, ra, rb, EAR)
  for a = -ra + 1.2, ra - 1, 2.3 do
    for _, s in ipairs{ -1, 1 } do c:px(R(cx + ux * a - uy * s * rb * 0.55), R(cy + uy * a + ux * s * rb * 0.55), EAR[2]) end
  end
end
local S = { {21,24,-0.12,-1}, {28,18,0.04,-1}, {37,21,0.12,-1}, {46,29,0.2,-0.98} }
local bx = { 19, 26, 36, 44 }
for i, e in ipairs(S) do
  stem({ {bx[i],51},{bx[i]+(e[1]-bx[i])*0.2,40},{e[1],34},{e[1]+e[3]*5,e[2]+5} }, 0.9, { "#3b6a3a","#59903f","#86b650","#b6d870" })
end
blade({ {26,51},{18,44},{13,38},{10,30} }, 3.0)
blade({ {38,51},{46,46},{52,42},{56,35} }, 2.8, { "#22403a","#2f6046","#3f8450","#5fa85a","#86c568","#b4de80" })
for i, e in ipairs(S) do ear(e[1], e[2], e[3], e[4], 6.2, 2.9) end
-- ladybug on the second stalk
c:fillMask(c:ellipse(27, 38, 1.8, 1.4), "#d83a3a") c:px(26, 38, "#7a1830") c:px(28, 39, "#7a1830") c:px(26, 37, "#ff8a7a") c:px(29, 38, "#2b1c26")
G.fin(c, NAME)
