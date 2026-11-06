-- _aB23_0.lua: private helpers for ph/cucumber-kimchi, cucumber-seed, cumin, cumin-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
function A.new(name) return G.new2(name) end
function A.tok(name) return { r = { name = name } } end
-- light a normal field onto a ramp; returns idx table
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.28 })
  return (X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }))
end
-- line of points (Bresenham-ish) along a cubic bezier
function A.curve(p, n)
  local pts, seen = {}, {}
  for i = 0, n or 40 do
    local x, y = G.bez(p, i / (n or 40))
    local xi, yi = floor(x + .5), floor(y + .5)
    local k = K(xi, yi)
    if not seen[k] then seen[k] = true pts[#pts + 1] = { xi, yi, i / (n or 40) } end
  end
  return pts
end
-- jagged tear: remove pixels of m on the + side of the line A->B, edge offset by hash noise (amp px)
function A.tear(m, ax, ay, bx, by, amp, seed)
  local vx, vy = bx - ax, by - ay
  local l = sqrt(vx*vx + vy*vy) vx, vy = vx / l, vy / l
  local px, py = -vy, vx
  local cut = {}
  m:each(function(x, y)
    local t = (x - ax) * vx + (y - ay) * vy
    local s = (x - ax) * px + (y - ay) * py
    local j = (X.hash(floor(t / 1.6), 3, seed or 1) - 0.5) * 2 * amp + (X.hash(floor(t), 7, seed or 1) - 0.5) * 0.9
    if s > j then cut[#cut + 1] = K(x, y) end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m
end
function A.save(c, name) G.save2(c, name) end
return A
