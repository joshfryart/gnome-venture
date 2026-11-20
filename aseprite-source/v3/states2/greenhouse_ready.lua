local W,H,NAME = 72,64,"greenhouse"
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or ("/tmp/ase/states2/" .. NAME .. "/")
local floor, sin = math.floor, math.sin
local c
local function newc() c = HP.canvas{ w = W, h = H, scale = 1, name = NAME } return c end
local function px(x, y, hex) c:px(x, y, hex) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
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
local DUSKSH = "#5a4660"
local SHC, SHC2 = lerp("#a8cc70", DUSKSH, .42), lerp("#a8cc70", DUSKSH, .56)
local WIN = { hi = P.sky.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }
local THATCH = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local INTERIOR = "#3b2c48"
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
local function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end
local function pt(list) local m = HP.mask() for _, q in ipairs(list) do m:set(q[1], q[2]) end return m end
local function rise(i) return (i + 1) // 2 end
local function sideWall(x1, yt, yb, d, extra)
  local m = HP.mask()
  for i = 1, d do local s = rise(i); for yy = yt - s - (extra or 0), yb - s do m:set(x1 + i, yy) end end
  return m
end
local function hipRoof(x0, x1, ye, yr, ov, a, d, ah)
  local rr, hd = rise(d), d // 2
  local EL, ER, BR = { x0 - ov, ye + 1 }, { x1 + ov + 1, ye + 1 }, { x1 + ov + d + 1, ye + 1 - rr }
  local RL, RR = { x0 - ov + a + hd, yr }, { x1 + ov + 1 - (ah or a + 3) + hd, yr }
  local F = c:poly{ EL, RL, RR, ER }
  local S = c:poly{ ER, RR, BR }:cut(F)
  return F, S
end
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
local function wallTones(base, lit)
  return { base = base, lite = lerp(base, lit or P.cream, .4), dark = lerp(base, DUSKSH, .12),
    eave = lerp(base, DUSKSH, .3), sbase = lerp(base, DUSKSH, .36), slite = lerp(base, DUSKSH, .27), sdark = lerp(base, DUSKSH, .47) }
end
local function mottle(m, base, lite, dark, seed, dens)
  m:each(function(x, y)
    if c:get(x, y) == base then
      local h = hsh(x * 3 + seed, y * 5 + seed)
      if h < dens then px(x, y, lite) if c:get(x + 1, y) == base and h < dens // 2 then px(x + 1, y, lite) end
      elseif h > 99 - dens then px(x, y, dark) end
    end
  end)
end
local function paintWalls(front, side, Wt, seed)
  c:fillMask(front, Wt.base) c:fillMask(side, Wt.sbase)
  mottle(front, Wt.base, Wt.lite, Wt.dark, seed or 1, 7)
  mottle(side, Wt.sbase, Wt.slite, Wt.sdark, (seed or 1) + 9, 9)
end
local function eaveShadow(x0, x1, yt, d, Wt, rows)
  for r = 0, (rows or 1) - 1 do R(x0, yt + r, x1, yt + r, Wt.eave) end
  for i = 1, d do local s = rise(i); for r = 0, (rows or 1) do px(x1 + i, yt - s + r, Wt.sdark) end end
end
local function paintRoof(F, S, Rr, o)
  o = o or {}
  c:fillMask(F, Rr.base) c:fillMask(S, Rr.shade)
  local x0, y0, x1, y1 = F:bbox()
  if o.tex ~= false then courses(F, Rr, x0, x1, y0 + 1, y1 - 1, o.h or 3, o.w or 5, { light = o.light or 12, dark = o.dark or 6, seed = o.seed or 1 }) end
  local sx0, sy0, sx1, sy1 = S:bbox()
  if sx0 then for yy = sy0, sy1 do if (yy - y0) % (o.h or 3) == (o.h or 3) - 1 then for xx = sx0, sx1 do if S:has(xx, yy) and S:has(xx - 1, yy) then px(xx, yy, lerp(Rr.shade, Rr.deep, .45)) end end end end end
  F:each(function(x, y)
    if not F:has(x, y - 1) and not S:has(x, y - 1) then px(x, y, Rr.hi)
    elseif not F:has(x - 1, y) then px(x, y, lerp(Rr.hi, Rr.base, .35)) end
  end)
  for xx = x0, x1 do if F:has(xx, y1) then px(xx, y1, lerp(Rr.shade, Rr.deep, .35)) end end
  if sx0 then S:each(function(x, y) if not S:has(x, y + 1) and not F:has(x, y + 1) then px(x, y, Rr.deep) end end) end
