-- _aC2r0_1.lua: private helpers for ph/morel, ph/moringa, ph/moringa-seed, ph/morning-glory-seed (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos

-- small lit leaflet (oval with a V fold along its long axis), midrib light/dark split. returns mask, idx
function G.leaflet(c, cx, cy, ang, ra, rb, ramp, tok, bias, o)
  o = o or {}
  local ca, sa = cos(ang), sin(ang)
  local m = G.rell(cx, cy, ca, sa, ra, rb)
  if o.cut then m:cut(o.cut) end
  local n = {}
  local px, py = -sa, ca
  if px + py < 0 then px, py = -px, -py end
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local a = (dx * ca + dy * sa) / (ra + 0.5)
    local s = (dx * px + dy * py) / (rb + 0.5)
    local fold = (s < 0 and -0.45 or 0.45) + s * 0.4
    local nx, ny, nz = px * fold + ca * a * 0.5, py * fold + sa * a * 0.5, 1
    local l = sqrt(nx * nx + ny * ny + nz * nz)
    n[K(x, y)] = { nx / l, ny / l, nz / l }
  end)
  local idx = G.toneN(c, m, n, ramp, { tok = tok, bias = bias, cuts = o.cuts or { 0.2, 0.38, 0.55, 0.7, 0.85 }, amb = 0.14, wrap = 0.3 })
  if not o.norib and ra >= 2.4 then
    m:each(function(x, y)
      local dx, dy = x - cx, y - cy
      local a = (dx * ca + dy * sa) / (ra + 0.5)
      local s = (dx * px + dy * py)
      if abs(s) < 0.5 and a > -0.75 and a < 0.6 and not (bias and bias[K(x, y)]) then
        c:put(x, y, ramp[(idx[K(x, y)] or 3) >= 4 and #ramp or 3], tok)
      end
    end)
  end
  return m, idx
end

-- 1px polyline in a colour (owner token optional)
function G.pline(c, pts, hex, tok)
  c:line(pts, 1):each(function(x, y) c:put(x, y, hex, tok) end)
end
return G
