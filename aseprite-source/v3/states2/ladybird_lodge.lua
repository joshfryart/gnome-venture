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
local SOILP = "#3a2430"
local Y, D = 46, 3
local function plot() return patch(5, 37, 51, 53) end

local function ladybird(x, y, open)   -- 5 wide x 4 tall, (x,y) top-left; open = wings flicked up
  local body = c:rrect(x, y + 1, x + 4, y + 3, 1)
  local head = c:rect(x + 1, y, x + 3, y)
  local wm = HP.mask()
  if open then wm:add(c:rect(x - 1, y - 1, x, y + 1)):add(c:rect(x + 4, y - 1, x + 5, y + 1)) end
  ink(body, head, wm)
  c:fillMask(wm, P.sky.hi)
  c:fillMask(head, P.ink)
  c:fillMask(body, P.ember.base)
  px(x, y + 1, P.ember.hi); px(x + 1, y + 1, P.ember.hi); px(x + 4, y + 3, P.ember.shade)
  px(x + 2, y + 1, P.ink); px(x + 2, y + 2, P.ink); px(x + 2, y + 3, P.ink)
  px(x + 1, y + 2, P.ink); px(x + 3, y + 3, P.ink)
  px(x + 1, y, P.cream) px(x + 3, y, P.cream)
end

local function ledge(xa, xb, yy, rows)
  for r = 0, rows - 1 do
    R(xa, yy + r, xb, yy + r, (r == 0) and P.stone.base or SLATE.base)
  end
  R(xa, yy, xb, yy, P.stone.hi)
  R(xa, yy + rows - 1, xb, yy + rows - 1, SLATE.shade)
  px(xa - 1, yy, P.ink); px(xa - 1, yy + rows - 1, P.ink)
  for i = 1, D do
    for r = 0, rows - 1 do px(xb + i, yy + r - rise(i), (r == rows - 1) and SLATE.deep or SLATE.shade) end
    px(xb + i, yy - 1 - rise(i), P.ink)
  end
  px(xb + 1, yy, P.stone.base)
end

-- one storey: lit front, cool side
local function storey(x0, x1, yt, yb, seed, W)
  local front, side = c:rect(x0, yt, x1, yb), sideWall(x1, yt, yb, D, 1)
  ink(front, side)
  paintWalls(front, side, W, seed)
  eaveShadow(x0, x1, yt, D, W, 1)
  px(x0 + 1, yt + 1, P.ember.hi) px(x0 + 2, yt + 1, P.ember.hi)
  return front, side
end
local function spot(x, y) R(x, y, x + 1, y + 1, P.ink); px(x, y, P.ember.deep) end
local function roofOn(x0, x1, ye, yr, ov, a)
  local F, S = hipRoof(x0, x1, ye, yr, ov, a, D)
  ink(F, S)
  paintRoof(F, S, SLATE, { h = 2, w = 3, light = 18, dark = 0, seed = 3 })
end
local function doorway(x0)
  door(x0, x0 + 3, Y - 7, Y, { open = true, frame = P.wood.deep, arch = 2, nostep = true })
end
local WALL = wallTones(P.ember.base, P.ember.hi)
local function tier1(x0, x1, spots)
  storey(x0, x1, 35, Y, 11, WALL)
  for yy = 37, Y - 1, 3 do dkrow(x0 + 1, x0 + 4, yy, "ember") end
  for _, s in ipairs(spots) do spot(s[1], s[2]) end
  for i = 1, D do px(x1 + i, Y - 6 - rise(i), P.ink) end
  plinth(x0, x1, Y, D, 1)
  doorway(27)
end

local function lodge(n)
  newc()
  plot()
  local x0, x1 = 22, 35
  if n == 3 then x0, x1 = 20, 37 end
  cast(x0, x1, Y, D, ({ 12, 20, 32 })[n], 3)
  if n == 1 then
    tier1(x0, x1, { { 24, 38 }, { 32, 37 }, { 24, 43 } })
    roofOn(x0, x1, 34, 28, 2, 7)
  elseif n == 2 then
    tier1(x0, x1, { { 24, 38 }, { 24, 43 }, { 33, 41 } })
    storey(x0, x1, 27, 31, 21, WALL)
    for yy = 29, 30, 2 do dkrow(x0 + 1, x0 + 3, yy, "ember") end
    window(27, 28, 4, 2, { glow = true, frame = P.wood.base, nobar = true, sill = P.stone.hi, sillsh = lerp(P.ember.base, DUSKSH, .3) })
    window(24, 28, 2, 2, { frame = P.wood.base, nobar = true, nosill = true })
    ledge(x0 - 1, x1 + 1, 33, 2)
    roofOn(x0, x1, 26, 20, 2, 7)
    -- flower box under the lower right window
    R(31, 41, 35, 42, P.wood.base); R(31, 42, 35, 42, P.wood.shade)
    px(31, 40, P.petal.base) px(33, 40, P.gold.base) px(35, 40, P.petal.hi) px(32, 40, P.moss.base) px(34, 40, P.moss.base)
  else
    tier1(x0, x1, { { 22, 38 }, { 22, 43 }, { 35, 44 } })
    window(33, 38, 3, 3, { glow = true, frame = P.wood.base, nobar = true, sill = P.stone.hi, sillsh = lerp(P.ember.base, DUSKSH, .3) })
    storey(22, 35, 28, 32, 21, WALL)
    window(27, 29, 4, 2, { glow = true, frame = P.wood.base, nobar = true, nosill = true })
    ledge(x0 - 1, x1 + 1, 33, 2)
    storey(25, 32, 22, 25, 31, WALL)
    window(28, 23, 2, 2, { glow = true, frame = P.wood.base, nobar = true, nosill = true })
    ledge(23, 34, 26, 2)
    -- balcony rail on the middle storey
    R(24, 31, 33, 31, P.wood.base); R(24, 31, 33, 31, P.wood.hi)
    for _, xx in ipairs{ 24, 27, 30, 33 } do R(xx, 32, xx, 32, P.wood.shade) end
    px(34, 31, P.ink) px(23, 31, P.ink)
    roofOn(25, 32, 21, 19, 1, 1)
    -- flag
    local pole = c:rect(28, 15, 28, 18)
    local flag = HP.mask():set(29, 15):set(30, 15):set(31, 15):set(29, 16):set(30, 16):set(29, 17)
    ink(pole, flag)
    c:fillMask(pole, P.wood.deep); c:fillMask(flag, P.gold.base); px(29, 15, P.gold.hi); px(30, 16, P.gold.shade)
  end
  flower(14, 49, P.petal.base); flower(41, 50, P.gold.base); flower(46, 44, P.sky.hi)
  return c
