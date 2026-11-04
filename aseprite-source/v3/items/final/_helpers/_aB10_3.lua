-- _aB10_3.lua: private helpers for breadfruit, breadfruit-seed, brewhouse-ladle, brick-path
-- (final pass, Opus). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
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

-- light a mask from normals onto ramp (dark..light), returns idx table and token
function A.lit(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  local tok = o.tok or { r = { name = o.name or "part" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = o.bias, tok = tok })
  return idx, tok
end

-- recolour pixels of mask by shifting their tone index (needs idx from A.lit)
function A.shiftTone(c, m, idx, ramp, d, tok)
  m:each(function(x, y) local k = K(x, y) if idx[k] then
    idx[k] = max(1, min(#ramp, idx[k] + d)) c:put(x, y, ramp[idx[k]], tok) end end)
end

-- paint a hand map: rows of chars, map char -> hex
function A.map(c, x0, y0, rows, cmap, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if cmap[ch] then c:put(x0 + xx - 1, y0 + yy - 1, cmap[ch], tok) end end end
end

-- breadfruit leaf: pinnately lobed blade along A-C-B; nl lobes per side. returns m, n, T, S, len
function A.lobedLeaf(ax, ay, cx, cy, bx, by, W, nl, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.6, W * math.sin(math.pi * min(1, t * 0.92 + 0.06)) ^ 0.6)
  end, { fold = o.fold or 0.4 })
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local ph = t * nl + (s > 0 and 0.5 or 0) * (o.stagger or 0)
    local f = abs((ph - floor(ph)) - 0.5) * 2   -- 1 at lobe centre... 0 at sinus
    local deep = o.deep or 0.62
    local lim = 1 - (1 - f) ^ 1.6 * deep
    if t > 0.12 and t < 0.9 and abs(s) > lim then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m, n, T, S, len
end
return A
