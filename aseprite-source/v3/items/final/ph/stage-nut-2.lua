-- stage-nut-2 (lean D2o_9)
-- Young nut sapling: slim trunk, three-lobed leaf crown, a sprouting split nut half-buried at its foot.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-nut-2" }
local sin, cos, pi, max, min, abs, floor = math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.floor
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a4d46e" }
local LEAF2 = { "#20374a", "#2b5a50", "#3f7f52", "#62a456", "#8cc462", "#c0e07c" }
local BARK = { "#2e1f2a", "#4a2f31", "#6b4430", "#8b5d3a", "#ab7a4a", "#cf9e63" }
local SOIL = { "#2f1d22", "#4a2c2a", "#6a4130", "#8a5a3a", "#aa7648", "#c99a5e" }
local NUT  = { "#43241f", "#6a3a26", "#93532e", "#b9733a", "#dc9a50", "#f4c77a" }
local HUSK = { "#2d4a2b", "#436b34", "#5f8c3e", "#84ac4a", "#aacb5c", "#d2e88a" }
local RED  = { "#4d1530", "#7c1f3a", "#b02f3e", "#d9533f", "#f08a55", "#ffc58a" }
local SPEC = "#fff6e2"
local tk = { r = { name = "p" } }
local function blob(m, ramp, R, bias, amb)
  local n = X.pillow(m, R or 6)
  local v = X.light(n, { amb = amb or 0.08, wrap = 0.25 })
  G.tone(c, m, v, ramp, nil, bias, tk)
  return v
end
local function ell(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function leafy(m, ramp, seed)  -- leaf-clump texture: dark notches + light flecks + dark under-rim
  local sh = m:copy():shift(1, 1):cut(m)
  local inner = m:copy():shrink(1)
  m:each(function(x, y)
    local h = X.hash(x, y, seed)
    if inner:has(x, y) then
      if h > 0.9 then c:px(x, y, ramp[1 + (y > 0 and 1 or 0)]) elseif h < 0.1 then c:px(x, y, ramp[5]) end
    end
  end)
end
local function rimlow(m, col)  -- darken lower-right edge pixels
  local cx, cy, n = 0, 0, 0
  m:each(function(x, y) cx = cx + x cy = cy + y n = n + 1 end)
  cx, cy = cx / n, cy / n
  m:edge():each(function(x, y) if (x - cx) + (y - cy) > 2 then c:px(x, y, col) end end)
end
local function leaf(p, wmax, ramp, o)
  o = o or {}
  local m, n, T, S = G.tube(p, function(t) return wmax * sin(pi * min(1, t * 0.92 + 0.04)) ^ 0.7 + 0.35 end)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  G.tone(c, m, v, ramp, nil, nil, tk)
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.22 and T[k] > 0.1 and T[k] < 0.92 then c:px(x, y, S[k] <= 0 and ramp[6] or ramp[3]) end end)
  return m
end
local function mound(extra)
  c:groundShadow(32, 55, 21, 4)
  local m = ell(32, 51, 20, 6)
  local bias = {}
  X.ao(bias, m, extra or HP.mask(), 2, -1)
  blob(m, SOIL, 4, bias)
  m:each(function(x, y) local h = X.hash(x, y, 3)
    if h > 0.93 then c:px(x, y, SOIL[6]) elseif h < 0.05 then c:px(x, y, SOIL[1]) end end)
  for _, p in ipairs{ {18,50},{19,50},{45,52},{46,52},{26,55} } do c:px(p[1], p[2], SOIL[5]) end
  c:px(14, 51, SOIL[6]) c:px(15, 49, SOIL[6])
  return m
end
local function trunk(p, w0, w1)
  local m, n, T, S = G.tube(p, function(t) return w0 + (w1 - w0) * t end)
  local v = X.light(n, { amb = 0.1, wrap = 0.2 })
  G.tone(c, m, v, BARK, nil, nil, tk)
  m:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, 7) > 0.8 and S[k] > -0.4 then c:px(x, y, BARK[2]) end
    if X.hash(x, y, 8) > 0.9 and S[k] < 0 then c:px(x, y, BARK[5]) end end)
  return m
end
local function nutfn(cx, cy, r)
  local m = ell(cx, cy, r, r + 0.5)
  blob(m, NUT, r)
  local cap = c:rect(cx - r, cy - r - 1, cx + r, cy - r + 1):cut(c:rect(0,0,0,0))
  cap = ell(cx, cy - r + 0.5, r + 0.5, 1.8)
  blob(cap, HUSK, 2)
  c:px(cx - 1, cy, NUT[6])
  return m:add(cap)
end

local nutm = ell(21, 48, 3, 2.5)
local mm = mound(nutm)
blob(nutm, NUT, 3)
c:px(21, 46, NUT[1]) c:px(21, 47, NUT[1]) c:px(20, 46, NUT[6]) c:px(22, 50, NUT[1])
G.line(c, { {21, 45}, {20, 43}, {21, 42} }, HUSK[4])
leaf({ {21,44},{18,42},{16,43},{15,45} }, 1.6, LEAF2)
local tr = trunk({ {32,49},{31,43},{33,37},{32,30} }, 1.8, 1.1)
leaf({ {32,44},{37,43},{41,44},{43,46} }, 2.2, LEAF)
leaf({ {32,40},{27,38},{24,39},{22,41} }, 2.0, LEAF2)
local a, b, d = ell(25, 27, 7, 6), ell(39, 27, 7, 6), ell(32, 19, 8, 7)
local bias = {}
X.ao(bias, d, a, 2, -1) X.ao(bias, b, d, 2, -1)
blob(a, LEAF2, 6) leafy(a, LEAF2, 11) rimlow(a, LEAF2[1])
blob(b, LEAF, 6, nil) leafy(b, LEAF, 12) rimlow(b, LEAF[1])
blob(d, LEAF, 7) leafy(d, LEAF, 13) rimlow(d, LEAF[1])
c:px(28, 16, SPEC) c:px(29, 16, SPEC) c:px(27, 17, LEAF[6]) c:px(36, 24, LEAF[6])

G.fin(c, "stage-nut-2")
