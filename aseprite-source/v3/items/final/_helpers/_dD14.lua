-- dD14 helper (Sonnet first draft chunk: sakura-seed..sea-grape-sorbet). Layer over _dD13.lua; shared files untouched.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dD13.lua")
local B, H, HP, X, R = D.B, D.H, D.HP, D.X, D.R
local floor, ceil, max, min, abs, sin, cos, sqrt, pi = math.floor, math.ceil, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi

-- egg mask, broad end down. returns mask (lit with ramp)
function D.eggM(cx, cy, rx, ry, k)
  local m = HP.mask()
  for y = floor(cy - ry), ceil(cy + ry) do
    local t = (y - cy) / ry
    local w = rx * sqrt(max(0, 1 - t * t)) * (1 + (k or .14) * t)
    for x = floor(cx - w + .5), floor(cx + w - .5) do m:set(x, y) end
  end
  return m
end
function D.egg(c, cx, cy, rx, ry, ramp, o)
  local m = D.eggM(cx, cy, rx, ry, o and o.k)
  D.lit(c, m, ramp, min(rx, ry) * .85, { amb = .08, wrap = .25 })
  if not (o and o.nospec) then c:px(floor(cx - rx * .45), floor(cy - ry * .5), (o and o.spec) or R(ramp)[6]) end
  return m
end
-- five-petal blossom from lit dots
function D.blossom(c, cx, cy, r, ramp, centre)
  for i = 0, 4 do
    local a = -pi / 2 + i * 2 * pi / 5
    D.sph(c, floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5), 1.5, ramp, { nospec = true })
  end
  c:px(cx, cy, centre or "#fff4d6") c:px(cx, cy - 1, centre or "#fff4d6")
end
-- coloured rotated ellipse with lighting
function D.eLit(c, cx, cy, rx, ry, ang, ramp, Rr, o)
  local m = D.ell(cx, cy, rx, ry, ang)
  D.lit(c, m, ramp, Rr or min(rx, ry) + .6, o)
  return m
end
-- paint per-pixel by function(x,y,mask)->hex|nil
function D.eachPaint(c, m, f) m:each(function(x, y) local h = f(x, y) if h then c:px(x, y, h) end end) end
-- thin bezier polyline of pixels
function D.bezLine(c, p, hex, n)
  local pts = D.curve(p, n or 60)
  for _, q in ipairs(pts) do c:px(floor(q[1] + .5), floor(q[2] + .5), hex) end
  return pts
end
-- recentre painted pixels (room for outline) then finish + save
function D.fin()
  local c = B.c
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + .5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy
    if x >= 0 and x < c.w and y >= 0 and y < c.h then pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d size %dx%d", dx, dy, W, Hh))
  H.fin(c)
end
return D
