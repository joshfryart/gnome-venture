-- _aB31_4.lua: private helpers for ph/fine-mesh-net, fine-rock-hammer, fine-secateurs, finger-lime (Opus single pass).
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
function A.tok(name) return { r = { name = name } } end
function A.clamp(i, n) return max(1, min(n, i)) end

-- light + quantise; returns idx table
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  return (X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }))
end

-- tube along a cubic bezier; flat0/flat1 cut the round caps square
function A.tube(p, wfn, o)
  o = o or {}
  local m, n, T, S, sm = G.tube(p, wfn, o.steps)
  local s0, s1 = sm[1], sm[#sm]
  local cut = HP.mask()
  m:each(function(x, y)
    if o.flat0 and ((x - s0.x) * s0.tx + (y - s0.y) * s0.ty) < -0.2 then cut:set(x, y) end
    if o.flat1 and ((x - s1.x) * s1.tx + (y - s1.y) * s1.ty) > 0.2 then cut:set(x, y) end
  end)
  m:cut(cut)
  local LEN = 0
  for i = 2, #sm do LEN = LEN + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end
  return m, n, T, S, sm, LEN
end

-- re-tone one pixel by d steps relative to stored idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  if idx[k] then local i = A.clamp(idx[k] + d, #ramp) idx[k] = i c:put(x, y, ramp[i], tok) end
end

-- pixels of `under` 4-touching `over` (not in it)
function A.touch(under, over)
  local r = HP.mask()
  over:grow(1):each(function(x, y) if under:has(x, y) and not over:has(x, y) then r:set(x, y) end end)
  return r
end

-- hand map: rows of chars -> colours (table), top-left at x0,y0
function A.map(c, rows, x0, y0, cols, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if cols[ch] then c:put(x0 + xx - 1, y0 + yy - 1, cols[ch], tok) end
  end end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A
