-- hedgehog.lua (rewrite 2, 2026-11-05): shared hedgehog anatomy for the 11 hedgehog portraits + 11 sprites.
-- Read: 3/4 view facing right. A big jagged mound of swept-back spines covers the crown, the back of the head
-- and the whole back; a small pale face mask sits UNDER the spine fringe and tapers into a long pointed snout
-- with a big dark wet nose at the tip; tiny bead eye, small low round ear, pale belly, stubby paws.
--   local HH = dofile(<v3>/lib/hedgehog.lua)
--   HH.portrait{ name=, out=, SP=, FACE=, BG=, behind=fn, body=fn, spines=fn, hat=fn, front=fn }
--   HH.sprite{ name=, out=, SP=, FACE=, frames={ {b=,blink=,...}, ... }, behind=, body=, spines=, hat=, front= }
-- Callbacks get (c, k): k.X(lx), k.Y(ly) map head-local units to pixels, k.s scale, k.b bob, k.p frame params,
-- k.torso mask (clothes area), k.crown {x,y} (top of spine crown), k.paw {x,y} (front paw), k.spine mask.
local HH = {}
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local HP = dofile(DIR .. "/hp.lua")
HH.HP, HH.P = HP, HP.P
local INK = "#2b1c26"
HH.INK = INK
HH.SP = { deep = "#33202c", shade = "#553630", base = "#7a5240", hi = "#a87c58", tip = "#ead3a8" }
HH.FACE = { hi = "#fcebcc", base = "#efcca2", shade = "#cf9f7a", deep = "#96644f" }
HH.NOSE = { base = "#3a2731", hi = "#a48e9c", sh = "#2e1e27" }
HH.EAR = "#e0a090"
HH.BLUSH = "#f0968c"

local floor, sqrt = math.floor, math.sqrt
local function rnd(v) return floor(v + 0.5) end
local function hash(x, y, s) local n = math.sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end
local function nrm(x, y) local l = sqrt(x * x + y * y) if l < 1e-6 then return 0, 0 end return x / l, y / l end
HH.rnd, HH.hash = rnd, hash
local LX, LY = nrm(-0.6, -0.8)

-- tone pick on a spine ramp: idx 1 deep .. 5 tip
local ORDER = { "deep", "shade", "base", "hi", "tip" }
local function tone(SP, i) if i < 1 then i = 1 elseif i > 5 then i = 5 end return SP[ORDER[i]] end