end

local function drawEmpty(k)
  newc()
  plot()
  sline(11, 36, 45, 36); sline(45, 36, 48, 47); sline(48, 47, 8, 47); sline(8, 47, 11, 36)
  stake(11, 36, 40); stake(45, 36, 40); stake(8, 47, 51); stake(48, 47, 51)
  stone(15, 49, 3); stone(39, 42, 2); stone(24, 51, 2)
  flower(14, 42, P.petal.base); flower(38, 50, P.gold.base); flower(20, 50, P.sky.hi); flower(43, 44, P.petal.hi)
  local sw = ({ 0, 1, 0, -1 })[k]
  local cx, cy = 28 + sw, 17
  -- stake: wobbles with the board
  local stk = HP.mask()
  for y = cy + 6, 43 do
    local off = floor(sw * ((43 - y) / (43 - cy - 6)) + (sw >= 0 and .5 or -.5))
    stk:set(28 + off, y)
  end
  local mound = E(28, 43, 3, 1)
  ink(stk, mound)
  c:fillMask(mound, P.wood.base)
  stk:each(function(x, y) px(x, y, P.wood.base) end)
  -- leaf board
  local lm = E(cx, cy, 14, 7)
  lm:add(c:rect(cx + 14, cy, cx + 15, cy)):add(c:rect(cx - 15, cy + 1, cx - 14, cy + 1))   -- pointed tips
  ink(lm)
  c:part(lm, "moss", { band = 2, nopop = true })
  local pan = E(cx, cy - 1, 13, 5)
  c:fillMask(pan, P.moss.hi)
  c:fillMask(c:rect(cx - 9, cy - 5, cx + 9, cy - 1):copy(), P.moss.hi)
  px(cx - 12, cy + 1, P.moss.deep) px(cx + 12, cy + 2, P.moss.deep)   -- tiny veins at the ends
  R(cx - 4, cy + 6, cx + 4, cy + 6, P.moss.shade)
  drawBuild(cx - 9, cy - 5, P.ink)
  -- tiny lodge icon
  R(cx - 2, cy + 2, cx + 2, cy + 2, P.stone.shade); R(cx - 1, cy + 1, cx + 1, cy + 1, P.stone.base)
  R(cx - 2, cy + 3, cx + 2, cy + 4, P.ember.base); px(cx, cy + 4, P.ink); px(cx - 2, cy + 3, P.ember.hi)
  -- the ladybird on the leaf hops, flicking its wings in the air
  local hop = ({ 0, 0, 2, 0 })[k]
  ladybird(cx + 5, cy - 11 - hop, k == 3)
  -- a petal drifts past
  local pxx = ({ 3, 14, 38, 49 })[k]; local pyy = ({ 38, 36, 40, 37 })[k]
  local pm = HP.mask():set(pxx, pyy):set(pxx + 1, pyy):set(pxx + 1, pyy + 1)
  ink(pm); c:fillMask(pm, P.petal.hi); px(pxx + 1, pyy + 1, P.petal.base)
  return c
end

local function charm(x, y)   -- red lucky charm on a gold loop, 5x5 centre (x,y)
  local ring = E(x, y, 2, 2)
  ink(ring)
  c:part(ring, "ember", { band = 1, pop = { x = x - 1, y = y - 1, horizontal = true } })
  px(x, y, P.ink); px(x - 1, y + 1, P.cream); px(x + 1, y - 1, P.cream)
  R(x - 1, y - 4, x + 1, y - 3, P.gold.base); px(x - 1, y - 4, P.ink); px(x + 1, y - 4, P.ink); px(x, y - 4, P.gold.hi)
  px(x, y - 3, P.gold.hi)
end

local function drawReady(k)
  lodge(1)
  charm(28, 50 + ({ 0, -1, 0, 0 })[k])
  -- ladybird crosses the garden in hops
  local lx = ({ 5, 9, 13, 17 })[k]; local ly = ({ 41, 38, 41, 38 })[k]
  ladybird(lx, ly, k % 2 == 0)
  c:sparkle(({ 23, 33, 22, 34 })[k], ({ 49, 48, 46, 47 })[k])
  c:sparkle(({ 35, 21, 38, 24 })[k], ({ 51, 52, 52, 51 })[k])
  badge(BOB[k])
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
saveStrip(frames, "ladybird_lodge-empty", "empty")
savePiece(lodge(1), "ladybird_lodge-l1")
savePiece(lodge(2), "ladybird_lodge-l2")
savePiece(lodge(3), "ladybird_lodge-l3")
frames = {}
for k = 1, 4 do frames[k] = drawReady(k) end
saveStrip(frames, "ladybird_lodge-ready", "ready")
