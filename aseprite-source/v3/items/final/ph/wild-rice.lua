-- wild-rice (lean P1b_O21)
local NAME = "wild-rice"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local LEAF = { "#1b3a30", "#275736", "#3a7a3e", "#58994a", "#82b85c", "#b4d57c" }
local ST   = { "#3d5a2a", "#5f8236", "#8ca64a", "#bccb70" }
local STR  = { "#4a2c26", "#7a4a30", "#a8743c", "#d2a456", "#efd080" }
local WAT  = { "#35557f", "#5688b4", "#92c4d8", "#d8f0ee" }
-- water pool with ripples
local w1 = c:ellipse(32, 54, 22, 3.5)
w1:each(function(x, y) local d = ((x - 32) / 22)^2 + ((y - 54) / 3.5)^2
  c:put(x, y, d > 0.7 and WAT[1] or (d > 0.3 and WAT[2] or WAT[3])) end)
for x = 20, 26 do c:put(x, 54, WAT[4]) end
for x = 38, 43 do c:put(x, 55, WAT[4]) end
-- leaves
local function leaf(ax, ay, cx, cy, bx, by, wm)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.995 then return -1 end return max(0.35, wm * sin(pi * t ^ 0.65) ^ 0.8) end)
  G.toneN(c, m, n, LEAF, { amb = 0.1, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end end)
end
leaf(30, 52, 12, 38, 5, 50, 3.0)
leaf(34, 52, 52, 36, 59, 49, 3.0)
leaf(31, 52, 22, 36, 18, 30, 2.4)
leaf(33, 52, 44, 38, 47, 33, 2.4)
-- stems
local function stem(p, w0, w1)
  local m, n = G.tube(p, function(t) return w0 + (w1 - w0) * t end)
  G.toneN(c, m, n, { ST[1], ST[1], ST[2], ST[3], ST[4], ST[4] }, { amb = 0.1, wrap = 0.3 })
  return m
end
stem({ { 32, 52 }, { 32, 40 }, { 32, 26 }, { 33, 14 } }, 1.6, 0.9)
stem({ { 30, 52 }, { 25, 42 }, { 20, 32 }, { 18, 25 } }, 1.4, 0.8)
stem({ { 34, 52 }, { 40, 44 }, { 45, 36 }, { 46, 29 } }, 1.4, 0.8)
-- leaf collars at nodes
for _, p in ipairs{ { 32, 34 }, { 32, 28 }, { 24, 38 }, { 42, 40 } } do c:put(p[1] - 1, p[2], ST[1]) c:put(p[1], p[2], ST[2]) c:put(p[1] + 1, p[2], ST[1]) c:put(p[1], p[2] + 1, ST[1]) end
-- panicle: drooping branches hung with grains
local function grain(x, y, awn)
  c:put(x, y, STR[2]) c:put(x, y + 1, STR[1]) c:put(x - 1, y, STR[4]) 
  if awn then c:put(x, y + 2, STR[4]) c:put(x, y + 3, STR[5]) end
end
local function branch(p, step, awn)
  local N = 40
  local last = nil
  for i = 0, N do
    local x, y = G.bez(p, i / N)
    local px, py = floor(x + 0.5), floor(y + 0.5)
    c:put(px, py, STR[3])
    if i > 3 and i % step == 0 then grain(px, py + 1, awn) end
  end
end
branch({ { 33, 13 }, { 27, 7 }, { 22, 9 }, { 21, 18 } }, 5, true)
branch({ { 33, 13 }, { 39, 7 }, { 44, 9 }, { 45, 17 } }, 5, true)
branch({ { 33, 13 }, { 31, 6 }, { 33, 4 }, { 34, 9 } }, 4, true)
branch({ { 33, 13 }, { 28, 12 }, { 26, 15 }, { 27, 22 } }, 5, false)
branch({ { 33, 13 }, { 38, 12 }, { 40, 15 }, { 39, 21 } }, 5, false)
branch({ { 18, 25 }, { 14, 22 }, { 12, 26 }, { 13, 32 } }, 5, true)
branch({ { 46, 29 }, { 50, 26 }, { 53, 29 }, { 52, 36 } }, 5, true)
-- quirk: a damselfly perched on the left stalk
local B = { "#1f5aa8", "#3a8ad8", "#8ad0f0" }
for x = 15, 19 do c:put(x, 21, B[x % 2 == 0 and 2 or 1]) end
c:put(20, 21, B[3]) c:put(16, 19, "#dff2f0") c:put(17, 19, "#dff2f0") c:put(17, 20, "#b8dff0") c:put(16, 20, "#b8dff0")
c:put(14, 21, B[1])
G.save(c, NAME)
