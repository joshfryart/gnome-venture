-- stage-fruit-3 (lean D2o_6)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-fruit-3" }
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

soil(32, 49, 23, 7)
leaf({ {31, 46}, {22, 40}, {15, 31}, {11, 24} }, 4.4, LEAF)
leaf({ {33, 46}, {42, 40}, {49, 31}, {53, 24} }, 4.4, LEAF)
stem({ {32, 46}, {32, 44}, {32, 42}, {32, 40} }, 1.3)
local fr = c:ellipse(32, 27, 12, 13)
shade(fr, FRU, 13, 0.08)
fr:copy():shrink(1):each(function(x, y) if X.hash(x, y, 5) > 0.93 then c:px(x, y, FRU[5]) end end)
-- belly bloom ring and lower-right reflected light
fr:edge():each(function(x, y) if x > 36 and y > 30 then c:px(x, y, "#7fa0a8") end end)
c:px(25, 20, SPEC) c:px(26, 20, SPEC) c:px(25, 21, FRU[6]) c:px(27, 19, FRU[6])
-- calyx and nub
for _, p in ipairs{ {30,14},{32,14},{34,14},{31,15},{33,15},{32,16} } do c:px(p[1], p[2], FRU[1]) end
stem({ {32, 15}, {32, 12}, {32, 10}, {32, 8} }, 1.1)
-- quirk: curl tendril
G.line(c, { {33, 9}, {36, 7}, {39, 7}, {40, 9}, {39, 11}, {37, 10} }, LEAF[4])
leaf({ {30, 48}, {23, 45}, {17, 43}, {12, 46} }, 3.2, LEAF)
leaf({ {34, 48}, {41, 45}, {47, 43}, {52, 46} }, 3.2, LEAF)

G.fin(c, "stage-fruit-3")
