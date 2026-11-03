-- _aB12_3.lua: private helpers for ph/broken-seed-scoop, broken-silk-net, broken-soil-probe, broken-sprinkler-can
-- (Opus single pass). Loads hp.lua + hpx.lua directly (read-only).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
local G = { HP = HP, X = X, K = K, P = HP.P }
G.INK, G.CREAM = HP.P.ink, HP.P.cream
G.CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }

-- 6-tone ramps, dark -> light
G.WOOD  = { "#4a2a2c", "#74402f", "#9b5e3a", "#bf804b", "#dda86a", "#f3d095" }
G.STEEL = { "#363852", "#555a78", "#7d839f", "#a8adc3", "#cfd3e2", "#eef1f7" }
G.BRASS = { "#5b321f", "#91531e", "#c38427", "#e6b23a", "#f6d66a", "#fff0ae" }
G.BAMBOO= { "#3d4628", "#5d6a31", "#87923e", "#b4b458", "#d9d27c", "#f3edb0" }
G.SILK  = { "#4d5b92", "#6c82bb", "#91acd9", "#b9d0ee", "#d9e8f8", "#f3faff" }
G.ENAM  = { "#1c4644", "#276557", "#378a69", "#55ae78", "#86cf8c", "#c2ecae" }
G.SEED  = { "#4a2a22", "#77472b", "#a6713d", "#cd9c57", "#ecc883" }
G.SOIL  = { "#2f1d22", "#4d2f2a", "#6e4434", "#8d5e42" }
G.WATER = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

function G.start(src)
  local name = src:match("([^/\\]+)%.lua$")
  local out = app.params.out or (src:match("^@(.*)[/\\][^/\\]*$") .. "/")
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  G.name, G.out = name, out
  return c
end
function G.tok(name) return { r = { name = name } } end

-- pillow-lit mask. o: R, amb, wrap, bias, cuts, tok, invert (cavity)
function G.lit(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 3, o.hs)
  if o.invert then for _, v in pairs(n) do v[1], v[2] = -v[1], -v[2] end end
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or G.CUTS, bias = o.bias, tok = o.tok or G.tok("lit") })
  return idx, n, v
end
-- straight cylinder A->B, half width wfn(t); returns m, T, S, idx
function G.cyl(c, ax, ay, bx, by, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)
  if o.clip then m:cut(o.clip) end
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or G.CUTS, bias = o.bias, tok = o.tok or G.tok("cyl") })
  return m, T, S, idx, n
end
-- vertical-axis cylinder shading over x0..x1
function G.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, o.ny or 0, sqrt(1 - t * t) }
  end)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or G.CUTS, bias = o.bias, tok = o.tok or G.tok("vcyl") })
  return idx, n
end
function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along a cubic bezier; returns m, n, T, S
function G.tube(p, wfn, N)
  N = N or 120
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
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  local m, n, T, S = HP.mask(), {}, {}, {}
  for y = floor(by0) - 6, floor(by1) + 6 do for x = floor(bx0) - 6, floor(bx1) + 6 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x + .5 - s.x)^2 + (y + .5 - s.y)^2
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w then
      local sd = (x + .5 - bs.x) * bs.px + (y + .5 - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S
end
function G.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or G.CUTS, bias = o.bias, tok = o.tok or G.tok("t") })
end
-- rotated ellipse mask
function G.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = math.ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local a = dx*ux + dy*uy
    local b = -dx*uy + dy*ux
    if (a/ra)^2 + (b/rb)^2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
-- paint list of {x,y} with hex (owner tok)
function G.pts(c, list, hex, tok) for _, p in ipairs(list) do c:put(p[1], p[2], hex, tok) end end
-- recentre the whole drawing in the 64 canvas (outlined bbox)
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
  print(string.format("recentre dx %d dy %d (outlined %dx%d)", dx, dy, W, Hh))
end
function G.save(c)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = G.out .. G.name .. ".aseprite", png = G.out .. G.name .. ".png", scale = 1 }
end
return G