end
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
end
local function door(dx0, dx1, dy0, yb, o)
  o = o or {}
  local Rw = o.ramp or P.wood
  local fr = o.frame or Rw.deep
  local f = c:rrect(dx0 - 1, dy0 - 1, dx1 + 1, yb, o.arch or 2)
  c:fillMask(f, fr)
  local leaf = c:rrect(dx0, dy0, dx1, yb, math.max((o.arch or 2) - 1, 0))
  c:fillMask(leaf, Rw.base)
  for xx = dx0 + 2, dx1 - 1, 2 do leaf:each(function(x, y) if x == xx then px(x, y, Rw.shade) end end) end
  leaf:each(function(x, y) if not leaf:has(x, y - 1) or x == dx0 then px(x, y, lerp(Rw.shade, Rw.deep, .5)) end end)
  px(dx1 - 1, dy0 + (yb - dy0) // 2 + 1, P.gold.hi)
  if not o.nostep then R(dx0 - 2, yb, dx1 + 2, yb, P.stone.base) R(dx0 - 2, yb, dx1 + 1, yb, P.stone.hi) end
end
local function plinth(x0, x1, yb, d, rows)
  rows = rows or 2
  R(x0, yb - rows + 1, x1, yb, P.stone.base)
  R(x0, yb - rows + 1, x1, yb - rows + 1, P.stone.hi)
  R(x0, yb, x1, yb, P.stone.shade)
  for xx = x0 + 2, x1, 5 do px(xx, yb - rows + 2 > yb and yb or yb - rows + 2, P.stone.shade) end
  for i = 1, d do local s = rise(i); for r = 0, rows - 1 do px(x1 + i, yb - s - r, (r == rows - 1) and P.stone.shade or P.stone.deep) end end
end
-- opaque cool cast shadow, lower right
local function cast(x0, x1, yb, d, hw, L)
  L = (L or 4) + 3
  local m = HP.mask()
  for j = 1, 3 do for xx = x0 + j, x1 + d + j + 1 do m:set(xx, yb + j) end end
  local rr = rise(d)
  for yy = yb - rr - hw, yb do
    local t = (yy - (yb - rr - hw)) / (hw + rr)
    for xx = x1 + d + 1, x1 + d + 1 + floor(t * L + .5) do m:set(xx, yy) end
  end
  c:fillMask(m, SHC)
  local k = HP.mask() for xx = x0 + 1, x1 + d do k:set(xx, yb + 2) end
  c:fillMask(k, SHC2)
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
end
-- 3x5 font
local GLY = {
  B = { "110", "101", "110", "101", "110" }, U = { "101", "101", "101", "101", "111" },
  I = { "111", "010", "010", "010", "111" }, L = { "100", "100", "100", "100", "111" },
  D = { "110", "101", "101", "101", "110" },
}
local function word(x, y, s, col)
  for i = 1, #s do
    local g = GLY[s:sub(i, i)]
    for r = 1, 5 do for k = 1, 3 do if g[r]:sub(k, k) == "1" then px(x + (i - 1) * 4 + k - 1, y + r - 1, col) end end end
  end
end
-- gold "!" badge top-right, bobbing by dy
local function badge(dy)
  local cx, cy = W - 8, 7 + dy
  local disc = E(cx, cy, 4, 4)
  ink(disc)
  c:fillMask(disc, P.gold.base)
  disc:each(function(x, y) if (x - cx) + (y - cy) > 4 then px(x, y, P.gold.shade) end end)
  px(cx - 2, cy - 3, P.gold.hi) px(cx - 3, cy - 2, P.gold.hi) px(cx - 1, cy - 3, P.gold.hi)
  R(cx + 1, cy - 2, cx + 1, cy + 0, P.gold.deep) px(cx + 1, cy + 2, P.gold.deep)
  R(cx, cy - 3, cx, cy + 0, P.cream); px(cx, cy + 2, P.cream)
end
local function save(canvas, name)
  HP.assertClean(canvas)
  canvas:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local function saveStrip(frames, name, tag)
  for k = 1, #frames do HP.assertClean(frames[k]) end
  HP.sheet{ cellw = W, cellh = H, frames = frames, tags = { { name = tag, from = 1, to = #frames } } }
    :save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local BOB = { 0, -1, 0, 1 }
-- dirt plot with ink rim
local DIRT = { hi = "#e8d2a2", base = "#d6b886", shade = "#b99468", deep = "#8f6e4c" }
local function plot(x0, y0, x1, y1, r)
  local m = c:rrect(x0, y0, x1, y1, r or 4)
  ink(m)
  c:part(m, DIRT, { band = 2, nopop = true })
  return m
end
local function stake(x, y0, y1)
  local m = c:rect(x, y0, x, y1); ink(m); c:part(m, "wood", { band = 1, nopop = true })
  px(x, y0, P.wood.hi)
end
local function stoneAt(x, y)
  local m = c:rect(x, y, x + 2, y + 1):add(c:rect(x + 1, y - 1, x + 1, y - 1))
  ink(m); c:fillMask(m, P.stone.base); px(x, y, P.stone.hi); px(x + 1, y - 1, P.stone.hi); R(x + 1, y + 1, x + 2, y + 1, P.stone.shade)
end
local function flowerAt(x, y, col)
  local head = pt{ {x, y - 1}, {x - 1, y}, {x, y}, {x + 1, y}, {x, y + 1} }
  local stem = c:rect(x, y + 2, x, y + 3)
  c:rim(HP.mask():add(head):add(stem), P.ink)
  c:fillMask(stem, P.moss.base); c:fillMask(head, col or P.petal.base); px(x, y, P.gold.hi)
end
local function line(x0, y0, x1, y1, hex)
  c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), hex)
end
local AX, AY = 36, 54
local GR = { hi = P.sky.hi, base = WIN.hi, shade = WIN.base, deep = WIN.shade }

local function sprouts(x, y, w, flowers)   -- wooden planter box top-left (x,y) w wide, with seedlings above
  local box = c:rect(x, y, x + w - 1, y + 3)
  local m = HP.mask():add(box)
  local sp = {}
  for xx = x + 1, x + w - 2, 3 do sp[#sp + 1] = xx; m:set(xx, y - 1):set(xx, y - 2):set(xx - 1, y - 2):set(xx + 1, y - 2) end
  c:rim(m, P.ink)
  c:part(box, "wood", { band = 1, pop = { x = x + 1, y = y, horizontal = true } })
  R(x + 1, y, x + w - 2, y, P.wood.deep)   -- soil
  for i, xx in ipairs(sp) do
    px(xx, y - 1, P.moss.shade); px(xx, y - 2, P.moss.base); px(xx - 1, y - 2, P.moss.hi); px(xx + 1, y - 2, P.moss.base)
    if flowers and i % 2 == 1 then px(xx, y - 3, P.petal.base) end
  end
end
local function vent(vx, vy, lift, prop)   -- 7 wide pane, 3 rows, top-hinged; lift rows open
  if lift > 0 then
    R(vx, vy + 3 - lift, vx + 6, vy + 2, INTERIOR)
    R(vx - 1, vy - lift, vx - 1, vy + 2, P.ink); R(vx + 7, vy - lift, vx + 7, vy + 2, P.ink)
    R(vx - 1, vy - lift - 1, vx + 7, vy - lift - 1, P.ink)
    if prop then R(vx + 5, vy + 3 - lift, vx + 5, vy + 2, P.wood.base) end
  end
  local y0 = vy - lift
  R(vx, y0, vx + 6, y0 + 2, GR.base)
  R(vx, y0, vx + 6, y0, P.cream); R(vx, y0 + 2, vx + 6, y0 + 2, P.cream); R(vx, y0, vx, y0 + 2, P.cream); R(vx + 6, y0, vx + 6, y0 + 2, P.cream)
  px(vx + 2, y0 + 1, P.cream); px(vx + 1, y0 + 1, GR.hi)
  if lift > 0 then R(vx, y0 + 2, vx + 6, y0 + 2, P.stone.hi) end
end
local function bench(x, y)   -- x,y top-left of a 11 wide bench; feet at y+8
  local back = c:rect(x, y, x + 10, y + 1)
  local seat = c:rect(x - 1, y + 4, x + 11, y + 5)
  local legs = c:rect(x + 1, y + 6, x + 2, y + 8):add(c:rect(x + 8, y + 6, x + 9, y + 8))
  local posts = c:rect(x + 1, y + 2, x + 1, y + 3):add(c:rect(x + 9, y + 2, x + 9, y + 3))
  ink(back, seat, legs, posts)
  c:part(legs, "wood", { band = 1, nopop = true }); c:part(posts, "wood", { band = 1, nopop = true })
  c:part(back, "wood", { band = 1, pop = { x = x + 1, y = y, horizontal = true } })
  c:part(seat, "wood", { band = 1, pop = { x = x, y = y + 4, horizontal = true } })
  R(x, y + 5, x + 10, y + 5, P.wood.shade)
end

local function greenhouse(x, y, o)
  o = o or {}
  local wl, wr, hh, rh = o.wl or 14, o.wr or 10, o.hh or 14, o.rh or 22
  local x0, x1, yt, d = x - wl, x + wr, y - hh, 4
  cast(x0, x1, y, d, 9, 4)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - rh, 2, 7, d)
  local U = ink(front, side, F, S)
  c:fillMask(front, WIN.base) c:fillMask(side, WIN.shade)
  for xx = x0, x1 do for yy = yt, y do if (xx - x0) % 6 == 0 or yy == yt or yy == y - 7 then px(xx, yy, P.cream) end end end
  side:each(function(xx, yy) if (xx - x1) == d or yy == y - 7 - rise(xx - x1) then px(xx, yy, P.stone.hi) end end)
  -- seedlings inside
  local pls, k = {}, 0
  while x0 + 2 + 6 * k + 2 <= x1 - 1 do pls[#pls + 1] = { x0 + 2 + 6 * k, ({ 6, 9, 7, 8 })[k % 4 + 1] }; k = k + 1 end
  for i, p in ipairs(pls) do
    R(p[1], y - p[2], p[1] + 2, y - 3, P.moss.base); px(p[1], y - p[2], P.moss.hi); px(p[1] + 2, y - p[2] + 2, P.moss.shade)
    if o.ripe then
      R(p[1], y - p[2] + 3, p[1] + 1, y - p[2] + 4, P.ember.base); px(p[1], y - p[2] + 3, P.ember.hi); px(p[1] + 1, y - p[2] + 4, P.ember.shade)
      if o.glow and o.glow[i] then px(p[1] - 1, y - p[2] + 2, P.gold.hi); px(p[1] + 2, y - p[2] + 2, P.gold.hi); px(p[1] + 2, y - p[2] + 5, P.gold.hi); px(p[1] - 1, y - p[2] + 5, P.gold.hi) end
    else px(p[1] + 1, y - p[2] - 1, P.petal.base) end
  end
  side:each(function(xx, yy) if yy > y - 6 - rise(xx - x1) and yy < y - 2 - rise(xx - x1) and (xx - x1) < d then px(xx, yy, P.moss.shade) end end)
  paintRoof(F, S, GR, { tex = false })
  local fx0, fy0, fx1, fy1 = F:bbox()
  k = 0
  while x0 + 1 + 6 * k <= x1 do
    local xx = x0 + 1 + 6 * k
    for yy = fy0 + 1, fy1 - 1 do if F:has(xx, yy) and F:has(xx + 1, yy) then px(xx, yy, P.cream) end end
    k = k + 1
  end
  plinth(x0, x1, y, d, 2)
  for xx = x0 + 1, x1, 4 do px(xx, y, P.stone.deep) end
  px(x0 + 2, yt + 2, P.cream) px(x0 + 3, yt + 1, P.cream) px(x0 + 8, yt + 3, WIN.hi) px(x0 + 9, yt + 2, WIN.hi)
  px(x0 + 3, y - rh + 3, P.cream) px(x0 + 4, y - rh + 2, P.cream)
  return { x0 = x0, x1 = x1, yt = yt, d = d, rh = rh, y = y, F = F }
end

local function rainChain(g)
  local cx = g.x0 - 2
  local cup = c:rect(cx - 1, g.yt, cx + 1, g.yt + 1)
  local tub = c:rect(cx - 4, g.y - 3, cx + 1, g.y + 1)
  local chain = c:rect(cx, g.yt + 2, cx, g.y - 4)
  ink(cup, tub, chain)
  c:fillMask(chain, P.stone.base)
  for yy = g.yt + 2, g.y - 4 do px(cx, yy, ((yy - g.yt) % 2 == 0) and P.stone.hi or P.stone.shade) end
  c:part(cup, "stone", { band = 1, nopop = true })
  c:part(tub, "wood", { band = 1, pop = { x = cx - 3, y = g.y - 3, horizontal = true } })
  R(cx - 3, g.y - 3, cx, g.y - 3, P.sea.base); px(cx - 3, g.y - 3, P.sea.hi)
end
local function vines(g)
  local x0, y = g.x0, g.y
  local path = {}
  local xx = x0 + 1
  for yy = y - 1, g.yt - 2, -1 do path[#path + 1] = { xx, yy }; if (y - yy) % 3 == 0 then xx = x0 + 1 + (((y - yy) // 3) % 2) * 2 end end
  for i, p in ipairs(path) do
    px(p[1], p[2], P.moss.shade)
    if i % 3 == 0 then px(p[1] + 1, p[2], P.moss.base); px(p[1] - 1, p[2], P.moss.hi) end
    if i % 5 == 2 then px(p[1] + 2, p[2] - 1, P.petal.base); px(p[1] + 2, p[2], P.cream) end
  end
  for xx2 = x0 + 2, x0 + 9 do px(xx2, g.yt + 1 + ((xx2 // 2) % 2), P.moss.shade); if xx2 % 3 == 0 then px(xx2, g.yt + 2 + ((xx2 // 2) % 2), P.moss.base) end end
  px(x0 + 6, g.yt - 0, P.petal.base); px(x0 + 8, g.yt + 3, P.cream)
end
local function lantern(g, cxr)
  local ry = g.y - g.rh
  local body = c:rect(cxr - 3, ry - 4, cxr + 3, ry + 1)
  local cap = c:poly{ { cxr - 4, ry - 5 }, { cxr + 4, ry - 5 }, { cxr + 1, ry - 8 }, { cxr - 1, ry - 8 } }
  local fin = c:rect(cxr, ry - 11, cxr, ry - 9)
  ink(body, cap, fin)
  c:fillMask(body, GR.base)
  R(cxr - 3, ry - 4, cxr + 3, ry - 4, P.cream); R(cxr - 3, ry + 1, cxr + 3, ry + 1, P.cream)
  R(cxr - 3, ry - 4, cxr - 3, ry + 1, P.cream); R(cxr + 3, ry - 4, cxr + 3, ry + 1, P.cream); R(cxr, ry - 3, cxr, ry, P.cream)
  R(cxr + 1, ry - 3, cxr + 2, ry, WIN.shade); R(cxr - 2, ry - 3, cxr - 1, ry, P.gold.hi); px(cxr - 2, ry - 3, P.cream)
  c:part(cap, "dusk", { band = 1, pop = { x = cxr - 3, y = ry - 5, horizontal = true } })
  c:fillMask(fin, P.gold.base); px(cxr, ry - 11, P.gold.hi)
end

---------------------------------------------------------------- the sign: leaf-shaped board on a stake
local function leafMask(cx, cy)
  local m = HP.mask()
  for dx = -15, 15 do
    local u = math.abs(dx) / 15.5
    local h = floor(8.5 * math.sqrt(math.max(0, 1 - u * u)) + .5)
    if math.abs(dx) >= 13 then h = math.min(h, 3 - (math.abs(dx) - 13)) end
    for dy = -h, h do m:set(cx + dx, cy + dy) end
  end
  m:set(cx + 16, cy - 1):set(cx + 17, cy - 2):set(cx + 16, cy)   -- pointed tip
  return m
end
local function icon(x, y)   -- tiny glasshouse, 7x5, top-left (x,y)
  R(x, y + 1, x + 6, y + 4, P.sky.base)
  R(x + 1, y, x + 5, y, P.sky.base); R(x + 2, y - 1, x + 4, y - 1, P.sky.base)
  R(x + 3, y - 1, x + 3, y + 4, P.cream); R(x, y + 2, x + 6, y + 2, P.cream)
  R(x, y + 4, x + 6, y + 4, P.stone.shade)
  px(x + 1, y + 3, P.moss.base); px(x + 5, y + 3, P.moss.base); px(x + 5, y + 2, P.moss.base)
  px(x + 2, y, P.cream)
end
local function leafSign(dx)
  local cx, cy = 36 + dx, 22
  local m = leafMask(cx, cy)
  local stem = c:rect(cx, cy + 9, cx, cy + 11)
  ink(m, stem)
  c:fillMask(stem, P.wood.base)
  c:fillMask(m, P.moss.hi)
  m:each(function(x, y) if not m:has(x + 1, y) or not m:has(x, y + 1) or (x - cx) + (y - cy) > 17 then px(x, y, P.moss.base) end end)
  m:each(function(x, y) if (x - cx) + (y - cy) > 21 or (not m:has(x, y + 1) and (x - cx) > 0) then px(x, y, P.moss.shade) end end)
  px(cx - 12, cy - 3, P.cream); px(cx - 11, cy - 4, P.cream); px(cx - 10, cy - 5, P.cream)
  icon(cx - 3, cy - 5)
  word(cx - 9, cy + 2, "BUILD", P.ink)
end

---------------------------------------------------------------- pieces
local function leafBit(x, y, f)
  local m = pt{ { x, y }, { x + 1, y }, { x + 2, y - 1 }, { x + 1, y + 1 } }
  c:rim(m, P.ink); c:fillMask(m, P.moss.base); px(x, y, P.moss.hi)
end
local LEAFPATH = { { 8, 36 }, { 24, 33 }, { 42, 36 }, { 60, 40 } }
local function drawEmpty(k)
  newc()
  plot(10, 41, 62, 59, 5)
  for _, p in ipairs{ { 18, 50 }, { 29, 56 }, { 41, 45 }, { 52, 52 }, { 24, 44 }, { 57, 47 } } do px(p[1], p[2], DIRT.deep); px(p[1] + 1, p[2], DIRT.shade) end
  -- string line round the footprint, corner stakes on top
  R(15, 45, 57, 45, P.cream); R(13, 57, 59, 57, P.cream)
  line(15, 45, 13, 57, P.cream); line(57, 45, 59, 57, P.cream)
  stake(15, 40, 46); stake(57, 40, 46); stake(13, 51, 58); stake(59, 51, 58)
  px(15, 45, P.cream); px(57, 45, P.cream); px(13, 57, P.cream); px(59, 57, P.cream)
  -- seedling sprouts, stones, a stack of glass panes
  for _, p in ipairs{ { 22, 53 }, { 30, 52 }, { 46, 55 } } do
    local m = pt{ { p[1], p[2] }, { p[1], p[2] - 1 }, { p[1] - 1, p[2] - 2 }, { p[1] + 1, p[2] - 2 } }
    c:rim(m, P.ink); c:fillMask(m, P.moss.base); px(p[1], p[2], P.moss.shade); px(p[1] - 1, p[2] - 2, P.moss.hi)
  end
  stoneAt(18, 47); stoneAt(40, 54); stoneAt(50, 50)
  flowerAt(24, 48, P.petal.base); flowerAt(35, 55, P.gold.base)
  local pane = c:poly{ { 46, 53 }, { 54, 53 }, { 56, 48 }, { 48, 48 } }
  ink(pane); c:fillMask(pane, P.sky.base); R(47, 52, 54, 52, P.sea.shade); px(49, 49, P.cream); px(50, 50, P.cream)
  line(48, 48, 56, 48, P.cream)
  -- sign swaying
  local dx = ({ 0, 1, 1, 0 })[k]
  stake(36, 32, 45)
  leafSign(dx)
  -- leaf blowing past
  local p = LEAFPATH[k]; leafBit(p[1], p[2])
  return c
end

local L1 = {}
local function drawL1(o)
  newc()
  o = o or {}
  greenhouse(AX, AY, o)
  return c
end
local function drawL2()
  newc()
  local g = greenhouse(AX, AY, { wl = 14, wr = 10, hh = 14, rh = 25 })
  vent(AX - 3, AY - 25 + 3, 2, true)
  rainChain(g)
  sprouts(g.x0 + 3, AY, 8, true); sprouts(g.x0 + 14, AY, 8, true)
  return c
end
local function drawL3()
  newc()
  local g = greenhouse(AX, AY, { wl = 17, wr = 13, hh = 16, rh = 26 })
  vent(AX - 8, AY - 26 + 3, 2, true)
  rainChain(g)
  lantern(g, AX + 3)
  vines(g)
  sprouts(g.x0 + 3, AY, 8, true); sprouts(g.x0 + 12, AY, 8, true)
  bench(g.x1 - 9, AY - 3)
  return c
end
local SPARK = { { 28, 39 }, { 40, 42 }, { 22, 47 }, { 46, 45 } }
local function drawReady(k)
  newc()
  local glow = ({ { true, false, true, false }, { false, true, false, true }, { true, false, true, false }, { false, true, false, true } })[k]
  local g = greenhouse(AX, AY, { ripe = true, glow = glow })
  local lift = ({ 0, 1, 2, 1 })[k]
  vent(AX - 3, AY - 22 + 3, lift, true)
  local s = SPARK[k]; c:sparkle(s[1], s[2])
  badge(BOB[k])
  return c
end

local function readyLevel(lv, k)
  newc()
  local glow = ({ { true, false, true, false, true }, { false, true, false, true, false }, { true, false, true, false, true }, { false, true, false, true, false } })[k]
  local lift = ({ 1, 2, 3, 2 })[k]
  local g
  if lv == 2 then
    g = greenhouse(AX, AY, { wl = 14, wr = 10, hh = 14, rh = 25, ripe = true, glow = glow })
    vent(AX - 3, AY - 25 + 3, lift, true)
    rainChain(g)
    sprouts(g.x0 + 3, AY, 8, true); sprouts(g.x0 + 14, AY, 8, true)
    local s = ({ { 24, 37 }, { 38, 40 }, { 30, 33 }, { 44, 38 } })[k]; c:sparkle(s[1], s[2])
    local t = ({ { g.x0 + 5, AY - 5 }, { g.x0 + 16, AY - 5 }, { g.x0 + 6, AY - 4 }, { g.x0 + 17, AY - 4 } })[k]; c:sparkle(t[1], t[2])
  else
    g = greenhouse(AX, AY, { wl = 17, wr = 13, hh = 16, rh = 26, ripe = true, glow = glow })
    vent(AX - 8, AY - 26 + 3, lift, true)
    rainChain(g)
    lantern(g, AX + 3)
    vines(g)
    sprouts(g.x0 + 3, AY, 8, true); sprouts(g.x0 + 12, AY, 8, true)
    bench(g.x1 - 9, AY - 3)
    local s = ({ { 24, 36 }, { 40, 39 }, { 32, 33 }, { 46, 36 } })[k]; c:sparkle(s[1], s[2])
    local t = ({ { g.x0 + 5, AY - 5 }, { g.x0 + 14, AY - 5 }, { g.x0 + 6, AY - 4 }, { g.x0 + 15, AY - 4 } })[k]; c:sparkle(t[1], t[2])
    if k % 2 == 1 then px(AX + 3, AY - 26 - 2, P.cream) else px(AX + 2, AY - 26 - 2, P.cream) end
  end
  badge(BOB[k])
  return c
end
for lv = 2, 3 do
  local f = {} for k = 1, 4 do f[k] = readyLevel(lv, k) end
  saveStrip(f, NAME .. "-ready-l" .. lv, "ready")
end
