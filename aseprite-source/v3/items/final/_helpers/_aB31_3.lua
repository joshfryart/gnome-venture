-- _aB31_3.lua: private helpers for ph/fig-jam, fig-seed, fine-felling-axe, fine-fly-rod (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end
-- light a normal field and paint the quantised ramp; returns idx
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end
-- vertical-axis cylinder normals over x0..x1
function A.vcylN(m, x0, x1, ny)
  local n = {}
  m:each(function(x, y)
    local t = max(-.95, min(.95, ((x + .5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { norm(t, ny or 0, sqrt(1 - t*t)) }
  end)
  return n
end
-- pixels of `under` 4-touching `over` (not in it)
function A.touch(under, over)
  local r = HP.mask()
  over:grow(1):each(function(x, y) if under:has(x, y) and not over:has(x, y) then r:set(x, y) end end)
  return r
end
-- plot a cubic bezier 1px
function A.curve(c, p, hex, tok, N)
  N = N or 80
  local pts = {}
  local lx, ly
  for i = 0, N do
    local x, y = G.bez(p, i / N)
    local xi, yi = floor(x + .5), floor(y + .5)
    if xi ~= lx or yi ~= ly then
      c:put(xi, yi, type(hex) == "function" and hex(i / N, xi, yi) or hex, tok)
      pts[#pts + 1] = { xi, yi }
      lx, ly = xi, yi
    end
  end
  return pts
end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A
