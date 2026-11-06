-- _aD12_1.lua: private helpers for ph/red-hot-poker-seed, red-ochre, reef-fish, reindeer-lichen (final pass, Sonnet high).
-- Read-only use of _aD11_0.lua (-> _aD10_0 -> batch2/_b2g1 -> batch1/_g1 -> _h -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aD11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local norm = A.norm

-- faceted wedge pebble: polygon in local coords (u along ang, v across), ridge along u axis splits two facets.
-- returns mask, normals
function A.facet(cx, cy, ang, verts, tilt, R)
  local ca, sa = cos(ang), sin(ang)
  local pts = {}
  for _, v in ipairs(verts) do pts[#pts + 1] = { cx + v[1] * ca - v[2] * sa, cy + v[1] * sa + v[2] * ca } end
  local m = HP.mask()
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0, y0, x1, y1 = min(x0, p[1]), min(y0, p[2]), max(x1, p[1]), max(y1, p[2]) end
  local function inside(x, y)
    local c = false
    local j = #pts
    for i = 1, #pts do
      local a, b = pts[i], pts[j]
      if (a[2] > y) ~= (b[2] > y) and x < (b[1] - a[1]) * (y - a[2]) / (b[2] - a[2]) + a[1] then c = not c end
      j = i
    end
    return c
  end
  for y = floor(y0) - 1, floor(y1) + 1 do for x = floor(x0) - 1, floor(x1) + 1 do
    if inside(x + 0.5, y + 0.5) then m:set(x, y) end
  end end
  local n = X.pillow(m, R or 1.4)
  local px, py = -sa, ca
  if px + py < 0 then px, py = -px, -py end
  m:each(function(x, y)
    local k = K(x, y)
    local v = (x + 0.5 - cx) * px + (y + 0.5 - cy) * py
    local t = (v < 0) and -(tilt or 0.5) or (tilt or 0.5)
    local nn = n[k]
    n[k] = { norm(nn[1] + px * t, nn[2] + py * t, nn[3]) }
  end)
  return m, n
end

-- deterministic rng
function A.rng(seed)
  local s = seed or 7
  return function() s = (s * 1103515245 + 12345) % 2147483648 return s / 2147483648 end
end

-- thin line mask (Bresenham) into mask m, with optional thickness 2 (adds right+down neighbour)
function A.lineMask(m, x0, y0, x1, y1, thick)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    m:set(x, y)
    if thick and thick >= 2 then m:set(x + 1, y) end
    if thick and thick >= 3 then m:set(x, y + 1) end
  end
  return m
end
return A
