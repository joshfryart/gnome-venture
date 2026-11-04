-- stage-herb-2 (lean D2o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "stage-herb-2"
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
-- young herb: one upright stem, five veined leaves alternating left and right; pink bud at the crown (quirk)
mound()
stem({ {32,51},{31,40},{33,24},{32,13} }, 1.3, { "#3b6449","#5b8d5a","#88b46e","#b9d793" })
local L = { {44, -1, 9.5}, {38, 1, 9}, {32, -1, 8}, {26, 1, 7}, {20, -1, 5.5} }
local sx = { [44]=31.5, [38]=32, [32]=32.5, [26]=33, [20]=32.5 }
for _, l in ipairs(L) do
  local y, s, ra = l[1], l[2], l[3]
  local ux, uy = s * 0.88, -0.48
  local ln = sqrt(ux*ux + uy*uy) ux, uy = ux / ln, uy / ln
  oval(sx[y] + ux * ra, y + uy * ra, ux, uy, ra, ra * 0.42, y % 12 == 2 and { "#1f4a3c","#2c6a48","#3f8f50","#62b45a","#8cd070","#bfe68a" } or LEAF, true)
end
oval(32, 10, 0, -1, 3.2, 2.2, { "#7a2850","#a8406a","#d0608a","#e888a8","#f6aac0","#fcd0dc" })
c:px(32, 8, "#fcd0dc") c:px(31, 12, "#32764b") c:px(33, 12, "#32764b")
G.fin(c, NAME)
