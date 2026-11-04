-- _aD10_4.lua: private helpers for ph/pua-kenikeni-seed, puddle-hat, pumpkin-butter, quail-egg-rice-bowl (final pass, Sonnet high).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS5 = { 0.22, 0.42, 0.62, 0.82 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + tone a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts = o.cuts or (#ramp == 5 and A.CUTS5 or A.CUTS6)
  local idx = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
  return idx, v
end

-- flat-ish slab: pillow normals with bevel R, optional tilt of the flat face {tx,ty}
function A.slab(m, R, tilt)
  local n = X.pillow(m, R)
  if tilt then
    for k, v in pairs(n) do n[k] = { norm(v[1] + tilt[1], v[2] + tilt[2], v[3]) } end
  end
  return n
end

-- re-tone one pixel by delta steps using idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- pixels of m that 4-touch mask o (contact / separation row)
function A.touch(m, o)
  local r = HP.mask()
  m:each(function(x, y)
    if o:has(x + 1, y) or o:has(x - 1, y) or o:has(x, y + 1) or o:has(x, y - 1) then r:set(x, y) end
  end)
  return r
end

-- Bresenham polyline of single pixels
function A.pline(c, pts, hex, tok)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local dx, dy = abs(x1 - x0), -abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local e = dx + dy
    while true do
      c:put(x0, y0, hex, tok)
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * e
      if e2 >= dy then e = e + dy x0 = x0 + sx end
      if e2 <= dx then e = e + dx y0 = y0 + sy end
    end
  end
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end


-- leaf blade with midrib and angled veins. o: bias, tok, veins {t*len offsets}, fold, cut(mask), amb, wrap
function A.vleaf(c, ax, ay, cx, cy, bx, by, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.4 })
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" .. tostring(m) } }
  local bias = o.bias or {}
  G.toneN(c, m, n, ramp, { bias = bias, tok = tok, amb = o.amb or 0.14, wrap = o.wrap or 0.28, cuts = A.CUTS6 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] and bias[k] < 0 then return end
    if abs(s) < (o.rib or 0.14) and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and ramp[6] or ramp[3], tok) return end
    for _, vt in ipairs(o.veins or {}) do
      local d = t * len - (vt + abs(s) * (o.slant or 2.3))
      if d > -0.55 and d < 0.55 and abs(s) > 0.26 and abs(s) < 0.86 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
    end
  end)
  return m, n, T, S, len, tok
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- 4-point star mask + faceted normals: f=(|dx|/A)^p+(|dy|/B)^p<=1; creased ridges on the axes
function A.star(cx, cy, Ax, By, p, H)
  local m, n = HP.mask(), {}
  for y = floor(cy - By) - 1, floor(cy + By) + 1 do for x = floor(cx - Ax) - 1, floor(cx + Ax) + 1 do
    local dx, dy = x - cx, y - cy
    local ax, ay = abs(dx) / Ax, abs(dy) / By
    local f = ax ^ p + ay ^ p
    if f <= 1 then
      m:set(x, y)
      local fx = ax > 0 and p * ax ^ (p - 1) / Ax * (dx > 0 and 1 or -1) or 0
      local fy = ay > 0 and p * ay ^ (p - 1) / By * (dy > 0 and 1 or -1) or 0
      local tx, ty = max(-1.6, min(1.6, H * fx)), max(-1.6, min(1.6, H * fy))
      n[K(x, y)] = { norm(tx, ty, 1) }
    end
  end end
  return m, n
end
-- local frame along a direction: W(u,v) -> x,y ; UV(x,y) -> u,v (v>0 = lower-right side)
function A.frame(ox, oy, dx, dy)
  local l = sqrt(dx * dx + dy * dy) local ux, uy = dx / l, dy / l
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local F = { ux = ux, uy = uy, px = px, py = py }
  function F.W(u, v) return ox + u * ux + v * px, oy + u * uy + v * py end
  function F.P(u, v) local x, y = F.W(u, v) return { x, y } end
  function F.UV(x, y) local rx, ry = x - ox, y - oy return rx * ux + ry * uy, rx * px + ry * py end
  return F
end
return A
