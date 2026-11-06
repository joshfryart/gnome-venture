-- ico-eyes (final, Opus). A pair of tall oval eyeballs pressed side by side, glancing up and to the right.
-- Material: per-pixel ellipsoid light on a 6-tone warm-white sclera (cool-violet shade), a lid-shadow band along
-- the top, ambient shading where the two eyes touch, faint pink veins at the outer corners; irises in a 5-tone
-- moss green with a dark limbal ring and radial fibres, ink pupils, a wet cream glint + a second small glint.
-- quirk: only the right eye wears three curly lashes.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, atan, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.atan, math.pi
local c = A.new("ico-eyes")
local SC = { "#4f4474", "#8379a6", "#b5abc8", "#dcd3e2", "#f3ecee", "#fff8ee" }
local IR = { "#173f36", "#2c6e47", "#469a55", "#72bd62", "#addb7c" }
local INK, CREAM, VEIN = "#2b1c26", "#fff4d6", "#e7a3b4"
local RX, RY, CY = 10.6, 14.6, 33
local EYES = { { cx = 43, back = true }, { cx = 21.5 } }  -- right eye first (behind), left overlaps it
local masks = {}

for i, e in ipairs(EYES) do
  local tok = A.tok("eye" .. i)
  local m, n = HP.mask(), {}
  for y = floor(CY - RY) - 1, floor(CY + RY) + 1 do for x = floor(e.cx - RX) - 1, floor(e.cx + RX) + 1 do
    local u, v = (x - e.cx) / (RX + 0.45), (y - CY) / (RY + 0.45)
    local q = u * u + v * v
    if q <= 1 then m:set(x, y)
      local nx, ny, nz = u, v, sqrt(max(1 - q, 0.02)) * 0.9
      local l = sqrt(nx * nx + ny * ny + nz * nz) n[K(x, y)] = { nx / l, ny / l, nz / l } end
  end end
  if i == 2 then -- left eye sits in front: carve the right eye under it
    masks[1]:cut(m)
  end
  local bias = {}
  -- lid shadow band along the top
  m:each(function(x, y) local u, v = (x - e.cx) / RX, (y - CY) / RY
    if v < -0.72 + 0.12 * u * u then bias[K(x, y)] = -1 end end)
  e.m, e.n, e.bias, e.tok = m, n, bias, tok
  masks[i] = m
end
-- ambient shading on the back eye where the front eye overlaps it
X.ao(EYES[1].bias, EYES[1].m, EYES[2].m, 2, -1)
for i, e in ipairs(EYES) do
  e.idx = A.shade(c, e.m, e.n, SC, { tok = e.tok, amb = 0.12, wrap = 0.4, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, bias = e.bias })
  -- veins near the outer corner
  local side = (i == 1) and 1 or -1
  local vx = floor(e.cx + side * (RX - 2))
  for _, p in ipairs{ { 0, 0 }, { -side, 1 }, { -side * 2, 1 }, { 0, 4 }, { -side, 5 } } do
    local x, y = vx + p[1], CY + 2 + p[2]
    if e.m:has(x, y) and not (i == 1 and EYES[2].m:has(x, y)) then c:put(x, y, VEIN, e.tok) end
  end
  -- iris: looking up-right; an ellipse foreshortened on the ball
  local ix, iy = e.cx + 3.2, CY - 2.5
  local irm = A.ell(ix, iy, 5.4, 6.2):clip(e.m)
  if i == 1 then irm:cut(EYES[2].m) end
  local iv = {}
  irm:each(function(x, y) local k = K(x, y)
    local d = sqrt(((x - ix) / 5.4) ^ 2 + ((y - iy) / 6.2) ^ 2)
    local ang = atan(y - iy, x - ix)
    local fib = (floor((ang + pi) / (2 * pi) * 14 + 0.5) % 2 == 0) and 0.1 or 0
    local lit = -((x - ix) + (y - iy)) / 10
    iv[k] = 0.45 + lit * 0.6 + fib - (d > 0.8 and 0.4 or 0)
  end)
  X.tone(c, irm, iv, IR, { cuts = { 0.2, 0.38, 0.55, 0.75 }, tok = e.tok })
  -- pupil
  local pm = A.ell(ix + 0.3, iy - 0.2, 2.4, 2.8):clip(irm)
  c:fillMask(pm, INK)
  -- glints
  c:put(floor(ix) - 2, floor(iy) - 3, CREAM, e.tok) c:put(floor(ix) - 1, floor(iy) - 3, CREAM, e.tok)
  c:put(floor(ix) - 2, floor(iy) - 2, CREAM, e.tok)
  c:put(floor(ix) + 2, floor(iy) + 2, IR[5], e.tok)
  -- sclera specular on the upper-left of the ball
  c:put(floor(e.cx) - 5, CY - 8, CREAM, e.tok) c:put(floor(e.cx) - 6, CY - 7, SC[6], e.tok)
end
-- quirk: three curly lashes on the right eye's upper lid
local e = EYES[1]
for _, l in ipairs{ { 38, { { 0, 0 }, { -1, -1 }, { -1, -2 }, { 0, -3 } } }, { 43, { { 0, 0 }, { 0, -1 }, { 0, -2 }, { 1, -3 } } },
  { 48, { { 0, 0 }, { 1, -1 }, { 1, -2 }, { 2, -3 } } } } do
  local x0 = l[1]
  local y0
  for y = CY - 16, CY do if e.m:has(x0, y) then y0 = y - 1 break end end
  for _, p in ipairs(l[2]) do c:put(x0 + p[1], y0 + p[2], INK) end
end
A.save(c, "ico-eyes")
