local W,H,NAME = 64,64,"tailor"
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
local AX, AY = 32, 54

local function dressForm(wx, wy)   -- inside a 5x6 glowing window at (wx,wy)
  px(wx + 2, wy, P.cream)
  R(wx + 1, wy + 1, wx + 3, wy + 3, P.petal.base); px(wx + 1, wy + 1, P.petal.hi); R(wx + 3, wy + 3, wx + 3, wy + 3, P.petal.shade)
  px(wx + 2, wy + 2, P.cream)
  px(wx + 2, wy + 4, P.wood.shade); R(wx + 1, wy + 5, wx + 3, wy + 5, P.wood.shade)
end
local function spoolSmall(x, y)
  R(x - 1, y - 1, x + 1, y + 1, P.petal.base); R(x - 1, y - 2, x + 1, y - 2, P.wood.hi); R(x - 1, y + 2, x + 1, y + 2, P.wood.shade); px(x - 1, y - 1, P.petal.hi)
end
local function bunting(x0, x1, y)
  local cols = { P.petal.base, P.gold.base, P.cream, P.sea.base, P.petal.base, P.gold.base, P.cream, P.sea.base, P.petal.base, P.gold.base, P.cream, P.sea.base, P.petal.base }
  local n = 0
  for xx = x0, x1 do px(xx, y, P.wood.deep) end
  for xx = x0 + 1, x1 - 2, 4 do
    n = n + 1
    local col = cols[n]
    R(xx, y + 1, xx + 2, y + 1, col); R(xx, y + 2, xx + 2, y + 2, col); R(xx + 1, y + 3, xx + 1, y + 3, col)
    px(xx, y + 1, lerp(col, P.cream, .4))
    px(xx + 2, y + 2, lerp(col, DUSKSH, .3))
    px(xx - 1, y + 1, P.ink); px(xx + 3, y + 1, P.ink); px(xx - 1 + 0, y + 2, P.ink)
  end
end
local function dormer(x, y)
  local body = c:rect(x, y + 2, x + 4, y + 5)
  local roof = c:poly{ { x - 1, y + 2 }, { x + 5, y + 2 }, { x + 2, y - 1 } }
  ink(body, roof)
  c:fillMask(body, P.dusk.base); R(x + 4, y + 2, x + 4, y + 5, P.dusk.shade)
  c:fillMask(roof, P.gold.shade); R(x - 1, y + 2, x + 5, y + 2, P.gold.deep); px(x + 1, y, P.gold.base); px(x + 2, y, P.gold.hi)
  R(x + 1, y + 3, x + 3, y + 4, P.gold.hi); px(x + 1, y + 3, P.cream); R(x + 2, y + 3, x + 2, y + 4, P.cream)
end
local function lanternHang(x, y)   -- bracket + lit lantern, (x,y) = top of the chain
  local ch = c:rect(x, y, x, y + 1)
  local cap = c:rect(x - 1, y + 2, x + 1, y + 2)
  local body = c:rect(x - 1, y + 3, x + 1, y + 6)
  ink(ch, cap, body)
  c:fillMask(ch, P.stone.shade); c:fillMask(cap, P.wood.deep)
  c:fillMask(body, P.gold.hi); px(x, y + 4, P.cream); R(x + 1, y + 3, x + 1, y + 6, P.gold.base); R(x - 1, y + 6, x + 1, y + 6, P.wood.deep)
end
local function stitchRow(x0, x1, y, col)
  for xx = x0, x1 do if (xx - x0) % 3 ~= 2 then px(xx, y, col) end end
end

