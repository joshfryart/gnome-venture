-- dried-apple-rings (final, Opus single pass). Three thin leathery apple rings threaded on a sagging twisted twine,
-- knotted at both ends with frayed tails. Material: per-pixel pillow light on each ring with radial wrinkles
-- (6-tone cream-tan flesh), a red skin rim lit top-left, a faint five-point core star round the hole, AO inside
-- each hole, twine twist (diagonal 3-tone barber stripe), one waxy glint per ring.
-- quirk: somebody has already taken a bite out of the right-hand ring.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("dried-apple-rings")

local FL   = { "#7a4630", "#a86a3c", "#cf9656", "#e8bc78", "#f6daa0", "#fff2cc" }
local SKIN = { "#5e1c30", "#8e2434", "#c0383a", "#e2604a" }
local TW   = { "#6a4a2e", "#a07a48", "#d2aa6a", "#f0d49a" }
local twk = { r = { name = "twine" } }

-- twine: sagging curve x 8..56
local X0, X1, YT, SAG = 10, 54, 14, 17
local function ty(x) local u = (x - X0) / (X1 - X0) return YT + SAG * 4 * u * (1 - u) end
local twm = HP.mask()
for x = X0, X1 do
  local y0, y1 = ty(x), ty(x + 1)
  for yy = floor(min(y0, y1) + .5), floor(max(y0, y1) + .5) do twm:set(x, yy) end
end
local function twist(m, ph)
  m:each(function(x, y) local q = (x + y + (ph or 0)) % 3
    c:put(x, y, q == 0 and TW[1] or (q == 1 and TW[2] or TW[3]), twk) end)
end
twist(twm)
-- end knots + frayed tails
for _, e in ipairs{ { X0, -1 }, { X1, 1 } } do
  local x, y = e[1], floor(ty(e[1]) + .5)
  local km = HP.ellipse(x, y, 1, 1)
  km:each(function(xx, yy) c:put(xx, yy, (xx - x) + (yy - y) < 0 and TW[4] or TW[2], twk) end)
  c:put(x + e[2] * 1, y + 2, TW[2], twk) c:put(x + e[2] * 1, y + 3, TW[3], twk) c:put(x + e[2] * 2, y + 4, TW[2], twk)
  c:put(x + e[2] * -1, y + 2, TW[3], twk) c:put(x + e[2] * -1, y + 3, TW[1], twk)
end

-- rings
local rings = {
  { x = 18.5, r = 6.4, tilt = -0.25, seed = 1 },
  { x = 32,   r = 6.8, tilt = 0.05, seed = 2 },
  { x = 45.5, r = 6.4, tilt = 0.3, seed = 3, bite = true },
}
for i, R in ipairs(rings) do
  local cx = R.x
  local hy = ty(cx)                 -- the hole hangs on the twine
  local cy = hy + 0.4                -- threaded through the middle
  local hx = cx
  local tok = { r = { name = "ring" .. i } }
  local rx, ry = R.r, R.r * 0.92
  -- wavy, shrivelled rim
  local m = HP.mask()
  for y = floor(cy - ry - 2), floor(cy + ry + 2) do for x = floor(cx - rx - 2), floor(cx + rx + 2) do
    local dx, dy = x - cx, y - cy
    local a = atan(dy, dx)
    local rr = 1 + 0.045 * sin(a * 7 + R.seed * 1.7) + 0.04 * sin(a * 3 + R.seed)
    if (dx / (rx * rr + 0.4)) ^ 2 + (dy / (ry * rr + 0.4)) ^ 2 <= 1 then m:set(x, y) end
  end end
  local hole = HP.mask()
  for y = floor(hy) - 3, floor(hy) + 3 do for x = floor(hx) - 3, floor(hx) + 3 do
    if (x - hx) ^ 2 + (y - hy) ^ 2 <= 6.8 then hole:set(x, y) end end end
  if R.bite then
    local bm = HP.ellipse(floor(cx + rx * 0.8), floor(cy + ry * 0.55), 3, 3)
    :add(HP.ellipse(floor(cx + rx * 0.45), floor(cy + ry * 0.95), 2, 2))
    m:cut(bm)
  end
  m:cut(hole)
  local n = X.pillow(m, 2.6)
  -- radial wrinkles
  A.bump(n, function(x, y)
    local dx, dy = x - cx, y - cy
    local a = atan(dy, dx)
    local w = sin(a * 9 + R.seed * 2.3 + sqrt(dx * dx + dy * dy) * 0.4) * 0.28
    return -dy / (abs(dx) + abs(dy) + 1) * w, dx / (abs(dx) + abs(dy) + 1) * w
  end)
  local bias = {}
  X.ao(bias, m, hole, 1, -1)
  local idx = A.shade(c, m, n, FL, { tok = tok, amb = 0.08, wrap = 0.25, cuts = { 0.3, 0.46, 0.62, 0.77, 0.9 } })
  for k, b in pairs(bias) do local x, y = k % 1024 - 256, k // 1024 - 256 A.step(c, idx, FL, x, y, b, tok) end
  -- skin rim: outer edge, lit top-left
  local edge = m:edge()
  edge:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local d = sqrt((dx / rx) ^ 2 + (dy / ry) ^ 2)
    if d > 0.72 then
      local lit = (-dx * 0.6 - dy * 0.8) / sqrt(dx * dx + dy * dy + 0.01)
      local bitten = R.bite and (dx > rx * 0.25 and dy > ry * 0.1)
      if bitten then
        c:put(x, y, FL[max(2, (idx[K(x, y)] or 3) - 1)], tok)    -- fresh bite edge: flesh, no skin
      else
        c:put(x, y, SKIN[lit > 0.35 and 4 or (lit > -0.2 and 3 or 2)], tok)
      end
    end
  end)
  -- core star: five faint seed-cell pips round the hole
  for j = 0, 4 do
    local a = j * 2 * pi / 5 - pi / 2 + R.seed
    local px, py = floor(hx + cos(a) * 3.6 + .5), floor(hy + sin(a) * 3.6 + .5)
    if m:has(px, py) and not edge:has(px, py) then A.step(c, idx, FL, px, py, -1, tok) end
  end
  -- hole rim: dark lower-right inner lip, lit upper-left lip on the far side
  hole:grow(1):each(function(x, y) if m:has(x, y) then
    if x >= hx and y >= hy - 0.5 then A.step(c, idx, FL, x, y, 1, tok) elseif x < hx and y < hy then A.step(c, idx, FL, x, y, -1, tok) end end end)
  -- twine shows through the hole
  hole:each(function(x, y) if twm:has(x, y) then
    c:put(x, y, ((x + y) % 3 == 0) and TW[1] or TW[2], twk) end end)
  -- AO where twine meets the ring top
  -- waxy glint
  local gx, gy = floor(cx - rx * 0.5 + .5), floor(cy + ry * 0.05 + .5)
  if m:has(gx, gy) and m:has(gx + 1, gy) then c:put(gx, gy, "#fffbe8", tok) c:put(gx + 1, gy, FL[6], tok) end
  if R.bite then
    -- tooth marks: little scallops on the bite edge
    for _, p in ipairs{ { 0.62, 0.3 }, { 0.55, 0.62 }, { 0.3, 0.86 } } do
      local x, y = floor(cx + rx * p[1] + .5), floor(cy + ry * p[2] + .5)
      if m:has(x, y) then c:put(x, y, FL[5], tok) end
    end
  end
end
A.save(c, "dried-apple-rings")
