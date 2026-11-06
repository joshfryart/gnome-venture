-- _aC2r1_1.lua: private helpers for ph/nav-crafting, nav-feedback, nav-festival, nav-friends (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min = math.floor, math.max, math.min
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + tone a normal field (optional extra value field add[k] and bias[k]); returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } })
  return idx, v
end

-- bevelled (pillow) fill
function A.pill(c, m, R, ramp, o)
  local n = X.pillow(m, R)
  local idx = A.shade(c, m, n, ramp, o)
  return idx, n
end

-- step an already toned pixel by d tones (clamped)
function A.step(c, idx, ramp, x, y, d)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i])
end

function A.map(c, rows, x0, y0, pal)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch]) end
  end end
end

function A.bias() return {} end
function A.ao(b, m, other, r, amt) return X.ao(b, m, other, r or 1, amt or -1) end
function A.cast(b, m, caster, dx, dy, amt) return G.cast(b, m, caster, dx, dy, amt or -1) end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
