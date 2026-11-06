-- ico-droplet (final pass, Opus single pass). Bold icon: one slim falling water drop, round bulb and a fine tip that
-- leans a touch to the left as it falls. Glass/water material: per-pixel light on a sphere+pillow field, 6-tone sea ramp
-- with cool-violet depth, a dark rim, a bright refracted caustic crescent inside the lower-right, a pale core, a curved
-- window-glint streak upper-left plus one cream sparkle, and a cool reflected edge.
-- quirk: a tiny air bubble is rising inside the drop.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA3_5.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = T.new("ico-droplet")
local W = { "#24306a", "#2a4f94", "#3474bc", "#4a9ad8", "#79c4ec", "#c2ecf8" }
local tk = { r = { name = "drop" } }

-- teardrop: round bulb radius R; above the bulb centre concave flanks (sin^1.4 profile) run to a fine tip leaning left
local CX, CY, R = 32, 40, 15
local YT = CY - floor(R * 1.9)
local m = HP.mask()
local cxOf = {}
for y = YT, CY + R do
  local w, cx
  if y <= CY then
    local u = (y - YT) / (CY - YT)
    w = R * sin(u * pi / 2) ^ 1.4 + 0.15
    cx = CX - 3.4 * (1 - u) ^ 2
  else
    w = sqrt(max(0, (R + 0.4) ^ 2 - (y - CY) ^ 2))
    cx = CX
  end
  cxOf[y] = cx
  for x = floor(cx - w + 0.5), floor(cx + w - 0.5) do m:set(x, y) end
end
-- normals: analytic sphere in the bulb, pillow-rounded up the tip (normal leans with the flank)
local ns = X.sphere(CX - 0.5, CY - 0.5, R, m)
local np = X.pillow(m, 7)
local n = {}
m:each(function(x, y) local k = K(x, y)
  local wS = y >= CY and 0.85 or max(0.2, 0.85 - (CY - y) / 30)
  local a, b = np[k], ns[k]
  n[k] = { T.norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) }
end)
local bias = {}
local d = X.dist(m)
-- caustic: light refracts through and pools inside the lower-right, 2-4 px in from the edge
m:each(function(x, y) local k = K(x, y)
  local dx, dy = x - CX, y - CY
  local r = sqrt(dx * dx + dy * dy)
  local ang = math.atan(dy, dx)                -- 0 = right, pi/2 = down
  if dy > 0 and ang > 0.15 and ang < 1.75 and d[k] > 1.2 and d[k] < 3.4 then bias[k] = (bias[k] or 0) + 2 end
  if dy > 2 and ang > 0.35 and ang < 1.5 and d[k] >= 3.6 and d[k] < 5.2 then bias[k] = (bias[k] or 0) + 1 end
end)
local idx = T.shade(c, m, n, W, { amb = 0.05, wrap = 0.3, bias = bias, tok = tk, cuts = { 0.12, 0.34, 0.62, 0.9, 0.99 } })
-- dark glassy rim: the outermost ring a step darker on the shade half
m:edge():each(function(x, y) if x + y > CX + CY - 6 then T.step(c, idx, W, x, y, -1, tk) end end)
-- refracted caustic crescent: hand-shaped moon inside the lower-right (outer edge stays dark)
m:each(function(x, y)
  local a = (x - CX - 0.5) ^ 2 + (y - CY - 0.5) ^ 2
  local b = (x - CX + 2.6) ^ 2 + (y - CY + 3.2) ^ 2
  if a <= (R - 1.6) ^ 2 and b > (R - 1.4) ^ 2 and y > CY - 3 then
    local deep = b > (R + 0.2) ^ 2 and y > CY + 3 and x > CX - 6
    c:put(x, y, deep and W[6] or W[5], tk) idx[K(x, y)] = deep and 6 or 5
  end
end)
-- pale core: a soft lit pool just above centre (water is clear)
for _, p in ipairs{ { 29, 37 }, { 30, 37 }, { 28, 38 }, { 29, 38 }, { 30, 38 }, { 31, 38 }, { 29, 39 }, { 30, 39 } } do
  local i = idx[K(p[1], p[2])]
  if i and i < 5 then T.step(c, idx, W, p[1], p[2], 1, tk) end
end
-- cool reflected light: a violet-tinged bounce on the lower edge
local rim = X.rim(n)
m:edge():each(function(x, y) if rim[K(x, y)] > 0.62 and y > CY + 6 and x < CX + 6 then c:put(x, y, "#5a6ad0", tk) end end)
-- window glint: curved streak following the upper-left of the bulb, plus a small dot nearer the tip
T.map(c, {
  "...ss",
  "..sss",
  ".ssh.",
  ".sh..",
  "ssh..",
  "sh...",
  "sh...",
  "h....",
}, 20, 29, { h = W[6], s = "#effcff" }, tk)
c:put(26, 21, W[6]) c:put(26, 22, W[6]) c:put(26, 23, W[5]) c:put(27, 19, W[5])
c:put(24, 31, T.CREAM, tk)
-- quirk: a tiny air bubble rising inside (ring of dark, lit cap, one glint)
T.map(c, {
  ".bbb.",
  "bhhlb",
  "bh.lb",
  "bllcb",
  ".bbb.",
}, 33, 40, { b = W[2], l = W[4], h = "#effcff", c = W[5] }, tk)
T.map(c, { ".b.", "bhb", ".b." }, 31, 35, { b = W[3], h = W[6] }, tk)
T.save(c, "ico-droplet", "ico")
