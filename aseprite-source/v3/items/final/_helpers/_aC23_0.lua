-- _aC23_0.lua: private helpers for ph/meadowsweet, meadowsweet-tea, melon, melon-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.save(c, name, norecentre)
  local out = app.params.out or (DIR .. "/../ph/")
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end

-- light + tone; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } })
  return idx, v
end

-- ellipsoid normals over mask (rz controls bulge)
function A.ellN(cx, cy, rx, ry, m, rz)
  local n = {}
  m:each(function(x, y)
    local a, b = (x - cx) / (rx + 0.5), (y - cy) / (ry + 0.5)
    local q = 1 - a*a - b*b
    n[K(x, y)] = { norm(a, b, sqrt(max(q, 0.02)) * (rz or 1)) }
  end)
  return n
end

function A.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local a, b = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if a*a + b*b <= 1 then m:set(x, y) end
  end end
  return m
end

-- 1px polyline painter (sampled)
function A.stroke(c, pts, col, tok, m)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local nn = max(abs(x1 - x0), abs(y1 - y0)) * 2 + 1
    for j = 0, nn do local t = j / nn
      local x, y = floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5)
      c:put(x, y, col, tok) if m then m:set(x, y) end
    end
  end
end
return A
