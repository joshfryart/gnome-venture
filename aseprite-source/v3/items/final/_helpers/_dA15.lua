-- _dA15: helper for chunk dA15 (beeswax .. black-pepper). Layer over _dA12 (-> batch2/_b2.lua); nothing shared is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA12.lua")
local HP, X, H = D.HP, D.X, D.H
local K = X.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
D.K = K
D.WAX  = { "#8a5a1c", "#b8801e", "#dca62c", "#f2c84a", "#fbe07a", "#fff2b4" }
D.BEET = { "#3a1030", "#661a48", "#922a5a", "#b8386a", "#d85c88", "#f090b0" }
D.TEAL2= { "#10283c", "#1c4660", "#2a7080", "#3aa09a", "#6cd0b4", "#b4f0d4" }
D.INDG = { "#1a1438", "#2c2460", "#443c8a", "#5c58b0", "#8a84d0", "#bcb8ee" }
D.IRON = { "#1c1a24", "#34323f", "#524f62", "#74718a", "#9d9ab4", "#c8c6d8" }
D.BIRCH= { "#6a6070", "#988e98", "#c0b8bc", "#e0dad6", "#f4efe6", "#fffaf0" }
D.PEP  = { "#2c1038", "#4a1c5c", "#6a2a80", "#8a3c9c", "#aa5cb8", "#cc8cd4" }
D.GRN  = { "#12362c", "#1c5238", "#2c7440", "#42944a", "#68b454", "#9ccc68" }
D.STN  = { "#444663", "#5e607a", "#74758c", "#9594a8", "#bcbacb", "#e2e0e6" }
D.GLS  = { "#2a4a7a", "#3a6aa0", "#5a9cc8", "#8ac8e0", "#b6e8f0", "#e4faf8" }
D.WD   = { "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54", "#e8b982" }
function D.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along bezier, half width wfn(t): mask, normals, T, S (S<0 lit side)
function D.tube(p, wfn, N)
  N = N or 120
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = D.bez(p, t)
    local x2, y2 = D.bez(p, min(1, t + .003)) local x1, y1 = D.bez(p, max(0, t - .003))
    local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm+1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 8, floor(by1) + 8 do for x = floor(bx0) - 8, floor(bx1) + 8 do
    local best, bs
    for _, s in ipairs(sm) do local q = (x - s.x)^2 + (y - s.y)^2 if not best or q < best then best, bs = q, s end end
    if bs.w > 0 and sqrt(best) <= bs.w then
      local sn = max(-.97, min(.97, ((x - bs.x) * bs.px + (y - bs.y) * bs.py) / (bs.w + .5)))
      m:set(x, y) local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) } T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S
end
-- tone from normals
function D.tn(m, n, ramp, cuts, o)
  o = o or {}
  return X.tone(D.c, m, X.light(n, { amb = o.amb or .1, wrap = o.wrap or .25 }), ramp, { cuts = cuts or { .22, .4, .56, .72, .88 }, bias = o.bias })
end
function D.rr(x0, y0, x1, y1, r, ramp, R, o) local m = D.c:rrect(x0, y0, x1, y1, r) D.lit(m, ramp, R or 3, o) return m end
function D.vc(m, ramp, x0, x1, o) return H.vcyl(D.c, m, ramp, x0, x1, o) end
function D.sh(cx, cy, rx, ry) D.c:groundShadow(cx, cy, rx, ry) end
function D.bee(x, y)
  local c = D.c
  c:px(x - 1, y - 2, D.CR) c:px(x, y - 2, "#d0e8f6")
  for i = -2, 2 do c:px(x + i, y, (i == 0 or i == 2) and D.INK or "#f8d048") c:px(x + i, y + 1, (i == 0 or i == 2) and D.INK or "#eab32e") end
end
function D.erase(m) local c = D.c m:each(function(x, y) if x >= 0 and y >= 0 and x < c.w and y < c.h then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end) end
return D
