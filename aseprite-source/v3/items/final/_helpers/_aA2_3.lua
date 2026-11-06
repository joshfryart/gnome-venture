-- _aA2_3.lua: private helpers for ico-chart, ico-check, ico-cherry, ico-chicken (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, asin = math.sqrt, math.floor, math.max, math.min, math.abs, math.asin
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- per-pixel light snapped to a 6-tone ramp (dark..light); returns idx table
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias, tok = o.tok })
end

-- upright solid of revolution seen a little from above. wfn(h) half width at axis height h; tilt = ry of a section
function A.vessel(cx, h0, h1, wfn, tilt)
  local m, n, I = HP.mask(), {}, {}
  for y = floor(h0) - 1, floor(h1 + tilt) + 2 do
    for x = floor(cx - 31), floor(cx + 31) do
      local h, u = y, 0
      for _ = 1, 4 do
        local w = wfn(min(max(h, h0), h1))
        u = (x - cx) / (w + 0.5)
        h = y - tilt * sqrt(max(0, 1 - u * u))
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

function A.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end

-- nudge the tone index of an already painted pixel
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- star polygon: n spikes, radii from rfn(i) (outer) and rin (inner), rotation a0
function A.star(cx, cy, n, rfn, rin, a0)
  local pts = {}
  for i = 0, 2 * n - 1 do
    local a = a0 + i * math.pi / n
    local r = (i % 2 == 0) and rfn(i // 2) or (type(rin) == "function" and rin(i // 2) or rin)
    pts[#pts + 1] = { cx + math.cos(a) * r, cy + math.sin(a) * r }
  end
  return HP.poly(pts)
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- paint a rows map with a palette (alias)
-- capsule/stroke mask along a polyline with radius r (round caps)
function A.stroke(pts, r)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local ax, ay, bx, by = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local vx, vy = bx - ax, by - ay
    local L2 = vx*vx + vy*vy
    for y = floor(min(ay, by) - r) - 1, floor(max(ay, by) + r) + 1 do
      for x = floor(min(ax, bx) - r) - 1, floor(max(ax, bx) + r) + 1 do
        local t = max(0, min(1, ((x - ax)*vx + (y - ay)*vy) / L2))
        local dx, dy = x - (ax + vx*t), y - (ay + vy*t)
        if dx*dx + dy*dy <= r*r then m:set(x, y) end
      end
    end
  end
  return m
end
return A
