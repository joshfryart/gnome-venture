local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local floor = math.floor
local c
local function px(x, y, hex) c:px(x, y, hex) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local DUSKSH = "#5a4660"
local INTERIOR = "#3b2c48"
local LEAFD = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1f3f3a" }
local HEAP = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }
local ROOF = { hi = P.ember.hi, base = P.ember.base, shade = P.ember.shade, deep = P.ember.deep }
local BOARD = "#f3dca6"
local function rampOf(r) if type(r) == "string" then return P[r] end return r end
local function step(x, y, r, dir)
  r = rampOf(r)
  local v = c:get(x, y); if not v then return end
  local T = { r.hi, r.base, r.shade, r.deep }
  for i = 1, 4 do
    if v == T[i] then
      local n
      if dir > 0 then n = (i == 3) and lerp(r.shade, r.deep, .45) or (i == 4) and nil or T[i + 1]
      else n = (i == 1) and lerp(r.hi, P.cream, .5) or (i == 4) and r.shade or T[i - 1] end
      if n then px(x, y, n) end
      return
    end
  end
end
local function dk(x, y, r) step(x, y, r, 1) end
local function lt(x, y, r) step(x, y, r, -1) end
local function shadeUnder(m, t) m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, t)) end end) end
local function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end
local function rise(i) return (i + 1) // 2 end
local function sideWall(x1, yt, yb, d, extra)
  local m = HP.mask()
  for i = 1, d do local s = rise(i); for yy = yt - s - (extra or 0), yb - s do m:set(x1 + i, yy) end end
  return m
end
local LX, LY, LZ = -0.55, -0.62, 0.56
local function ball(m, cx, cy, rx, ry, T, o)
  o = o or {}
  local t1, t2, t3 = o.t1 or .62, o.t2 or .2, o.t3 or -.18
  m:each(function(x, y)
    local u, v = (x + .5 - cx - .5) / (rx + .5), (y + .5 - cy - .5) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > t1 and T.hi) or (l > t2 and T.base) or (l > t3 and T.shade) or T.deep)
  end)
  if not o.norefl then
    m:each(function(x, y) if (not m:has(x + 1, y) or not m:has(x, y + 1)) and c:get(x, y) == T.deep and (x - cx) + (y - cy) * (rx / math.max(ry, 1)) > rx * .5 then px(x, y, T.shade) end end)
  end
  if not o.nospec then local sx, sy = floor(cx - rx * .42 + .5), floor(cy - ry * .5 + .5); if m:has(sx, sy) then px(sx, sy, o.spec or P.cream) end end
end
local function cyl(m, cx, rx, T, o)
  o = o or {}
  m:each(function(x, y)
    local u = (x + .5 - cx - .5) / (rx + .5)
    local l = -0.72 * u + 0.69 * math.sqrt(math.max(0, 1 - u * u))
    px(x, y, (l > (o.t1 or .78) and T.hi) or (l > (o.t2 or .35) and T.base) or (l > (o.t3 or -.15) and T.shade) or T.deep)
  end)
  if not o.norefl then m:each(function(x, y) if not m:has(x + 1, y) and c:get(x, y) == T.deep then px(x, y, T.shade) end end) end
end
local function leaves(m, r, x0, x1, y0, y1, sx, sy)
  local inner = m:shrink(1)
  for gy = y0, y1, sy do
    local row = (gy - y0) // sy
    for gx = x0 + (row % 2) * (sx // 2), x1, sx do
      if inner:has(gx, gy) and inner:has(gx + 2, gy + 1) then
        lt(gx, gy, r) lt(gx + 1, gy, r) dk(gx + 1, gy + 1, r) dk(gx + 2, gy + 1, r)
      end
    end
  end
end
-- 3x5 font
local GL = {
  B = { "110", "101", "110", "101", "110" }, U = { "101", "101", "101", "101", "111" },
  I = { "111", "010", "010", "010", "111" }, L = { "100", "100", "100", "100", "111" },
  D = { "110", "101", "101", "101", "110" },
}
local function word(x, y, hex)  -- BUILD, 19 px wide, top-left (x,y)
  local ox = x
  for ch in ("BUILD"):gmatch(".") do
    for r, row in ipairs(GL[ch]) do for k = 1, 3 do if row:sub(k, k) == "1" then px(ox + k - 1, y + r - 1, hex or P.ink) end end end
    ox = ox + 4
  end
end
local function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  c:rim(HP.mask():add(head):add(stem), P.ink)
  c:fillMask(stem, P.moss.base); c:fillMask(head, col or P.petal.base); px(x, y, P.gold.hi)
end
local function stone(x, y, w, h)
  local m = c:rrect(x, y, x + w - 1, y + h - 1, 1)
  ink(m); c:part(m, "stone", { band = 1, nopop = true }); px(x, y, P.stone.hi)
end
local function stake(x, y0, y1) local m = c:rect(x, y0, x, y1); ink(m); c:part(m, "wood", { band = 1, nopop = true }); px(x, y0, P.wood.hi) end
local function line(x0, y0, x1, y1, hex) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), hex) end
local function badge(cx, cy)
  local disc = E(cx, cy, 4, 4)
  ink(disc)
  c:part(disc, "gold", { band = 2, pop = { x = cx - 2, y = cy - 2, horizontal = true } })
  R(cx, cy - 3, cx, cy, P.ink); R(cx, cy + 2, cx, cy + 2, P.ink)
  px(cx - 3, cy - 2, P.cream)
