-- _aB30_2.lua: private helpers for feast-berry-honey-cake, feast-dunewhisper-pilaf, feast-egg-pie, feast-forest-roast
-- (Opus single pass). Read-only use of v3/lib/hp.lua + hpx.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local D = { HP = HP, X = X, K = K, FINAL = DIR .. "/../" }
local floor, sqrt, max, min, abs, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
D.norm = norm
D.CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }
function D.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.tok(name) return { r = { name = name } } end
-- paint mask m with normals n onto ramp (6 tones dark->light)
function D.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or D.CUTS, bias = o.bias, tok = o.tok or D.tok(tostring(ramp)) }), v
end
function D.lit(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 3, o.hs)
  local idx = D.toneN(c, m, n, ramp, o)
  return idx, n
end
-- rotated ellipsoid mask + normals
function D.oval(cx, cy, rx, ry, ang, flat)
  ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local m, n = HP.mask(), {}
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u*u + v*v
    if q <= 1 then
      m:set(x, y)
      local wx, wy = u * ca - v * sa, u * sa + v * ca
      n[K(x, y)] = { norm(wx, wy, sqrt(max(1 - q, 0.02)) * (flat or 1)) }
    end
  end end
  return m, n
end
-- vertical-axis cylinder normals for a wall mask (centre cx, half width r); tilt adds an up/down lean
function D.vcylN(m, cx, r, tilt)
  local n = {}
  m:each(function(x, y)
    local s = max(-0.97, min(0.97, (x - cx) / (r + 0.5)))
    n[K(x, y)] = { norm(s, tilt or 0.1, sqrt(1 - s*s)) }
  end)
  return n
end
-- flat mask on the ellipse plane: tilted up toward the viewer (top surfaces in 3/4)
function D.ellipseMask(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local u, v = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if u*u + v*v <= 1 then m:set(x, y) end
  end end
  return m
end
-- sweep: union of mask shifted down 0..h
function D.sweep(m, h) local s = m:copy() for i = 1, h do s:add(m:shift(0, i)) end return s end
function D.rell(cx, cy, ux, uy, ra, rb)
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
function D.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- pixels of a polyline (1 px)
function D.pline(pts) return HP.line(pts, 1) end
-- leaf blade with midrib along A->B (lens shape), ramp 6 tones
function D.leaf(c, ax, ay, bx, by, w, ramp, tok)
  local dx, dy = bx - ax, by - ay
  local L = sqrt(dx*dx + dy*dy)
  local ux, uy = dx / L, dy / L
  local m, n = HP.mask(), {}
  for y = floor(min(ay, by)) - 6, floor(max(ay, by)) + 6 do for x = floor(min(ax, bx)) - 6, floor(max(ax, bx)) + 6 do
    local rx, ry = x - ax, y - ay
    local t = (rx*ux + ry*uy) / L
    local s = -rx*uy + ry*ux
    if t >= 0 and t <= 1 then
      local hw = w * sin(math.pi * t) ^ 0.8
      if abs(s) <= hw + 0.2 then
        m:set(x, y)
        local f = (s < 0) and -0.5 or 0.5
        n[K(x, y)] = { norm(-uy * f, ux * f, 1) }
      end
    end
  end end
  tok = tok or D.tok("leaf")
  D.toneN(c, m, n, ramp, { tok = tok })
  for i = 1, floor(L) - 1 do local x, y = floor(ax + ux * i + .5), floor(ay + uy * i + .5)
    if m:has(x, y) then c:put(x, y, ramp[2], tok) end end
  return m
end
-- shift all drawn pixels so the outlined bbox sits centred
function D.recentre(c)
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
function D.save(c, folder, name)
  D.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local base = D.FINAL .. folder .. "/" .. name
  c:save{ aseprite = base .. ".aseprite", png = base .. ".png", scale = 1 }
  if app.params.out then c:save{ png = app.params.out .. name .. ".png", scale = 1 } end
end
return D
