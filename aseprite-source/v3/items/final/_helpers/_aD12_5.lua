-- _aD12_5.lua: private helpers for ph/roasted-roots, rock-crystal, rock-dust, rock-garden (final pass, Sonnet high).
-- Read-only use of _dD12.lua (-> batch2/_b2 -> _h -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dD12.lua")
local HP, X, K, B = D.HP, D.X, D.K, D.B
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
function D.clamp(v, a, b) return max(a, min(b, v)) end
-- paint mask m with ramp via function idxf(x,y)->tone index (clamped)
function D.paintF(c, m, ramp, f)
  m:each(function(x, y) local i = f(x, y) if i then c:px(x, y, ramp[max(1, min(#ramp, floor(i + 0.5)))]) end end)
end
-- lit mask with per-pixel tone bias function bf(x,y)->steps (can be nil); returns idx table
function D.litB(c, m, ramp, R, o, bf)
  o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local bias = {}
  if bf then m:each(function(x, y) local b = bf(x, y) if b and b ~= 0 then bias[K(x, y)] = b end end) end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.26, 0.44, 0.6, 0.75, 0.88 }, bias = bias })
  return idx, n, v
end
-- pixels of m that touch (4-adj) a pixel of `other` that is not in m
function D.touching(m, other)
  local r = HP.mask()
  m:each(function(x, y)
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do
      local qx, qy = x + d[1], y + d[2]
      if other:has(qx, qy) and not m:has(qx, qy) then r:set(x, y) break end
    end
  end)
  return r
end
function D.hash(x, y, s) return X.hash(x, y, s) end
return D
