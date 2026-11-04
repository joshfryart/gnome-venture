-- _aB24_2: helper for dog-rose-seed, dragon-fruit, dragon-fruit-seed, dragon-topiary (Opus artist pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
D.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.VEIN, D.COOL = "#c2e48c", "#3a6c72"
D.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
function D.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.tok(name) return { r = { name = name } } end
-- jitter normals with hash noise (leafy / bumpy surfaces)
function D.bump(n, amp, seed, cell)
  cell = cell or 1
  for k, v in pairs(n) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local cx, cy = x // cell, y // cell
    local a = (X.hash(cx, cy, seed) - 0.5) * 2 * amp
    local b = (X.hash(cx, cy, seed + 7) - 0.5) * 2 * amp
    n[k] = { norm(v[1] + a, v[2] + b, v[3]) }
  end
  return n
end
-- tone with a light value table directly
function D.toneV(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  if o.rim then
    local r = X.rim(n)
    for k, val in pairs(r) do if v[k] then v[k] = v[k] + val * o.rim end end
  end
  return X.tone(c, m, v, ramp, { cuts = o.cuts or D.CUTS, bias = o.bias, tok = o.tok })
end
function D.ramp6(ramp, i) return ramp[max(1, min(#ramp, i))] end
function D.save(c, name) G.save2(c, name) end
return D
