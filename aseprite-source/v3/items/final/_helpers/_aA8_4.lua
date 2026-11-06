-- _aA8_4.lua: private helpers for ico-pushpin, ico-puzzle, ico-question, ico-rabbit (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua). No shared file edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, cos, sin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin, math.pi
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
A.INK, A.CREAM, A.SPEC = "#2b1c26", "#fff4d6", "#fff1cf"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) A.name = name return G.new2(name) end
function A.save(c) G.save2(c, A.name) end

-- light normals -> 6-tone ramp. o: amb, wrap, cuts, bias, tok
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx, tok = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, tok, v
end

-- tube along a chain of cubic beziers (each {p1,p2,p3,p4}); wfn(t) half width over the whole chain (t 0..1)
function A.tubeN(curves, wfn, steps)
  local N = steps or 120
  local raw = {}
  for ci, p in ipairs(curves) do
    for i = (ci == 1 and 0 or 1), N do
      local x, y = G.bez(p, i / N) raw[#raw + 1] = { x, y }
    end
  end
  local acc, L = { 0 }, 0
  for i = 2, #raw do L = L + sqrt((raw[i][1] - raw[i-1][1])^2 + (raw[i][2] - raw[i-1][2])^2) acc[i] = L end
  local sm = {}
  for i = 1, #raw do
    local a, b = raw[max(1, i - 1)], raw[min(#raw, i + 1)]
    local tx, ty = b[1] - a[1], b[2] - a[2]
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    local t = acc[i] / L
    sm[i] = { x = raw[i][1], y = raw[i][2], t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 9, floor(by1) + 9 do for x = floor(bx0) - 9, floor(bx1) + 9 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x - s.x)^2 + (y - s.y)^2
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w then
      local dx, dy = x - bs.x, y - bs.y
      local sd = dx * bs.px + dy * bs.py
      local al = dx * bs.tx + dy * bs.ty
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      local an = max(-0.97, min(0.97, al / (bs.w + 0.5)))   -- round end caps
      m:set(x, y)
      local k = K(x, y)
      local q = max(0.03, 1 - sn*sn - an*an)
      n[k] = { norm(bs.px * sn + bs.tx * an, bs.py * sn + bs.ty * an, sqrt(q)) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm, L
end

-- surface of revolution along A->B; rfn(d) radius at distance d px from A (d 0..L). returns m, n, D, S
function A.lathe(ax, ay, bx, by, rfn)
  local vx, vy = bx - ax, by - ay
  local L = sqrt(vx*vx + vy*vy)
  local ux, uy = vx / L, vy / L
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, n, D, S = HP.mask(), {}, {}, {}
  for y = floor(min(ay, by)) - 14, floor(max(ay, by)) + 14 do for x = floor(min(ax, bx)) - 14, floor(max(ax, bx)) + 14 do
    local rx, ry = x - ax, y - ay
    local d, s = rx*ux + ry*uy, rx*px + ry*py
    if d >= 0 and d <= L then
      local r = rfn(d)
      if r > 0 and abs(s) <= r then
        m:set(x, y)
        local dr = (rfn(min(L, d + 0.5)) - rfn(max(0, d - 0.5))) / 1.0
        local sn = max(-0.97, min(0.97, s / (r + 0.5)))
        local cz = sqrt(1 - sn*sn)
        n[K(x, y)] = { norm(px * sn - ux * dr, py * sn - uy * dr, cz) }
        D[K(x, y)], S[K(x, y)] = d, sn
      end
    end
  end end
  return m, n, D, S, { ux = ux, uy = uy, px = px, py = py, L = L }
end

-- fur / fibre texture: short strokes along (fx,fy), one tone darker (or lighter on lit tones)
function A.fur(c, m, idx, ramp, tok, seed, fx, fy, dens)
  fx, fy, dens = fx or 0.5, fy or 1, dens or 0.11
  m:each(function(x, y)
    local k = K(x, y)
    local i = idx[k]
    if i and i >= 2 and i <= 5 and X.hash(x, y, seed) < dens then
      local j = (X.hash(y, x, seed + 7) < 0.6) and i - 1 or i + 1
      j = max(1, min(#ramp, j))
      for s = 0, 1 do
        local xx, yy = floor(x + fx * s + .5), floor(y + fy * s + .5)
        if m:has(xx, yy) and idx[K(xx, yy)] == i then c:put(xx, yy, ramp[j], tok) end
      end
    end
  end)
end

function A.pts(c, list, hex, tok) for _, p in ipairs(list) do c:put(p[1], p[2], hex, tok) end end
function A.paintMap(c, rows, x0, y0, map, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if map[ch] then c:put(x0 + xx - 1, y0 + yy - 1, map[ch], tok) end end end
end
return A
