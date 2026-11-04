-- _aB20_3.lua: private helpers for cinnamon-seed, cistern-pearl, clay-pot, clean-dew (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Output dir = script-param out.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local A = setmetatable({}, { __index = G })
A.HP, A.X, A.K = HP, X, K

-- lathe body: radius rfn(y) about vertical axis cx, rows y0..y1. returns mask, normals, U (x offset -1..1)
-- slope: normal tilt from dr/dy (bulges face up/down)
function A.lathe(cx, y0, y1, rfn)
  local m, n, U = HP.mask(), {}, {}
  for y = y0, y1 do
    local r = rfn(y)
    if r > 0 then
      local dr = (rfn(min(y1, y + 1)) - rfn(max(y0, y - 1))) / 2
      for x = floor(cx - r - 1), floor(cx + r + 1) do
        local dx = x + 0.5 - cx
        if abs(dx) <= r then
          m:set(x, y)
          local u = max(-0.97, min(0.97, dx / (r + 0.4)))
          local nz = sqrt(1 - u * u)
          local nx, ny = u, -dr * nz * 0.9
          local l = sqrt(nx * nx + ny * ny + nz * nz)
          n[K(x, y)] = { nx / l, ny / l, nz / l }
          U[K(x, y)] = u
        end
      end
    end
  end
  return m, n, U
end

-- tone with light + optional spec override (top tone) and cool rim (index rimI)
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local idx, tok = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = o.bias, tok = o.tok })
  if o.rim then
    local r = X.rim(n)
    m:each(function(x, y) local k = K(x, y) if r[k] > (o.rimT or 0.55) and (idx[k] or 9) <= 2 and not (o.bias and o.bias[k]) then c:put(x, y, o.rim, tok) end end)
  end
  return idx, tok
end

function A.run(c, name) G.recentre(c) G.save(c, name) end
return A
