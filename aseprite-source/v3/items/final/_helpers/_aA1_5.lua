-- _aA1_5.lua: private helpers for ico-brain, ico-bread, ico-bridge, ico-bucket (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, asin = math.sqrt, math.floor, math.max, math.min, math.abs, math.asin
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.SPEC, A.CREAM, A.INK = "#fff4d6", "#fff4d6", "#2b1c26"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- lit tone from a normal field (ramp dark..light)
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts = o.cuts
  if not cuts then
    cuts = {}
    for i = 1, #ramp - 1 do cuts[i] = 0.12 + 0.76 * (i - 1) / (#ramp - 2) end
  end
  return X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
end

-- upright vessel of revolution seen slightly from above. wfn(h) half width at axis height h.
function A.vessel(cx, h0, h1, wfn, tilt)
  local m, n, I = HP.mask(), {}, {}
  for y = floor(h0) - 1, floor(h1 + tilt) + 2 do
    for x = floor(cx - 30), floor(cx + 30) do
      local h, u, w = y, 0, wfn(min(max(y, h0), h1))
      for _ = 1, 3 do
        w = wfn(min(max(h, h0), h1))
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

function A.ellM(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end

-- shift tone index of an already-painted pixel by d
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

-- stamp a thick polyline (round brush radius r) into a mask
function A.stroke(pts, r, m)
  m = m or HP.mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local L = sqrt((b[1] - a[1])^2 + (b[2] - a[2])^2)
    local n = max(1, math.ceil(L * 3))
    for j = 0, n do
      local t = j / n
      local x, y = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
      for yy = floor(y - r) - 1, floor(y + r) + 1 do for xx = floor(x - r) - 1, floor(x + r) + 1 do
        if (xx - x)^2 + (yy - y)^2 <= r * r + 0.15 then m:set(xx, yy) end
      end end
    end
  end
  return m
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