end
local BOB = { 0, -1, 0, 1 }
local out = app.params.out
local function save(canvas, name)
  HP.assertClean(canvas)
  canvas:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local function saveStrip(frames, W, H, name, tag)
  for _, f in ipairs(frames) do HP.assertClean(f) end
  HP.sheet{ cellw = W, cellh = H, frames = frames, tags = { { name = tag, from = 1, to = #frames } } }
    :save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local W, H = 72, 56
local X, Y = 36, 46
local function newc() c = HP.canvas{ w = W, h = H, scale = 1, name = "root_cellar" } return c end
local function shadow(rx) c:groundShadow(X + 4, 47, rx, 2) end
local TEAL = P.moss.deep
local function lantern(x, y, lit)   -- top-left of the 5x6 lantern (cap row at y)
  local cap = c:rect(x + 1, y, x + 3, y)
  local body = c:rect(x, y + 1, x + 4, y + 5)
  local hook = c:rect(x + 2, y - 2, x + 2, y - 1)
  c:rim(HP.mask():add(cap):add(body):add(hook), P.ink)
  c:fillMask(hook, P.stone.shade)
  c:fillMask(body, lit and P.gold.base or P.sky.shade)
  R(x + 1, y + 2, x + 3, y + 4, lit and P.gold.hi or P.sky.hi)
  px(x + 2, y + 3, P.cream)
  R(x, y + 1, x, y + 5, P.wood.deep); R(x + 4, y + 1, x + 4, y + 5, P.wood.deep)
  R(x, y + 5, x + 4, y + 5, P.wood.deep)
  c:fillMask(cap, P.wood.base); px(x + 1, y, P.wood.hi)
end

local function crate(x0, y0, x1, y1)
  local m = c:rect(x0, y0, x1, y1)
  c:rim(m, P.ink)
  c:fillMask(m, P.wood.base)
  R(x0, y0, x1, y0, P.wood.hi)
  R(x1, y0 + 1, x1, y1, P.wood.shade); R(x0 + 1, y1, x1, y1, P.wood.shade)
  -- slats and cross brace
  R(x0 + 1, y0 + 1, x1 - 1, y0 + 1, P.wood.shade)
  local n = y1 - y0 - 2
  line(x0 + 1, y0 + 2, x1 - 1, y1 - 1, P.wood.deep)
  px(x0 + 1, y0 + 2, P.wood.deep)
end

local function turnip(x, y)   -- leafy top poking out of a crate, (x,y) = bulb centre-top
  local m = HP.mask():set(x, y):set(x + 1, y):set(x, y + 1):set(x + 1, y + 1)
  local lf = HP.mask():set(x, y - 1):set(x + 1, y - 2):set(x - 1, y - 2):set(x + 2, y - 1)
  c:rim(HP.mask():add(m):add(lf), P.ink)
  c:fillMask(lf, P.moss.base); px(x + 1, y - 2, P.moss.hi)
  c:fillMask(m, P.cream); px(x + 1, y + 1, P.petal.base); px(x, y + 1, P.petal.hi)
end

-- the grassy mound with the stone arch (scene look, drawn bigger)
local function mound(rx, ry)
  local m = E(X, Y - 3, rx, ry):clip(c:rect(0, 0, W, Y))
  c:rim(m, P.ink)
  ball(m, X, Y - 3, rx, ry, LEAFD, { nospec = true, t1 = .55 })
  leaves(m, LEAFD, X - rx + 2, X + rx - 2, Y - ry - 2, Y - 2, 6, 3)
  return m
end

-- openw: nil = closed door; else width in px of the swung-open leaf (hinge on the left)
local function portal(mnd, openw, shoot, k)
  local arch = c:rrect(X - 8, Y - 14, X + 8, Y, 4)
  local rev = sideWall(X + 8, Y - 12, Y, 3)
  c:rim(arch:copy():add(rev), P.ink, mnd:copy():grow(1))
  c:fillMask(arch, P.stone.base); c:fillMask(rev, P.stone.shade)
  arch:each(function(xx, yy) if not arch:has(xx - 1, yy) or not arch:has(xx, yy - 1) then px(xx, yy, P.stone.hi) end end)
  for _, xx in ipairs{ X - 6, X - 2, X + 2, X + 6 } do px(xx, Y - 14, P.stone.shade) px(xx, Y - 13, P.stone.shade) end
  for _, yy in ipairs{ Y - 9, Y - 5 } do
    for _, xx in ipairs{ X - 8, X - 7, X + 7, X + 8 } do px(xx, yy, P.stone.shade) end
  end
  px(X + 9, Y - 6, P.stone.deep); px(X + 10, Y - 9, P.stone.deep)
  local dr = c:rrect(X - 6, Y - 12, X + 6, Y, 3)
  if not openw then
    c:fillMask(dr, P.wood.base)
    for _, xx in ipairs{ X - 4, X - 2, X, X + 2, X + 4 } do dr:each(function(a, b) if a == xx then px(a, b, P.wood.shade) end end) end
    dr:each(function(a, b) if not dr:has(a, b - 1) or not dr:has(a - 1, b) then px(a, b, P.wood.deep) end end)
    R(X - 5, Y - 6, X + 5, Y - 6, P.stone.deep); px(X - 5, Y - 6, P.stone.shade)
    R(X - 5, Y - 9, X + 5, Y - 9, P.stone.deep)
    px(X + 4, Y - 4, P.gold.hi)
  else
    c:fillMask(dr, INTERIOR)
    -- warm glow spilling from inside, right of the swung leaf
    local gx = X - 6 + openw
    local glow = E(X + 2, Y - 5, 5, 7):clip(dr):cut(c:rect(X - 7, Y - 14, gx - 1, Y))
    c:fillMask(glow, P.gold.shade)
    c:fillMask(E(X + 2, Y - 5, 4, 6):clip(dr):cut(c:rect(X - 7, Y - 14, gx - 1, Y)), P.gold.base)
    c:fillMask(E(X + 2, Y - 5, 2, 4):clip(dr):cut(c:rect(X - 7, Y - 14, gx - 1, Y)), P.gold.hi)
    -- the green shoot
    local sx = X + 3
    local h = shoot
    R(sx, Y - 1 - h, sx, Y - 1, P.moss.base)
    c:fillMask(c:rect(sx + 1, Y - 1 - h, sx + 1, Y - 1), P.moss.shade)
    local lf1 = HP.mask():set(sx - 1, Y - h):set(sx - 2, Y - h - 1):set(sx - 1, Y - h - 1)
    local lf2 = HP.mask():set(sx + 1, Y - h - 2):set(sx + 2, Y - h - 3):set(sx + 1, Y - h - 3)
    c:fillMask(lf1, P.moss.deep); c:fillMask(lf2, P.moss.deep); px(sx-1,Y-h-1,P.moss.shade); px(sx+1,Y-h-3,P.moss.shade)
    c:fillMask(lf1, P.moss.hi); c:fillMask(lf2, P.moss.hi)
    px(sx, Y - 2 - h, P.moss.hi); px(sx - 1, Y - h, P.moss.base)
    -- the leaf of the door swung open, seen edge-on, hinge on the left
    local leaf = c:rrect(X - 6, Y - 12, X - 6 + openw - 1, Y, 3):clip(dr)
    c:fillMask(leaf, P.wood.base)
    leaf:each(function(a, b) if (a - (X - 6)) % 2 == 0 and a < X - 6 + openw - 1 then px(a, b, P.wood.shade) end end)
    leaf:each(function(a, b) if not leaf:has(a, b - 1) or a == X - 6 then px(a, b, P.wood.deep) end end)
    R(X - 6 + openw - 1, Y - 11, X - 6 + openw - 1, Y - 1, P.wood.hi)
    R(X - 6, Y - 6, X - 6 + openw - 2, Y - 6, P.stone.deep)
    -- light on the step
    R(X + 1, Y, X + 6, Y, P.gold.hi)
  end
  if not openw then
    R(X - 8, Y, X + 8, Y, P.stone.shade); R(X - 7, Y, X + 7, Y, P.stone.hi)
  else
    R(X - 8, Y, X, Y, P.stone.shade); R(X - 7, Y, X - 1, Y, P.stone.hi)
    R(X + 7, Y, X + 8, Y, P.stone.shade); px(X + 7, Y, P.stone.hi)
  end
end

local function hatch()
  local pts = { { X + 11, Y - 12 }, { X + 17, Y - 10 }, { X + 17, Y - 6 }, { X + 11, Y - 8 } }
  local m = c:poly(pts)
  c:rim(m, P.ink)
  c:fillMask(m, P.wood.base)
  m:each(function(x, y) if (x - X - 11) % 3 == 2 then px(x, y, P.wood.shade) end end)
  m:each(function(x, y) if not m:has(x, y - 1) then px(x, y, P.wood.hi) elseif not m:has(x, y + 1) then px(x, y, P.wood.deep) end end)
  px(X + 13, Y - 10, P.stone.base); px(X + 14, Y - 10, P.stone.hi)
  px(X + 15, Y - 8, P.gold.hi)
  R(X + 11, Y - 8, X + 17, Y - 5, LEAFD.deep)
end

local function flick(x, y, k)   -- lantern flicker on top of a lit lantern
  if k % 2 == 0 then
    R(x + 1, y + 2, x + 3, y + 4, P.gold.base); px(x + 2, y + 3, P.gold.hi)
  else
    px(x - 1, y + 3, P.gold.hi); px(x + 5, y + 3, P.gold.hi)
  end
end
local OPEN = { 9, 6, 4, 6 }
local SHOOT = { 4, 6, 9, 6 }
local function spark(sx, sy)
  for _, d in ipairs{ {0,-3},{0,3},{-3,0},{3,0} } do px(sx + d[1], sy + d[2], P.gold.shade) end
  for _, d in ipairs{ {0,-2},{0,2},{-2,0},{2,0},{0,-1},{0,1},{-1,0},{1,0} } do px(sx + d[1], sy + d[2], P.gold.base) end
  px(sx, sy, P.cream); px(sx + 5, sy - 4, P.gold.base); px(sx + 5, sy - 5, P.gold.hi)
end
local function mote(k) px(X + 12 + k, Y - 14 - (k % 2), P.gold.hi) end

local function level2(k)
  newc()
  shadow(23)
  local m = mound(20, 15)
  portal(m, OPEN[k], SHOOT[k])
  hatch()
  crate(X - 23, Y - 8, X - 16, Y)
  crate(X - 21, Y - 13, X - 17, Y - 9)
  lantern(X - 21, Y - 19, true)
  if k then flick(X - 21, Y - 19, k) end
  crate(X + 12, Y - 5, X + 17, Y)
  local g = HP.mask():set(X + 13, Y - 6):set(X + 14, Y - 7):set(X + 15, Y - 6):set(X + 16, Y - 7)
  c:rim(g, P.ink); c:fillMask(g, P.moss.base); px(X + 14, Y - 7, P.moss.hi)
  return c
end
local SP2 = { { 56, 21 }, { 10, 40 }, { 58, 30 }, { 11, 14 } }
local function ready2(k)
  level2(k)
  -- hatch leaf rattles: lit gap flashes
  if k % 2 == 1 then R(X + 11, Y - 8, X + 17, Y - 8, P.gold.hi) end
  local p = SP2[k]; spark(p[1], p[2]); mote(k)
  badge(67, 6 + BOB[k])
  return c
end

local function level3(k)
  newc()
  shadow(26)
  local rxm, rym = 23, 17
  local m = mound(rxm, rym)
  portal(m, OPEN[k], SHOOT[k])
  local function slab(x0, x1, y0, y1)
    local s = c:rect(x0, y0, x1, y1)
    c:rim(s, P.ink)
    c:fillMask(s, P.stone.base); R(x0, y0, x1, y0, P.stone.hi); R(x0, y1, x1, y1, P.stone.shade)
    for xx = x0 + 3, x1 - 1, 5 do px(xx, y1, P.stone.deep) end
  end
  slab(X - 10, X + 10, Y - 1, Y)
  slab(X - 8, X + 8, Y - 3, Y - 2)
  local lw = c:rect(X - 13, Y - 7, X - 11, Y); local rw = c:rect(X + 11, Y - 7, X + 13, Y)
  for _, w in ipairs{ lw, rw } do c:rim(w, P.ink); c:fillMask(w, P.stone.base) end
  for _, w in ipairs{ lw, rw } do
    local x0, y0, x1, y1 = w:bbox()
    R(x0, y0, x1, y0, P.stone.hi); R(x1, y0 + 1, x1, y1, P.stone.shade); R(x0, y1, x1, y1, P.stone.shade)
    px(x0, y0 + 3, P.stone.shade); px(x0 + 1, y0 + 5, P.stone.shade)
  end
  crate(X - 24, Y - 8, X - 17, Y)
  crate(X - 22, Y - 13, X - 18, Y - 9)
  turnip(X - 22, Y - 14)
  local pts = { { X + 15, Y - 12 }, { X + 21, Y - 10 }, { X + 21, Y - 6 }, { X + 15, Y - 8 } }
  local hm = c:poly(pts)
  c:rim(hm, P.ink); c:fillMask(hm, P.wood.base)
  hm:each(function(x, y) if (x - X - 15) % 3 == 2 then px(x, y, P.wood.shade) end end)
  hm:each(function(x, y) if not hm:has(x, y - 1) then px(x, y, P.wood.hi) elseif not hm:has(x, y + 1) then px(x, y, P.wood.deep) end end)
  px(X + 17, Y - 10, P.stone.base); px(X + 19, Y - 8, P.gold.hi)
  local sl = c:rect(X - 14, Y - 17, X - 14, Y - 7)
  local sr = c:rect(X + 14, Y - 17, X + 14, Y - 7)
  local al = c:rect(X - 14, Y - 18, X - 11, Y - 18)
  local ar = c:rect(X + 11, Y - 18, X + 14, Y - 18)
  ink(sl, al); ink(sr, ar)
  c:part(sl, "wood", { band = 1, nopop = true }); c:part(sr, "wood", { band = 1, nopop = true })
  c:fillMask(al, P.wood.base); c:fillMask(ar, P.wood.base)
  lantern(X - 13, Y - 15, true); lantern(X + 10, Y - 15, true)
  flick(X - 13, Y - 15, k); flick(X + 10, Y - 15, k + 1)
  local function top(dx) return floor(Y - 3 - rym * math.sqrt(math.max(0, 1 - (dx / rxm) ^ 2)) + .5) end
  local cols = { P.petal.base, P.gold.base, P.sky.hi, P.cream, P.petal.base, P.gold.base, P.sky.hi }
  local spots = { -17, -11, -5, 1, 7, 13, 18 }
  for i, dx in ipairs(spots) do
    local ty = top(dx)
    local lift = ((i % 2 == 0) and 4 or 2) - (((i + k) % 2 == 0) and 0 or 1)
    flower(X + dx, ty - lift + 1, cols[i])
  end
  for _, dx in ipairs{ -14, -8, -2, 4, 10, 16 } do
    local ty = top(dx)
    c:fillMask(c:rect(X + dx, ty, X + dx, ty + 1), P.moss.base); px(X + dx, ty - 1, P.moss.hi)
    px(X + dx + 1, ty, P.moss.base)
  end
  return c
end
local SP3 = { { 62, 17 }, { 8, 20 }, { 65, 30 }, { 7, 32 } }
local function ready3(k)
  level3(k)
  local p = SP3[k]; spark(p[1], p[2]); mote(k)
  badge(67, 6 + BOB[k])
  return c
end
local f2, f3 = {}, {}
for k = 1, 4 do f2[k] = ready2(k) end
saveStrip(f2, W, H, "root_cellar-ready-l2", "ready")
for k = 1, 4 do f3[k] = ready3(k) end
saveStrip(f3, W, H, "root_cellar-ready-l3", "ready")
