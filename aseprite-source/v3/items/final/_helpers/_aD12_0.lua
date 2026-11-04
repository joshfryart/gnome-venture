-- _aD12_0.lua: private helpers for ph/rat-pelt, rat-tooth, red-bean-buns, red-hibiscus-seed (final pass, Sonnet high).
-- Read-only use of _aD11_0.lua (-> _aD10_0 -> batch2/_b2g1 -> _g1 -> _h -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aD11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt

function A.frac(v) return v - floor(v) end
function A.clamp(v, a, b) return max(a, min(b, v)) end

-- tone a mask from normals, then return idx table and the tone fn (cuts 6 tones)
function A.paintIdx(c, idx, ramp, m)
  m:each(function(x, y) local i = idx[K(x, y)] if i then c:px(x, y, ramp[A.clamp(i, 1, #ramp)]) end end)
end

-- tangent-derived side sign along a bezier tube at t: +1 when the tube's S>0 side points toward (fx,fy)
function A.sideSign(p, t, fx, fy)
  local x2, y2 = A.bez(p, min(1, t + 0.002))
  local x1, y1 = A.bez(p, max(0, t - 0.002))
  local tx, ty = x2 - x1, y2 - y1
  local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  if px + py < 0 then px, py = -px, -py end
  return (px * fx + py * fy) >= 0 and 1 or -1
end

-- serrate cut for a G.blade mask: teeth point toward the tip. returns number cut
function A.teeth(m, T, S, len, per, depth, t0, t1)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if t > (t0 or 0.12) and t < (t1 or 0.95) then
      local ph = t * len / per + (s > 0 and 0.5 or 0)
      local f = ph - floor(ph)
      local lim = (1 - depth) + depth * f
      if abs(s) > lim then cut[#cut + 1] = k end
    end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return #cut
end
return A
