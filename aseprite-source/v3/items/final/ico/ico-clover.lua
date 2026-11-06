-- ico-clover (final, Opus). Shamrock: three heart-shaped leaflets on a slim, gently S-curved stalk. Each leaflet
-- is folded along its midrib (two lit planes, pillow edges), 6-tone moss ramp, dark midrib groove, 2-3 thin side
-- veins, the pale chevron watermark clover leaves carry, dark AO where the leaflets crowd the centre and a small
-- contact shadow on the stalk under them. Stalk: 3 px tube with a lit edge and a fine fibre line.
-- quirk: a tiny fourth leaflet is just unfurling between the top and right leaves (luck on the way).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, cos, sin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin, math.pi
local c = A.new("ico-clover")
local LEAF  = { "#17423a", "#1f5c44", "#2b7a48", "#43994c", "#69b955", "#a3d873" }
local CHEV  = "#bde58a"
local STALK = { "#1f5040", "#2f7446", "#4f9a50", "#7fc062", "#a8d878" }
local CX, CY = 32, 27

-- stalk first (leaves overlap its top)
local ts = A.tok("stalk")
local sm, sn, sT, sS = A.tube({ { CX, CY + 2 }, { CX + 1, CY + 12 }, { CX - 3, CY + 20 }, { CX + 3, CY + 29 } },
  function(t) return 1.45 - t * 0.25 end)
local sb = {}
sm:each(function(x, y) local k = K(x, y) if sT[k] < 0.22 then sb[k] = -1 end if sT[k] < 0.12 then sb[k] = -2 end end)
A.shade(c, sm, sn, STALK, { tok = ts, bias = sb, cuts = { 0.2, 0.4, 0.6, 0.8 } })

-- leaflets
local tl = A.tok("leaf")
local all = HP.mask()
local function leaflet(ang, L, W, order)
  local ux, uy = cos(ang), sin(ang)          -- along leaflet, from centre out
  local vx, vy = -uy, ux                       -- across
  local m = HP.mask()
  local ox, oy = CX + ux * 1.0, CY + uy * 1.0
  for y = floor(CY - L - W) - 2, floor(CY + L + W) + 2 do for x = floor(CX - L - W) - 2, floor(CX + L + W) + 2 do
    local dx, dy = x - ox, y - oy
    local a = dx * ux + dy * uy
    local b = dx * vx + dy * vy
    -- heart: two lobes at the far end + a wedge to the base
    local la = L * 0.66
    local lr = W * 0.56
    local inL = (a - la) ^ 2 + (b - lr * 0.86) ^ 2 <= lr * lr or (a - la) ^ 2 + (b + lr * 0.86) ^ 2 <= lr * lr
    local inW = a >= 0 and a <= la + 1 and abs(b) <= (a / (la + 1)) * (W * 0.98) + 0.7
    -- notch at the tip
    local notch = a > la + lr * 0.35 and abs(b) < 1.0
    if (inL or inW) and not notch and a >= -0.6 then m:set(x, y) end
  end end
  m:cut(all)
  -- normals: pillow edges + fold along the midrib
  local n0, d = X.pillow(m, 2.2)
  local n = {}
  local S, Aa = {}, {}
  m:each(function(x, y)
    local k = K(x, y)
    local dx, dy = x - ox, y - oy
    local a = dx * ux + dy * uy
    local b = dx * vx + dy * vy
    local s = b >= 0 and 1 or -1
    local f = 0.32
    local nx, ny, nz = n0[k][1] - vx * s * f, n0[k][2] - vy * s * f, n0[k][3]
    local l = sqrt(nx * nx + ny * ny + nz * nz)
    n[k] = { nx / l, ny / l, nz / l }
    S[k], Aa[k] = b, a
  end)
  local bias = {}
  X.ao(bias, m, all, 2, -1)
  m:each(function(x, y) local k = K(x, y) if Aa[k] < 1.5 then bias[k] = (bias[k] or 0) - 1 end end)
  local idx = A.shade(c, m, n, LEAF, { tok = tl, bias = bias, amb = 0.1, wrap = 0.3 })
  -- midrib groove + veins
  m:each(function(x, y)
    local k = K(x, y)
    local a, b = Aa[k], S[k]
    if abs(b) < 0.5 and a > 1.5 and a < L * 0.85 then c:put(x, y, LEAF[max(1, idx[k] - 2)], tl) end
    -- side veins: curve out from the midrib toward the lobes
    for _, va in ipairs{ 3.8, 6.8 } do
      local along = a - va - abs(b) * 0.55
      if abs(along) < 0.5 and abs(b) > 1.2 and abs(b) < W * 0.75 and d[k] > 1.2 then
        c:put(x, y, LEAF[max(1, idx[k] - 1)], tl) end
    end
    -- pale chevron watermark
    local ch = a - (L * 0.42) - abs(b) * -0.6
    if abs(a - (L * 0.36 + abs(b) * 0.55)) < 0.55 and abs(b) > 1 and abs(b) < W * 0.62 and d[k] > 1.5 then
      c:put(x, y, LEAF[min(6, idx[k] + 1)], tl) end
  end)
  -- one lit pop on the upper-left lobe
  local px, py = floor(ox + ux * L * 0.66 + vx * -W * 0.48 + 0.5), floor(oy + uy * L * 0.66 + vy * -W * 0.48 + 0.5)
  if m:has(px, py) then c:put(px, py, LEAF[6], tl) end
  all:add(m)
  return m
end
-- order matters for overlap: lower-left, lower-right, then top over both
leaflet(pi * 0.93, 14, 9.5, 1)
leaflet(pi * 0.07, 14, 9.5, 2)
leaflet(-pi * 0.5, 14.5, 9.5, 3)
-- centre hub: dark cup where the leaflets join
for _, p in ipairs{ { 32, 27, 2 }, { 32, 28, 2 }, { 31, 28, 3 }, { 33, 28, 3 } } do
  c:put(p[1], p[2], LEAF[p[3]], tl) end
-- glint


-- quirk: tiny fourth leaflet unfurling between top and right leaves
local tq = A.tok("bud")
local qa = -pi * 0.25
local qx, qy = CX + cos(qa) * 16.5, CY + sin(qa) * 16.5
local qm = A.ell(qx, qy, 2.6, 2.4):cut(all)
qm:cut(c:rect(floor(qx + .5), floor(qy - 3), floor(qx + .5), floor(qy - 1.6)))
local qn = X.sphere(qx, qy, 2.6, qm)
A.shade(c, qm, qn, LEAF, { tok = tq, amb = 0.15, wrap = 0.3 })
c:put(floor(qx + .5), floor(qy + .5), LEAF[2], tq)

A.save(c, "ico-clover")
