-- _aA1_2.lua: private helpers for ico-bird, ico-blossom, ico-boat, ico-bone (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, asin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.asin, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.SPEC, A.CREAM, A.INK = "#fff4d6", "#fff4d6", "#2b1c26"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- lit tone from a normal field (6-tone ramp dark..light)
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias, tok = o.tok })
end

-- upright vessel of revolution seen slightly from above (barrels, baskets, pots).
-- wfn(h) = half width at height h (screen y of the axis), tilt = ellipse ry of a horizontal section.
-- returns mask, normals, info[k] = {u=-1..1 across, phi=angle, h=height}
function A.vessel(cx, h0, h1, wfn, tilt)
  local m, n, I = HP.mask(), {}, {}
  for y = floor(h0) - 1, floor(h1 + tilt) + 2 do
    for x = floor(cx - 30), floor(cx + 30) do
      local h, u, w = y, 0, wfn(min(max(y, h0), h1))
      for _ = 1, 3 do
        w = wfn(min(max(h, h0), h1))
        u = (x - cx) / (w + 0.5)
        local nz = sqrt(max(0, 1 - u * u))
        h = y - tilt * nz
      end
      if abs(u) <= 1 and h >= h0 and h <= h1 then
        local nz = sqrt(max(0.02, 1 - u * u))
        local dw = (wfn(min(h + 1, h1)) - wfn(max(h - 1, h0))) / 2
        local k = K(x, y)
        m:set(x, y)
        n[k] = { G.norm(u, -dw * 1.2 + 0.08, nz) }
        I[k] = { u = u, phi = asin(max(-1, min(1, u))), h = h }
      end
    end
  end
  return m, n, I
end

function A.ellM(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end

-- paint a tone-index adjust on already-placed pixels by re-reading idx table
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- char map painter with a palette table, (x0,y0) = top-left
function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- height-field modelling (aA1_2): primitives return height >0 inside; smooth union keeps soft fillets
function A.smax(a, b, k)
  k = k or 2
  local h = max(k - abs(a - b), 0) / k
  return max(a, b) + h * h * k * 0.25
end
function A.capsuleH(ax, ay, bx, by, r)
  local vx, vy = bx - ax, by - ay
  local L2 = vx * vx + vy * vy
  return function(x, y)
    local t = max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / L2))
    local dx, dy = x - (ax + vx * t), y - (ay + vy * t)
    local q = r * r - dx * dx - dy * dy
    return q > 0 and sqrt(q) or -(sqrt(-q))
  end
end
function A.sphereH(cx, cy, r, sx, sy)
  sx, sy = sx or 1, sy or 1
  return function(x, y)
    local dx, dy = (x - cx) / sx, (y - cy) / sy
    local q = r * r - dx * dx - dy * dy
    return q > 0 and sqrt(q) or -(sqrt(-q))
  end
end
-- build mask + normals + concavity (crease) from a height function over a box
function A.field(hf, x0, y0, x1, y1, zs)
  zs = zs or 1
  local m, n, H, C = HP.mask(), {}, {}, {}
  for y = y0, y1 do for x = x0, x1 do
    local h = hf(x, y)
    if h > 0 then
      local k = K(x, y)
      m:set(x, y) H[k] = h
      local gx = (hf(x + 0.5, y) - hf(x - 0.5, y))
      local gy = (hf(x, y + 0.5) - hf(x, y - 0.5))
      n[k] = { G.norm(-gx * zs, -gy * zs, 1) }
      C[k] = hf(x + 1, y) + hf(x - 1, y) + hf(x, y + 1) + hf(x, y - 1) - 4 * h
    end
  end end
  return m, n, H, C
end
return A
