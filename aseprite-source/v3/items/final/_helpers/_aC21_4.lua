-- _aC21_4: helper for ph/lungwort-seed, lupine-seed, lychee, lychee-seed (Opus single pass).
-- Wraps batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua) read-only.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local A = setmetatable({}, { __index = G })
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

-- tear a mask along line A->B: cut the right-hand side of A->B, jagged by +-amp. returns torn inner edge mask.
function A.tear(m, ax, ay, bx, by, amp, seed)
  local vx, vy = bx - ax, by - ay
  local L = sqrt(vx * vx + vy * vy)
  local ux, uy = vx / L, vy / L
  local px, py = -uy, ux
  local cut = {}
  m:each(function(x, y)
    local rx, ry = x - ax, y - ay
    local t = rx * ux + ry * uy
    local d = rx * px + ry * py
    local j = (X.hash(floor(t / 2), 7, seed or 1) - 0.5) * 2 * amp + ((floor(t / 2) % 2 == 0) and 0.6 or -0.6)
    if d > j then cut[#cut + 1] = K(x, y) end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  local torn = HP.mask()
  m:edge():each(function(x, y)
    local d = (x - ax) * px + (y - ay) * py
    if d > -amp - 2.2 then torn:set(x, y) end
  end)
  return torn
end

function A.ln(c, x0, y0, x1, y1, hex, tok, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for s = 0, n do
    local x, y = floor(x0 + (x1 - x0) * s / n + .5), floor(y0 + (y1 - y0) * s / n + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end
  end
end

-- generic veined leaf blade A-C-B, half width w, shape exponent pw. returns m, T, S, len
-- o: ramp, vein, tok, cut(mask), veins(bool), per, bias, amb, fold, cuts
function A.leaf(c, ax, ay, cx, cy, bx, by, w, o)
  o = o or {}
  local pw = o.pw or 0.7
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(o.minw or 0.45, w * sin(pi * min(1, t * (o.sk or 0.94) + (o.st or 0.06))) ^ pw)
  end, { fold = o.fold or 0.32 })
  if o.cut then m:cut(o.cut) end
  local R = o.ramp
  G.toneN(c, m, n, R, { tok = o.tok, bias = o.bias, cuts = o.cuts or { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = o.amb or 0.14, wrap = 0.3 })
  local per = o.per or 3.2
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if o.bias and o.bias[k] then return end
    if abs(s) < 0.15 and t > 0.04 and t < 0.88 then c:put(x, y, s <= 0 and (o.vein or R[6]) or R[3], o.tok) return end
    if o.veins then
      local f = ((t * L - abs(s) * 3) / per) % 1
      if f < 0.2 and abs(s) > 0.22 and abs(s) < 0.75 and t > 0.1 and t < 0.82 then c:put(x, y, s < 0 and R[5] or R[2], o.tok) end
    end
  end)
  return m, T, S, L, n
end

-- jittered grid of points over bbox (for bumpy skins / mottling)
function A.cells(x0, y0, x1, y1, sp, jit, seed)
  local P = {}
  local gy = 0
  for y = y0 - sp, y1 + sp, sp * 0.87 do
    local gx = 0
    for x = x0 - sp + (gy % 2) * sp * 0.5, x1 + sp, sp do
      P[#P + 1] = { x + (X.hash(gx, gy, seed) - 0.5) * jit, y + (X.hash(gx, gy, seed + 9) - 0.5) * jit }
      gx = gx + 1
    end
    gy = gy + 1
  end
  return P
end
function A.near2(P, x, y)
  local d1, d2, i1 = 1e9, 1e9, 0
  for i, p in ipairs(P) do
    local d = (x - p[1]) ^ 2 + (y - p[2]) ^ 2
    if d < d1 then d2 = d1 d1, i1 = d, i elseif d < d2 then d2 = d end
  end
  return sqrt(d1), sqrt(d2), i1
end

-- egg/heart-ish body: ellipse whose half width shrinks toward the bottom by `taper`. returns mask, normals, U(map of {dx,dy,q})
function A.egg(cx, cy, rx, ry, taper)
  local m, n, U = HP.mask(), {}, {}
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local dy = (y - cy) / (ry + 0.45)
    local rxe = (rx + 0.45) * (1 - (taper or 0) * max(0, dy) ^ 1.5)
    local dx = (x - cx) / rxe
    local q = dx * dx + dy * dy
    if q <= 1 then
      m:set(x, y)
      local k = K(x, y)
      n[k] = { G.norm(dx, dy, sqrt(max(1 - q, 0.03)) * 1.1) }
      U[k] = { dx, dy, q }
    end
  end end
  return m, n, U
end

-- perturb normals by bump cells; returns new normals + crease set + tip set
function A.bumpy(m, n, P, amt, crease)
  local nn, cr, tip = {}, {}, {}
  m:each(function(x, y) local k = K(x, y)
    local d1, d2, i = A.near2(P, x, y)
    local p = P[i]
    local b = n[k]
    local ox, oy = (x - p[1]) * amt, (y - p[2]) * amt
    nn[k] = { G.norm(b[1] + ox, b[2] + oy, b[3]) }
    if d2 - d1 < (crease or 0.9) then cr[k] = true end
    if d1 < 0.75 then tip[k] = true end
  end)
  return nn, cr, tip
end
return A
