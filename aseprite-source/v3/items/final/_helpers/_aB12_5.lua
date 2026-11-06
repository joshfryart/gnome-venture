-- _aB12_5.lua: private helpers for the broken travel quartet (tin-lantern, tin-watering-can, walking-stick,
-- wayfarer-s-staff). Opus single pass. Wraps v3/lib/hp.lua + hpx.lua (read-only).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local floor, sqrt, max, min, abs, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin
local A = { HP = HP, X = X, K = K, P = HP.P }

-- 6-tone ramps, dark -> light
A.TIN   = { "#2c2c48", "#464863", "#686b85", "#9093aa", "#bcbdcc", "#ebeaf2" }
A.GOLD  = { "#58261f", "#8f4a1f", "#c4691f", "#e8962a", "#f8c548", "#ffeaa2" }
A.WOOD  = { "#3e2125", "#5f3329", "#86492f", "#a96a40", "#cb8f58", "#ebbd86" }
A.DWOOD = { "#2f1a22", "#4a2a26", "#6a3a2c", "#8a5236", "#ad7448", "#d49d68" }
A.GLOW  = { "#6e3a2a", "#a8602c", "#d89038", "#f2bd55", "#ffdf8a", "#fff3cc" }
A.GEM   = { "#1f2a5e", "#2c4a9c", "#3a72c8", "#5fa6e8", "#9ad6f6", "#e4f8ff" }
A.ROPE  = { "#4e3226", "#7a5434", "#a47a48", "#c9a264", "#e6c98c", "#f7e6b4" }
A.SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
A.SPEC = "#fff4d6"
A.CUTS = { 0.24, 0.42, 0.58, 0.73, 0.87 }

function A.new(name)
  A.name = name
  A.out = app.params.out or (DIR .. "/../ph/")
  return HP.canvas{ w = 64, h = 64, scale = 1, name = name }
end
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }), v
end
function A.lit(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 2, o.hs)
  local idx = A.tone(c, m, n, ramp, o)
  return idx, n
end
-- vertical cylinder normals (x0..x1 across), optional vertical round-off near top/bottom rows
function A.vcyl(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  return n
end
function A.sphere(c, cx, cy, r, ramp, o)
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .3, cy - .3, r, m)
  local idx = A.tone(c, m, n, ramp, o)
  return m, n, idx
end
function A.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier, half width wfn(t). returns mask, normals, T, S (S<0 = lit side), samples, length
function A.tube(p, wfn, steps)
  local N = steps or 160
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = A.bez(p, t)
    local x2, y2 = A.bez(p, min(1, t + 0.002))
    local x1, y1 = A.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  local len = 0
  for i = 2, #sm do len = len + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 6, floor(by1) + 6 do for x = floor(bx0) - 6, floor(bx1) + 6 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x + .5 - s.x - .5)^2 + (y + .5 - s.y - .5)^2
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
  return m, n, T, S, sm, len
end
function A.rell(cx, cy, ux, uy, ra, rb)
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
-- erase pixels (a real gap)
function A.clear(c, x, y)
  if x >= 0 and y >= 0 and x < c.w and y < c.h then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end
end
function A.clearMask(c, m) m:each(function(x, y) A.clear(c, x, y) end) end
-- move painted pixels of mask m by dx,dy (keeps colours and owners)
function A.move(c, m, dx, dy)
  local buf = {}
  m:each(function(x, y) local i = y * c.w + x if c.pix[i] then buf[#buf+1] = { x, y, c.pix[i], c.own[i] } end end)
  for _, b in ipairs(buf) do A.clear(c, b[1], b[2]) end
  for _, b in ipairs(buf) do c:put(b[1] + dx, b[2] + dy, b[3], b[4]) end
end
-- hand pixel map; map char -> hex
function A.rows(c, rows, x0, y0, map, tok)
  tok = tok or { r = { name = "hand" } }
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if map[ch] then c:put(x0 + i - 1, y0 + j - 1, map[ch], tok) end
  end end
end
function A.get(c, x, y) return c.pix[y * c.w + x] end
-- darken/lighten an existing pixel by ramp step if its colour is in ramp
function A.step(c, x, y, ramp, d)
  local h = A.get(c, x, y)
  if not h then return end
  for i, v in ipairs(ramp) do if v == h then c:put(x, y, ramp[max(1, min(#ramp, i + d))], c.own[y * c.w + x]) return end end
end
function A.recentre(c)
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
function A.save(c)
  A.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.out .. A.name .. ".aseprite", png = A.out .. A.name .. ".png", scale = 1 }
end
return A
