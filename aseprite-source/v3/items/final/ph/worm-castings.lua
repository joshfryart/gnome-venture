-- worm-castings (lean D3o_14)
-- dark crumbly mound of stacked rounded pellets with moist sheen, a pink earthworm looping out of the top. Quirk: the worm has one bead eye.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function T(c, m, ramp, R, bias) G.tone(c, m, X.light(X.pillow(m, R or 4), { amb = 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local function ell(c, cx, cy, rx, ry, a)
  local p = {}
  for i = 0, 15 do local t = i / 16 * 2 * pi
    local x, y = rx * cos(t), ry * sin(t)
    p[#p + 1] = { cx + x * cos(a) - y * sin(a), cy + x * sin(a) + y * cos(a) } end
  return c:poly(p)
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "worm-castings" }
local DIRT = { "#1c120e", "#2e1e16", "#463022", "#62442e", "#82603f", "#a8845a" }
local PINK = { "#7a2e48", "#a8485e", "#cc6a78", "#e48c92", "#f4b4ae", "#fddcd2" }
c:groundShadow(32, 54, 22, 4)
-- pellets, back row to front
local rows = {
  { y = 36, xs = { 24, 31, 38 } },
  { y = 41, xs = { 18, 25, 32, 39, 46 } },
  { y = 47, xs = { 14, 21, 28, 35, 42, 49 } },
  { y = 52, xs = { 18, 25, 32, 39, 45 } },
}
for r, row in ipairs(rows) do
  for i, x in ipairs(row.xs) do
    local jx, jy = floor(X.hash(x, row.y, 5) * 3) - 1, floor(X.hash(row.y, x, 9) * 3) - 1
    local m = ell(c, x + jx, row.y + jy, 4.2, 3.4, (X.hash(x, row.y, 2) - 0.5))
    local bias = {}
    if r < #rows then X.ao(bias, m, HP.mask(), 1, 0) end
    T(c, m, DIRT, 3)
    c:px(x + jx - 2, row.y + jy - 1, DIRT[6])
    c:px(x + jx - 1, row.y + jy - 2, DIRT[5])
    c:px(x + jx + 2, row.y + jy + 2, DIRT[1])
  end
end
-- worm
local wm, wn = G.tube({ {30,38},{26,26},{40,18},{44,26} }, function(t) return 2.6 - 0.8 * t end)
G.tone(c, wm, X.light(wn, { amb = 0.15, wrap = 0.35 }), PINK, CUTS)
wm:each(function(x, y) if floor((y * 0.7 + x * 0.5)) % 4 == 0 then c:px(x, y, PINK[2]) end end)
-- clitellum band
c:fillMask(c:rect(28, 28, 29, 31):cut(HP.mask()), PINK[5])
c:px(43, 22, PINK[1]) -- eye
c:px(44, 21, PINK[6])
c:px(34, 20, PINK[6]) c:px(33, 21, PINK[5])
c:sparkle(14, 40)
G.fin(c, "worm-castings")
