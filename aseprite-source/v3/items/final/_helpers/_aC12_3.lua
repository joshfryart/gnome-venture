-- _aC12_3.lua: private helpers for ph/hooked-forager-s-knife, hops, hops-seed, hori-hori (final, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- ribbon along a cubic bezier with asymmetric sides. wfn(t) -> wa (side -A), wb (side +A), A = (-ty, tx).
-- returns m, T, S (signed px offset, +A positive), SM (sample per pixel key), samples, length
function A.ribbon(p, wfn, N)
  N = N or 200
  local sm, len = {}, 0
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.003))
    local x1, y1 = G.bez(p, max(0, t - 0.003))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local wa, wb = wfn(t)
    sm[#sm + 1] = { x = x, y = y, t = t, tx = tx, ty = ty, ax = -ty, ay = tx, wa = wa, wb = wb }
    if i > 0 then len = len + sqrt((x - sm[i].x)^2 + (y - sm[i].y)^2) end
  end
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  local m, T, S, SM = HP.mask(), {}, {}, {}
  for y = floor(by0) - 8, floor(by1) + 8 do for x = floor(bx0) - 8, floor(bx1) + 8 do
    local best, bi = 1e9, 1
    for i, s in ipairs(sm) do local q = (x - s.x)^2 + (y - s.y)^2 if q < best then best, bi = q, i end end
    local s = sm[bi]
    local along = (x - s.x) * s.tx + (y - s.y) * s.ty
    local ok = not ((bi == 1 and along < -0.5) or (bi == #sm and along > 0.5))
    local d = (x - s.x) * s.ax + (y - s.y) * s.ay
    if ok and d >= -s.wa and d <= s.wb and (s.wa + s.wb) > 0.2 then
      m:set(x, y) local k = K(x, y) T[k], S[k], SM[k] = s.t, d, s
    end
  end end
  return m, T, S, SM, sm, len
end

function A.light(n, o) o = o or {} return X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 }) end
function A.tone(c, m, n, ramp, o)
  o = o or {}
  return X.tone(c, m, A.light(n, o), ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end

-- hop leaf: three (or one) serrated lobes from a base point. returns union mask
function A.hopLeaf(c, bx, by, ang, L, ramp, tok, o)
  o = o or {}
  local lobes = o.lobes or { { 0, 1.0, 1.0 }, { -0.95, 0.72, 0.85 }, { 0.95, 0.72, 0.85 } }
  local all = HP.mask()
  local done = {}
  -- side lobes first, centre last
  for li = #lobes, 1, -1 do
    local lb = lobes[li]
    local a = ang + lb[1]
    local ll = L * lb[2]
    local ux, uy = cos(a), sin(a)
    local ex, ey = bx + ux * ll, by + uy * ll
    local cxp, cyp = bx + ux * ll * 0.5 + (-uy) * (o.bend or 0.8), by + uy * ll * 0.5 + ux * (o.bend or 0.8)
    local W = (o.w or 0.42) * ll * lb[3]
    local m, n, T, S, len = G.blade(bx, by, cxp, cyp, ex, ey, function(t)
      if t > 0.98 then return -1 end
      local base = W * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.75
      local saw = (t * ll / 2.6) % 1
      return max(0.4, base * (1 - 0.2 * saw * min(1, t * 4)))
    end, { fold = 0.4 })
    local bias = {}
    for _, d in ipairs(done) do X.ao(bias, m, d, 1, -1) end
    for _, d in ipairs(done) do m:cut(d) end
    A.tone(c, m, n, ramp, { bias = bias, tok = tok, amb = 0.14, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
    m:each(function(x, y) local k = K(x, y)
      if bias[k] then return end
      local s, t = S[k], T[k]
      if abs(s) < 0.16 and t < 0.9 then c:put(x, y, s <= 0 and (o.vein or ramp[6]) or ramp[3], tok) return end
      -- side veins every ~4 px, swept toward the tip
      local ph = (t * len - abs(s) * 3.2) / 4.2
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.72 and t > 0.12 and t < 0.85 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
    end)
    done[#done + 1] = m
    all:add(m)
  end
  return all
end
return A
