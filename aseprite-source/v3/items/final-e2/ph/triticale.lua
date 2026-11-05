-- triticale (lean E2_17)
local NAME = "triticale"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function ell(cx, cy, rx, ry, a)
  a = a or 0
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy - max(rx, ry)) - 1, floor(cy + max(rx, ry)) + 1 do for x = floor(cx - max(rx, ry)) - 1, floor(cx + max(rx, ry)) + 1 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u, v = (dx * ca + dy * sa) / rx, (-dx * sa + dy * ca) / ry
    if u * u + v * v <= 1 then m:set(x, y) end
  end end
  return m
end
local function shade(m, ramp, tok, R, amb, wrap)
  local n = X.pillow(m, R)
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = amb or 0.1, wrap = wrap or 0.2 })
  return n
end
local function dot(x, y, col, tok) c:put(floor(x), floor(y), col, tok) end
local GR = { "#4a2a12", "#7a4a1e", "#a8702c", "#cf9a42", "#eec068", "#fff0a8" }
local LF = { "#1a3a3a", "#27584a", "#3a7a58", "#5a9a68", "#86bc7c", "#b8dc98" }
local ST = { "#6a5a22", "#9a8636", "#c8b050", "#e4d078" }
c:groundShadow(32, 59, 12, 2)
-- leaves first (behind the stem)
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, nn, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(u) if u > 0.98 then return -1 end return max(0.5, w * sin(pi * min(1, u * 0.9 + 0.1)) ^ 0.6) end, { fold = 0.4 })
  local tk = { r = { name = "lf" .. ax .. bx } }
  G.toneN(c, m, nn, LF, { tok = tk, cuts = CUTS, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.05 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and LF[6] or LF[2], tk) end end)
end
leaf(31, 52, 18, 36, 5, 46, 3.4)
leaf(33, 44, 46, 28, 59, 38, 3.2)
-- stalk
local sm, sn, T = G.tube({ {32,60}, {31,46}, {33,34}, {32,24} }, function(u) return 1.9 - 0.4 * u end)
sm:each(function(x, y) c:put(x, y, (x <= 31 + (y < 40 and 1 or 0)) and ST[3] or ST[1], { r = { name = "stalk" } }) end)
for _, y in ipairs{ 46, 54 } do sm:each(function(x, yy) if yy == y then c:put(x, yy, ST[1], { r = { name = "node" } }) end end) end
-- ear: stacked paired grains, plump and tapering
local gt = { r = { name = "grain" } }
local gy = 27
local row = 0
while gy > 9 do
  local w = 4.2 - max(0, (14 - gy)) * 0.18
  for side = -1, 1, 2 do
    local gm = ell(32 + side * 2.6, gy, 2.2, 3.4, side * 0.35)
    local gn = X.pillow(gm, 2.4)
    G.toneN(c, gm, gn, GR, { tok = gt, cuts = CUTS, amb = 0.06, wrap = 0.2 })
    c:put(32 + side * 2, gy - 1, GR[6], gt)
    c:put(32 + side * 3, gy + 1, GR[2], gt)
  end
  gy = gy - 3
end
ell(32, 8, 1.6, 2.2):each(function(x, y) c:put(x, y, GR[5], gt) end)
-- long awns fanning out from the ear
for i, d in ipairs{ -1, 1 } do
  for j = 0, 4 do
    local y0 = 25 - j * 4
    local pts = { {32 + d * 4, y0}, {32 + d * 9, y0 - 5}, {32 + d * 13, y0 - 11}, {32 + d * (14 + j), y0 - 18 - j} }
    c:line(pts, 1):each(function(x, y) if x >= 2 and x <= 61 and y >= 2 then c:put(x, y, (x + y) % 2 == 0 and GR[4] or GR[3], { r = { name = "awn" } }) end end)
  end
end
-- quirk: dew bead on the left leaf
for _, p in ipairs{ {16,38,"#e8f6ff"},{17,38,"#a8d0e8"},{16,39,"#6aa0c8"} } do dot(p[1], p[2], p[3], { r = { name = "dew" } }) end
G.save(c, NAME)
