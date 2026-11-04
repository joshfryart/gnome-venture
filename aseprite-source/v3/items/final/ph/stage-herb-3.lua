-- stage-herb-3 (lean D2o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "stage-herb-3"
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
-- blooming herb: fan of five stems tipped with lavender flower spikes, lance leaves low down; a bee visits (quirk)
mound()
local LAV = { "#4a2a78","#6a42a0","#8a60c0","#a884d8","#c8a8ec","#e6d2f8" }
blade({ {30,51},{20,46},{14,40},{9,32} }, 2.8)
blade({ {35,51},{46,47},{52,42},{57,35} }, 2.6, { "#22403a","#2f6046","#3f8450","#5fa85a","#86c568","#b4de80" })
blade({ {31,51},{27,42},{22,36},{18,30} }, 2.4, { "#2b5a3e","#3c7c4a","#55a055","#7cc062","#a3d878","#cdee98" })
local STM = { "#3b6449","#5b8d5a","#88b46e","#b9d793" }
local T = { {{32,51},{27,38},{19,28},{15,20}}, {{32,51},{29,36},{26,24},{24,13}}, {{32,51},{32,36},{32,24},{32,10}},
            {{32,51},{35,36},{39,24},{41,14}}, {{32,51},{37,38},{46,29},{51,21}} }
for i, p in ipairs(T) do
  stem(p, 0.9, STM)
  for k = 0, 5 do
    local t = 0.72 + k * 0.055
    local x, y = G.bez(p, t)
    for _, s in ipairs{ -1, 1 } do
      if (k + (s > 0 and 1 or 0)) % 2 == 0 or k == 5 then
        local fx = x + s * 1.6 * (1 - k * 0.12)
        local fm = c:ellipse(R(fx), R(y), 1.7, 1.5)
        G.tone(c, fm, X.light(X.pillow(fm, 2), LIGHT), LAV)
      end
    end
  end
  local x, y = G.bez(p, 1.0)
  c:fillMask(c:ellipse(R(x), R(y), 1.2, 1.4), LAV[4]) c:px(R(x), R(y) - 1, LAV[6])
end
for i, p in ipairs(T) do
  local x, y = G.bez(p, 0.45)
  oval(x - 3 * (i < 3 and 1 or -1) * (i == 3 and 0 or 1) + (i == 3 and -3 or 0), y + 1, i < 3 and -0.9 or 0.9, -0.4, 4, 1.6, LEAF)
end
-- bee
c:fillMask(c:ellipse(47, 30, 2.4, 1.6), "#f4c430") c:px(46, 30, "#2b1c26") c:px(48, 30, "#2b1c26") c:px(45, 29, "#fbe27a")
c:px(46, 28, "#dff2f8") c:px(47, 28, "#dff2f8") c:px(48, 28, "#c0e0ee")
G.fin(c, NAME)
