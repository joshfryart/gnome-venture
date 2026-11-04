-- carob (lean W2_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function egg(cx, y0, y1, w, pw) local m = HP.mask() for y = y0, y1 do local t = (y - y0) / (y1 - y0); local h = w * sin(pi * t ^ pw) ^ 0.8 + 0.5; for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do m:set(x, y) end end return m end
local function shade(c, m, R, ramp, bias, o) local n = X.pillow(m, R); return n, G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp, nil, bias) end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "carob" }
local PD = { "#24120f", "#3d1d15", "#5c2c1c", "#7d3f26", "#a05a34", "#c58452" }
local LF = { "#17342f", "#1f4d3b", "#2e6a46", "#47884f", "#6aa85a", "#98c872" }
local TW = { "#3a2619", "#5b3d28", "#80593a", "#a8805a" }
local lt = { r = { name = "leaf" } }
-- twig (top right) with two round leaflets
local tm, tn = G.tube({ {54, 3}, {51, 7}, {47, 9}, {43, 12} }, function(t) return 1.6 - 0.3 * t end)
G.tone(c, tm, X.light(tn, { amb = 0.2, wrap = 0.3 }), TW)
for _, L in ipairs{ {52, 4, 59, 3, 3.3}, {50, 6, 56, 11, 3.0} } do
  local ax, ay, bx, by, w = L[1], L[2], L[3], L[4], L[5]
  local len = sqrt((bx-ax)^2 + (by-ay)^2)
  local m = G.rell((ax+bx)/2, (ay+by)/2, (bx-ax)/len, (by-ay)/len, len/2 + 0.5, w)
  local n = X.pillow(m, w + 1)
  G.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), LF, nil, nil, lt)
  G.line(c, { {floor(ax+0.5), floor(ay+0.5)}, {floor(bx+0.5), floor(by+0.5)} }, LF[6])
end
-- pods: a long curved one and a shorter one, hanging from the twig
local function pod(pts, wmax, seed, ends)
  local m, n, T = G.tube(pts, function(t) return wmax * (1 - (2*t - 1)^6) ^ 0.5 + 0.9 end)
  local bias = {}
  m:each(function(x, y) local k = K(x, y); local t = T[k] or 0
    local bump = (t * 9 + X.hash(floor(t*9), 0, seed) * 0.6) % 1
    if bump < 0.2 and t > 0.12 and t < 0.88 then bias[k] = -1 end
    if X.hash(x, y, seed) > 0.93 then bias[k] = 1 end
  end)
  G.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.2 }), PD, nil, bias)
  return m, n, T
end
local m1, n1 = pod({ {45, 12}, {18, 18}, {10, 40}, {18, 56} }, 3.6, 3)
local m2, n2 = pod({ {43, 12}, {47, 28}, {40, 44}, {36, 57} }, 3.2, 9)
-- sutures: pale ridge along the lit edge, stem caps
m1:copy():shrink(1):each(function(x, y) end)
for _, m in ipairs{ m1, m2 } do
  m:edge():each(function(x, y) if x + y < 52 and X.hash(x, y, 2) > 0.45 and not m:copy():shrink(1):has(x, y) then c:px(x, y, PD[6]) end end)
end
c:fillMask(c:ellipse(44, 12, 2, 1.6), TW[3]) c:px(43, 11, TW[4])
-- spec dabs
for _, p in ipairs{ {26, 17}, {27, 17}, {12, 32}, {45, 24}, {45, 25} } do c:px(p[1], p[2], "#e8b88a") end
-- quirk: tail of the short pod curls into a tiny split showing a seed
c:px(36, 56, "#d9a96a") c:px(37, 56, "#5a2b14")
G.fin(c, "carob")
