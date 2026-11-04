-- _aD11_1.lua: private helpers for ph/raccoon-pelt, radish, radish-kimchi, radish-seed (final pass, Sonnet high).
-- Read-only use of _aD11_0.lua (-> _aD10_0 -> batch2/_b2g1 -> batch1/_g1 -> _h -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aD11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local norm = A.norm

-- lathe (vertical axis of revolution): hwf(y) = half width or nil. cx may be x.5. returns m, n, U(-1..1), 
function A.lathe(cx, y0, y1, hwf, ycap)
  local m, n, U = HP.mask(), {}, {}
  for y = y0, y1 do
    local hw = hwf(y)
    if hw and hw > 0 then
      local a, b = hwf(y - 1) or hw, hwf(y + 1) or hw
      local slope = (b - a) / 2
      for x = floor(cx - hw - 1), math.ceil(cx + hw + 1) do
        local dx = x - cx
        if abs(dx) <= hw then
          local sn = max(-0.97, min(0.97, dx / (hw + 0.5)))
          local nz = sqrt(1 - sn * sn)
          m:set(x, y) n[K(x, y)] = { norm(sn, -slope * 0.9 * nz, nz) } U[K(x, y)] = sn
        end
      end
    end
  end
  return m, n, U
end

-- straight/curved 4-point path between two points with optional bow (perpendicular offset of the controls)
function A.path(ax, ay, bx, by, bow)
  bow = bow or 0
  local dx, dy = bx - ax, by - ay
  local l = sqrt(dx * dx + dy * dy)
  local px, py = -dy / l * bow, dx / l * bow
  return { { ax, ay }, { ax + dx / 3 + px, ay + dy / 3 + py }, { ax + 2 * dx / 3 + px, ay + 2 * dy / 3 + py }, { bx, by } }
end

-- fur / grain flecks: bias[k] += -1/+1 streaks along direction dirf(x,y)->dx,dy (unit)
function A.streaks(m, dirf, seed, bias, lo, hi, plen)
  lo, hi, plen = lo or 0.16, hi or 0.86, plen or 2.4
  m:each(function(x, y)
    local dx, dy = dirf(x, y)
    local u = -x * dy + y * dx
    local v = x * dx + y * dy
    local h = X.hash(floor(u * 0.95 + 0.5), floor(v / plen + (floor(u) % 2) * 0.5), seed)
    local b = h < lo and -1 or (h > hi and 1 or 0)
    if b ~= 0 then bias[K(x, y)] = (bias[K(x, y)] or 0) + b end
  end)
  return bias
end

function A.ragged(m, seed, cutp, addp)
  local out = m:copy()
  m:edge():each(function(x, y) if X.hash(x, y, seed) < cutp then out.s[K(x, y)] = nil end end)
  m:grow(1):cut(m):each(function(x, y) if X.hash(x, y, seed + 7) < addp then out:set(x, y) end end)
  return out
end
return A
