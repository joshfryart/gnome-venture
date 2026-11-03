-- _aR20_2.lua: private helpers for ph/bitter-melon, bitter-melon-seed, black-bean, black-bean-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
function A.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- light + quantise a normal field to a 6 tone ramp
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
-- round berry: sphere light, cool reflected rim, crown, specular. returns mask, normals, idx
function A.berry(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - 0.5, cy - 0.5, r, m)
  local tok = o.tok or { r = { name = "berry" .. cx .. "_" .. cy } }
  local idx = A.tone(c, m, n, ramp, { amb = 0.05, wrap = 0.25, bias = o.bias, tok = tok })
  local rim = X.rim(n)
  if o.bounce then m:edge():each(function(x, y) if rim[K(x, y)] > 0.75 then c:put(x, y, o.bounce, tok) end end) end
  -- waxy bloom: pale dusty flecks on the mid tones (2x2 cells, deterministic)
  if o.bloom then m:shrink(1):each(function(x, y) local i = idx[K(x, y)]
    if i and i >= 3 and i <= 4 and X.hash(floor(x / 2), floor(y / 2), floor(cx * 7 + cy)) > 0.7 then c:put(x, y, ramp[i + 1], tok) end end) end
  -- crown (navel) toward the lower right
  if o.crown then
    local qx, qy = floor(cx + r * 0.25 + 0.5), floor(cy + r * 0.3 + 0.5)
    c:put(qx, qy, ramp[1], tok) c:put(qx - 1, qy, ramp[2], tok) c:put(qx + 1, qy, ramp[2], tok)
    c:put(qx, qy - 1, ramp[2], tok) c:put(qx, qy + 1, ramp[2], tok)
    c:put(qx - 1, qy - 1, ramp[4], tok)
  end
  if o.spec ~= false then
    local sx, sy = floor(cx - r * 0.45 + 0.5), floor(cy - r * 0.5 + 0.5)
    c:put(sx, sy, o.spec or A.CREAM, tok)
    if r >= 4 then c:put(sx + 1, sy, ramp[6], tok) c:put(sx, sy + 1, ramp[6], tok) end
  end
  return m, n, idx, tok
end
-- 1 px pixel line (bresenham)
function A.line(c, x0, y0, x1, y1, hex, tok)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    c:put(x0, y0, hex, tok)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
end
-- oval leaf along a quadratic A-C-B: lit fold, midrib, side veins, dark base. returns mask
function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * math.sin(math.pi * min(1, t * 0.96 + 0.05)) ^ 0.75)
  end, { fold = o.fold or 0.45 })
  local tok = o.tok or { r = { name = "leaf" .. ax .. ay } }
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.12 then bias[k] = -1 end end)
  A.tone(c, m, n, ramp, { amb = 0.12, wrap = 0.28, bias = bias, tok = tok })
  local veins = o.veins or { 0.3, 0.5, 0.7 }
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.08 and t < 0.88 then c:put(x, y, s <= 0 and ramp[6] or ramp[3], tok) end
    for _, vt in ipairs(veins) do
      local d = t * len - (vt * len + abs(s) * 2.6)
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
    end
  end)
  return m, T, S
end
function A.fin(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
-- polar lobed leaf (palmate): R(theta) = base radius with nl lobes, pointed tips; ang = direction of the middle lobe
function A.palm(cx, cy, R, nl, ang, depth, spread)
  local m = HP.mask()
  spread = spread or 2.4
  depth = depth or 0.45
  for y = floor(cy - R - 2), floor(cy + R + 2) do for x = floor(cx - R - 2), floor(cx + R + 2) do
    local dx, dy = x - cx, y - cy
    local r = sqrt(dx*dx + dy*dy)
    local a = math.atan(dy, dx) - ang
    a = (a + math.pi) % (2 * math.pi) - math.pi
    if abs(a) <= spread then
      local ph = (a / spread * 0.5 + 0.5) * nl          -- 0..nl
      local f = abs((ph - floor(ph)) - 0.5) * 2          -- 0 lobe centre .. 1 notch
      local rr = R * (1 - depth * f ^ 1.3) * (1 - 0.25 * (abs(a) / spread) ^ 2)
      if r <= rr then m:set(x, y) end
    elseif r <= R * 0.22 then m:set(x, y) end
  end end
  return m
end
-- remove pixels beyond a jagged tear line from (ax,ay) to (bx,by): side = pixels where cross > 0
function A.tear(m, ax, ay, bx, by, amp, seed)
  local vx, vy = bx - ax, by - ay
  local l = sqrt(vx*vx + vy*vy)
  local cut = {}
  m:each(function(x, y)
    local t = ((x - ax) * vx + (y - ay) * vy) / l
    local s = ((x - ax) * vy - (y - ay) * vx) / l
    local j = (X.hash(floor(t / 2), 0, seed or 3) - 0.5) * 2 * (amp or 1.5)
    if s > j then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end
return A
