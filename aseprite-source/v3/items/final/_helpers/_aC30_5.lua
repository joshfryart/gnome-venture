-- _aC30_5.lua: private helpers for ph/oats-seed, okra, okra-seed, old-campfire-ash (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- light + tone; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.mod then for k, d in pairs(o.mod) do if v[k] then v[k] = max(0, min(1, v[k] + d)) end end end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- step one pixel's tone by d using idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- torn edge: remove pixels of m beyond a jagged line through (ax,ay) with outward normal (nx,ny)
function A.tear(m, ax, ay, nx, ny, amp, seed)
  local l = sqrt(nx*nx + ny*ny) nx, ny = nx / l, ny / l
  local tx, ty = -ny, nx
  local cut = {}
  m:each(function(x, y)
    local d = (x - ax) * nx + (y - ay) * ny
    local a = (x - ax) * tx + (y - ay) * ty
    local seg = floor(a / 2)
    local j = (X.hash(seg, 7, seed or 1) - 0.5) * 2 * amp + ((seg % 2 == 0) and amp * 0.5 or -amp * 0.5)
    if d > j then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end

-- union of masks with normals (later wins)
function A.merge(list)
  local m, n = HP.mask(), {}
  for _, e in ipairs(list) do
    e[1]:each(function(x, y) m:set(x, y) n[K(x, y)] = e[2][K(x, y)] end)
  end
  return m, n
end

function A.save(c, name, recentre)
  if recentre ~= false then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
