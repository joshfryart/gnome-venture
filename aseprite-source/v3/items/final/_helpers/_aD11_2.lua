-- _aD11_2: artist helper for the rain barrels (own copy; shared files untouched). Per-pixel lit cask renderer.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local A = { G = G, HP = HP, X = X, K = K }
A.hash = X.hash
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.WOOD  = { "#3c2230", "#6a3a38", "#98593a", "#c27c44", "#e3a35a", "#f9d28b" }
A.OLD   = { "#3a2a36", "#5e4448", "#85665a", "#aa8a74", "#cfb094", "#ecd6b8" }   -- weathered, bleached
A.IRON  = { "#272437", "#42415c", "#62637f", "#8a8ca8", "#b6bad2", "#eef0ff" }
A.BRASS = { "#55261f", "#86441f", "#bc7420", "#e3a42c", "#f8d150", "#fff6b0" }
A.WATER = { "#1d3f72", "#29629c", "#3b88c0", "#5cb0d8", "#92d4ea", "#dcf6fc" }
A.POND  = { "#183a3c", "#215650", "#2f7a58", "#479a58", "#74b866", "#b2d686" }
A.STONE = { "#363448", "#54536a", "#76758c", "#9a99ae", "#bfbdcc", "#e6e4ee" }
A.MOSS  = { "#173f36", "#21593f", "#38793f", "#58983f", "#88b848", "#bcd878" }
A.RED   = { "#5e1e36", "#9a2c3a", "#d2433a", "#f06a40", "#ff9a5c", "#ffd08a" }
A.SHELL = { "#5e3030", "#8c5038", "#b8764a", "#dc9c5e", "#f2c484", "#fff0c0" }
A.BOUNCE = "#9a6478"

function A.new(name) return G.new2(name) end
function A.fin(c, name) G.save2(c, name) end
function A.rod(c, ax, ay, bx, by, w, ramp, o) return G.cyl(c, ax, ay, bx, by, type(w) == "function" and w or function() return w end, ramp, o) end
function A.ell(cx, cy, rx, ry, ang) return G.oval and nil or nil end
local B = dofile(DIR .. "/../../batch2/_b2.lua")
A.ell = B.ell
A.ln = B.ln
function A.lit(c, m, ramp, R, o) o = o or {} o.R = R or 3 return G.lit(c, m, ramp, o) end

local function clamp(v, a, b) return max(a, min(b, v)) end
local function cuts() return { 0.26, 0.44, 0.6, 0.75, 0.88 } end

