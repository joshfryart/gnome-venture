-- batch1 shared helpers (first-draft items). Wraps hp.lua + hpx.lua lighting.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local P = dofile(LIB .. "palette.lua")
local K = X.K
local H = { HP = HP, X = X, P = P, K = K, out = app.params.out or "./" }
local floor, sqrt, sin, cos, pi, max, min = math.floor, math.sqrt, math.sin, math.cos, math.pi, math.max, math.min

local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
function H.mix(a, b, t)
  local r1,g1,b1 = rgb(a) local r2,g2,b2 = rgb(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5))
end
function H.ramp(r)
  if type(r) == "string" then r = P[r] end
  if #r == 6 then return r end
  return { r.deep, r.shade, H.mix(r.shade, r.base, .5), r.base, H.mix(r.base, r.hi, .55), r.hi }
end
function H.new(name)
  H.name = name
  return HP, X, HP.canvas{ w = 64, h = 64, scale = 1, name = name }, P
end
local CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }
-- pillow-lit part. o: R bevel, amb, wrap, bias, cuts, nospec
function H.lit(c, m, ramp, o)
  o = o or {}
  ramp = H.ramp(ramp)
  local n = X.pillow(m, o.R or 3, o.hs)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return idx, n, v
end
-- vertical-axis cylinder shade (jars, pails): normal varies with x only between x0..x1
function H.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  ramp = H.ramp(ramp)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return n
end
function H.disc(c, cx, cy, r, ramp, o)
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .4, cy - .4, r, m)
  local v = X.light(n, { amb = 0.06, wrap = 0.2 })
  X.tone(c, m, v, H.ramp(ramp), { cuts = (o and o.cuts) or CUTS })
  return m, n
end
function H.spec(c, x, y, hex, big)
  c:px(x, y, hex or P.cream)
  if big then c:px(x + 1, y, hex or P.cream) end
end
-- tapered cylinder A->B with lighting; wfn(t) half width
function H.cyl(c, ax, ay, bx, by, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, H.ramp(ramp), { cuts = o.cuts or CUTS, bias = o.bias })
  return m, T, S
end
function H.leaf(c, ax, ay, bx, by, w, ramp, veins)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 1.02 + 0.06)) ^ 0.7)
  end)
  local r = H.ramp(ramp)
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), r, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  m:each(function(x, y)
    local s, t = S[K(x, y)], T[K(x, y)]
    if math.abs(s) < 0.2 and t > 0.06 and t < 0.86 then c:px(x, y, s <= 0 and r[6] or r[3]) end
    for _, vt in ipairs(veins or {}) do
      local d = t * len - (vt + math.abs(s) * 2.4)
      if d > -0.5 and d < 0.5 and math.abs(s) > 0.3 and math.abs(s) < 0.8 then c:px(x, y, s < 0 and r[5] or r[2]) end
    end
  end)
  return m
end
-- bezier (4 pts) swept disc mask; returns mask, T (t per pixel)
function H.sweep(pts, wfn, steps)
  steps = steps or 60
  local m, T = HP.mask(), {}
  for i = 0, steps do
    local t = i / steps
    local u = 1 - t
    local x = u^3*pts[1][1] + 3*u*u*t*pts[2][1] + 3*u*t*t*pts[3][1] + t^3*pts[4][1]
    local y = u^3*pts[1][2] + 3*u*u*t*pts[2][2] + 3*u*t*t*pts[3][2] + t^3*pts[4][2]
    local r = wfn(t)
    for dy = -math.ceil(r), math.ceil(r) do
      for dx = -math.ceil(r), math.ceil(r) do
        if dx*dx + dy*dy <= r*r + 0.25 then
          local px, py = floor(x + dx + .5), floor(y + dy + .5)
          if not m:has(px, py) then T[K(px, py)] = t end
          m:set(px, py)
        end
      end
    end
  end
  return m, T
end
function H.fin(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = H.out .. H.name .. ".aseprite", png = H.out .. H.name .. ".png", scale = 1 }
end
function H.each(m, f) m:each(f) end
return H
