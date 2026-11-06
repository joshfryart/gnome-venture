-- _aC23_3.lua: private helpers for milkweed-seed, millet, millet-seed, millipede-plate (final pass, Opus).
-- Read-only wrap of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = { G = G, HP = HP, X = X, K = K }
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
A.INK, A.CREAM = "#2b1c26", "#fff4d6"

-- tube along a cubic bezier with arc length. wfn(t) = half width.
-- returns m, n, T, S (-1..1, <0 lit side), AL (arc length px), TG (frame), len, D (signed px offset), samples
-- o.cap = true -> round ends; default flat ends.
function A.tube(p, wfn, o)
  o = o or {}
  local N = o.steps or 220
  local sm, len = {}, 0
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.002))
    local x1, y1 = G.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    if i > 0 then len = len + sqrt((x - sm[i].x) ^ 2 + (y - sm[i].y) ^ 2) end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t), a = len }
  end
  local m, n, T, S, AL, TG, D = HP.mask(), {}, {}, {}, {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 9, floor(by1) + 9 do for x = floor(bx0) - 9, floor(bx1) + 9 do
    local best, bs, bi
    for i, s in ipairs(sm) do
      local q = (x - s.x) ^ 2 + (y - s.y) ^ 2
      if not best or q < best then best, bs, bi = q, s, i end
    end
    local along = (x - bs.x) * bs.tx + (y - bs.y) * bs.ty
    local endcut = (not o.cap) and ((bi == 1 and along < -0.4) or (bi == #sm and along > 0.4))
    if bs.w > 0 and sqrt(best) <= bs.w and not endcut then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn * sn) }
      T[k], S[k], AL[k], D[k] = bs.t, sn, bs.a + along, sd
      TG[k] = bs
    end
  end end
  return m, n, T, S, AL, TG, len, D, sm
end

-- lit rotated oval (G.oval normals). returns m, n, idx
function A.oval(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, o.flat)
  if o.clip then m:cut(o.clip) end
  local idx = G.toneN(c, m, n, ramp, { tok = o.tok, bias = o.bias, cuts = o.cuts, amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  return m, n, idx
end

-- one glint at the brightest specular point of mask
function A.glint(c, m, n, hex, tok, power, big)
  local x, y = G.specAt(m, n, power or 30)
  if x then c:put(x, y, hex or A.CREAM, tok) if big and m:has(x + 1, y) then c:put(x + 1, y, hex or A.CREAM, tok) end end
  return x, y
end

-- 1px hard line, painted with owner tok
function A.line(c, x0, y0, x1, y1, hex, tok)
  local dx, dy = x1 - x0, y1 - y0
  local n = max(abs(dx), abs(dy))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    c:put(floor(x0 + dx * t + 0.5), floor(y0 + dy * t + 0.5), hex, tok)
  end
end

-- torn edge: remove pixels of m whose along-coordinate is within a jagged band of the ends
function A.tear(m, T, S, len, a0, a1, seed)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local a = T[k] * len
    local j = floor((S[k] + 1) * 3.5)
    local h0 = 1.2 + 3.2 * X.hash(j, 1, seed or 7)
    local h1 = 1.2 + 3.2 * X.hash(j, 2, seed or 7)
    if (a0 and a < h0) or (a1 and a > len - h1) then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
end
return A
