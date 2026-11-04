-- _aB25_0.lua: private helper copy (of batch2/_b2g1.lua) for ph/durian, durian-seed, dutch-tulip-seed, eagle-down.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch1/_g1.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
G.out = app.params.out or (DIR .. "/")
G.H = G
function G.new2(name) G.out = app.params.out or (DIR .. "/") local c = HP.canvas{ w = 64, h = 64, scale = 1, name = name } return c end
function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier, half width wfn(t). returns mask, normals, T, S (S<0 lit side), samples
function G.tube(p, wfn, steps)
  local N = steps or 160
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.002))
    local x1, y1 = G.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
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
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm
end
function G.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = math.ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local a = dx*ux + dy*uy
    local b = -dx*uy + dy*ux
    if (a/ra)^2 + (b/rb)^2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
function G.rot(ux, uy, a) local c, s = cos(a), sin(a) return ux*c - uy*s, ux*s + uy*c end
-- shift all drawn pixels so the final (outlined) bbox sits centred on the 64 canvas
function G.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function G.save2(c, name) G.recentre(c) G.save(c, name) end
return G
