-- ico-shell (final, Opus single pass). Coiled sea-snail shell seen from the side: a logarithmic spiral of three
-- visible whorls, each lit as a round tube (6-tone cream-peach), deep AO in the spiral suture where whorls meet,
-- rust flame stripes on the older whorls that fade out toward the mouth, fine growth ribs on the last whorl,
-- glossy specular on the body whorl, cool bounce light on the lower-right rim, a flared pearly-pink lip with a dark
-- interior at the mouth. quirk: a hermit crab is stepping out of the mouth, eyes on stalks and one claw up.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, pi, exp, log, atan = math.floor, math.sqrt, math.max, math.min, math.abs,
  math.cos, math.sin, math.pi, math.exp, math.log, math.atan
local c = A.new("ico-shell")
local SH = { "#6e3a46", "#a85e56", "#d48e6c", "#efb98e", "#fbd9ae", "#fff0d2" }
local SR = { "#4e1e30", "#7a2e34", "#a5432f", "#c4613a", "#dc8450", "#eea26a" }
local NC = { "#5a2448", "#8d3466", "#c95f8f", "#f297b6", "#ffc9da", "#ffeaf0" }
local BOUNCE = "#b98ab0"
local stok, ntok, ktok = A.tok("shell"), A.tok("nacre"), A.tok("crab")

local CX, CY = 29.5, 29.5
local TE = pi * 0.44          -- aperture angle (screen, clockwise)
local RE = 26.0               -- outer radius at the mouth
local KK = log(2.25) / (2 * pi)
local function r(th) return RE * exp(KK * (th - TE)) end

-- classify pixels into whorls: u across the tube (0 inner suture .. 1 outer edge)
local shell, U, TH, RHO = HP.mask(), {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - CX, y - CY
  local rho = sqrt(dx * dx + dy * dy)
  local th = atan(dy, dx)
  while th > TE do th = th - 2 * pi end
  while th + 2 * pi <= TE do th = th + 2 * pi end
  if rho <= r(th) then
    while rho < r(th - 2 * pi) do th = th - 2 * pi end
    local ro, ri = r(th), r(th - 2 * pi)
    if ro > 1.2 then
      shell:set(x, y)
      local k = K(x, y)
      U[k], TH[k], RHO[k] = (rho - ri) / max(0.5, ro - ri), th, rho
    end
  end
end end

-- normals: round tube across each whorl + a gentle dome over the whole coil
local n, bias = {}, {}
shell:each(function(x, y) local k = K(x, y)
  local dx, dy = x - CX, y - CY
  local rho = max(0.3, RHO[k])
  local ex, ey = dx / rho, dy / rho
  local s = max(-0.95, min(0.95, (U[k] * 2 - 1) * 0.95))
  local nz = sqrt(1 - s * s)
  n[k] = { A.norm(ex * s + dx / 60, ey * s + dy / 60, nz) }
  local ri = r(TH[k] - 2 * pi)
  local d = RHO[k] - ri
  if d < 1.0 then bias[k] = -2 elseif d < 2.0 then bias[k] = -1 end
end)
local idx = A.shade(c, shell, n, SH, { amb = 0.1, wrap = 0.3, bias = bias, tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })

-- flame stripes: zig-zag bands crossing the whorls, fading out over the last 0.9 rad before the mouth
shell:each(function(x, y) local k = K(x, y)
  local th, u = TH[k], U[k]
  local left = TE - th
  if left > 0.9 and u > 0.12 then
    local ph = th * 9 / (2 * pi) + abs(u - 0.5) * 0.9
    local f = ph - floor(ph)
    local reach = min(1, (left - 0.9) / 1.6)
    if f < 0.34 and u > 1 - 0.88 * reach then c:put(x, y, SR[idx[k]], stok) end
  end
end)
-- growth ribs on the last whorl (no stripes there): fine darker lines across the tube
shell:each(function(x, y) local k = K(x, y)
  local left = TE - TH[k]
  if left >= 0 and left < 1.0 and U[k] > 0.15 then
    local ph = left / 0.2
    if ph - floor(ph) < 0.22 then A.step(c, idx, SH, x, y, -1, stok) end
  end
end)
-- cool bounce light on the lower-right rim of the body whorl
local rim = X.rim(n)
shell:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and U[k] > 0.8 and TE - TH[k] < 2 * pi and TE - TH[k] > 0.5 then c:put(x, y, BOUNCE, stok) end end)
-- glossy specular on the body whorl (upper-left crest): a short streak + cream glint
do
  local th = -pi * 0.78   -- upper-left of the coil
  for i = 0, 4 do
    local t = th + (i - 2) * 0.09
    while t > TE do t = t - 2 * pi end
    while t + 2 * pi <= TE do t = t + 2 * pi end
    local ro, ri = r(t), r(t - 2 * pi)
    local rr = ri + (ro - ri) * 0.36
    c:put(floor(CX + cos(t) * rr + .5), floor(CY + sin(t) * rr + .5), i == 2 and A.CREAM or SH[6], stok)
  end
end

-- mouth: flared pearly lip (oval facing down-left) with a dark interior
local ro, ri = r(TE), r(TE - 2 * pi)
local rm = (ro + ri) / 2
local ex, ey = cos(TE), sin(TE)
local tx, ty = -sin(TE), cos(TE)
local mx, my = CX + ex * rm + tx * 2.2, CY + ey * rm + ty * 2.2
local ra, rb = (ro - ri) / 2 + 1.8, 4.6
local lip = A.rell(mx, my, ex, ey, ra, rb)
local hole = A.rell(mx + tx * 0.9 - ex * 0.2, my + ty * 0.9 - ey * 0.2, ex, ey, ra - 2.4, rb - 2.0)
local ln = X.pillow(lip, 2.2)
local nidx = A.shade(c, lip, ln, NC, { amb = 0.15, wrap = 0.35, tok = ntok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- lip AO where it meets the body whorl
lip:each(function(x, y) if shell:has(x - 1, y - 1) and not shell:has(x, y) and not hole:has(x, y) then
  A.step(c, nidx, NC, x, y, -1, ntok) end end)
hole:each(function(x, y)
  local edge = not hole:has(x - 1, y) or not hole:has(x, y - 1)
  c:put(x, y, edge and NC[2] or "#3a1a30", ntok) end)

-- quirk: hermit crab peeking out of the mouth (eye stalks + one raised claw), hand-placed
do
  local hx, hy = floor(mx + .5), floor(my + .5)
  local CR = { K = A.INK, g = A.CREAM, a = "#ff9a5c", b = "#e8603b", d = "#a8352f", e = "#6e2038" }
  A.map(c, {
    "....gK.gK..",
    "....KK.KK..",
    ".....b..b..",
    ".ab..b..b..",
    "abd..b..b..",
    "bd..aaabbb.",
    ".bbaabbbbbd",
    "..dbbbbbbdd",
    "...d.d.d.d.",
  }, hx - 15, hy - 3, CR, ktok)
end
A.save(c, "ico-shell")
