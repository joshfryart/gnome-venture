-- pigeon-pea (lean E2_05)
local NAME = "pigeon-pea"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function P(x, y, col) c:put(x, y, col) end
local function RC(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function dome(m, ramp, R, name, o) local n = X.pillow(m, R) local t = { tok = { r = { name = name } }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 } if o then for k, v in pairs(o) do t[k] = v end end G.toneN(c, m, n, ramp, t) return n end
local W = { "#4e4e78", "#7c7ca4", "#aeaecb", "#d4d4e6", "#ecebf4", "#fbfaff" }
local D = { "#3a2418", "#5e3a22", "#8a5a30", "#ae7a40", "#cf9c58", "#e8c07c" }
local PG = { "#16402a", "#215c36", "#33803f", "#58a448", "#86c85c", "#bfe88a" }
local IN = { "#6a7a30", "#9aae48", "#c8d86c", "#e8f0a0" }
local SD = { "#5a3a22", "#a8845a", "#d8c08a", "#f2e4b8", "#fff6d8" }
local MAR = "#6a1e3a"
c:groundShadow(32, 58, 26, 3)
local function bz(p, t) local u = 1 - t
  return u*u*u*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t*t*t*p[4][1], u*u*u*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t*t*t*p[4][2] end
-- hanging closed pod + stem + leaves (top)
local sm = G.tube({ { 28, 6 }, { 30, 12 }, { 36, 14 }, { 42, 14 } }, function(t) return 1.1 end)
local stn = X.pillow(sm, 1.5) G.toneN(c, sm, stn, { "#3c2a1a", "#5e4228", "#86603a", "#a8844e", "#c8a468", "#e0c488" }, { tok = { r = { name = "stem" } } })
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.985 then return -1 end local u = min(1, t * 0.9 + 0.1) return max(0.5, w * sin(pi * u ^ 1.2) ^ 0.75) end, { fold = 0.5 })
  G.toneN(c, m, n, PG, { tok = { r = { name = "lf" .. ax } }, cuts = { .18, .34, .5, .66, .82 }, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.05 and T[k] < 0.9 then P(x, y, S[k] <= 0 and PG[6] or PG[2]) end end)
end
leaf(28, 7, 20, 2, 10, 6, 3.4)
leaf(28, 7, 18, 12, 9, 14, 3.4)
local hp = { { 41, 14 }, { 43, 24 }, { 49, 28 }, { 50, 34 } }
local pm, pn, PT = G.tube(hp, function(t) return 1.5 + 2.6 * sin(pi * min(1, t * 1.05)) ^ 0.6 end)
G.toneN(c, pm, pn, PG, { tok = { r = { name = "pod2" } }, cuts = { .18, .34, .5, .66, .82 }, amb = 0.12, wrap = 0.25 })
pm:each(function(x, y) if X.hash(x, y, 3) > 0.8 then P(x, y, MAR) end end)
-- big open pod (crescent, seeds exposed)
local bp = { { 8, 30 }, { 14, 62 }, { 50, 62 }, { 56, 28 } }
local wf = function(t) return 1.3 + 5.2 * sin(pi * t) ^ 0.55 end
local m, n, T = G.tube(bp, wf)
G.toneN(c, m, n, PG, { tok = { r = { name = "pod" } }, cuts = { .18, .34, .5, .66, .82 }, amb = 0.12, wrap = 0.25 })
m:each(function(x, y) local k = K(x, y) if X.hash(x, y, 7) > 0.86 and (T[k] < 0.2 or T[k] > 0.8) then P(x, y, MAR) end end)
local inner = G.tube(bp, function(t) if t < 0.2 or t > 0.82 then return -1 end return max(0.5, 3.2 * sin(pi * (t - 0.2) / 0.62) ^ 0.5 + 0.3) end)
inner:each(function(x, y) P(x, y, IN[2]) end)
inner:edge():each(function(x, y) if m:has(x, y) and not inner:has(x, y) then P(x, y, PG[6]) end end)
inner:each(function(x, y) if not inner:has(x, y - 1) then P(x, y, IN[1]) end end)
local ts = { 0.3, 0.43, 0.57, 0.7 }
for i, t in ipairs(ts) do
  local x, y = bz(bp, t) x, y = floor(x + .5), floor(y + .5) - 1
  local sm2 = c:ellipse(x, y, 3, 3)
  G.toneN(c, sm2, X.pillow(sm2, 2.6), SD, { tok = { r = { name = "seed" .. i } }, cuts = { .22, .42, .62, .82 }, amb = 0.1, wrap = 0.3 })
  P(x + 1, y + 1, SD[1]) P(x + 1, y + 2, SD[1]) P(x - 1, y - 1, SD[5])
  P(x, y + 2, IN[1])
end
-- loose seed rolled off (quirk)
local ls = c:ellipse(53, 51, 2, 2)
G.toneN(c, ls, X.pillow(ls, 2), SD, { tok = { r = { name = "loose" } }, cuts = { .22, .42, .62, .82 } })
P(54, 52, SD[1]) P(52, 50, SD[5])
G.save(c, NAME)
