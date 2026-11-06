-- _aA7_2.lua: private helpers for ico/ico-mouse, ico-mushroom, ico-music, ico-newspaper (final pass, Opus). Copy of _aA0_2.lua.
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi, atan, log, exp = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan, math.log, math.exp
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS = CUTS
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- blend two normal fields (w = weight of b)
function A.blend(na, nb, w)
  local n = {}
  for k, a in pairs(na) do local b = nb[k] or a
    n[k] = { norm(a[1] * (1 - w) + b[1] * w, a[2] * (1 - w) + b[2] * w, a[3] * (1 - w) + b[3] * w) } end
  return n
end

-- re-tone one pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- coiled shell. m mask; spiral centre (sx,sy); a = start radius; gap = px between whorls at r=gapR (log spiral)
-- o: ramp, tok, aspect (y stretch: py *= aspect), dir (+1/-1), sphere {cx,cy,r}, bands {from,to,ramp}, ribs (deg step)
function A.coil(c, m, o)
  local ramp, tok = o.ramp, o.tok
  local sx, sy, asp, dir = o.sx, o.sy, o.aspect or 1, o.dir or 1
  local b = o.b or 0.2                      -- growth rate per radian
  local a = o.a or 1.2
  local nS = X.sphere(o.cx, o.cy, o.r, m)
  local nP = X.pillow(m, o.R or 4)
  local n = A.blend(nP, nS, o.wS or 0.65)
  local bias, ph = {}, {}
  m:each(function(x, y)
    local dx, dy = x + 0.5 - sx, (y + 0.5 - sy) * asp
    local r = sqrt(dx*dx + dy*dy)
    local th = atan(dy, dx) * dir + (o.rot or 0)
    local k = K(x, y)
    if r < a then ph[k] = 0.5 return end
    local p = (log(r / a) / b - th) / (2 * pi)
    local f = p - floor(p)
    ph[k] = f
    local spacing = r * (1 - exp(-2 * pi * b))   -- px between whorls here
    local dpx = f * spacing                         -- px from inner suture, outward
    local dout = (1 - f) * spacing                  -- px to next suture outward
    if dpx < 1 then bias[k] = -3                    -- suture groove
    elseif dout < 1.2 then bias[k] = -1             -- whorl rolls down into the groove
    elseif dpx < 2.2 then bias[k] = 1 end           -- lit lip just outside the groove
  end)
  if o.bias then for k, v in pairs(o.bias) do bias[k] = (bias[k] or 0) + v end end
  local idx, v = A.shade(c, m, n, ramp, { amb = o.amb or 0.08, wrap = o.wrap or 0.25, bias = bias, tok = tok })
  -- colour bands (Cepaea-like) following the whorl
  if o.bands then
    m:each(function(x, y) local k = K(x, y) local f = ph[k]
      for _, bd in ipairs(o.bands) do
        if f >= bd[1] and f < bd[2] and (bias[k] or 0) > -3 then c:put(x, y, bd[3][idx[k]], tok) end
      end
    end)
  end
  -- growth ribs: faint radial lines every `ribs` degrees (one tone darker on mid tones)
  if o.ribs then
    m:each(function(x, y) local k = K(x, y)
      local dx, dy = x + 0.5 - sx, (y + 0.5 - sy) * asp
      local r = sqrt(dx*dx + dy*dy)
      if r > 3 then
        local th = (atan(dy, dx) * 180 / pi + 360 + r * (o.ribTwist or 2.5)) % o.ribs
        if th < (o.ribW or 360 / (2 * pi * r)) * 1.0 and idx[k] and idx[k] >= 3 and idx[k] <= 5 and (bias[k] or 0) == 0 then
          A.step(c, idx, o.bandIdxRamp or ramp, x, y, -1, tok) end
      end
    end)
  end
  return idx, n, ph, bias
end

