-- stage-cover-4 (lean D2o_6)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-cover-4" }
local floor_ = math.floor
local sin, pi, max, min, abs = math.sin, math.pi, math.max, math.min, math.abs
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local FRU  = { "#2f4a22", "#4a6b2a", "#6f8f35", "#98b341", "#c1d25a", "#e4ec8a" }
local PINK = { "#5a1f4a", "#8c2a63", "#c13d7c", "#e8609a", "#ff93bd", "#ffd0e0" }
local HUSK = { "#5a3a22", "#7e5430", "#a8763f", "#cfa05a", "#e8c987", "#f7e6b4" }
local SOIL = { "#2a1a1c", "#46291f", "#693c27", "#8a5231", "#aa6e3f", "#c98d52" }
local SPEC = "#fff6f2"
local lt = { r = { name = "leaf" } }
local function shade(m, ramp, R, amb)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp)
end
local function leaf(p, wmax, ramp, pw)
  local m, n, T, S = G.tube(p, function(t) return max(0.45, wmax * sin(pi * min(1, t)) ^ (pw or 0.7)) end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), ramp, nil, nil, lt)
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.17 and T[k] > 0.1 and T[k] < 0.93 then c:px(x, y, S[k] <= 0 and ramp[5] or ramp[2]) end
  end)
  return m
end
local function stem(p, w)
  local m, n = G.tube(p, function(t) return w end)
  G.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), { LEAF[2], LEAF[3], LEAF[4], LEAF[5], LEAF[6], LEAF[6] })
  return m
end
local function soil(cx, cy, rx, ry, furrow)
  cy = cy - 3
  local top = c:ellipse(cx, cy, rx - 2, ry - 1)
  local lip = c:ellipse(cx, cy + 2, rx, ry + 1) lip:cut(top)
  shade(lip, SOIL, 4, 0.0)
  shade(top, SOIL, ry + 1, 0.2)
  top:edge():each(function(x, y) if y < cy then c:px(x, y, SOIL[5]) end end)
  top:copy():shrink(1):each(function(x, y)
    local h = X.hash(x, y, 7)
    if h > 0.95 then c:px(x, y, SOIL[6]) elseif h < 0.06 then c:px(x, y, SOIL[2]) end
  end)
  if furrow then
    for _, f in ipairs(furrow) do
      for x = f[1], f[2] do local yy = f[3] + floor_((x - cx) * (x - cx) / (rx * rx) * 1.6)
        c:px(x, yy, SOIL[2]) c:px(x, yy + 1, SOIL[5]) end
    end
  end
  lip:each(function(x, y) if X.hash(x, y, 3) > 0.93 then c:px(x, y, SOIL[4]) end end)
  return top
end

soil(32, 47, 24, 7)
local lobes = { {15,40,8,7}, {49,40,8,7}, {25,35,9,9}, {40,35,9,9}, {32,41,10,7} }
for _, L in ipairs(lobes) do
  local m = c:ellipse(L[1], L[2], L[3], L[4])
  local ring = m:copy():grow(1) ring:cut(m)
  c:fillMask(ring, LEAF[1])
  shade(m, LEAF, L[4] + 2, 0.12)
  m:copy():shrink(1):each(function(x, y) local h = X.hash(x, y, L[1])
    if h > 0.9 then c:px(x, y, LEAF[2]) elseif h < 0.05 then c:px(x, y, LEAF[6]) end end)
end
local function flower(x, y)
  c:px(x, y - 1, PINK[5]) c:px(x - 1, y, PINK[4]) c:px(x + 1, y, PINK[3]) c:px(x, y + 1, PINK[2])
  c:px(x, y, "#ffe28a")
end
flower(18, 35) flower(26, 28) flower(38, 27) flower(47, 35) flower(32, 36)
c:px(44, 41, "#d83a2e") c:px(45, 41, "#d83a2e") c:px(44, 42, "#a82424") c:px(45, 42, "#a82424") c:px(44, 41, "#ff7a62") c:px(45, 42, PINK[1])
c:px(26, 33, SPEC) c:px(24, 36, LEAF[6]) c:px(37, 31, LEAF[6])

G.fin(c, "stage-cover-4")
