-- _aC20_4: helper for lime-marmalade, lime-seed, lingonberry, lingonberry-cordial (Opus artist pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
D.CUTS6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }
D.CUTS5 = { 0.24, 0.42, 0.6, 0.78 }
D.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }

function D.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.tok(name) return { r = { name = name } } end
function D.find(ramp, hex) hex = (hex or ""):lower() for i, h in ipairs(ramp) do if h:lower() == hex then return i end end end
-- vertical-axis cylinder normals over x0..x1 (jars, bottles)
function D.vcylN(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-0.97, min(0.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  return n
end
-- lit + toned part; returns idx
function D.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return (X.tone(c, m, v, ramp, { cuts = o.cuts or (#ramp == 6 and D.CUTS6 or D.CUTS5), bias = o.bias, tok = o.tok }))
end
-- 1px polyline
function D.line(c, pts, hex, tok)
  c:line(pts, 1):each(function(x, y) c:put(x, y, hex, tok) end)
end
-- glossy berry: sphere tone, cool rim, specular; returns mask
function D.berry(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = c:ellipse(cx, cy, r, r)
  if o.cut then m:cut(o.cut) end
  local n = X.sphere(cx - 0.5, cy - 0.5, r, m)
  local tok = o.tok or D.tok("berry" .. cx .. "_" .. cy)
  D.tone(c, m, n, ramp, { amb = 0.04, wrap = 0.2, bias = o.bias, tok = tok })
  if o.rimc then
    local rim = X.rim(n)
    m:edge():each(function(x, y) local k = K(x, y) if (rim[k] or 0) > 0.7 and not (o.bias and o.bias[k]) then c:put(x, y, o.rimc, tok) end end)
  end
  return m, n, tok
end
function D.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  local out = app.params.out or "./"
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return D