-- ---------------------------------------------------------------------------------------- cask
-- o: cx, yt (rim centre), yb (lowest straight body row), wt, wb, bulge, ry (rim), ryb (bottom curve), nst (staves), wood ramp,
--    hoops = { {y=, ramp=, th=3, tilt=0, rivets={dx..}} }, lv (water drop below rim), water ramp, brim (water at lip),
--    notch = {k=stave index, depth=px}  (broken stave), knot = {x,y}, moss = fn(x,y,u,v)->nil
function A.cask(c, o)
  local cx, yt, yb = o.cx, o.yt, o.yb
  local wood = o.wood or A.WOOD
  local nst = o.nst or 7
  local ryb = o.ryb or 3
  local function hw(y)
    local t = clamp((y - yt) / (yb - yt), 0, 1)
    return o.wt + (o.wb - o.wt) * t + o.bulge * sin(pi * t)
  end
  local ymax = yb + ryb
  local body = HP.mask()
  for y = yt, ymax do
    local w = y <= yb and hw(y) or hw(yb) * sqrt(max(0, 1 - ((y - yb) / (ryb + .5)) ^ 2))
    local W = floor(w + .5)
    for x = cx - W, cx + W do body:set(x, y) end
  end
  local rimM = c:ellipse(cx, yt, o.wt + 1, o.ry)
  local inner = c:ellipse(cx, yt, o.wt - 2, o.ry - 2)
  -- stave index per column (angular)
  local function stave(x, y)
    local w = hw(min(y, yb)) + .5
    local u = clamp((x - cx) / w, -.999, .999)
    local sf = (math.asin(u) + pi / 2) / (pi / nst)
    return floor(sf), u, sf
  end
  -- hoop y table
  local hy = {}
  for i, h in ipairs(o.hoops or {}) do
    h.th = h.th or 3
    local w0 = hw(h.y) + .5
    local rh = o.ry * (hw(h.y) / o.wt) * .9
    hy[i] = {}
    for x = cx - floor(w0 + 1.6), cx + floor(w0 + 1.6) do
      local u = clamp((x - cx) / (w0 + .8), -.999, .999)
      hy[i][x] = h.y + floor(rh * sqrt(1 - u * u) + .5) + floor((h.tilt or 0) * (x - cx) + .5)
    end
  end
  -- normals + bias
  local n, bias = {}, {}
  local lowRow = {}
  body:each(function(x, y)
    local w = hw(min(y, yb)) + .5
    local u = clamp((x - cx) / w, -.97, .97)
    local nz = sqrt(1 - u * u)
    local tt = clamp((y - yt) / (yb - yt), 0, 1.3)
    local ny = (tt - .45) * .55
    local l = sqrt(u * u + ny * ny + nz * nz)
    n[K(x, y)] = { u / l, ny / l, nz / l }
    local k = K(x, y)
    local sk, _, sf = stave(x, y)
    local b = 0
    local sv = o.stave and o.stave(sk)
    if sv then b = b + sv else
      local hh = X.hash(sk, 3, 9)
      b = b + (hh > .66 and 1 or (hh < .22 and -1 or 0))
    end
    -- seams: darkest on the boundary, lit lip beside it
    local fr = sf - floor(sf)
    local wpx = (pi / nst) * w * sqrt(1 - u * u)         -- stave width in px here
    local d = fr * wpx
    if d < .7 then b = b - 2 elseif d < 1.7 and wpx > 3 then b = b + 1 end
    if wpx - d < .55 then b = b - 1 end
    -- grain: vertical streaks
    local gs = floor(X.hash(x, 0, 5) * 9)
    local gl = 4 + floor(X.hash(x, 1, 6) * 4)
    local g = X.hash(x, floor((y + gs) / gl), 21)
    if g > .8 then b = b - 1 elseif g < .07 then b = b + 1 end
    -- hoop shadow
    for i, h in ipairs(o.hoops or {}) do
      local yy = hy[i][x]
      if yy then
        if y == yy + h.th then b = b - 1 end
        if y == yy - 1 then b = b + 0 end
      end
    end
    -- bottom AO
    if y >= ymax - 1 then b = b - 1 end
    bias[k] = b
  end)
  if o.knot then
    local kx, ky = o.knot[1], o.knot[2]
    for dy = -2, 2 do for dx = -1, 1 do
      local k = K(kx + dx, ky + dy)
      if n[k] then
        local r = (dx * dx) / 1.2 + (dy * dy) / 3
        if r <= .5 then bias[k] = -3 elseif r <= 1.4 then bias[k] = -1 end
      end
    end end
    local k = K(kx - 1, ky - 2) if n[k] then bias[k] = 1 end
  end
  -- under-rim ambient
  rimM:grow(2):cut(rimM):each(function(x, y) local k = K(x, y) if bias[k] and y > yt then bias[k] = bias[k] - 1 end end)
  local v = X.light(n, { amb = .07, wrap = .28 })
  local tok = { r = { name = "wood" } }
  local idx = X.tone(c, body, v, wood, { cuts = cuts(), bias = bias, tok = tok })
  -- reflected light on the shade edge (warm-violet bounce), lower body only
  body:each(function(x, y)
    local k = K(x, y)
    local w = hw(min(y, yb)) + .5
    local u = (x - cx) / w
    if u > .8 and y > yt + 10 and y < ymax - 1 and idx[k] <= 2 and X.hash(x, y, 4) > .3 then c:put(x, y, A.BOUNCE, tok) end
  end)
  if o.bodyFx then o.bodyFx(c, body, idx, hw, tok) end
  -- hoops
  for i, h in ipairs(o.hoops or {}) do
    local hr = h.ramp or A.IRON
    local htok = { r = { name = "hoop" .. i } }
    local w0 = hw(h.y) + .5
    for x = cx - floor(w0 + 1.6), cx + floor(w0 + 1.6) do
      local u = clamp((x - cx) / (w0 + .8), -.97, .97)
      local nz = sqrt(1 - u * u)
      local dl = (u * X.L[1] + nz * X.L[3] + .28) / 1.28
      local vv = clamp(.07 + .93 * max(dl, 0), 0, 1)
      local base = 1
      for j, t in ipairs(cuts()) do if vv >= t then base = j + 1 end end
      local yy = hy[i][x]
      for r = 0, h.th - 1 do
        local ii = base
        if r == 0 then ii = min(5, ii + 1) elseif r == h.th - 1 then ii = ii - 2 elseif h.th >= 3 and r == h.th - 2 then ii = ii - 1 end
        if abs(x - cx) >= floor(w0 + 1.2) then ii = ii - 1 end
        c:put(x, yy + r, hr[clamp(ii, 1, 6)], htok)
      end
    end
    for _, dx in ipairs(h.rivets or {}) do
      local x = cx + dx
      local yy = hy[i][x]
      if yy then c:put(x, yy + 1, h.rivetC or hr[6], htok) c:put(x, yy + 2, hr[1], htok) end
    end
    -- specular streak on the lit hoop face
    local sx = cx - floor(w0 * .5)
    local yy = hy[i][sx]
    if yy then c:put(sx, yy, hr[6], htok) c:put(sx + 1, yy, hr[6], htok) end
    h._y = hy[i]
  end
  -- rim: end-grain ring
  local rtok = { r = { name = "rim" } }
  local ring = rimM:copy():cut(inner)
  if o.notch then
    -- a broken stave: cut a jagged bite from the front-right rim
    local nx0, nx1 = o.notch.x0, o.notch.x1
    ring:each(function(x, y) if x >= nx0 and x <= nx1 and y >= yt + 1 then ring:set(x, y) end end)
  end
  ring:each(function(x, y)
    local dxn = (x - cx) / (o.wt + 1)
    local dyn = (y - yt) / o.ry
    local i = 5
    if dxn > .35 then i = 4 end
    if dxn > .75 then i = 3 end
    if dyn > .7 then i = i - 1 end
    local h = X.hash(x, y, 12)
    if h > .86 then i = i - 1 elseif h < .08 then i = i + 1 end
    if dyn < -.5 and dxn < .1 then i = i + 1 end
    -- outer edge on the front is shaded
    c:put(x, y, wood[clamp(i, 1, 6)], rtok)
  end)
  -- front outer lip: 1px shade row under the rim front
  rimM:copy():cut(rimM:shift(0, -1)):each(function(x, y) if y > yt + 1 then c:put(x, y, wood[2], rtok) end end)
  -- interior
  local lv = o.lv or 3
  local water = inner:shift(0, lv):clip(inner)
  local wall = inner:copy():cut(water)
  local wtok = { r = { name = "wall" } }
  wall:each(function(x, y)
    local dxn = (x - cx) / (o.wt - 2)
    local i = 2
    if dxn > .2 then i = 3 end
    if dxn < -.45 then i = 1 end
    if y > yt - 1 and dxn > .2 then i = 3 end
    local h = X.hash(x, 0, 31)
    if h > .75 then i = i - 1 end
    c:put(x, y, wood[clamp(i, 1, 6)], wtok)
  end)
  local wr = o.water or A.WATER
  local wk = { r = { name = "water" } }
  local wedge = water:edge()
  local wb = water:bbox()
  water:each(function(x, y)
    local dxn = (x - cx) / (o.wt - 2)
    local dyn = (y - (yt + lv)) / (o.ry - 2)
    local i = 4
    if dyn < -.35 then i = 3 end
    -- ripple ring
    local rr = sqrt(dxn * dxn + dyn * dyn * .9)
    if o.ripple and abs(rr - o.ripple) < .09 then i = 5 end
    if dyn < -.6 then i = 3 end
    c:put(x, y, wr[i], wk)
  end)
  -- dark meniscus against the wall, bright lip on the near-left
  water:shift(0, 1):cut(water):each(function(x, y) end)
  inner:edge():each(function(x, y)
    if water:has(x, y) then
      local dxn = (x - cx) / (o.wt - 2)
      if y > yt + lv and dxn < .1 then c:put(x, y, wr[5], wk) else c:put(x, y, wr[2], wk) end
    end
  end)
  -- brim: convex water standing proud of the lip
  if o.brim then
    inner:edge():each(function(x, y)
      local dxn = (x - cx) / (o.wt - 2)
      c:put(x, y, (dxn < .3) and wr[6] or wr[5], wk)
    end)
  end
  c:put(cx - 3, yt + lv, wr[6], wk) c:put(cx - 2, yt + lv, wr[6], wk) c:put(cx - 4, yt + lv + 1, wr[5], wk)
  return { body = body, rim = rimM, inner = inner, water = water, wall = wall, hw = hw, wood = wood, wr = wr, cx = cx, yt = yt, yb = yb,
    ymax = ymax, o = o, hy = hy, idx = idx }
end

-- ---------------------------------------------------------------------------------------- bits
function A.drop(c, x, y, ramp)
  local rp = ramp or A.WATER
  c:px(x, y, rp[4]) c:px(x - 1, y + 1, rp[4]) c:px(x, y + 1, rp[5]) c:px(x + 1, y + 1, rp[3]) c:px(x, y + 2, rp[3])
  c:px(x - 1, y + 2, rp[2]) c:px(x + 1, y + 2, rp[2]) c:px(x, y + 3, rp[2])
  c:px(x - 1, y + 1, rp[6])
end
function A.tinydrop(c, x, y, ramp)
  local rp = ramp or A.WATER
  c:px(x, y, rp[5]) c:px(x, y + 1, rp[3])
end
-- ring collar on a pipe: horizontal band crossing a vertical rod
function A.collar(c, x, y, hw, ramp, h)
  h = h or 2
  for yy = 0, h - 1 do for xx = -hw, hw do
    local i = (yy == 0) and 5 or 2
    if xx == -hw then i = i - 1 end
    c:px(x + xx, y + yy, ramp[clamp(i + (xx < 0 and 1 or 0), 1, 6)])
  end end
end
return A