-- Paint a spine mound.
-- o.shapes = { {cx,cy,rx,ry, a0,a1}, ... } (a0..a1 = degrees where outline spikes grow, y-down: 270 = up, 180 = left)
-- o.back = {x,y} sweep direction (backwards), o.len spike length, o.hw spike half width, o.step degrees,
-- o.gap stroke grid spacing, o.slen stroke length, o.cut mask kept free (face), o.seed
function HH.spines(c, o)
  local SP = o.SP
  local base = HP.mask()
  for _, e in ipairs(o.shapes) do base:add(c:ellipse(e[1], e[2], e[3], e[4])) end
  if o.clip then base:clip(o.clip) end
  local bx, by = nrm(o.back[1], o.back[2])
  local sweep = o.sweep or 0.9
  local spikes = {}
  for si, e in ipairs(o.shapes) do
    if e[5] then
      local a = e[5]
      local j = 0
      while a <= e[6] + 0.01 do
        local r = math.rad(a + (hash(si, j, o.seed) - 0.5) * (o.step * 0.35))
        local nx, ny = math.cos(r), math.sin(r)
        local ex, ey = e[1] + nx * (e[3] + 0.3), e[2] + ny * (e[4] + 0.3)
        -- skip spikes buried in another shape
        local buried = false
        for sj, f in ipairs(o.shapes) do
          if sj ~= si and ((ex + nx * 2 - f[1]) / (f[3] + 0.5)) ^ 2 + ((ey + ny * 2 - f[2]) / (f[4] + 0.5)) ^ 2 <= 1 then buried = true end
        end
        if o.cut and o.cut:has(rnd(ex), rnd(ey)) then buried = true end
        if o.skip and o.skip(ex, ey) then buried = true end
        if not buried then
          local vx, vy = nrm(nx + bx * sweep, ny + by * sweep)
          local len = o.len * (0.75 + 0.5 * hash(j, si, (o.seed or 0) + 3))
          local px, py = -vy, vx
          local hw = o.hw
          local rx0, ry0 = ex - nx * (o.root or 1.5), ey - ny * (o.root or 1.5)
          local tx, ty = ex + vx * len, ey + vy * len
          local m = c:poly{ { rx0 + px * hw, ry0 + py * hw }, { tx, ty }, { rx0 - px * hw, ry0 - py * hw } }
          m:set(rnd(tx - vx * 0.6), rnd(ty - vy * 0.6))
          spikes[#spikes + 1] = { m = m, rx = rx0, ry = ry0, tx = tx, ty = ty, vx = vx, vy = vy, px = px, py = py, nx = nx, ny = ny,
            order = ex * bx + ey * by }
        end
        a = a + o.step
        j = j + 1
      end
    end
  end
  local all = base:copy()
  for _, s in ipairs(spikes) do all:add(s.m) end
  if o.cut then all:cut(o.cut) end
  -- lighting centre
  local x0, y0, x1, y1 = base:bbox()
  local cx, cy = o.cx or (x0 + x1) / 2, o.cy or (y0 + y1) / 2
  local RX, RY = (x1 - x0) / 2 + 1, (y1 - y0) / 2 + 1
  local function lit(x, y) return -((x - cx) / RX * LX * -1 * -1 + 0) end
  local function L(x, y) local u, v = (x - cx) / RX, (y - cy) / RY return u * LX + v * LY end
  -- dark under-coat
  base:each(function(x, y)
    if o.cut and o.cut:has(x, y) then return end
    local l = L(x, y)
    c:put(x, y, l > 0.15 and SP.shade or SP.deep)
  end)
  -- interior strokes (back first, front last), each: shade root, base, hi, tip + shadow pixel
  local pts = {}
  local g = o.gap
  local oy = o.oy or 0
  for gy = floor((y0 - oy) / g) - 1, floor((y1 - oy) / g) + 1 do
    for gx = floor(x0 / g) - 1, floor(x1 / g) + 1 do
      local x = gx * g + (gy % 2) * g * 0.5 + (hash(gx, gy, o.seed) - 0.5) * g * 0.6
      local y = gy * g + (hash(gy, gx, (o.seed or 0) + 1) - 0.5) * g * 0.6 + oy
      if base:has(rnd(x), rnd(y)) and not (o.cut and o.cut:has(rnd(x), rnd(y))) then pts[#pts + 1] = { x, y } end
    end
  end
  table.sort(pts, function(p, q) return p[1] * bx + p[2] * by > q[1] * bx + q[2] * by end)
  local slen = o.slen
  for _, p in ipairs(pts) do
    local nx, ny = nrm(p[1] - cx, (p[2] - cy) * RX / RY)
    local vx, vy = nrm(nx + bx * sweep, ny + by * sweep)
    local l = L(p[1], p[2])
    local lift = l > 0.35 and 1 or (l > -0.25 and 0 or -1)
    local maxi = lift > 0 and 5 or 4
    local n = slen + (hash(p[1], p[2] - oy, 9) > 0.5 and 1 or 0)
    for t = 0, n do
      local x, y = rnd(p[1] + vx * t), rnd(p[2] + vy * t)
      if all:has(x, y) then
        local f = t / n
        local ti = f < 0.3 and 2 or (f < 0.65 and 3 or (f < 0.95 and 4 or 5))
        c:put(x, y, tone(SP, math.min(maxi, ti + lift)))
        -- shadow on the lower-right side of the spine
        local sx, sy = rnd(p[1] + vx * t + 0.7), rnd(p[2] + vy * t + 0.9)
        if (sx ~= x or sy ~= y) and all:has(sx, sy) and t < n then c:put(sx, sy, tone(SP, 1 + (lift > 0 and 1 or 0))) end
      end
    end
  end
  -- outline spikes (back first)
  table.sort(spikes, function(p, q) return p.order > q.order end)
  for _, s in ipairs(spikes) do
    local lf = s.nx * LX + s.ny * LY
    local lift = lf > 0.25 and 1 or (lf > -0.35 and 0 or -1)
    local dl = sqrt((s.tx - s.rx) ^ 2 + (s.ty - s.ry) ^ 2)
    s.m:each(function(x, y)
      if o.cut and o.cut:has(x, y) then return end
      local f = ((x + 0.5 - s.rx) * s.vx + (y + 0.5 - s.ry) * s.vy) / dl
      local side = (x + 0.5 - s.rx) * s.px + (y + 0.5 - s.ry) * s.py
      local ti = f < 0.3 and 2 or (f < 0.62 and 3 or (f < 0.84 and 4 or 5))
      -- the side facing away from the light is one step darker
      local away = side * (s.px * 0.6 + s.py * 0.8) > 0.3
      c:put(x, y, tone(SP, ti + lift - (away and 1 or 0)))
    end)
  end
  return all, spikes
end

-- face mask, snout, nose, eye, ear (head-local units, facing right; dir=-1 mirrors)
function HH.face(c, k, o)
  o = o or {}
  local X, Y, s, FACE, SP = k.X, k.Y, k.s, k.FACE, k.SP
  local function E(lx, ly, rx, ry) return c:ellipse(X(lx), Y(ly), rx * s, ry * s) end
  local function PL(pts) local q = {} for i, p in ipairs(pts) do q[i] = { X(p[1]), Y(p[2]) } end return c:poly(q) end
  local face = E(4.2, 2.8, 7.4, 6.4)
  local snout = PL{ { 6, -2.2 }, { 12, 0.8 }, { 16.3, 3.8 }, { 16.7, 6.0 }, { 12, 7.5 }, { 6, 9.0 } }
  face:add(snout)
  k.faceMask = face
  -- shading: lit upper-left, shade band underside + back cheek
  face:each(function(x, y)
    local hx = (x - X(4.2)) * k.dir / s
    local hy = (y - Y(2.8)) / s
    local col = FACE.base
    if hy > 4.6 - hx * 0.12 or (not face:has(x, y + rnd(1.4 * s))) then col = FACE.shade end
    if hx < -4.5 and hy > -1 then col = FACE.shade end
    c:put(x, y, col)
  end)
  -- underside deep line
  face:each(function(x, y) if not face:has(x, y + 1) then c:put(x, y, FACE.deep) end end)
  -- muzzle bridge highlight
  local hl = c:line({ { X(7.8), Y(0.6) }, { X(13.8), Y(3.2) } }, s > 1.3 and 2 or 1)
  hl:clip(face):each(function(x, y) c:put(x, y, FACE.hi) end)
  c:line({ { X(1), Y(-1.5) }, { X(3.5), Y(-2.6) } }, 1):clip(face):each(function(x, y) c:put(x, y, FACE.hi) end)
  -- mouth
  c:line({ { X(11.4), Y(7.2) }, { X(13.9), Y(6.6) } }, 1):clip(face):each(function(x, y) c:put(x, y, FACE.deep) end)
  if o.mouthO then
    local mx, my = rnd(X(12.4)), rnd(Y(7.2))
    c:put(mx, my, "#6e3442")
    if s > 1.3 then c:put(mx + k.dir, my, "#6e3442") c:put(mx, my + 1, FACE.deep) c:put(mx + k.dir, my + 1, FACE.deep) end
  end
  -- blush
  local bx, by = rnd(X(5.4)), rnd(Y(5.4))
  c:put(bx, by, HH.BLUSH) c:put(bx + k.dir, by, HH.BLUSH)
  if s > 1.3 then c:put(bx, by + 1, HH.BLUSH) c:put(bx + k.dir, by + 1, HH.BLUSH) c:put(bx + 2 * k.dir, by, HH.BLUSH) end
  -- nose: big wet dark bead at the tip
  local nose = E(16.7, 4.8, 2.3, 2.0)
  c:fillMask(nose, HH.NOSE.base)
  nose:each(function(x, y) if not nose:has(x, y + 1) then c:put(x, y, HH.NOSE.sh) end end)
  local nx, ny = rnd(X(16.0)), rnd(Y(3.8))
  c:put(nx, ny, HH.NOSE.hi)
  if s > 1.3 then c:put(nx + k.dir, ny, HH.NOSE.hi) c:put(nx, ny + 1, "#6e5866") end
  -- eye: small black bead with one glint
  local ex, ey = rnd(X(6.6)), rnd(Y(0.7))
  if k.p and k.p.blink then
    for i = -1, 1 do c:put(ex + i, ey + 1, INK) end
    if s > 1.3 then c:put(ex + 2 * k.dir, ey + 1, INK) end
  elseif s > 1.3 then
    for yy = -1, 2 do for xx = -1, 2 do
      if not ((xx == -1 or xx == 2) and (yy == -1 or yy == 2)) then c:put(ex + xx, ey + yy, INK) end
    end end
    c:put(k.dir > 0 and ex or ex + 1, ey, "#f6ead6")
    c:put(k.dir > 0 and ex + 1 or ex, ey + 2, "#5a4458")
  else
    c:put(ex, ey, INK) c:put(ex + 1, ey, INK) c:put(ex, ey + 1, INK) c:put(ex + 1, ey + 1, INK)
    c:put(k.dir > 0 and ex or ex + 1, ey, "#f6ead6")
  end
  return face
end

-- small low round ear at the spine/face boundary
function HH.ear(c, k)
  local X, Y, s, FACE = k.X, k.Y, k.s, k.FACE
  local em = c:ellipse(X(-2.2), Y(0.4), 2.4 * s, 2.3 * s)
  em:each(function(x, y) c:put(x, y, FACE.shade) end)
  local inner = c:ellipse(X(-1.9), Y(0.8), 1.1 * s, 1.1 * s)
  inner:each(function(x, y) c:put(x, y, HH.EAR) end)
  em:each(function(x, y)
    if not em:has(x, y - 1) or not em:has(x - k.dir, y) then c:put(x, y, FACE.base) end
  end)
  em:each(function(x, y)
    if not em:has(x, y + 1) or not em:has(x + k.dir, y) and not k.faceMask:has(x + k.dir, y) then c:put(x, y, FACE.deep) end
  end)
  -- ink rim where the ear meets spines
  em:grow(1):cut(em):each(function(x, y)
    if k.spine:has(x, y) and not k.faceMask:has(x, y) then c:put(x, y, INK) end
  end)
end

-- spine fringe: short spikes from the crown lying down over the brow, pointing forward-down
function HH.fringe(c, k)
  local X, Y, s, SP = k.X, k.Y, k.s, k.SP
  local list = k.fringe or { { -1.0, -3.2, 3.6, 2.4 }, { 1.6, -4.4, 3.4, 1.8 }, { 4.2, -4.6, 3.0, 1.2 }, { 6.6, -4.2, 2.4, 0.9 } }
  for i, f in ipairs(list) do
    local rx, ry = X(f[1]), Y(f[2])
    local tx, ty = X(f[1] + f[3]), Y(f[2] + f[4])
    local vx, vy = nrm(tx - rx, ty - ry)
    local px, py = -vy, vx
    local hw = 1.1 * s
    local m = c:poly{ { rx + px * hw - vx * s, ry + py * hw - vy * s }, { tx, ty }, { rx - px * hw - vx * s, ry - py * hw - vy * s } }
    local dl = sqrt((tx - rx) ^ 2 + (ty - ry) ^ 2) + s
    m:each(function(x, y)
      local f2 = ((x + 0.5 - rx + vx * s) * vx + (y + 0.5 - ry + vy * s) * vy) / dl
      local side = (x + 0.5 - rx) * px + (y + 0.5 - ry) * py
      local ti = f2 < 0.45 and 3 or (f2 < 0.8 and 4 or 5)
      if side * (px * 0.6 + py * 0.8) > 0.4 then ti = ti - 1 end
      c:put(x, y, tone(SP, ti))
    end)
    -- ink edge on the face side (underside of the spine) so it reads over the pale face
    m:each(function(x, y)
      if k.faceMask:has(x, y + 1) and not m:has(x, y + 1) then c:put(x, y + 1, SP.deep) end
    end)
  end
end

local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
HH.under = under

local function ctx(c, o, x, y, s, dir, p)
  local k = { c = c, s = s, dir = dir, hx = x, hy = y, p = p or {}, SP = o.SP or HH.SP, FACE = o.FACE or HH.FACE, o = o }
  for kk, v in pairs(HH.SP) do if not k.SP[kk] then k.SP[kk] = v end end
  k.X = function(lx) return x + dir * lx * s end
  k.Y = function(ly) return y + ly * s end
  return k
end

-- head: spine cap (+ optional extra shapes for the back), face, ear, fringe
local function head(c, k, back)
  local X, Y, s, d = k.X, k.Y, k.s, k.dir
  local function A(a0, a1) if d > 0 then return a0, a1 end return 180 - a1, 180 - a0 end
  local a0, a1 = A(152, 312)
  local shapes = { { X(-2.6), Y(-2.2), 12.6 * s, 11.2 * s, a0, a1 } }
  for _, e in ipairs(back or {}) do shapes[#shapes + 1] = e end
  -- face is cut from the spine area so the mask sits under the fringe
  local fm = c:ellipse(X(4.2), Y(2.8), 7.4 * s, 6.4 * s)
    local sp = HH.spines(c, { SP = k.SP, shapes = shapes, back = { -d, -0.12 }, sweep = 1.0, len = (s > 1.3 and 4.2 or 3.4) * (s > 1.3 and s / 1.6 or 1) * 1.5,
    hw = s > 1.3 and 2.3 or 1.5, step = s > 1.3 and 11 or 15, gap = s > 1.3 and 3.2 or 2.6, slen = s > 1.3 and 4 or 2,
    seed = k.o.seed or 1, root = s > 1.3 and 2 or 1.2, oy = k.b or 0 })
  k.spine = sp
  k.crown = { x = rnd(X(-2.0)), y = rnd(Y(-13.4)) }
  return sp
end

function HH.drawHead(c, k)
  HH.face(c, k, k.o.faceOpts)
  HH.ear(c, k)
  HH.fringe(c, k)
end

---------------------------------------------------------------- portrait 80x100
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, dd in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if c:get(x + dd[1], y + dd[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
HH.backdrop = backdrop

function HH.portrait(o)
  local c = HP.canvas{ w = 80, h = 100, scale = 1, name = o.name }
  local s, d = o.s or 1.75, o.dir or 1
  local hx, hy = o.hx or (d > 0 and 38 or 41), o.hy or 47
  local k = ctx(c, o, hx, hy, s, d, {})
  if o.behind then o.behind(c, k) end
  -- body back mound behind the shoulders (continuous with the head cap)
  local function A(a0, a1) if d > 0 then return a0, a1 end return 180 - a1, 180 - a0 end
  local b0, b1 = A(100, 200)
  local back = { { k.X(-5.5), 83, 17, 20, b0, b1 } }
  k.torso = c:ellipse(k.X(5), 101, 25, 25):clip(c:rect(0, 0, 79, 99))
  head(c, k, back)
  k.spine:clip(c:rect(0, 0, 79, 99))
  -- shoulders + chest (pale fur), clothes on top via o.body
  local fur = k.torso:copy()
  c:fillMask(fur, k.FACE.base)
  if o.body then o.body(c, k) end
  -- re-draw the spines that sit over the shoulder line (spines poke over the collar on the back side)
  if o.spines then o.spines(c, k) end
  HH.drawHead(c, k)
  if o.hat then o.hat(c, k) end
  if o.front then o.front(c, k) end
  c:finish{ outline = true }
  backdrop(c, o.BG or HP.P.sky)
  HP.assertClean(c)
  c:save{ aseprite = o.out .. o.name .. ".aseprite", png = o.out .. o.name .. ".png", scale = 1 }
  print(o.name .. " portrait ok")
  return c
end

---------------------------------------------------------------- sprite 64x96, 4-frame idle
function HH.sprite(o)
  local frames = {}
  for _, p in ipairs(o.frames or { {}, { b = 1 }, {}, { blink = true } }) do
    local c = HP.canvas{ w = 64, h = 96, name = o.name }
    local b = p.b or 0
    local d = o.dir or 1
    local hx, hy = (o.hx or (d > 0 and 26 or 38)), (o.hy or 44) + b
    local k = ctx(c, o, hx, hy, o.s or 1.15, d, p)
    k.b = b
    c:groundShadow(32, 89.5, 15, 2.5)
    if o.behind then o.behind(c, k) end
    -- feet (fixed on the ground)
    for _, fx in ipairs{ -2, 9 } do
      local m = c:ellipse(k.X(fx), 88, 3.2, 1.6)
      m:add(c:ellipse(k.X(fx + 1.5), 88.5, 2.2, 1.2))
      c:part(m, k.FACE, { band = 1, nopop = true, inner = false })
      under(c, m, k.FACE.deep)
    end
    local function A(a0, a1) if d > 0 then return a0, a1 end return 180 - a1, 180 - a0 end
    local b0, b1 = A(92, 215)
    k.b = b
    local back = { { k.X(-6.5), 68 + b, 12.5, 17.5, b0, b1 } }
    head(c, k, back)
    -- belly / torso (pale), clothes on top
    k.torso = c:ellipse(k.X(5.5), 71 + b * 0.5, 10.5, 14.5):clip(c:rect(0, 0, 63, 86))
    c:part(k.torso, k.FACE, { band = 2, nopop = true, inner = false })
    k.paw = { x = rnd(k.X(13)), y = rnd(71.5 + b) }
    k.neck = 57 + b
    if o.body then o.body(c, k) end
    if o.spines then o.spines(c, k) end
    HH.drawHead(c, k)
    if o.hat then o.hat(c, k) end
    -- front arm: stubby, paw forward
    if o.arm ~= false then
      local arm = c:line({ { k.X(6), 64 + b }, { k.X(11), 70 + b } }, 4)
      local sleeve = o.sleeve or k.FACE
      c:part(arm, sleeve, { band = 1, nopop = true, inner = false })
      under(c, arm, sleeve.deep)
    end
    if o.front then o.front(c, k) end
    if o.arm ~= false and o.paw ~= false then
      local pm = c:ellipse(k.X(13), 71.5 + b, 2.2, 2)
      c:part(pm, k.FACE, { band = 1, nopop = true, inner = false })
      under(c, pm, k.FACE.deep)
    end
    if o.top then o.top(c, k) end
    c:finish{ outline = true }
    HP.assertClean(c)
    frames[#frames + 1] = c
  end
  HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = #frames } } }
    :save{ aseprite = o.out .. o.name .. ".aseprite", png = o.out .. o.name .. ".png", scale = 1 }
  print(o.name .. " sprite ok")
end

---------------------------------------------------------------- FRONT VIEW (head-on), added 2026-11-05
-- Symmetric front view for the hedgehog PORTRAITS (sprites stay 3/4 profile). k.hx must be a .5 centre (39.5)
-- so left/right pixels mirror exactly. Callbacks get k.crown (top of the spine arch), k.torso, k.pawL / k.pawR,
-- k.faceMask, k.spine; HH.pawFront(c, k, x, y) draws a front paw.
local function fpoly(c, k, pts)
  local q = {}
  for i, p in ipairs(pts) do q[i] = { k.hx + 0.5 + p[1] * k.s, k.hy + p[2] * k.s } end
  return c:poly(q)
end
function HH.faceMaskFront(c, k)
  local cx, cy, s = k.hx, k.hy, k.s
  local function E(x, y, rx, ry) return c:ellipse(cx + x * s, cy + y * s, rx * s, ry * s) end
  local f = E(0, 1.5, 13, 10.5)
  f:add(fpoly(c, k, { { -8, 5 }, { 8, 5 }, { 4.5, 13 }, { -4.5, 13 } }))
  f:add(E(0, 13.6, 5, 3.2))
  -- widow's peak: the spine crown dips into the brow
  f:cut(fpoly(c, k, { { -6.5, -10.5 }, { 6.5, -10.5 }, { 0, -3.5 } }))
  return f
end

-- spine crown as a jagged arch over the top and both sides of the face (+ optional extra shapes)
function HH.headFront(c, k, extra)
  local cx, cy, s = k.hx, k.hy, k.s
  local face = HH.faceMaskFront(c, k)
  k.faceMask = face
  local shapes = { { cx, cy - 3 * s, 24 * s, 21 * s, 140, 400 } }
  for _, e in ipairs(extra or {}) do shapes[#shapes + 1] = e end
  local sp = HH.spines(c, { SP = k.SP, shapes = shapes, back = { 0, -1 }, sweep = 0.3, len = 6.5 * s, hw = 2.3 * s,
    step = 10, gap = 3.2 * s, slen = 4, seed = k.o.seed or 1, root = 2 * s, cut = face, cx = cx, cy = cy + 2 * s })
  k.spine = sp
  k.crown = { x = rnd(cx), y = rnd(cy - 24 * s) }
  return sp
end

function HH.faceFront(c, k, o)
  o = o or {}
  local cx, cy, s, FACE, SP = k.hx, k.hy, k.s, k.FACE, k.SP
  local face = k.faceMask
  local W = rnd(2 * cx) -- mirror: right pixel = W - left pixel
  local function pair(lx, y, hex) c:put(lx, y, hex) c:put(W - lx, y, hex) end
  local function Y(ly) return rnd(cy + ly * s) end
  local function LX(dx) return floor(cx - dx * s) end
  -- base shading: light from the upper left, shade band on the right + underside, brow shadow under the spines
  face:each(function(x, y)
    local u, v = (x - cx) / (13 * s), (y - cy - 1.5 * s) / (11 * s)
    local l = -0.6 * u - 0.8 * v
    local col = FACE.base
    if not face:has(x + 2, y) and u > 0 then col = FACE.shade end
    if u > 0.55 and v > -0.3 then col = FACE.shade end
    if v > 0.25 and not face:has(x, y + 2) then col = FACE.shade end
    if l > 0.5 and face:has(x - 1, y) and face:has(x, y - 1) and face:has(x, y - 2) then col = FACE.hi end
    if not face:has(x, y - 1) then col = FACE.shade end
    c:put(x, y, col)
  end)
  face:each(function(x, y) if not face:has(x, y + 1) then c:put(x, y, FACE.deep) end end)
  -- muzzle: folds down both sides of the short snout, highlight down the bridge (lit side)
  for _, q in ipairs{ { 7.0, 5 }, { 6.5, 6 }, { 6.0, 7 }, { 5.5, 8 }, { 5.0, 9 }, { 4.6, 10 } } do
    local lx, y = LX(q[1]), Y(q[2])
    c:put(lx, y, FACE.shade) c:put(W - lx, y, FACE.deep)
  end
  for ly = 3, 8 do c:put(LX(1.5), Y(ly), FACE.hi) end
  c:put(LX(2.5), Y(4), FACE.hi)
  -- right side of the snout a tone down
  for ly = 5, 10 do for dx = 1, 3 do local x = W - LX(dx) if face:has(x, Y(ly)) and c:get(x, Y(ly)) == FACE.base:lower() then c:put(x, Y(ly), FACE.shade) end end end
  -- blush
  for _, d in ipairs{ 8, 9 } do pair(LX(d), Y(5), HH.BLUSH) end
  pair(LX(9), Y(6), HH.BLUSH)
  -- eyes: small dark beads, 2x3, glint upper-left
  if k.p and k.p.blink then
    for _, d in ipairs{ 5, 6, 7 } do pair(LX(d), Y(1), INK) end
  else
    for ly = -1, 1 do for _, d in ipairs{ 5.5, 6.5 } do pair(LX(d), Y(ly), INK) end end
    c:put(LX(6.5), Y(-1), "#f6ead6") c:put(W - LX(6.5), Y(-1), "#f6ead6")
    c:put(LX(5.5), Y(1), "#5a4458") c:put(W - LX(5.5), Y(1), "#5a4458")
    -- soft dark patch under each eye
    for _, d in ipairs{ 5.5, 6.5 } do pair(LX(d), Y(2), FACE.shade) end
  end
  -- nose: big wet dark bead at the centre of the snout tip
  local nose = c:ellipse(cx, cy + 11.4 * s, 3.6 * s, 2.5 * s)
  c:fillMask(nose, HH.NOSE.base)
  nose:each(function(x, y) if not nose:has(x, y + 1) then c:put(x, y, HH.NOSE.sh) end end)
  pair(LX(1.5), Y(12), HH.NOSE.sh)
  c:put(LX(2.5), Y(10), HH.NOSE.hi) c:put(LX(1.5), Y(10), HH.NOSE.hi) c:put(LX(2.5), Y(11), "#6e5866")
  -- mouth: small smile under the nose
  local my = Y(15.2)
  pair(LX(1.5), my, FACE.deep) pair(LX(0.5), my + 1, FACE.deep)
  if o.mouthO then pair(LX(0.5), my + 1, "#6e3442") pair(LX(0.5), my + 2, FACE.deep) end
  -- ears: small round, low on both sides, tucked under the spines
  for side = -1, 1, 2 do
    local ex, ey = cx + side * 12.8 * s, cy - 2.2 * s
    local em = c:ellipse(ex, ey, 2.6 * s, 2.5 * s)
    em:each(function(x, y) c:put(x, y, side < 0 and FACE.base or FACE.shade) end)
    c:fillMask(c:ellipse(ex + side * 0.3 * s, ey + 0.4 * s, 1.1 * s, 1.1 * s), HH.EAR)
    em:each(function(x, y) if not em:has(x, y + 1) or not em:has(x + side, y) and not face:has(x + side, y) then c:put(x, y, FACE.deep) end end)
    em:grow(1):cut(em):each(function(x, y) if not face:has(x, y) then c:put(x, y, INK) end end)
  end
  -- fringe: short spines lying down over the brow, mirrored pairs
  for _, f in ipairs{ { 5.3, -10.5, 4.6, -6.0 }, { 9.0, -9.5, 8.3, -5.2 }, { 1.8, -9.0, 1.2, -4.0 } } do
    for side = -1, 1, 2 do
      local rx, ry = cx + side * f[1] * s, cy + f[2] * s
      local tx, ty = cx + side * f[3] * s, cy + f[4] * s
      local vx, vy = nrm(tx - rx, ty - ry)
      local px, py = -vy, vx
      local hw = 1.3 * s
      local m = c:poly{ { rx + px * hw, ry + py * hw }, { tx, ty }, { rx - px * hw, ry - py * hw } }
      local dl = sqrt((tx - rx) ^ 2 + (ty - ry) ^ 2)
      m:each(function(x, y)
        local f2 = ((x + 0.5 - rx) * vx + (y + 0.5 - ry) * vy) / dl
        local ti = f2 < 0.45 and 3 or (f2 < 0.8 and 4 or 5)
        if side > 0 then ti = ti - 1 end
        c:put(x, y, tone(SP, ti))
      end)
      m:each(function(x, y) if face:has(x, y + 1) and not m:has(x, y + 1) then c:put(x, y + 1, FACE.shade) end end)
    end
  end
  return face
end

function HH.pawFront(c, k, x, y, rx, ry)
  local m = c:ellipse(x, y, rx or 3.5, ry or 3)
  c:part(m, k.FACE, { band = 1, nopop = true, inner = false })
  HH.under(c, m, k.FACE.deep)
  local by = select(4, m:bbox())
  c:put(x - 1, by - 1, k.FACE.shade) c:put(x + 1, by - 1, k.FACE.shade)
  return m
end

function HH.portraitFront(o)
  local c = HP.canvas{ w = 80, h = 100, scale = 1, name = o.name }
  local hy = o.hy or 46
  local k = ctx(c, o, 39.5, hy, o.s or 1, 1, {})
  k.frontView = true
  if o.behind then o.behind(c, k) end
  -- spines continue down behind both shoulders
  local flank = { { 18, 86, 10, 18, 150, 215 }, { 61, 86, 10, 18, -35, 30 } }
  HH.headFront(c, k, flank)
  k.spine:clip(c:rect(0, 0, 79, 99))
  k.torso = c:ellipse(39.5, 102, 25, 30):add(c:ellipse(39.5, hy + 22, 9, 7)):clip(c:rect(0, 0, 79, 99))
  c:fillMask(k.torso, k.FACE.base)
  k.pawL, k.pawR = { x = 29, y = 89 }, { x = 50, y = 89 }
  if o.body then o.body(c, k) end
  if o.spines then o.spines(c, k) end
  HH.faceFront(c, k, o.faceOpts)
  if o.hat then o.hat(c, k) end
  if o.front then o.front(c, k) end
  c:finish{ outline = true }
  backdrop(c, o.BG or HP.P.sky)
  HP.assertClean(c)
  c:save{ aseprite = o.out .. o.name .. ".aseprite", png = o.out .. o.name .. ".png", scale = 1 }
  print(o.name .. " portrait ok")
  return c
end

return HH
