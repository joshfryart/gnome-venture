local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local floor, sqrt, sin = math.floor, math.sqrt, math.sin
local out = app.params.out or "./"
local c
local CW, CH = 56, 56
local function newc() c = HP.canvas{ w = CW, h = CH, scale = 1, name = "state" } return c end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local px = function(x, y, hex) c:px(x, y, hex) end
local DUSKSH = "#5a4660"
local WIN = { hi = P.sky.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }
local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local function hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end
local function shadeUnder(m, t) m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, t)) end end) end
local CURSNAP   -- snapshot taken right after a building's cast shadow, so tap boxes ignore the shadow
local CURSNAP; local function snapshot() return nil end
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
local dk = function(x, y, r) step(x, y, r, 1) end
local lt = function(x, y, r) step(x, y, r, -1) end
local function dkrow(x0, x1, y, r) for x = x0, x1 do dk(x, y, r) end end
local function ltrow(x0, x1, y, r) for x = x0, x1 do lt(x, y, r) end end
local function courses(m, r, x0, x1, y0, y1, h, w, opt)
  opt = opt or {}
  for y = y0, y1 do
    local row = (y - y0) % h
    local course = (y - y0) // h
    for x = x0, x1 do
      if m:has(x, y) and m:has(x, y - 1) and m:has(x - 1, y) and m:has(x + 1, y) then
        local tx = (x - x0 + (course % 2) * (w // 2))
        if row == h - 1 then dk(x, y, r)
        elseif tx % w == 0 then if not opt.nojoint then dk(x, y, r) end
        else
          local t = hsh(tx // w + 3, course + (opt.seed or 0))
          if t < (opt.light or 12) then lt(x, y, r) elseif t > 100 - (opt.dark or 8) then dk(x, y, r) end
        end
      end
    end
  end
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
local SHEDR = { hi = P.sea.base, base = P.sea.shade, shade = P.sea.deep, deep = "#22305a" }
local SLATE = { hi = P.stone.base, base = P.stone.shade, shade = P.stone.deep, deep = "#2e2f48" }
local HEAP = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }
local STRAW = { hi = "#fff0c0", base = "#f0d58c", shade = "#d9b46a", deep = P.gold.shade }
local THATCH = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local INTERIOR = "#3b2c48"   -- dark room seen through a window or open door (cool, never black)

------------------------------------------------------------ VOLUME KIT (patch4)
-- The view is 3/4: front wall lit, right side wall receding up-right at 2:1 in cool shade, roof seen from above.
-- side(x1, yt, yb, d): the right side wall, column i rises (i+1)//2 rows.
local function rise(i) return (i + 1) // 2 end
local function sideWall(x1, yt, yb, d, extra)
  local m = HP.mask()
  for i = 1, d do local s = rise(i); for yy = yt - s - (extra or 0), yb - s do m:set(x1 + i, yy) end end
  return m
end
-- top(x0, x1, yt, d): the lid/top plane of a box, a parallelogram behind the front top edge.
local function topPlane(x0, x1, yt, d)
  local m = HP.mask()
  for i = 0, d do local s = rise(i); for yy = yt - s, yt - 1 do end end
  for j = 1, rise(d) do for xx = x0 + 2 * j - 1, x1 + math.min(d, 2 * j) do m:set(xx, yt - j) end end
  return m
end
-- hip roof: a big lit front slope (eave row ye, ridge row yr, overhang ov, ridge inset a) and the right hip plane in shade.
local function hipRoof(x0, x1, ye, yr, ov, a, d, ah)
  local rr, hd = rise(d), d // 2
  local EL, ER, BR = { x0 - ov, ye + 1 }, { x1 + ov + 1, ye + 1 }, { x1 + ov + d + 1, ye + 1 - rr }
  local RL, RR = { x0 - ov + a + hd, yr }, { x1 + ov + 1 - (ah or a + 3) + hd, yr }
  local F = c:poly{ EL, RL, RR, ER }
  local S = c:poly{ ER, RR, BR }:cut(F)
  return F, S
end
-- hard pixels, one ramp: front base, side cool (hue shifted toward violet), eave shadow tone
local function wallTones(base, lit)
  return { base = base, lite = lerp(base, lit or P.cream, .4), dark = lerp(base, DUSKSH, .12),
    eave = lerp(base, DUSKSH, .3), sbase = lerp(base, DUSKSH, .36), slite = lerp(base, DUSKSH, .27), sdark = lerp(base, DUSKSH, .47) }
end
-- stucco mottling: sparse 1-2 px specks one half-step lighter or darker, on wall pixels only
local function mottle(m, base, lite, dark, seed, dens)
  m:each(function(x, y)
    if c:get(x, y) == base then
      local h = hsh(x * 3 + seed, y * 5 + seed)
      if h < dens then px(x, y, lite) if c:get(x + 1, y) == base and h < dens // 2 then px(x + 1, y, lite) end
      elseif h > 99 - dens then px(x, y, dark) end
    end
  end)
end
local function paintWalls(front, side, W, seed)
  c:fillMask(front, W.base) c:fillMask(side, W.sbase)
  mottle(front, W.base, W.lite, W.dark, seed or 1, 7)
  mottle(side, W.sbase, W.slite, W.sdark, (seed or 1) + 9, 9)
end
-- the eave throws a 1-2 px shadow line on the wall under it (front and side)
local function eaveShadow(x0, x1, yt, d, W, rows)
  for r = 0, (rows or 1) - 1 do R(x0, yt + r, x1, yt + r, W.eave) end
  for i = 1, d do local s = rise(i); for r = 0, (rows or 1) do px(x1 + i, yt - s + r, W.sdark) end end
end
-- warm rim light on the upper-left edges of a mask (pixels whose left or top neighbour is outside)
local function rimLight(m, hex, only)
  m:each(function(x, y) if (not m:has(x - 1, y) or not m:has(x, y - 1)) and (not only or c:get(x, y) == only) then px(x, y, hex) end end)
end
-- roof: front slope base with tile courses, ridge cap and left hip edge lit, eave fascia dark; hip plane in shade
local function paintRoof(F, S, Rr, o)
  o = o or {}
  c:fillMask(F, Rr.base) c:fillMask(S, Rr.shade)
  local x0, y0, x1, y1 = F:bbox()
  if o.tex ~= false then courses(F, Rr, x0, x1, y0 + 1, y1 - 1, o.h or 3, o.w or 5, { light = o.light or 12, dark = o.dark or 6, seed = o.seed or 1 }) end
  local sx0, sy0, sx1, sy1 = S:bbox()
  if sx0 then for yy = sy0, sy1 do if (yy - y0) % (o.h or 3) == (o.h or 3) - 1 then for xx = sx0, sx1 do if S:has(xx, yy) and S:has(xx - 1, yy) then px(xx, yy, lerp(Rr.shade, Rr.deep, .45)) end end end end end
  -- edges: ridge cap + left hip catch the light; the hip line between the planes is one step lighter than the shade
  F:each(function(x, y)
    if not F:has(x, y - 1) and not S:has(x, y - 1) then px(x, y, Rr.hi)
    elseif not F:has(x - 1, y) then px(x, y, lerp(Rr.hi, Rr.base, .35)) end
  end)
  for xx = x0, x1 do if F:has(xx, y1) then px(xx, y1, lerp(Rr.shade, Rr.deep, .35)) end end   -- fascia under the eave
  if sx0 then S:each(function(x, y) if not S:has(x, y + 1) and not F:has(x, y + 1) then px(x, y, Rr.deep) end end) end
end
-- recessed window: frame, dark (or glowing) glass with a shadow on its top and left inner edge, cross bar,
-- a sill that catches light with a shadow line under it, optional shutters
local function window(wx, wy, w, h, o)
  o = o or {}
  local fr = o.frame or P.wood.base
  R(wx - 1, wy - 1, wx + w, wy + h, fr)
  local glass = o.glow and P.gold.hi or (o.glass or WIN.shade)
  R(wx, wy, wx + w - 1, wy + h - 1, glass)
  local rec = o.glow and P.gold.base or (o.rec or INTERIOR)
  R(wx, wy, wx + w - 1, wy, rec) R(wx, wy, wx, wy + h - 1, rec)
  if not o.nobar then
    local mx, my = wx + w // 2, wy + h // 2
    if w >= 5 then R(mx, wy, mx, wy + h - 1, fr) end
    if h >= 5 then R(wx, my, wx + w - 1, my, fr) end
  end
  if o.glow then px(wx + 1, wy + 1, P.cream) else px(wx + 1, wy + 1, o.glint or WIN.hi) end
  px(wx - 1, wy - 1, o.frameHi or lerp(fr, P.cream, .35))
  if not o.nosill then
    R(wx - 2, wy + h, wx + w + 1, wy + h, o.sill or P.stone.hi)
    R(wx - 1, wy + h + 1, wx + w + 1, wy + h + 1, o.sillsh)
  end
  if o.shut then
    local S = o.shut
    for _, sx in ipairs{ wx - 3, wx + w + 1 } do
      R(sx, wy - 1, sx + 1, wy + h - 1, S.base)
      for yy = wy, wy + h - 1, 2 do R(sx, yy, sx + 1, yy, S.shade) end
      px(sx, wy - 1, S.hi)
    end
    R(wx + w + 2, wy - 1, wx + w + 2, wy + h - 1, S.shade)   -- right shutter's own edge in shade
  end
end
-- recessed plank door with a frame, arch, shadowed top and left jamb, handle, and a step that catches light
local function door(dx0, dx1, dy0, yb, o)
  o = o or {}
  local Rw = o.ramp or P.wood
  local fr = o.frame or Rw.deep
  local f = c:rrect(dx0 - 1, dy0 - 1, dx1 + 1, yb, o.arch or 2)
  c:fillMask(f, fr)
  local leaf = c:rrect(dx0, dy0, dx1, yb, math.max((o.arch or 2) - 1, 0))
  c:fillMask(leaf, o.open and INTERIOR or Rw.base)
  if not o.open then
    for xx = dx0 + 2, dx1 - 1, 2 do leaf:each(function(x, y) if x == xx then px(x, y, Rw.shade) end end) end
    leaf:each(function(x, y) if not leaf:has(x, y - 1) or x == dx0 then px(x, y, lerp(Rw.shade, Rw.deep, .5)) end end)
    px(dx1 - 1, dy0 + (yb - dy0) // 2 + 1, P.gold.hi)
  else
    leaf:each(function(x, y) if x == dx1 then px(x, y, lerp(INTERIOR, Rw.shade, .4)) end end)
  end
  if o.lintel then R(dx0 - 2, dy0 - 2, dx1 + 2, dy0 - 2, o.lintel) end
  if not o.nostep then R(dx0 - 2, yb, dx1 + 2, yb, P.stone.base) R(dx0 - 2, yb, dx1 + 1, yb, P.stone.hi) end
end
-- stone plinth / base course: lit top ledge, jointed blocks, dark contact row; the side continues it in shade
local function plinth(x0, x1, yb, d, rows)
  rows = rows or 2
  R(x0, yb - rows + 1, x1, yb, P.stone.base)
  R(x0, yb - rows + 1, x1, yb - rows + 1, P.stone.hi)
  R(x0, yb, x1, yb, P.stone.shade)
  for xx = x0 + 2, x1, 5 do px(xx, yb - rows + 2 > yb and yb or yb - rows + 2, P.stone.shade) end
  for i = 1, d do local s = rise(i); for r = 0, rows - 1 do px(x1 + i, yb - s - r, (r == rows - 1) and P.stone.shade or P.stone.deep) end end
end
-- corner quoins: alternating long/short stones up a wall edge (borrowed from the town corners)
local function quoins(xc, y0, y1, dir, lite, dark)
  for yy = y0, y1, 4 do R(xc, yy, xc + dir * 2, yy + 1, lite) R(xc, yy + 2, xc + dir, yy + 3, lite) px(xc + dir * 2, yy + 1, dark) end
end
-- hard cast shadow on the ground (light upper left): a band under the footprint that slides right as it
-- comes forward, plus a wedge off the shade side; a darker contact row tucks under the front wall.
local function cast(x0, x1, yb, d, hw, L)
  L = (L or 4) + 3
  local m = HP.mask()
  for j = 1, 3 do for xx = x0 + j, x1 + d + j + 1 do m:set(xx, yb + j) end end
  local rr = rise(d)
  for yy = yb - rr - hw, yb do
    local t = (yy - (yb - rr - hw)) / (hw + rr)
    for xx = x1 + d + 1, x1 + d + 1 + floor(t * L + .5) do m:set(xx, yy) end
  end
  shadeUnder(m, .38)
  local k = HP.mask() for xx = x0 + 1, x1 + d do k:set(xx, yb + 2) end
  shadeUnder(k, .25)
  CURSNAP = snapshot()
end
local function castRound(cx, yb, rx, L)
  local m = E(cx + (L or 3), yb + 1, rx, 2)
  shadeUnder(m, .38)
  CURSNAP = snapshot()
end
-- sphere / cylinder shading quantised to 4 tones (hard pixels), with a reflected-light edge on the shade side
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
  if not o.norefl then   -- reflected light: the outermost lower-right edge lifts one step
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
local function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end
-------------------------------------------------------------- shared bits
local GLYPH = {
  B = { "110", "101", "110", "101", "110" }, U = { "101", "101", "101", "101", "111" },
  I = { "111", "010", "010", "010", "111" }, L = { "100", "100", "100", "100", "111" },
  D = { "110", "101", "101", "101", "110" },
}
local function drawBuild(x, y, hex)   -- 19x5, (x,y) top-left
  local cx = x
  for ch in ("BUILD"):gmatch(".") do
    for r = 1, 5 do for k = 1, 3 do if GLYPH[ch][r]:sub(k, k) == "1" then px(cx + k - 1, y + r - 1, hex or P.ink) end end end
    cx = cx + 4
  end
end
local function patch(x0, y0, x1, y1)
  local m = c:rrect(x0, y0, x1, y1, 4)
  ink(m)
  c:part(m, "wood", { band = 2, nopop = true })
  for _, p in ipairs{ { x0 + 5, y0 + 6 }, { x1 - 9, y1 - 2 }, { x1 - 3, y0 + 5 }, { x0 + 13, y1 - 1 }, { x0 + 22, y0 + 3 }, { x0 + 2, y1 - 4 } } do px(p[1], p[2], P.wood.deep) end
  for _, p in ipairs{ { x0 + 9, y0 + 7 }, { x1 - 14, y0 + 8 }, { x0 + 3, y0 + 3 } } do px(p[1], p[2], P.wood.hi) end
  return m
end
local function stake(x, y0, y1) local m = c:rect(x, y0, x, y1); ink(m); c:part(m, "wood", { band = 1, nopop = true }) end
local function sline(x0, y0, x1, y1) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), P.cream) end
local function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  ink(head, stem)
  c:fillMask(stem, P.moss.base)
  c:fillMask(head, col or P.petal.base)
  px(x, y, P.gold.hi)
end
local function stone(x, y, w)
  local m = c:rrect(x, y, x + w, y + 2, 1)
  ink(m); c:part(m, "stone", { band = 1, pop = { x = x + 1, y = y, horizontal = true } })
end
local function leaf(x, y)   -- little flying leaf, 4x2
  local m = HP.mask():set(x, y):set(x + 1, y):set(x + 2, y):set(x + 1, y + 1):set(x + 2, y + 1):set(x + 3, y + 1)
  ink(m)
  c:fillMask(m, P.moss.base); px(x, y, P.moss.hi); px(x + 3, y + 1, P.moss.shade)
end
local function badge(dy)
  local cx, cy = 50, 6 + dy
  local disc = E(cx, cy, 4, 4)
  ink(disc)
  c:part(disc, "gold", { band = 2, pop = { x = cx - 2, y = cy - 3, horizontal = true } })
  R(cx, cy - 3, cx + 1, cy, P.ink) R(cx, cy + 2, cx + 1, cy + 3, P.ink)   -- drop shadow of the mark
  R(cx - 1, cy - 3, cx, cy - 1, P.cream)
  R(cx - 1, cy + 1, cx, cy + 2, P.cream)
end
local BOB = { 0, -1, 0, 1 }
local function savePiece(canvas, name)
  HP.assertClean(canvas)
  canvas:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local function saveStrip(frames, name, tag)
  for k = 1, 4 do HP.assertClean(frames[k]) end
  HP.sheet{ cellw = CW, cellh = CH, frames = frames, tags = { { name = tag, from = 1, to = 4 } } }
    :save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local SOIL = "#3a2430"
local ROOFW = { hi = P.wood.hi, base = P.wood.base, shade = P.wood.shade, deep = P.wood.deep }
local X0, X1, Y, D = 20, 36, 46, 3

local function plot() return patch(5, 37, 51, 53) end

local function pinkWorm(cols, rows, sway, eyes, h)   -- standing worm, bottom row rows[2]
end

-- a standing worm: base centre (bx,by) = bottom row, h rows tall, 3 wide, tilts by sway at the top
local function wormUp(bx, by, h, sway, face)
  local m, cell = HP.mask(), {}
  for i = 0, h - 1 do
    local y = by - i
    local off = floor(sway * (i / (h - 1)) + (sway >= 0 and .5 or -.5))
    for dx = -1, 1 do m:set(bx + off + dx, y) end
    cell[i] = bx + off
  end
  ink(m)
  for i = 0, h - 1 do
    local y, cx = by - i, cell[i]
    local ring = (i % 3 == 2)
    px(cx - 1, y, ring and P.petal.base or P.petal.hi); px(cx, y, ring and P.petal.shade or P.petal.base); px(cx + 1, y, ring and P.petal.deep or P.petal.shade)
  end
  if face then
    local cx, y = cell[h - 1], by - (h - 1)
    px(cx - 1, y + 1, P.ink) px(cx + 1, y + 1, P.ink)
    px(cx, y + 2, P.ink)
  end
  return m
end

-- the box of trays (n = 1..3)
local function trayTop(k) return (k == 1) and 38 or (38 - 4 * (k - 1)) end
local function box(n)
  local yt = trayTop(n)
  local front, side, top = c:rect(X0, yt, X1, Y), sideWall(X1, yt, Y, D), topPlane(X0, X1, yt, D)
  ink(front, side, top)
  c:fillMask(front, P.sea.base) c:fillMask(side, P.sea.shade) c:fillMask(top, SOIL)
  -- soil top: crumbs and lit grains
  top:each(function(x, y) local h = hsh(x * 3, y * 7); if h < 18 then px(x, y, P.wood.deep) elseif h > 86 then px(x, y, P.wood.shade) end end)
  for k = 1, n do
    local ty = trayTop(k)
    local bot = (k == 1) and Y or (trayTop(k - 1) - 1)
    R(X0, ty, X1, ty, P.sea.hi)
    R(X0, ty + 1, X1, ty + 1, P.sea.deep)
    for i = 1, D do px(X1 + i, ty - rise(i), P.sea.base) px(X1 + i, ty + 1 - rise(i), P.sea.deep) end
    -- plank grooves on the front
    for yy = ty + 2, bot - 1 do for xx = X0 + 4, X1 - 1, 4 do if yy % 2 == 0 then px(xx, yy, lerp(P.sea.base, P.sea.shade, .5)) end end end
  end
  R(X0, Y, X1, Y, P.sea.shade)
  rimLight(front, P.sea.hi, P.sea.base)
  -- colony vents: a dark slot with a pink worm looking out
  local function vent(vx, vy)
    R(vx, vy, vx + 2, vy + 1, INTERIOR)
    px(vx, vy + 1, P.petal.base); px(vx + 1, vy + 1, P.petal.hi); px(vx + 1, vy, P.petal.base)
    R(vx - 1, vy + 2, vx + 3, vy + 2, P.sea.shade)
  end
  vent(24, 42); vent(31, 42)
  if n >= 2 then vent(27, trayTop(2) + 2) end
  if n >= 3 then vent(27, trayTop(3) + 2) end
  return yt
end

local function wormsOnTop()   -- soil squiggles on the open top
  px(23, 36, P.petal.base) px(24, 36, P.petal.hi) px(25, 37, P.petal.base)
  px(30, 37, P.petal.base) px(31, 36, P.petal.hi) px(32, 36, P.petal.base)
end

local function pail(x, y)     -- castings pail, (x,y) = bottom-left of a 7 wide x 7 tall pail
  local body = c:rect(x, y - 6, x + 6, y)
  local heap = c:rrect(x + 1, y - 9, x + 5, y - 6, 1)
  local handle = c:rect(x + 1, y - 11, x + 5, y - 10)
  ink(body, heap, handle)
  c:fillMask(handle, P.stone.shade)
  c:fillMask(heap, SOIL) px(x + 2, y - 8, P.wood.shade) px(x + 4, y - 7, P.wood.shade)
  cyl(body, x + 3, 3, SLATE, { t1 = .6 })
  R(x, y - 6, x + 6, y - 6, P.stone.hi)
  R(x, y - 3, x + 6, y - 3, SLATE.shade)
  px(x + 1, y - 5, P.cream)
end
local function spout()
  local pipe = c:rect(37, 39, 42, 40):add(c:rect(41, 41, 42, 43))
  ink(pipe)
  c:fillMask(pipe, P.stone.base)
  R(37, 39, 42, 39, P.stone.hi); R(37, 40, 42, 40, P.stone.shade); R(41, 41, 41, 43, P.stone.base); R(42, 41, 42, 43, P.stone.shade)
  px(41, 45, P.sea.hi); px(41, 46, P.sea.base)
end
local function roof()
  local yt = trayTop(3)
  for _, x in ipairs{ X0 + 1, X1 - 1 } do local m = c:rect(x, yt - 2, x, yt - 1); ink(m); c:part(m, "wood", { band = 1, nopop = true }) end
  local F, S = hipRoof(X0, X1, yt - 2, yt - 6, 2, 6, D)
  ink(F, S)
  paintRoof(F, S, ROOFW, { h = 2, w = 4, seed = 5 })
end

local function drawEmpty(k)
  newc()
  plot()
  -- corner stakes joined by a string line; stones and flowers
  sline(11, 36, 45, 36); sline(45, 36, 48, 47); sline(48, 47, 8, 47); sline(8, 47, 11, 36)
  stake(11, 36, 40); stake(45, 36, 40); stake(8, 47, 51); stake(48, 47, 51)
  stone(15, 49, 3); stone(39, 42, 2); stone(24, 51, 2)
  flower(14, 42, P.petal.base); flower(38, 50, P.gold.base); flower(20, 50, P.sky.hi); flower(43, 44, P.petal.hi)
  -- the sign: a smiling pink worm balances the board on its head
  local sw = ({ 0, 1, 0, -1 })[k]
  local mound = E(28, 44, 4, 1); ink(mound); c:part(mound, "wood", { band = 1, nopop = true })
  local cx = 28 + sw
  local head = c:rrect(cx - 3, 28, cx + 3, 33, 2)
  local body = wormUp(28, 44, 10, sw, false)   -- rows 35..44
  local bx0, by0 = 15 + sw, 14
  local board = c:rect(bx0, by0, bx0 + 24, by0 + 13)
  ink(head, board)
  c:fillMask(board, P.petal.base)
  c:fillMask(c:rect(bx0 + 1, by0 + 1, bx0 + 23, by0 + 12), P.cream)
  R(bx0 + 1, by0 + 12, bx0 + 23, by0 + 12, "#f6dfae")
  R(bx0, by0 + 13, bx0 + 24, by0 + 13, P.petal.shade)
  px(bx0, by0, P.petal.hi)
  drawBuild(bx0 + 3, by0 + 2, P.ink)
  c:part(head, "petal", { band = 2, pop = { x = cx - 2, y = 29, horizontal = true } })
  R(cx - 2, 30, cx - 2, 31, P.ink) R(cx + 2, 30, cx + 2, 31, P.ink)
  px(cx - 2, 30, P.ink) px(cx + 2, 30, P.ink)
  R(cx - 3, 32, cx - 3, 32, P.petal.hi); R(cx + 3, 32, cx + 3, 32, P.ember.hi)
  px(cx - 1, 32, P.ink) px(cx, 33, P.ink) px(cx + 1, 32, P.ink)
  -- tiny crate icon
  local ix = bx0 + 9
  R(ix, by0 + 8, ix + 6, by0 + 8, P.wood.deep); px(ix + 3, by0 + 8, P.petal.base); px(ix + 2, by0 + 8, P.petal.hi)
  R(ix, by0 + 9, ix + 6, by0 + 11, P.sea.base); R(ix, by0 + 9, ix + 6, by0 + 9, P.sea.hi); R(ix, by0 + 11, ix + 6, by0 + 11, P.sea.shade)
  px(ix + 3, by0 + 10, P.ink)
  -- a leaf drifts past
  local lx = ({ 2, 16, 30, 44 })[k]; local ly = ({ 35, 33, 35, 37 })[k]
  leaf(lx, ly)
  return c
end

local function wallLevel(n)
  newc()
  plot()
  local pitch = 8 + 4 * (n - 1)
  cast(X0, X1, Y, D, pitch, 3)
  if n >= 2 then pail(11, 46) end
  box(n)
  if n == 1 then wormsOnTop() end
  if n >= 3 then roof(); spout() end
  flower(15, 50, P.petal.base); flower(40, 50, P.gold.base); flower(46, 46, P.sky.hi)
  return c
end

local function drawReady(k)
  wallLevel(1)
  local sw1, sw2 = ({ -1, 0, 1, 0 })[k], ({ 1, 0, -1, 0 })[k]
  wormUp(24, 36, ({ 7, 8, 7, 6 })[k], sw1, true)
  wormUp(31, 36, ({ 6, 7, 8, 7 })[k], sw2, true)
  -- castings pile grows on the right
  local hgt = k + 1
  local pile = E(44, 46 - 1, 2 + k, hgt // 1 - 0 > 0 and (k + 1) // 2 + 1 or 1)
  local pm = c:rrect(41 - (k - 1), 46 - hgt, 47 + (k - 1) // 2, 46, 1)
  ink(pm); c:fillMask(pm, SOIL)
  pm:each(function(x, y) if y == 46 - hgt then px(x, y, P.wood.deep) end end)
  px(41 - (k - 1) + 1, 46 - hgt + 1, P.wood.shade); px(44, 47 - hgt + 1, P.wood.shade)
  c:sparkle(({ 14, 40, 18, 44 })[k], ({ 30, 28, 24, 34 })[k])
  c:sparkle(({ 46, 12, 38, 14 })[k], ({ 40, 38, 30, 40 })[k])
  badge(BOB[k])
  return c
end


local function readyLevel(n, k)
  wallLevel(n)
  local sw1, sw2 = ({ -1, 0, 1, 0 })[k], ({ 1, 0, -1, 0 })[k]
  local hgt = k + 1
  if n == 2 then
    local yt = trayTop(2)
    wormUp(24, yt - 1, ({ 7, 8, 7, 6 })[k], sw1, true)
    wormUp(31, yt - 1, ({ 6, 7, 8, 7 })[k], sw2, true)
    local pm = c:rrect(41 - (k - 1), 46 - hgt, 47 + (k - 1) // 2, 46, 1)
    ink(pm); c:fillMask(pm, SOIL)
    pm:each(function(x, y) if y == 46 - hgt then px(x, y, P.wood.deep) end end)
    px(41 - (k - 1) + 1, 46 - hgt + 1, P.wood.shade); px(44, 47 - hgt + 1, P.wood.shade)
    c:sparkle(({ 14, 40, 18, 44 })[k], ({ 24, 22, 18, 28 })[k])
    c:sparkle(({ 46, 12, 38, 16 })[k], ({ 34, 32, 24, 36 })[k])
  else
    -- castings drop from the spout onto a growing pile; a worm waves beside the box
    local pm = c:rrect(41, 46 - hgt, 45, 46, 1)
    -- falling clump from the spout end
    local fy = ({ 44, 41, 44, 41 })[k]
    ink(pm); c:fillMask(pm, SOIL)
    pm:each(function(x, y) if y == 46 - hgt then px(x, y, P.wood.deep) end end)
    px(42, 47 - hgt, P.wood.shade); px(45, 47 - hgt + 1, P.wood.shade)
    local fl = ({ 43, 42, 43, 42 })[k]
    if k % 2 == 0 then
      local d = c:rect(41, fl - 1, 42, fl); ink(d); c:fillMask(d, SOIL); px(41, fl - 1, P.wood.deep)
    end
    wormUp(49, 46, ({ 6, 7, 8, 7 })[k], ({ 1, 0, -1, 0 })[k], true)
    c:sparkle(({ 14, 44, 16, 46 })[k], ({ 24, 22, 20, 26 })[k])
    c:sparkle(({ 47, 12, 40, 12 })[k], ({ 30, 30, 20, 34 })[k])
    c:sparkle(({ 30, 29, 31, 30 })[k], ({ 21, 18, 19, 22 })[k])
  end
  badge(BOB[k])
  return c
end
local function bothSheets(name)
  for n = 2, 3 do
    local fr = {}
    for k = 1, 4 do fr[k] = readyLevel(n, k) end
    saveStrip(fr, name .. "-ready-l" .. n, "ready")
  end
end
bothSheets("worm_farm")
