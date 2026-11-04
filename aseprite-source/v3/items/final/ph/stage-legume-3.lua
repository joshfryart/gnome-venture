-- stage-legume-3 (lean D2o_8)
local NAME = "stage-legume-3"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local DIRT = { "#2f1d22", "#4a2c2c", "#6b4331", "#8d5d3d", "#b0804f", "#d3a669" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local STEM = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
local WOOD = { "#2e1c1c", "#4d3022", "#6d4a31", "#8f6643", "#b48a58" }
local COT  = { "#7a6a3a", "#b5a050", "#dcc872", "#f1e6a0", "#fff6c8" }
local CUTS6 = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function tone(m, ramp, R, cuts, o)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.3 }), ramp, cuts or CUTS6)
end
local function soil(cy, rx, ry)
  local m = c:ellipse(32, cy, rx, ry)
  tone(m, DIRT, ry + 1)
  m:each(function(x, y)
    if y >= cy + ry - 1 then c:px(x, y, DIRT[2]) end
    if y >= cy + ry then c:px(x, y, DIRT[1]) end
  end)
  m:copy():shrink(2):each(function(x, y)
    if X.hash(x, y, 3) > 0.93 then c:px(x, y, DIRT[6]) c:px(x + 1, y + 1, DIRT[2]) end
  end)
  return m
end
local function stem(p, w0, w1, ramp)
  local m, n = G.tube(p, function(t) return w0 + (w1 - w0) * t end)
  G.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), ramp or STEM, { 0.3, 0.6, 0.85 })
  return m
end
local function leaf(p, wmax, ramp)
  ramp = ramp or LEAF
  local len = sqrt((p[4][1] - p[1][1])^2 + (p[4][2] - p[1][2])^2)
  local m, n, T, S = G.tube(p, function(t)
    if t < 0.05 then return 0 end
    return max(0.6, wmax * sin(pi * min(1, t)) ^ 0.7)
  end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), ramp, CUTS6)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.2 and t > 0.1 and t < 0.92 then c:px(x, y, s <= 0 and ramp[6] or ramp[3]) end
    if wmax > 3 and t > 0.3 then
      for _, vt in ipairs{ 0.4, 0.55, 0.7 } do
        local d = (t - vt) * len - abs(s) * 2
        if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.8 then c:px(x, y, s < 0 and ramp[5] or ramp[2]) end
      end
    end
  end)
  return m
end
local function mirror(p) local q = {} for i, v in ipairs(p) do q[i] = { 64 - v[1], v[2] } end return q end
local function rot(ux, uy, a) return ux * cos(a) - uy * sin(a), ux * sin(a) + uy * cos(a) end
local function tri(x, y, dx, dy, s)
  local E = { x + dx, y + dy }
  G.line(c, { { x, y }, { x + dx * 0.5, y + dy * 0.5 + 1 }, E }, STEM[2])
  local l = sqrt(dx * dx + dy * dy)
  local ux, uy = dx / l, dy / l
  local L = 7.5 * s
  for _, a in ipairs{ -1.15, 1.15, 0 } do
    local vx, vy = rot(ux, uy, a)
    local px, py = -vy, vx
    local q = { E, { E[1] + vx * L * 0.3 + px * 0.8, E[2] + vy * L * 0.3 + py * 0.8 },
      { E[1] + vx * L * 0.65, E[2] + vy * L * 0.65 }, { E[1] + vx * L, E[2] + vy * L } }
    leaf(q, 2.9 * s)
  end
end
local function vx(y, bx, y0) return bx + 5 * sin((y0 - y) * 0.5) end
local function helix(bx, y0, y1)
  local pts = {}
  for y = y0, y1, -1 do pts[#pts + 1] = { floor(vx(y, bx, y0) + 0.5), y } end
  local m = c:line(pts, 2)
  c:fillMask(m, STEM[2])
  m:each(function(x, y)
    if not m:has(x - 1, y - 1) then c:px(x, y, STEM[3]) elseif not m:has(x + 1, y + 1) then c:px(x, y, STEM[1]) end
  end)
end
local function stake(bx, y0, y1)
  local m, n = G.tube({ { bx, y0 }, { bx, y0 + (y1 - y0) / 3 }, { bx, y0 + 2 * (y1 - y0) / 3 }, { bx, y1 } }, function(t) return 1.7 end)
  G.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), WOOD, { 0.25, 0.5, 0.75, 0.9 })
  m:each(function(x, y) if X.hash(x, y, 8) > 0.86 then c:px(x, y, WOOD[2]) end end)
end
soil(50, 22, 6)
stake(44, 47, 9)
stem({ {32,47}, {32,40}, {38,36}, {44,32} }, 1.5, 1.2)
helix(44, 32, 12)
tri(vx(26, 44, 32), 26, -8, -4, 0.9)
tri(vx(21, 44, 32), 21, 5, -5, 0.85)
tri(vx(15, 44, 32), 15, -2, -4, 0.6)
-- quirk: one pea blossom
G.line(c, { {38, 38}, {39, 34} }, STEM[2])
c:fillMask(c:rect(38, 31, 41, 33), "#f6e8f0") c:px(37, 32, "#e07aa8") c:px(39, 34, "#e07aa8") c:px(41, 33, "#c85a8a") c:px(38, 31, "#fff6f2")
G.fin(c, NAME)