local function tailor(x, y, o)
  o = o or {}
  local hl, hr, hh, rh = o.hl or 11, o.hr or 9, o.hh or 14, o.rh or 24
  local x0, x1, yt, d = x - hl, x + hr, y - hh, 4
  cast(x0, x1, y, d, 10, 4)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - rh, 3, 8, d)
  ink(front, side, F, S)
  local Wt = wallTones(P.dusk.base, P.dusk.hi)
  paintWalls(front, side, Wt, 4)
  side:each(function(xx, yy) if (xx - x1) % 2 == 0 then px(xx, yy, Wt.sdark) end end)
  paintRoof(F, S, THATCH, { tex = false })
  local fx0, fy0, fx1, fy1 = F:bbox()
  for yy = fy0 + 2, fy1 - 1, 3 do
    for xx = fx0, fx1 do
      if F:has(xx, yy) and F:has(xx - 1, yy) and F:has(xx + 1, yy) then
        if (xx + yy) % 4 ~= 0 then dk(xx, yy, THATCH) end
        if (xx + yy) % 4 == 2 then lt(xx, yy - 1, THATCH) end
      end
    end
  end
  eaveShadow(x0, x1, yt, d, Wt, 1)
  plinth(x0, x1, y, d, 2)
  door(x - 3, x + 1, y - 9, y, { frame = P.wood.deep, arch = 2 })
  if o.form then
    window(x0 + 2, y - hh + 4, 5, 6, { frame = P.cream, sill = P.cream, sillsh = Wt.eave, nobar = true, glow = true })
    dressForm(x0 + 2, y - hh + 4)
  else
    window(x0 + 2, y - 11, 3, 4, { frame = P.cream, sill = P.cream, sillsh = Wt.eave, nobar = true, glass = o.lit and P.gold.hi or nil })
  end
  window(x + 4, y - 10, 3, 3, { frame = P.cream, sill = P.cream, sillsh = Wt.eave, nobar = true })
  for xx = x + 3, x + 8 do local col = ((xx - x) % 2 == 0) and P.petal.base or P.cream; R(xx, y - 13, xx, y - 12, col) end
  for xx = x + 3, x + 8, 2 do px(xx, y - 11, P.petal.shade) end
  R(x + 3, y - 13, x + 8, y - 13, P.petal.hi)
  if o.stitch then stitchRow(x0 + 1, x1 - 1, yt + 2, P.gold.hi); stitchRow(x0 + 1, x1 - 1, y - 3, P.gold.base) end
  if o.board then
    -- bigger sign-board nailed to the thatch with a gold spool
    local bx, by = x + 1, y - rh + 4
    local b = c:rect(bx, by, bx + 9, by + 6)
    ink(b)
    c:part(b, "wood", { band = 1, pop = { x = bx + 1, y = by, horizontal = true } })
    R(bx + 1, by + 1, bx + 8, by + 5, P.wood.hi); R(bx + 1, by + 5, bx + 8, by + 5, P.wood.base)
    local sp = c:rect(bx + 3, by + 1, bx + 6, by + 5)
    R(bx + 3, by + 1, bx + 6, by + 1, P.gold.hi); R(bx + 3, by + 5, bx + 6, by + 5, P.gold.shade)
    R(bx + 4, by + 2, bx + 5, by + 4, P.gold.base); px(bx + 4, by + 2, P.cream); px(bx + 5, by + 3, P.petal.base); px(bx + 5, by + 4, P.petal.base)
    px(bx + 7, by + 3, P.petal.base); px(bx + 8, by + 4, P.petal.base)
    px(bx, by, P.ink); px(bx + 9, by, P.ink)
  else
    spoolSmall(x, y - 20)
  end
  return { x0 = x0, x1 = x1, yt = yt, d = d, y = y, rh = rh }
end

local function clothesline(g, sag)
  local px0 = AX - 22
  local post = c:rect(px0, g.y - 14, px0, g.y)
  ink(post); c:fillMask(post, P.wood.base); px(px0, g.y - 14, P.wood.hi); R(px0, g.y - 6, px0, g.y, P.wood.shade)
  local ly = g.y - 13
  for xx = px0 + 1, g.x0 - 1 do
    local t = (xx - px0) / (g.x0 - px0)
    px(xx, ly + floor(math.sin(t * math.pi) * (sag or 1.4) + .5), P.cream)
  end
  px(g.x0 - 1, ly, P.stone.shade)
  return ly
end
local function shirt(x, y, col)  -- top-left; 5 wide 5 tall with sleeves
  local m = c:rect(x, y, x + 4, y + 1):add(c:rect(x + 1, y + 2, x + 3, y + 4))
  c:rim(m, P.ink); c:fillMask(m, col); R(x + 3, y + 2, x + 3, y + 4, lerp(col, DUSKSH, .3)); px(x, y, lerp(col, P.cream, .5)); px(x + 2, y, lerp(col, DUSKSH, .3))
  px(x + 1, y - 1, P.wood.hi)
end
local function sock(x, y)
  local m = pt{ { x, y }, { x + 1, y }, { x, y + 1 }, { x + 1, y + 1 }, { x, y + 2 }, { x + 1, y + 2 }, { x, y + 3 }, { x + 1, y + 3 }, { x + 2, y + 3 }, { x + 2, y + 4 }, { x + 1, y + 4 } }
  c:rim(m, P.ink); c:fillMask(m, P.sea.base); R(x, y, x + 1, y, P.cream); R(x, y + 2, x + 1, y + 2, P.cream); px(x + 2, y + 4, P.sea.shade)
  px(x, y - 1, P.wood.hi)
