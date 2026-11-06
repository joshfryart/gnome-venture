-- _aB23_4.lua: private helpers for ph/date-seed, ph/date-syrup, ph/dendrobium-seed, ph/desert-gem (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sin, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.pi, math.sqrt
A.HP, A.X, A.K = HP, X, K
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.INK, A.CREAM = "#2b1c26", "#fff4d6"

function A.new(name) return G.new2(name) end

-- torn leaf scrap along bezier A-C-B. o.w = half width, o.tornA / o.tornB = ragged end, o.seed = noise seed.
-- returns mask, normals, T, S, len (call before toning so callers can add AO bias)
function A.scrap(ax, ay, cx, cy, bx, by, o)
  local W = o.w or 7
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.995 then return -1 end
    return max(0.6, W * (o.shape and o.shape(t) or sin(pi * min(1, t * 0.7 + 0.2)) ^ 0.5))
  end, { fold = o.fold or 0.35 })
  local cut = {}
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    -- ragged tear: a jagged line across the blade, noise per across-position
    local q = floor((s + 1) * 4.5)
    local j = X.hash(q, 7, o.seed or 1)
    if o.tornA and t < o.tornA + 0.05 * j + 0.03 * abs(s) then cut[#cut + 1] = k end
    if o.tornB and t > o.tornB - 0.05 * j - 0.02 * abs(s) then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m, n, T, S, len
end

-- polygon facet with a flat normal
function A.facet(pts, nx, ny, nz)
  local m = HP.poly(pts)
  local l = sqrt(nx*nx + ny*ny + nz*nz)
  local n = {}
  m:each(function(x, y) n[K(x, y)] = { nx/l, ny/l, nz/l } end)
  return m, n
end

-- light value of a single normal
function A.lv(nx, ny, nz, o)
  o = o or {}
  local l = sqrt(nx*nx + ny*ny + nz*nz)
  local v = X.light({ [0] = { nx/l, ny/l, nz/l } }, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return v[0]
end

function A.save(c, name) G.save2(c, name) end
return A
