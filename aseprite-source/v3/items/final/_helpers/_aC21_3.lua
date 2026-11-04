-- _aC21_3: helper for ph/lotus-root-seed, lucky-draught, lucuma, lucuma-seed (Opus single pass).
-- Wraps batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua) read-only.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan
local A = setmetatable({}, { __index = G })
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

-- tear a mask along line A->B: cut the +side (right of A->B), jagged by +-amp (stepped every 2 px).
-- returns the new torn-edge pixels (inner 1 px row along the tear) for pale fibre colour.
function A.tear(m, ax, ay, bx, by, amp, seed)
  local vx, vy = bx - ax, by - ay
  local L = sqrt(vx * vx + vy * vy)
  local ux, uy = vx / L, vy / L
  local px, py = -uy, ux
  local cut, keep = {}, HP.mask()
  m:each(function(x, y)
    local rx, ry = x - ax, y - ay
    local t = rx * ux + ry * uy
    local d = rx * px + ry * py
    local j = (X.hash(floor(t / 2), 7, seed or 1) - 0.5) * 2 * amp + ((floor(t / 2) % 2 == 0) and 0.6 or -0.6)
    if d > j then cut[#cut + 1] = K(x, y) end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local tornEdge = HP.mask()
  m:edge():each(function(x, y)
    local rx, ry = x - ax, y - ay
    local d = rx * px + ry * py
    if d > -amp - 2.2 then tornEdge:set(x, y) end
  end)
  return tornEdge
end

-- light a mask with given normals and a ramp; returns idx
function A.shade(c, m, n, ramp, o)
  o = o or {}
  return G.toneN(c, m, n, ramp, o)
end

-- bresenham line with owner tok, optional clip mask
function A.ln(c, x0, y0, x1, y1, hex, tok, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for s = 0, n do
    local x, y = floor(x0 + (x1 - x0) * s / n + .5), floor(y0 + (y1 - y0) * s / n + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end
  end
end

-- shift tone of existing pixels in mask by looking them up in ramp (dk < 0 darker)
function A.retone(c, m, ramp, dk, tok)
  local pos = {}
  for i, h in ipairs(ramp) do pos[h:lower()] = i end
  m:each(function(x, y)
    local h = c:get(x, y)
    local i = h and pos[h]
    if i then c:put(x, y, ramp[max(1, min(#ramp, i + dk))], tok) end
  end)
end

-- pixels of mask m whose 4-neighbour is in `other` (contact row)
function A.touch(m, other)
  local r = HP.mask()
  m:each(function(x, y)
    if not other:has(x, y) and (other:has(x + 1, y) or other:has(x - 1, y) or other:has(x, y + 1) or other:has(x, y - 1)) then r:set(x, y) end
  end)
  return r
end
A.atan = atan
return A
