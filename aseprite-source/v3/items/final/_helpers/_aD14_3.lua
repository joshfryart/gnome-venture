-- _aD14_3.lua: private helper for scarab-shell / scarecrow / scorpion-plate / scorpion-stinger (artist D14_3).
-- Self-contained (reads hp.lua, hpx.lua, palette.lua only). Per-pixel lighting, hsl ramp builder, bezier tubes.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local A = { HP = HP, X = X, K = K, out = app.params.out or "./" }

local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function hex(r, g, b) return string.format("#%02x%02x%02x", max(0, min(255, floor(r + .5))), max(0, min(255, floor(g + .5))), max(0, min(255, floor(b + .5)))) end
function A.mix(a, b, t)
  local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b)
  return hex(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
end
local function rgb2hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local mx, mn = max(r, g, b), min(r, g, b)
  local l = (mx + mn) / 2
  if mx == mn then return 0, 0, l end
  local d = mx - mn
  local s = l > .5 and d / (2 - mx - mn) or d / (mx + mn)
  local h
  if mx == r then h = (g - b) / d + (g < b and 6 or 0) elseif mx == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
  return h * 60, s, l
end
local function hsl2rgb(h, s, l)
  h = h % 360
  local c = (1 - abs(2 * l - 1)) * s
  local x = c * (1 - abs((h / 60) % 2 - 1))
  local m = l - c / 2
  local r, g, b = 0, 0, 0
  if h < 60 then r, g, b = c, x, 0 elseif h < 120 then r, g, b = x, c, 0 elseif h < 180 then r, g, b = 0, c, x
  elseif h < 240 then r, g, b = 0, x, c elseif h < 300 then r, g, b = x, 0, c else r, g, b = c, 0, x end
  return (r + m) * 255, (g + m) * 255, (b + m) * 255
end
local function hueToward(h, target, amt)
  local d = ((target - h + 540) % 360) - 180
  return h + d * amt
end
-- 6-tone ramp (dark..light) from a base colour, following the guide recipe (warm lights, cool-violet shadows)
function A.ramp(base, o)
  o = o or {}
  local h, s, l = rgb2hsl(rgb(base))
  local head = 1 - l
  local function mk(hh, ss, ll) return hex(hsl2rgb(hh, min(1, ss), max(0, min(1, ll)))) end
  local hi1 = mk(hueToward(h, 45, .12), s * 1.0, l + head * .30)
  local hi2 = mk(hueToward(h, 50, .2), s * .85, l + head * .58)
  local mid = mk(hueToward(h, 270, .06), s * .95, l * .88)
  local sh = mk(hueToward(h, 270, .14), s * .85, l * .72)
  local dp = mk(hueToward(h, 270, .28), s * .6, l * .48)
  return { dp, sh, mid, base, hi1, hi2 }
end
function A.hash(x, y, s) return X.hash(x, y, s) end

function A.bez(p, t)
  local u = 1 - t
  return u ^ 3 * p[1][1] + 3 * u * u * t * p[2][1] + 3 * u * t * t * p[3][1] + t ^ 3 * p[4][1],
         u ^ 3 * p[1][2] + 3 * u * u * t * p[2][2] + 3 * u * t * t * p[3][2] + t ^ 3 * p[4][2]
end
-- tube along a cubic bezier: half width wfn(t). Returns mask, normals, T, S, samples (S<0 = lit side)
function A.tube(p, wfn, o)
  o = o or {}
  local N = o.steps or 200
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = A.bez(p, t)
    local x2, y2 = A.bez(p, min(1, t + .002))
    local x1, y1 = A.bez(p, max(0, t - .002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx * tx + ty * ty)
    tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 8, floor(by1) + 8 do for x = floor(bx0) - 8, floor(bx1) + 8 do
    local best, bs
    for _, s in ipairs(sm) do
      local dx, dy = x - s.x, y - s.y
      local q = dx * dx + dy * dy
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w + (o.pad or 0) then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-.97, min(.97, sd / (bs.w + .5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn * sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm
end
-- rotated ellipse mask: centre, axis unit (ux,uy), radius along axis ra, across rb
function A.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = math.ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local a = dx * ux + dy * uy
    local b = -dx * uy + dy * ux
    if (a / ra) ^ 2 + (b / rb) ^ 2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
local CUTS = { .2, .38, .55, .71, .86 }
function A.tone(c, m, v, ramp, cuts, bias, tok)
  return X.tone(c, m, v, ramp, { cuts = cuts or CUTS, bias = bias, tok = tok })
end
-- pillow-lit mask: bevel radius R
function A.lit(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 3, o.hs)
  local v = X.light(n, { amb = o.amb or .08, wrap = o.wrap or .25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return n, v, idx
end
-- paint mask m from normals n with ramp; o.adj(x,y,i,v) may change the tone index. returns v, idx
function A.paint(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or .08, wrap = o.wrap or .25 })
  local cuts = o.cuts or CUTS
  local idx = {}
  local tok = o.tok or { r = { name = tostring(ramp) } }
  m:each(function(x, y)
    local k = K(x, y)
    local val = v[k] or 0
    local i = 1
    for j, t in ipairs(cuts) do if val >= t then i = j + 1 end end
    if o.adj then i = o.adj(x, y, i, val) or i end
    i = max(1, min(#ramp, i))
    idx[k] = i
    c:put(x, y, ramp[i], tok)
  end)
  return v, idx
end
function A.sphere(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .4, cy - .4, r, m)
  local v = X.light(n, { amb = .06, wrap = .2 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, tok = o.tok })
  return m, n, v
end
function A.line(c, pts, hexc, w) c:line(pts, w or 1):each(function(x, y) c:px(x, y, hexc) end) end
function A.poly(c, pts, ramp, R, o) local m = c:poly(pts) A.lit(c, m, ramp, R, o) return m end
-- recentre painted pixels (1px outline room) on the canvas
function A.centre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, v in pairs(c.pix) do
    if c.own[i] ~= true or true then
      local x, y = i % c.w, i // c.w
      x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y)
    end
  end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + .5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do
    local x, y = i % c.w + dx, i // c.w + dy
    if x >= 0 and x < c.w and y >= 0 and y < c.h then pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  end
  c.pix, c.own = pix, own
  print(string.format("centre dx %d dy %d size %dx%d", dx, dy, W, Hh))
end
function A.fin(c, name)
  A.centre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.out .. name .. ".aseprite", png = A.out .. name .. ".png", scale = 1 }
end
A.floor, A.sqrt, A.max, A.min, A.abs, A.sin, A.cos, A.pi = floor, sqrt, max, min, abs, sin, cos, pi
return A