end

---------------------------------------------------------------- sign: hanging tag board on a pole, needle
local function cottageIcon(x, y)   -- 7x5
  R(x + 2, y, x + 4, y, P.gold.base); R(x + 1, y + 1, x + 5, y + 1, P.gold.base); R(x, y + 1, x + 6, y + 1, P.gold.shade)
  R(x + 1, y + 2, x + 5, y + 4, P.dusk.base); R(x + 3, y + 3, x + 3, y + 4, P.wood.deep); px(x + 1, y + 3, P.cream)
  px(x + 3, y, P.gold.hi); px(x + 5, y + 3, P.dusk.shade)
end
local function tagSign(k)
  local dx = ({ 0, 1, 1, 0 })[k]
  local thr = ({ 0, 1, 2, 1 })[k]
  -- pole and arm
  local pole = c:rect(8, 16, 8, 47)
  local arm = c:rect(8, 15, 38, 16)
  ink(pole, arm)
  c:part(pole, "wood", { band = 1, nopop = true })
  c:part(arm, "wood", { band = 1, pop = { x = 10, y = 15, horizontal = true } })
  -- board
  local bx, by = 12 + dx, 21
  local b = c:rect(bx, by, bx + 22, by + 14)
  -- threads
  line(14, 17, 14 + dx, 20, P.cream); line(32, 17, 32 + dx, 20, P.cream)
  ink(b)
  c:fillMask(b, P.wood.hi)
  R(bx, by + 13, bx + 22, by + 14, P.wood.base); R(bx + 21, by, bx + 22, by + 14, P.wood.base)
  R(bx, by, bx, by + 14, P.cream); R(bx, by, bx + 22, by, P.cream)
  px(bx + 2, by + 1, P.wood.deep); px(bx + 20, by + 1, P.wood.deep)
  cottageIcon(bx + 8, by + 2)
  word(bx + 2, by + 8, "BUILD", P.ink)
  -- needle through the arm end, thread dangling
  local nx = 37
  R(nx, 12, nx, 21, P.stone.hi); px(nx, 21, P.stone.base)
  c:rim(c:rect(nx, 12, nx, 21), P.ink); px(nx, 21, P.stone.base)
  px(nx, 12, P.ink); px(nx, 13, P.stone.shade)
  px(nx, 12, P.ink)
  local sw = ({ 0, 1, 1, 0 })[k]
  for i = 0, 8 do px(nx + 1 + ((i // 3 + sw) % 2), 13 + i, P.petal.base) end
  px(nx + 1 + sw % 2, 22 + 0, P.petal.hi)
end
local function bird(x, y)   -- sparrow facing left, top-left (x,y), 6x4
  local body = c:rect(x + 1, y + 1, x + 5, y + 3):add(c:rect(x, y, x + 2, y + 1))
  local tail = pt{ { x + 6, y + 2 }, { x + 7, y + 1 } }
  ink(body, tail)
  c:fillMask(body, P.wood.base); R(x + 3, y + 1, x + 5, y + 2, P.wood.shade); R(x + 1, y + 3, x + 4, y + 3, P.cream)
  c:fillMask(tail, P.wood.shade); px(x, y, P.wood.hi); px(x + 1, y, P.wood.hi)
  px(x - 1, y + 1, P.gold.base); px(x + 1, y + 1, P.ink)
  px(x + 1, y + 4, P.ink); px(x + 4, y + 4, P.ink)
end
local function drawEmpty(k)
  newc()
  plot(10, 42, 54, 59, 5)
  for _, p in ipairs{ { 20, 52 }, { 30, 56 }, { 44, 47 }, { 38, 53 }, { 17, 47 } } do px(p[1], p[2], DIRT.deep); px(p[1] + 1, p[2], DIRT.shade) end
  R(15, 46, 49, 46, P.cream); R(13, 58, 51, 58, P.cream)
  line(15, 46, 13, 58, P.cream); line(49, 46, 51, 58, P.cream)
  stake(15, 41, 47); stake(49, 41, 47); stake(13, 52, 59); stake(51, 52, 59)
  px(15, 46, P.cream); px(49, 46, P.cream); px(13, 58, P.cream); px(51, 58, P.cream)
  -- buttons, pincushion, stones
  for _, p in ipairs{ { 22, 54 }, { 47, 56 } } do
    local m = E(p[1], p[2], 1, 1); c:rim(m, P.ink); c:fillMask(m, P.gold.base); px(p[1] - 1, p[2] - 1, P.gold.hi); px(p[1], p[2], P.ink); px(p[1] + 1, p[2] + 1, P.gold.shade)
  end
  local cush = E(28, 50, 2, 1); c:rim(cush, P.ink); c:fillMask(cush, P.petal.base); px(27, 49, P.petal.hi); px(30, 51, P.petal.shade)
  px(29, 47, P.cream); px(29, 48, P.stone.hi)
  stoneAt(33, 56); stoneAt(18, 49)
  flowerAt(42, 55, P.dusk.hi); flowerAt(24, 56, P.petal.base)
  tagSign(k)
  local hp = ({ { 34, 50 }, { 37, 48 }, { 40, 50 }, { 43, 48 } })[k]
  bird(hp[1], hp[2])
  return c
end

local function drawL1() newc(); tailor(AX, AY, {}); return c end
local function drawL2()
  newc()
  local g = tailor(AX, AY, { hl = 12, hr = 10, hh = 15, rh = 26, form = true, stitch = true })
  local ly = clothesline(g, 1.4)
  shirt(AX - 21, ly + 1, P.petal.base)
  sock(AX - 15, ly + 1)
  return c
end
local function drawL3()
  newc()
  local g = tailor(AX, AY, { hl = 14, hr = 12, hh = 16, rh = 28, form = true, stitch = true, board = true })
  local ly = clothesline(g, 1.4)
  shirt(AX - 21, ly + 1, P.petal.base)
  sock(AX - 15, ly + 1)
  dormer(g.x0 + 5, AY - 28 + 5)
  bunting(g.x0, g.x1, g.yt + 1)
  lanternHang(g.x1 - 1, g.yt + 5)
  return c
end

local function scarf(x, y, amp, k)
  local m = HP.mask()
  local offs = {}
  for r = 0, 9 do
    local off = (r < 3) and 0 or (r < 6 and floor(amp * .5) or amp)
    offs[r] = off
    for xx = x + off, x + off + 3 do m:set(xx, y + r) end
  end
  for i = 0, 3, 2 do m:set(x + amp + i, y + 10) end
  c:rim(m, P.ink)
  for r = 0, 9 do
    local col = (r % 3 == 2) and P.cream or P.petal.base
    local off = offs[r]
    R(x + off, y + r, x + off + 3, y + r, col)
    px(x + off + 3, y + r, lerp(col, DUSKSH, .3))
  end
  px(x, y, P.petal.hi); px(x + 1, y + 3, P.petal.hi)
  px(x + amp, y + 10, P.cream); px(x + amp + 2, y + 10, P.cream)
end
local function drawReady(k)
  newc()
  local g = tailor(AX, AY, { lit = true })
  local ly = clothesline(g, 1.4)
  local amp = ({ 0, 1, 0, -1 })[k]
  scarf(AX - 19, ly + 1, amp, k)
  -- needle on the left stitching the hem, gold thread glints
  local stitch = ({ 0, 1, 2, 1 })[k]
  local nx, ny = AX - 28 + stitch, AY - 7 - stitch
  local n = pt{ { nx, ny }, { nx + 1, ny - 1 }, { nx + 2, ny - 2 }, { nx + 3, ny - 3 }, { nx + 4, ny - 4 } }
  c:rim(n, P.ink); c:fillMask(n, P.stone.hi); px(nx, ny, P.stone.shade)
  px(nx + 4, ny - 4, P.cream)
  for i = 0, 5 do px(nx - 1 - i, ny + 1 + (i % 2), P.gold.base) end
  px(nx - 2 - k, ny + 1 + (k % 2), P.cream)
  c:sparkle(AX - 11 + ({ 0, 3, 6, 3 })[k], AY - 30 + ({ 0, -2, 0, 2 })[k])
  px(AX - 23, AY - 1, P.gold.hi)
  badge(BOB[k])
  return c
end

save(drawL1(), NAME .. "-l1")
save(drawL2(), NAME .. "-l2")
save(drawL3(), NAME .. "-l3")
local ef = {} for k = 1, 4 do ef[k] = drawEmpty(k) end
saveStrip(ef, NAME .. "-empty", "empty")
local rf = {} for k = 1, 4 do rf[k] = drawReady(k) end
saveStrip(rf, NAME .. "-ready", "ready")
