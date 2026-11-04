-- wild-strawberries (lean W2_39)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wild-strawberries" }
local floor, sin, cos, pi, abs, sqrt = math.floor, math.sin, math.cos, math.pi, math.abs, math.sqrt
local RED  = { "#4a0f26", "#7b1631", "#b01f3a", "#d93a45", "#f06a5a", "#ffa58c" }
local UNR  = { "#5d6b4a", "#8a9a62", "#b7c27c", "#dbe29a", "#eef1b8", "#fbfbd8" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local STK  = { "#2c5a40", "#3f7a4d", "#6aa35c", "#9ccd6c" }
local tk = { r = { name = "x" } }

local function leaflet(ax, ay, cx, cy, bx, by)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    return 4.2 * sin(pi * math.min(1, t * 1.05)) ^ 0.7 + 0.5 * sin(t * 30) * (t > 0.2 and 1 or 0)
  end)
  G.toneN(c, m, n, LEAF, { tok = tk })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.92 then c:px(x, y, S[k] <= 0 and LEAF[6] or LEAF[4]) end
    if T[k] > 0.3 and T[k] < 0.85 and abs(S[k]) > 0.4 and abs(S[k]) < 0.6 and floor(T[k] * 14) % 2 == 0 then c:px(x, y, LEAF[2]) end
  end)
end
leaflet(46, 24, 51, 15, 57, 15)
leaflet(46, 24, 54, 28, 60, 30)
leaflet(46, 24, 42, 15, 47, 7)
local function stem(pts, w)
  local m, n = G.tube(pts, function(t) return w end)
  G.toneN(c, m, n, STK, { tok = tk })
end
stem({ {31, 27}, {36, 24}, {41, 27}, {46, 24} }, 1.0)
stem({ {30, 10}, {29, 16}, {31, 22}, {31, 27} }, 1.2)
stem({ {31, 26}, {27, 23}, {22, 24}, {20, 29} }, 0.8)
stem({ {31, 27}, {35, 28}, {39, 30}, {38, 35} }, 0.8)
stem({ {31, 27}, {31, 33}, {29, 38}, {28, 44} }, 0.8)

local function berry(cx, top, h, r, ramp, ripe)
  local m = HP.mask()
  for y = top, top + h - 1 do
    local t = (y - top + 0.5) / h
    local w = (t < 0.38) and r * sin(pi / 2 * (t / 0.38)) ^ 0.55 or r * ((1 - t) / 0.62) ^ 0.75
    for x = floor(cx - w + 0.5), floor(cx + w + 0.5) - 1 do m:set(x, y) end
  end
  local n = X.pillow(m, r)
  local _, v = G.toneN(c, m, n, ramp, { tok = tk })
  local inner = m:copy():shrink(1)
  m:each(function(x, y)
    if y % 3 == 1 and (x + (y // 3) * 2) % 4 == 0 and inner:has(x, y) then
      c:px(x, y, ripe and "#f6d56a" or "#d8d27a")
      if inner:has(x + 1, y + 1) then c:px(x + 1, y + 1, ramp[2]) end
    end
  end)
  local sx, sy = G.specAt(m, n, 30)
  if sx then c:px(sx, sy, "#fff6ee") c:px(sx, sy + 1, ramp[6]) end
  -- calyx
  for _, p in ipairs{ {0,-1,4},{-1,0,3},{1,0,3},{-2,1,2},{2,1,2},{0,1,2},{-3,1,1},{3,1,1} } do c:px(cx + p[1], top + p[2], LEAF[p[3] + 1]) end
  c:px(cx - 1, top - 1, LEAF[5]) c:px(cx - 2, top, LEAF[6])
end
berry(19, 29, 14, 6.5, RED, true)
berry(38, 35, 14, 6.5, RED, true)
berry(28, 44, 9, 4.5, UNR, false)   -- quirk: one small unripe berry

-- flower
local fl = HP.mask()
for i = 0, 4 do
  local a = i * 2 * pi / 5 - pi / 2
  fl:add(c:ellipse(30 + cos(a) * 3.4, 8 + sin(a) * 3.4, 2.4, 2.4))
end
c:fillMask(fl, "#d4c9e6")
fl:each(function(x, y) if fl:has(x + 1, y + 1) and fl:has(x, y + 1) and fl:has(x + 1, y) then c:px(x, y, "#fffaf0") end end)
c:fillMask(c:ellipse(30, 8, 1.7, 1.7), "#f2b92a")
c:px(29, 7, "#fff0a0")
G.save(c, "wild-strawberries")
