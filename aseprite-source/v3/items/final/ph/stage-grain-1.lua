-- stage-grain-1 (lean D2o_6)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-grain-1" }
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

soil(32, 47, 24, 8, { {13, 25, 47}, {36, 52, 47}, {20, 44, 52} })
local hk = c:ellipse(32, 44, 3, 2) shade(hk, HUSK, 3)
leaf({ {31, 44}, {28, 36}, {24, 30}, {20, 24} }, 1.9, LEAF, 0.45)
leaf({ {33, 44}, {37, 36}, {42, 30}, {47, 26} }, 1.9, LEAF, 0.45)
leaf({ {32, 43}, {31, 38}, {32, 34}, {31, 29} }, 1.4, FRU, 0.45)
-- roots threading into soil
G.line(c, { {30, 46}, {28, 48}, {26, 49} }, SOIL[6]) G.line(c, { {33, 46}, {35, 48}, {38, 49} }, SOIL[6])
-- quirk: seed husk worn as a hat on the middle blade
c:px(30, 28, HUSK[3]) c:px(31, 28, HUSK[4]) c:px(32, 28, HUSK[3]) c:px(31, 27, HUSK[5])

G.fin(c, "stage-grain-1")
