-- stage-vegetable-4 (lean D2o_12)
-- Ripe cabbage stage: round folded head on a soil mound, two flared outer leaves, ladybird quirk.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local sin, cos, pi, abs, floor, max, min, sqrt, atan2 = math.sin, math.cos, math.pi, math.abs, math.floor, math.max, math.min, math.sqrt, math.atan
local function solid(c, m, ramp, R, amb) local n = X.pillow(m, R) local idx = G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp) return n, idx end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-vegetable-4" }
local SOIL = { "#2e1c1a", "#4a2c24", "#6b4230", "#8d5d3e", "#b07f55" }
local CAB  = { "#1f4a45", "#2f6b52", "#4f9460", "#7cb56e", "#a9d083", "#d3e8a0" }
local LF   = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 54, 22, 3)
local soil = c:ellipse(32, 50, 21, 6)
solid(c, soil, SOIL, 6)
soil:each(function(x, y) local h = X.hash(x, y, 3) if h > 0.9 then c:px(x, y, SOIL[5]) elseif h < 0.07 then c:px(x, y, SOIL[1]) end end)
local function leaf(p, w)
  local m, n = G.tube(p, function(t) return 0.8 + w * sin(pi * t) ^ 0.7 end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), LF)
  for i = 4, 36 do local x, y = G.bez(p, i / 40) c:px(floor(x + 0.5), floor(y + 0.5), LF[6]) end
  return m
end
leaf({ {32, 24}, {29, 15}, {34, 9}, {42, 10} }, 2.6)
leaf({ {24, 48}, {5, 47}, {3, 29}, {14, 18} }, 5)
leaf({ {40, 48}, {59, 47}, {61, 31}, {51, 20} }, 5)
local head = c:ellipse(32, 34, 14, 13)
local n, idx = solid(c, head, CAB, 12)
local function fold(k)
  local pts = { {32 + k * 0.15, 22}, {32 + k * 0.6, 27}, {32 + k * 0.95, 34}, {32 + k * 0.75, 43} }
  G.line(c, pts, CAB[1])
  local q = {} for i, p in ipairs(pts) do q[i] = { p[1] + 1, p[2] } end
  G.line(c, q, CAB[5])
end
fold(-9) fold(-3) fold(4) fold(10)
c:px(25, 27, CAB[6]) c:px(26, 27, CAB[6]) c:px(25, 28, CAB[6]) c:px(27, 26, CAB[6])
-- quirk: ladybird
c:fillMask(c:rect(38, 30, 40, 31), "#d6403a") c:px(39, 30, "#2b1c26") c:px(37, 31, "#2b1c26") c:px(38, 29, "#2b1c26")
G.fin(c, "stage-vegetable-4")
