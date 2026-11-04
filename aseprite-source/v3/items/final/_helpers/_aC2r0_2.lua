-- _aC2r0_2.lua: private helpers for morpho-scales, mossy-shell, mossy-throne, moth-orchid-seed (final pass, Opus).
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

function A.save(c, name)
  local out = app.params.out or (DIR .. "/../ph/")
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end

-- light + quantise; returns idx
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }), v
end

-- lumpy moss: jittered cells (size sz) each a small dome lit upper-left, cavities between, on a pillow body
function A.moss(c, m, ramp, o)
  o = o or {}
  local sz, seed = o.size or 3.2, o.seed or 1
  local base = X.pillow(m, o.R or 2.5)
  local n, bias = {}, o.bias or {}
  m:each(function(x, y)
    local best, bdx, bdy = 1e9, 0, 0
    local cx0, cy0 = floor(x / sz), floor(y / sz)
    for j = cy0 - 1, cy0 + 1 do for i = cx0 - 1, cx0 + 1 do
      local px = (i + 0.2 + X.hash(i, j, seed) * 0.6) * sz
      local py = (j + 0.2 + X.hash(i, j, seed + 5) * 0.6) * sz
      local q = (x - px)^2 + (y - py)^2
      if q < best then best, bdx, bdy = q, x - px, y - py end
    end end
    local k = K(x, y)
    local b = base[k]
    n[k] = { norm(b[1] + bdx * 0.32, b[2] + bdy * 0.32, b[3]) }
    if sqrt(best) > sz * 0.62 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local tok = o.tok or { r = { name = "moss" } }
  local idx = A.shade(c, m, n, ramp, { bias = bias, tok = tok, amb = o.amb or 0.1, wrap = o.wrap or 0.3, cuts = o.cuts })
  return idx, tok
end
-- paint a hand map: rows of chars, map char -> hex
function A.map(c, x0, y0, rows, cmap, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if cmap[ch] then c:put(x0 + xx - 1, y0 + yy - 1, cmap[ch], tok) end end end
end
return A
