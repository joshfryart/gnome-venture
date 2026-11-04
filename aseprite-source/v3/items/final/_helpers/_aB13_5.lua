-- _aB13_5.lua: private helpers for camp-kit, candied-chestnuts, candied-citrus-peel, candied-ginger (aB13_5, Opus single pass).
-- Read-only layer over batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Not shared.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local A = { G = G, HP = HP, X = X, K = K }
function A.new(name)
  G.out = app.params.out or (DIR .. "/../ph/")
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  return c
end
function A.save(c, name) G.save2(c, name) end
-- tone a mask from a normal table with optional bias; returns idx, tok
function A.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias, tok = o.tok })
end
-- pixel line, optional clip mask
function A.ln(c, x0, y0, x1, y1, hex, clip, tok)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end
  end
end
-- dark row on m where it touches 'other' (ambient seam), drawn on m's pixels
function A.seam(c, m, other, hex, tok)
  m:each(function(x, y)
    if other:has(x, y) then return end
    if other:has(x+1, y) or other:has(x-1, y) or other:has(x, y+1) or other:has(x, y-1) then c:put(x, y, hex, tok) end
  end)
end
function A.paint(c, rows, x0, y0, map)
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if map[ch] then c:put(x0 + i - 1, y0 + j - 1, map[ch]) end
  end end
end
return A