-- snail foot / body along a cubic bezier. returns m, n, T, S, idx, samp
function A.foot(c, p, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(p, wfn)
  if o.add then
    for _, extra in ipairs(o.add) do
      local em, en = extra[1], extra[2]
      em:each(function(x, y) if not m:has(x, y) then m:set(x, y) n[K(x, y)] = en[K(x, y)] T[K(x, y)] = extra[3] or 1 S[K(x, y)] = 0 end end)
    end
  end
  -- flatter sole: tilt normals of the lower rows downward (sole is shadowed)
  local bias = o.bias or {}
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.12, wrap = o.wrap or 0.32, bias = bias, tok = o.tok, cuts = o.cuts })
  return m, n, T, S, idx, samp
end

-- skin: reticulated furrows (two diagonal families, sparse) on mid/hi tones
function A.skin(c, m, idx, ramp, tok, o)
  o = o or {}
  local s1, s2 = o.s1 or 5, o.s2 or 7
  m:each(function(x, y) local k = K(x, y) local i = idx[k]
    if i and i >= 3 and i <= 5 and not (o.skip and o.skip:has(x, y)) then
      local a = (x + 2 * y) % s1 == 0
      local b = (2 * x - y + 50) % s2 == 0
      if (a and (x + y) % 3 ~= 0) or (b and (x * y) % 4 == 0) then A.step(c, idx, ramp, x, y, -1, tok) end
    end
  end)
end

-- frilled sole edge: bottom pixel of each column of mask, between x0..x1, alternating deep/shade
function A.sole(c, m, ramp, x0, x1, tok)
  for x = x0, x1 do
    local yb
    for y = 63, 0, -1 do if m:has(x, y) then yb = y break end end
    if yb then
      c:put(x, yb, ramp[(x % 3 == 0) and 1 or 2], tok)
      if m:has(x, yb - 1) and x % 3 ~= 1 then c:put(x, yb - 1, ramp[2], tok) end
    end
  end
end

-- eye stalk: thin 2 px tube A->B + 2px bulb + 2x3 ink pill with glint toward (fx) facing direction
function A.stalk(c, ax, ay, bx, by, ramp, tok, face)
  local m, n = X.cyl(ax, ay, bx, by, function(t) return 0.55 + (1 - t) * 0.35 end)
  local v = X.light(n, { amb = 0.2, wrap = 0.4 })
  X.tone(c, m, v, ramp, { cuts = CUTS, tok = tok })
  -- bulb
  local bm = c:ellipse(floor(bx), floor(by), 2, 2)
  local bn = X.sphere(floor(bx) + 0.5, floor(by) + 0.5, 2.2, bm)
  X.tone(c, bm, X.light(bn, { amb = 0.3, wrap = 0.5 }), ramp, { cuts = CUTS, tok = tok })
  -- eye pill (2x3) inside the bulb, leaning to the facing side, pale bulb rim all round
  local ex = face > 0 and floor(bx) or floor(bx) - 1
  local ey = floor(by) - 1
  for yy = 0, 2 do for xx = 0, 1 do c:put(ex + xx, ey + yy, A.INK, tok) end end
  c:put(ex, ey, A.CREAM, tok)
  return m:add(bm)
end

-- leaf blade with midrib + veins (from _aA0_0 pattern, own copy)
function A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, o)
  o = o or {}
  local wfn = o.wfn or function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.98 + 0.04)) ^ (o.pw or 0.75))
  end
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, wfn, { fold = o.fold or 0.45 })
  if o.cut then m:cut(o.cut) end
  local tok = o.tok or { r = { name = "leaf" } }
  local idx = G.toneN(c, m, n, ramp, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, bias = o.bias })
  local vs = o.vs or 3.2
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and ramp[min(6, (idx[k] or 3) + 2)] or ramp[max(2, (idx[k] or 3) - 1)], tok)
    elseif t > 0.12 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.8 then
      local d = (t * len - abs(s) * w * 1.1) % vs
      if d < 0.9 then c:put(x, y, s < 0 and ramp[min(6, (idx[k] or 3) + 1)] or ramp[max(1, (idx[k] or 3) - 1)], tok) end
    end
  end)
  return m, T, S, idx
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- recentre, outline, check, save. out dir = app.params.out or <final>/<folder>/
function A.save(c, name, folder)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../" .. folder .. "/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A
