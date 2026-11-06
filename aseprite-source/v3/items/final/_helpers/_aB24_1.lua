-- _aB24_1.lua: private helpers for ph/dill-pickles, dill-seed, diver-s-creel, doenjang (final pass, Opus).
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

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- surface of revolution about vertical axis cx; wfn(y) = half width. returns mask, normals, U (signed -1..1)
function A.rev(cx, y0, y1, wfn)
  local m, n, U = HP.mask(), {}, {}
  for y = y0, y1 do
    local w = wfn(y)
    local dw = (wfn(min(y1, y + 1)) - wfn(max(y0, y - 1))) / 2
    for x = floor(cx - w - 1), floor(cx + w + 1) do
      local u = (x + 0.5 - cx) / (w + 0.3)
      if abs(u) <= 1 then
        m:set(x, y)
        local k = K(x, y)
        local nz = sqrt(max(0.04, 1 - u*u))
        n[k] = { norm(u, -dw * nz * 0.9, nz) }
        U[k] = u
      end
    end
  end
  return m, n, U
end

-- re-tone one pixel by delta steps using idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.dots(c, pts, hex, tok) for _, p in ipairs(pts) do c:put(p[1], p[2], hex, tok) end end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
