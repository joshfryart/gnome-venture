-- _aR21_2.lua: private helpers for bog-iron, bog-peat, bok-choy, bok-choy-kimchi (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
-- normals from a rounded height field (bevel R) plus extra(x,y) relief (knobs, pits)
function A.hnorm(m, R, extra)
  local d = X.dist(m)
  local function h(x, y)
    local v = d[K(x, y)]
    if not v then return 0 end
    local t = min(v + 0.5, R) / R
    return R * sqrt(1 - (1 - t) ^ 2) + (extra and extra(x, y) or 0)
  end
  local n = {}
  m:each(function(x, y)
    local gx = (h(x + 1, y) - h(x - 1, y)) / 2
    local gy = (h(x, y + 1) - h(x, y - 1)) / 2
    n[K(x, y)] = { norm(-gx, -gy, 1) }
  end)
  return n, d
end
-- bump field from a list of {x, y, r, amp}
function A.bumps(list)
  return function(x, y)
    local s = 0
    for _, b in ipairs(list) do
      local q = ((x - b[1])^2 + (y - b[2])^2) / (b[3] * b[3])
      if q < 1 then s = s + b[4] * (1 - q) ^ 2 end
    end
    return s
  end
end
function A.ring(m) return m:grow(1):cut(m) end
return A
