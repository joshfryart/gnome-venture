-- yuzu (lean P1b_O21)
local NAME = "yuzu"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local Y  = { "#7b4a2c", "#b8741f", "#e0a323", "#f2c933", "#fbe262", "#fff4a0" }
local YG = { "#4e5a24", "#7f8c22", "#a9b52c", "#cfd548", "#e9ea78", "#f7f6b4" }
local LEAF = { "#14352c", "#1f5636", "#2f7a3e", "#4a9a48", "#76b95a", "#a8d676" }
local BR = { "#3a2418", "#5e3c24", "#8c6238", "#bf9358" }
c:groundShadow(32, 57, 16, 2)
-- lumpy squat fruit
local fruit = HP.mask()
local CX, CY = 32, 37
for y = 14, 60 do for x = 8, 56 do
  local dx, dy = x - CX, (y - CY) / 0.93
  local a = math.atan(dy, dx)
  local r = 21 + 1.0 * sin(3 * a + 1) + 0.7 * sin(5 * a + 2) + 0.5 * sin(8 * a)
  if sqrt(dx * dx + dy * dy) <= r then fruit:set(x, y) end
end end
local n = X.pillow(fruit, 21)
local v = X.light(n, { amb = 0.08, wrap = 0.25 })
local idx = {}
fruit:each(function(x, y)
  local k = K(x, y)
  local val = v[k]
  local i = 1
  for j, t in ipairs{ 0.2, 0.38, 0.55, 0.72, 0.88 } do if val >= t then i = j + 1 end end
  idx[k] = i
end)
fruit:each(function(x, y)
  local k = K(x, y)
  local green = (y - 15) + X.hash(x, y, 4) * 5 + abs(x - 32) * 0.15
  c:put(x, y, (green < 14 and X.hash(x, y, 9) > 0.15 or green < 9) and YG[idx[k]] or Y[idx[k]], { r = { name = "fruit" } })
end)
-- rind dimples: dark pit, shadowed upper-left lip, lit lower-right lip
local inner = fruit:copy():shrink(2)
for gy = 0, 12 do for gx = 0, 12 do
  local px = 9 + gx * 4 + floor(X.hash(gx, gy, 5) * 4) + (gy % 2) * 2
  local py = 17 + gy * 4 + floor(X.hash(gx, gy, 6) * 4)
  if inner:has(px, py) and inner:has(px + 1, py + 1) and inner:has(px - 1, py - 1) then
    local k = K(px, py)
    local i = idx[k]
    c:put(px, py, (py - 15 < 12) and YG[max(1, i - 2)] or Y[max(1, i - 2)])
    c:put(px - 1, py, (py - 15 < 12) and YG[max(1, i - 1)] or Y[max(1, i - 1)])
    c:put(px + 1, py + 1, (py - 15 < 12) and YG[min(6, i + 1)] or Y[min(6, i + 1)])
  end
end end
-- cool-violet reflected light along the lower-right rim
local rim = fruit:edge()
rim:each(function(x, y) if x + y > 82 and y > 40 then c:put(x, y, "#c88a4a") end end)
-- specular glints
for _, p in ipairs{ { 21, 26 }, { 22, 26 }, { 21, 27 }, { 24, 24 } } do c:put(p[1], p[2], "#fffbd0") end
-- calyx + stem
for _, p in ipairs{ { 29, 16 }, { 30, 15 }, { 34, 15 }, { 35, 16 }, { 28, 17 }, { 36, 17 }, { 32, 17 } } do c:put(p[1], p[2], LEAF[3]) end
c:put(30, 16, LEAF[4]) c:put(31, 16, LEAF[2]) c:put(33, 16, LEAF[2]) c:put(32, 16, LEAF[1]) c:put(31, 17, LEAF[2]) c:put(33, 17, LEAF[1])
for y = 10, 15 do c:put(31, y, BR[3]) c:put(32, y, BR[2]) c:put(33, y, BR[1]) end
c:put(31, 9, BR[4]) c:put(32, 9, BR[3])
-- one leaf with a winged petiole
local m, nn, T, S = G.blade(33, 11, 42, 2, 56, 11, function(t) if t > 0.995 then return -1 end return max(0.4, 4.3 * sin(pi * t ^ 0.75) ^ 0.75) end)
G.toneN(c, m, nn, LEAF, { amb = 0.1, wrap = 0.3 })
m:each(function(x, y) local k = K(x, y)
  if abs(S[k]) < 0.2 and T[k] > 0.1 and T[k] < 0.92 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end
  if T[k] > 0.2 and T[k] < 0.85 and abs(abs(S[k]) - 0.55) < 0.09 and ((x + y) % 3 ~= 0) then c:put(x, y, S[k] < 0 and LEAF[5] or LEAF[2]) end
end)
local wm, wn = G.oval(38, 12, 3.2, 2.0, -0.4, 1)
wm:cut(m)
G.toneN(c, wm, wn, LEAF, { amb = 0.1, wrap = 0.3 })
c:put(37, 11, LEAF[6])
-- quirk: a dew drop on the leaf
c:put(47, 7, "#a8e0f0") c:put(48, 7, "#dff6f6") c:put(47, 8, "#4a8ac0") c:put(48, 8, "#6ab0d8")
G.save(c, NAME)
