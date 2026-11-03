-- _aB11_1.lua: private helpers for ph/broken-fine-{fly-rod,foraging-knife,mesh-net,rock-hammer} (Opus single pass).
-- Read-only use of batch1/_h.lua (hp.lua + hpx.lua lighting). Copies of batch2 bez/tube/recentre live here.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/../../batch1/_h.lua")
local D = setmetatable({}, { __index = H })
local HP, X, K = H.HP, H.X, H.K
D.HP, D.X, D.K = HP, X, K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi

D.WOOD    = { "#3e2420", "#5e3828", "#85522f", "#a96e3d", "#c98c52", "#e8b982" }
D.ASH     = { "#4a2c22", "#74462c", "#a06a3c", "#c48c50", "#deb070", "#f6d69a" }
D.CANE    = { "#5a3418", "#86501e", "#b47828", "#d89c3a", "#f0c25e", "#fde49a" }
D.CORK    = { "#5a3c2a", "#7e5838", "#a47a4c", "#c49a62", "#ddb87c", "#f2d6a0" }
D.STEEL   = { "#33354e", "#4b5070", "#6b7190", "#8f95b0", "#b9bdd2", "#e6e8f2" }
D.GUN     = { "#22243a", "#30344e", "#444a68", "#5e6688", "#8590b0", "#c0c8e0" }
D.BRASS   = { "#6a3418", "#9a5220", "#cc7e2a", "#eeab3a", "#ffd15e", "#fff0b4" }
D.LEATHER = { "#3a2220", "#5a3430", "#7e4a3a", "#a2644a", "#c4825c", "#e0a47c" }
D.TWINE   = { "#5a4a30", "#7e6a46", "#a48a5c", "#c8ae7a", "#e4cc98", "#fcecc0" }
D.BRISTLE = { "#2e2226", "#4a3632", "#6c5040", "#8e6c50", "#b08c66", "#d4b48a" }
D.RED     = { "#5a1a2c", "#8e2a38", "#c0403a", "#e8603c", "#ff8a5c", "#ffc09a" }
D.NAVY    = { "#1e2448", "#2c3866", "#3e5090", "#5a70b8" }
D.GREEN   = { "#1e3f34", "#2c5e3e", "#3f8a48", "#5fae52", "#8fcf6c", "#c4e88c" }
D.NETIN   = { "#2a2236", "#362c44", "#443854", "#544868", "#665a7a", "#7a6e8e" }
D.STONE   = { "#3e3a4a", "#565264", "#726e80", "#928e9e", "#b4b0bc", "#d8d4dc" }
D.INK, D.CREAM = "#2b1c26", "#fff4d6"
D.CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }

function D.start(src)
  local name = src:match("([^/\\]+)%.lua$")
  local _, _, c = H.new(name)
  H.out = app.params.out or (DIR .. "/../ph/")
  return c, name
end
function D.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier, half width wfn(t). returns mask, normals, T, S (S<0 lit side)
function D.tube(p, wfn, steps)
  local N = steps or 160
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = D.bez(p, t)
    local x2, y2 = D.bez(p, min(1, t + 0.002))
    local x1, y1 = D.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 5, floor(by1) + 5 do for x = floor(bx0) - 5, floor(bx1) + 5 do
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
  return m, n, T, S
end
-- tone a mask from normals with bias
function D.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, H.ramp(ramp), { cuts = o.cuts or D.CUTS, bias = o.bias, tok = o.tok })
end
-- local frame shape: fn(a, b) -> true if inside. Origin (ox,oy), axis angle ang (radians, screen). b = across (+ = clockwise side)
function D.shape(ox, oy, ang, a0, a1, b0, b1, fn)
  local ux, uy = cos(ang), sin(ang)
  local vx, vy = -uy, ux
  local m, A, B = HP.mask(), {}, {}
  local R = max(abs(a0), abs(a1), abs(b0), abs(b1)) + 2
  for y = floor(oy - R), floor(oy + R) do for x = floor(ox - R), floor(ox + R) do
    local dx, dy = x - ox, y - oy
    local a, b = dx * ux + dy * uy, dx * vx + dy * vy
    if fn(a, b) then m:set(x, y) A[K(x, y)], B[K(x, y)] = a, b end
  end end
  return m, A, B
end
function D.erase(c, m) m:each(function(x, y) local k = y * c.w + x c.pix[k] = nil c.own[k] = nil end) end
function D.paintMask(c, m, f) m:each(function(x, y) local h = f(x, y) if h then c:px(x, y, h) end end) end
-- shift all drawn pixels so the outlined bbox sits centred on the canvas
function D.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2 + 0.5) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function D.fin(c) D.recentre(c) H.fin(c) end
return D
