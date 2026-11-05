-- ensete (lean P1b_O0)
-- quirk: the right leaf has torn along a vein, as banana leaves do. Bulbous striped pseudostem, wide paddle leaves with red midribs.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ensete" }
local pi, sin, cos, floor, max, min, abs = math.pi, math.sin, math.cos, math.floor, math.max, math.min, math.abs
local LEAF = { "#14392f", "#1d5a3a", "#2c7f45", "#4ca64c", "#7cc858", "#b9e47e" }
local RIB = { "#4a1424", "#7d2234", "#b53c44", "#e0716a" }
local STEM = { "#4f6a46", "#7c9a58", "#a8c474", "#cfe29a", "#eaf3bd", "#f8fbdc" }
local ltok = { r = { name = "leaf" } }

local function leaf(ax, ay, cx, cy, bx, by, w, phase, cutFn)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return 0.9 + w * sin(pi * min(1, t * 1.02)) ^ 0.7 end, { fold = 0.5 })
  if cutFn then cutFn(m) end
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local ph = (T[k] * len * 0.6 - abs(S[k]) * 3.2 + phase) % 2.2
    if ph < 0.55 and abs(S[k]) > 0.18 then bias[k] = -1
    elseif ph > 1.1 and ph < 1.35 and abs(S[k]) > 0.18 then bias[k] = 1 end
  end)
  G.toneN(c, m, n, LEAF, { bias = bias, amb = 0.1, wrap = 0.25, tok = ltok })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.17 and T[k] < 0.97 then c:px(x, y, (S[k] < 0) and RIB[4] or ((T[k] < 0.5) and RIB[3] or RIB[2])) end
  end)
  return m
end
-- left, right (torn), centre rolled
leaf(31, 30, 10, 12, 4, 33, 6.8, 0)
leaf(33, 30, 54, 10, 60, 31, 6.8, 0.7, nil)
leaf(32, 28, 31, 14, 36, 4, 3.4, 0.3, nil)
-- tear: knock out a thin slit in the right leaf (gap over what is painted)
for i = 0, 8 do local x, y = floor(51 + i * 0.6), floor(29 + i * 1.1)
  c.pix[y * c.w + x] = nil c.pix[y * c.w + x + 1] = nil end

-- pseudostem: bulbous base to slim neck
local pts = { {32,28}, {32,38}, {30,44}, {32,56} }
local m, n, T = G.tube(pts, function(t) return 4.6 + 8.2 * (t ^ 1.6) end)
local bias = {}
m:each(function(x, y) local k = K(x, y)
  if (y % 6 == 0 or y % 6 == 1 and X.hash(x, y, 1) > 0.5) and y > 29 then bias[k] = -1 end
  if (x * 2 + y) % 9 == 0 and y > 30 and X.hash(x, y, 7) > 0.4 then bias[k] = -2 end
end)
G.toneN(c, m, n, STEM, { bias = bias, amb = 0.08, wrap = 0.3, tok = { r = { name = "stem" } } })
-- maroon streaks and collar
m:each(function(x, y) if y > 32 and (x + floor(y / 6)) % 5 == 0 and y % 6 > 1 and X.hash(x, y, 3) > 0.45 then c:px(x, y, RIB[2]) end end)
for x = 25, 39 do if m:has(x, 31) then c:px(x, 31, RIB[1]) end end
local sx, sy = G.specAt(m, n, 25)
if sx then c:px(sx, sy, "#fff8e8") c:px(sx, sy + 1, STEM[6]) end
G.save(c, "ensete")
