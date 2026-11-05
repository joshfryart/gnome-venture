-- sun-dried-tomatoes (lean P1b_O15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local H = X.hash
local NAME = "sun-dried-tomatoes"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local RED = { "#2f0d1f", "#5a1428", "#8a1f2a", "#b2332f", "#d4553a", "#ee8450" }
local TW = { "#7a5a34", "#c9a56a", "#e8cf92" }
local WD = { "#6a4a2c", "#9a6b3c", "#c99555", "#e8c98a" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650" }
local function ly(x) local u = (x - 32) / 27 return floor(10 + 5 * (1 - u * u) + 0.5) end
-- twine
for x = 5, 59 do local y = ly(x) c:put(x, y, (x % 4 < 2) and TW[2] or TW[1]) c:put(x, y - 1, (x % 4 < 2) and TW[3] or TW[2]) end
local function tomato(cx, yTop, h, rx, seed)
  local y1 = yTop + h
  local m = HP.mask()
  for y = yTop, y1 do
    local t = (y - yTop) / h
    local w = rx * sin(pi * min(1, t ^ 0.75)) ^ 0.55 * (1 - 0.18 * t) + 0.9 * sin(y * 1.7 + seed)
    w = max(0.8, w)
    for x = floor(cx - w + 0.5), floor(cx + w - 0.5) do m:set(x, y) end
  end
  local n = X.pillow(m, rx * 1.1)
  local bias = {}
  m:each(function(x, y)
    local wr = sin(y * 1.15 + (x - cx) ^ 2 * 0.045 + seed)
    if wr > 0.78 then bias[K(x, y)] = -1 end
    if wr < -0.95 then bias[K(x, y)] = 1 end
  end)
  local _, v = G.toneN(c, m, n, RED, { amb = 0.08, wrap = 0.25, bias = bias })
  local inner = m:copy():shrink(1)
  inner:each(function(x, y) if v[K(x, y)] > 0.5 and H(x, y, seed) > 0.92 then c:px(x, y, "#f6e9d8") end end)
  local sx, sy = G.specAt(m, n, 25)
  c:put(sx, sy, RED[6]) c:put(sx + 1, sy, "#f6c9a0")
  -- hanging string + stem cap
  for y = ly(cx) + 1, yTop do c:put(cx, y, TW[2]) end
  c:fillMask(c:rect(cx - 1, yTop, cx + 1, yTop + 1), LEAF[2]) c:put(cx - 1, yTop, LEAF[4])
  return m
end
tomato(16, 17, 28, 7.5, 1)
tomato(32, 19, 31, 8.2, 3)
tomato(48, 17, 24, 7, 5)
-- quirk: wooden clothespin on the middle one
c:fillMask(c:rect(30, 13, 34, 22), WD[2])
c:fillMask(c:rect(30, 13, 31, 22), WD[3])
c:fillMask(c:rect(34, 13, 34, 22), WD[1])
for y = 17, 22 do c:put(32, y, WD[1]) end
c:put(32, 16, "#8a8a9a") c:put(31, 13, WD[4]) c:put(30, 14, WD[4])
G.save(c, NAME)
