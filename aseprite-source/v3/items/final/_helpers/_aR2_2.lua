-- _aR2_2.lua: private helpers for ph/ant-chitin, ph/antler-shard, ph/aphid-wings, ph/apple (final pass, Opus).
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

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end

-- normals from a height function h(x,y) (0 outside); mask = h > 0 inside box
function A.hfield(h, x0, y0, x1, y1, hs)
  hs = hs or 1
  local m, n, H = HP.mask(), {}, {}
  for y = y0, y1 do for x = x0, x1 do
    local v = h(x, y)
    if v and v > 0 then m:set(x, y) H[K(x, y)] = v end
  end end
  m:each(function(x, y)
    local gx = ((h(x + 0.5, y) or 0) - (h(x - 0.5, y) or 0)) * hs
    local gy = ((h(x, y + 0.5) or 0) - (h(x, y - 0.5) or 0)) * hs
    n[K(x, y)] = { A.norm(-gx, -gy, 1) }
  end)
  return m, n, H
end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- paint a char map; BC maps chars to hex
function A.map(c, rows, x0, y0, BC, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if BC[ch] then c:put(x0 + xx - 1, y0 + yy - 1, BC[ch], tok) end end end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
