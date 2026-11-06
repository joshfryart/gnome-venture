-- _aB34_4.lua: private helpers for ph/glowcap-lantern, glowing-bead, glowstone-lantern, gnat-dust (final pass, Opus).
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
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + tone a normal field
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- vertical cylinder normals across x0..x1 (optionally bulged in y by ry for domes)
function A.vcylN(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-0.96, min(0.96, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  return n
end

-- emissive: tone by distance to a glow centre (bright core), mixed with a little directional light
function A.glow(c, m, cx, cy, R, ramp, o)
  o = o or {}
  local n = o.n
  local v = {}
  local lam = n and X.light(n, { amb = 0.1, wrap = 0.3 }) or nil
  m:each(function(x, y) local k = K(x, y)
    local d = sqrt((x - cx) ^ 2 + ((y - cy) * (o.sy or 1)) ^ 2) / R
    local e = max(0, 1 - d) ^ (o.pw or 0.8)
    v[k] = e * (1 - (o.mix or 0.3)) + (lam and lam[k] or 0.5) * (o.mix or 0.3)
  end)
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }), v
end

-- re-tone one pixel by delta steps using idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- twisted cord along a cubic bezier: tube lit, then diagonal twist grooves
function A.cord(c, p, w, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(p, function() return w end, 120)
  local tok = o.tok or { r = { name = o.name or "cord" } }
  local idx = A.shade(c, m, n, ramp, { tok = tok, amb = 0.1, wrap = 0.3 })
  local LEN = 0
  for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
  local per = o.per or 2.6
  m:each(function(x, y) local k = K(x, y)
    local ph = (T[k] * LEN + S[k] * (o.slant or 1.4)) % per
    if ph < 0.75 then A.step(c, idx, ramp, x, y, -2, tok) end
  end)
  return m, idx, T, S, samp
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
