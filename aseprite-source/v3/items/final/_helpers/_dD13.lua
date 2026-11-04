-- dD13 helper (Sonnet first draft chunk: rock-pick..sago-seed). Layer over _dD11.lua (which wraps batch2/_b2.lua); shared files untouched.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dD11.lua")
local B, H, HP, X, R = D.B, D.H, D.HP, D.X, D.R
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi

-- bezier points (dense list of {x,y,tx,ty})
function D.curve(p, n)
  n = n or 40
  local out = {}
  for i = 0, n do
    local t = i / n local u = 1 - t
    local x = u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1]
    local y = u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
    local dx = 3*u*u*(p[2][1]-p[1][1]) + 6*u*t*(p[3][1]-p[2][1]) + 3*t*t*(p[4][1]-p[3][1])
    local dy = 3*u*u*(p[2][2]-p[1][2]) + 6*u*t*(p[3][2]-p[2][2]) + 3*t*t*(p[4][2]-p[3][2])
    local l = sqrt(dx*dx + dy*dy) if l == 0 then l = 1 end
    out[#out+1] = { x, y, dx / l, dy / l }
  end
  return out
end
-- tapered swept mask along a curve: wfn(t) half width; returns mask
function D.sweepM(pts, wfn)
  local m = HP.mask()
  for i, p in ipairs(pts) do
    local t = (i - 1) / (#pts - 1) local r = wfn(t)
    for dy = -math.ceil(r), math.ceil(r) do for dx = -math.ceil(r), math.ceil(r) do
      if dx*dx + dy*dy <= r*r + .25 then m:set(floor(p[1] + dx + .5), floor(p[2] + dy + .5)) end
    end end
  end
  return m
end
-- twisted rope along dense points; w = half width; ramp 6 tones
function D.rope(c, pts, w, ramp)
  local rp = R(ramp)
  local tok = { r = { name = "rope" } }
  for i, p in ipairs(pts) do
    local nx, ny = -p[4], p[3]
    for dy = -math.ceil(w), math.ceil(w) do for dx = -math.ceil(w), math.ceil(w) do
      if dx*dx + dy*dy <= w*w + .3 then
        local d = dx*nx + dy*ny
        local lit = -(nx * -.6 + ny * -.7) * (d / (w + .3))   -- crude: side toward light brighter
        local ph = (i * .55 + d * 1.1) % 3
        local idx = 4
        if lit > .35 then idx = 5 elseif lit < -.35 then idx = 3 end
        if ph < .8 then idx = idx - 2 elseif ph > 2.2 then idx = idx + 1 end
        c:put(floor(p[1] + dx + .5), floor(p[2] + dy + .5), rp[max(1, min(6, idx))], tok)
      end
    end end
  end
end
-- speckle a mask with hex colours at a density
function D.speck(c, m, hexes, dens, seed)
  m:each(function(x, y)
    local h = X.hash(x, y, seed or 7)
    if h > 1 - dens then c:px(x, y, hexes[1 + floor(X.hash(x, y, (seed or 7) + 5) * #hexes) % #hexes]) end
  end)
end
-- a needle: short line from (x,y) in direction ang, len; two tones (top/bottom)
function D.needle(c, x, y, ang, len, hexA, hexB)
  local ex, ey = x + cos(ang) * len, y + sin(ang) * len
  B.ln(c, floor(x + .5), floor(y + .5), floor(ex + .5), floor(ey + .5), hexA)
  if hexB then c:px(floor(ex + .5), floor(ey + .5), hexB) end
end
-- pearl: small lit sphere
function D.pearl(c, cx, cy, r, ramp, spec)
  return D.sph(c, cx, cy, r, ramp, { spec = spec })
end
-- arched door: rectangle with elliptical top. cx, yb (bottom), w (half width), h (height). returns mask
function D.archM(c, cx, yb, w, h)
  local m = c:rect(cx - w, yb - h + w, cx + w - 1, yb)
  m:add(c:ellipse(cx - .5, yb - h + w, w, w):clip(c:rect(cx - w - 1, yb - h - 1, cx + w, yb - h + w)))
  return m
end
-- plank door: planks vertical, wood ramp, ring handle. o: frame hex, handle hex
function D.door(c, cx, yb, w, h, wood, o)
  o = o or {}
  local m = D.archM(c, cx, yb, w, h)
  local rp = R(wood or "wood")
  D.lit(c, m, rp, 2.2, { amb = .1 })
  -- plank lines
  m:each(function(x, y)
    if (x - (cx - w)) % 3 == 2 then c:px(x, y, rp[2]) end
  end)
  -- iron strap
  c:fillMask(c:rect(cx - w, yb - floor(h * .35), cx + w - 1, yb - floor(h * .35)), o.strap or "#444663")
  c:px(cx + w - 3, yb - floor(h * .4) , o.handle or "#ffe38a")
  c:px(cx + w - 3, yb - floor(h * .4) + 1 , o.handle or "#ffe38a")
  return m
end
-- grass mound: o cx, yb (base y), rx, ry, ramp, skew (x offset of peak)
function D.mound(c, o)
  local m = HP.mask()
  local sk = o.skew or 0
  for y = o.yb - o.ry, o.yb do
    local t = (y - (o.yb - o.ry)) / o.ry           -- 0 top .. 1 bottom
    local hw = o.rx * sqrt(1 - (1 - t) ^ 2.2)
    local off = sk * (1 - t)
    for x = floor(o.cx + off - hw + .5), floor(o.cx + off + hw - .5) do m:set(x, y) end
  end
  local rp = R(o.ramp or "moss")
  D.lit(c, m, rp, o.R or (o.ry * .75), { amb = .08, wrap = .3 })
  return m
end
return D
