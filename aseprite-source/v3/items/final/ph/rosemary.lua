-- rosemary (lean W2_16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function cyl(m, cx, hw) local n = {} m:each(function(x, y) local nx = max(-0.97, min(0.97, (x - cx) / hw)); n[K(x, y)] = { nx, -0.1, sqrt(1 - nx * nx) } end) return n end
local function shade(c, m, n, ramp, bias, amb) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, nil, bias) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "rosemary" }
local main = { { 24, 57 }, { 22, 42 }, { 30, 26 }, { 40, 10 } }
local function needles(P, t0, t1, st, len)
  local t = t0
  while t <= t1 do
    local x, y = G.bez(P, t)
    local x2, y2 = G.bez(P, min(1, t + 0.02))
    local tx, ty = x2 - x, y2 - y
    local l = sqrt(tx * tx + ty * ty)
    tx, ty = tx / l, ty / l
    for _, s in ipairs{ -1, 1 } do
      local a = s * 0.95
      local dx, dy = tx * cos(a) - ty * sin(a), tx * sin(a) + ty * cos(a)
      local L = len * (1 - 0.35 * t) + (s > 0 and 0 or 0.6)
      local lit = (dy < 0.1 and dx < 0.6) and 1 or 0
      for i = 1, floor(L + 0.5) do
        local col = i == 1 and "#255644" or (i == floor(L + 0.5) and (lit == 1 and "#9ccd6c" or "#70b45a") or (lit == 1 and "#4b9650" or "#32764b"))
        c:px(floor(x + dx * i + 0.5), floor(y + dy * i + 0.5), col)
      end
    end
    t = t + st
  end
end
local function branch(P, t0, len) needles(P, t0, 1, 0.045, len) end
local b1 = { { 25, 36 }, { 31, 35 }, { 38, 30 }, { 47, 21 } }
local b2 = { { 27, 29 }, { 23, 25 }, { 20, 19 }, { 18, 11 } }
branch(b2, 0.12, 4) branch(b1, 0.12, 4)
needles(main, 0.12, 1, 0.04, 4.6)
local function stem(P, w, ramp)
  local m, n = G.tube(P, function(t) return w * (1 - 0.5 * t) + 0.3 end)
  shade(c, m, n, ramp)
end
local W = { "#5a3a22", "#7a5a3a", "#a07c4c", "#c9a468" }
stem(b1, 0.9, W) stem(b2, 0.9, W) stem(main, 1.3, W)
c:fillMask(c:rect(23, 56, 25, 58), "#e0c890") c:px(24, 57, "#a07c4c")
-- little blue flowers (quirk)
for _, f in ipairs{ { 41, 11 }, { 47, 18 }, { 17, 14 }, { 36, 20 } } do
  c:fillMask(c:rect(f[1], f[2], f[1] + 1, f[2] + 1), "#8a8ae0")
  c:px(f[1], f[2], "#c4c4ff") c:px(f[1] + 1, f[2] + 1, "#5a5ab8") c:px(f[1] + 2, f[2], "#8a8ae0")
end
G.fin(c, "rosemary")
