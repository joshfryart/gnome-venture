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
local W, H = 56, 56
local function newc() c = HP.canvas{ w = W, h = H, scale = 1, name = "rain_barrel" } return c end
local function shadow(cx, rx) c:groundShadow(cx + 3, 47, rx, 2) end

local function barrel(cx, yb, rx, h, o)
  o = o or {}
  local b = c:rrect(cx - rx, yb - h + 1, cx + rx, yb, 2)
  local top = E(cx, yb - h, rx, 2)
  local tap
  if o.tap then
    local tx, ty = o.tap[1], o.tap[2]
    tap = c:rect(tx, ty, tx + 2, ty + 1):add(c:rect(tx + 2, ty + 2, tx + 2, ty + 3))
  end
  local all = HP.mask():add(b):add(top)
  if tap then all:add(tap) end
  c:rim(all, P.ink)
  cyl(b, cx, rx, P.wood)
  local inner = b:shrink(1)
  for _, f in ipairs{ -.55, .1, .6 } do
    local xx = cx + floor(rx * f + .5)
    for yy = yb - h + 3, yb - 1 do if inner:has(xx, yy) then dk(xx, yy, "wood") end end
  end
  for _, hy in ipairs(o.hoops or { yb - h + 4, yb - 4 }) do
    local hm = c:rect(cx - rx, hy, cx + rx, hy + 1):clip(b)
    cyl(hm, cx, rx, P.stone, { t1 = .7 })
    R(cx - rx + 1, hy + 1, cx + rx - 1, hy + 1, P.stone.deep)
    px(cx - floor(rx / 2), hy, P.cream)
  end
  px(cx - floor(rx * .6), yb - floor(h / 2) + 1, P.cream)
  -- water top
  c:fillMask(top, P.sea.base)
  top:each(function(x, y)
    if not top:has(x, y - 1) then px(x, y, P.wood.hi) elseif not top:has(x, y + 1) then px(x, y, P.wood.shade) end
  end)
  px(cx - 2, yb - h, P.sea.hi); px(cx - 1, yb - h, P.cream)
  if tap then
    local tx, ty = o.tap[1], o.tap[2]
    c:fillMask(tap, P.stone.shade); px(tx, ty, P.stone.hi); px(tx + 1, ty, P.stone.base)
    px(tx + 2, ty + 3, P.stone.base)
  end
  return b, top
end

local function puddle(x, y, rx)
  local m = E(x, y, rx, 1)
  c:fillMask(m, P.sea.shade)
  px(x - 1, y, P.sea.hi)
end
-------------------------------------------------------------- level 1
local function drawL1(ready, k)
  newc()
  shadow(28, 10)
  puddle(39, 47, 3)
  if ready and (k == 3) then px(40, 47, P.sea.hi); px(37, 47, P.sea.hi) end
  local b, top = barrel(28, 46, 8, 18, { tap = { 37, 39 } })
  return b, top
end

-------------------------------------------------------------- level 2
local function drawL2()
  newc()
  shadow(28, 13)
  puddle(42, 47, 3)
  -- barrel B (right, a little smaller, carries the tap), barrel A (left, fed by the gutter)
  barrel(34, 46, 5, 16, { tap = { 40, 41 }, hoops = { 35, 42 } })
  barrel(22, 46, 5, 18, { hoops = { 33, 42 } })
  -- iron link pipe between the barrels, low down
  local pipe = c:rect(26, 40, 30, 43)
  c:rim(pipe, P.ink)
  c:fillMask(pipe, P.stone.base); R(26, 40, 30, 40, P.stone.hi); R(26, 43, 30, 43, P.stone.shade)
  R(26, 39, 26, 44, P.stone.shade); R(30, 39, 30, 44, P.stone.shade)
  px(26, 39, P.stone.hi); px(30, 39, P.stone.hi)
  c:fillMask(c:rect(26, 39, 26, 44), P.stone.shade); c:fillMask(c:rect(30, 39, 30, 44), P.stone.shade)
  px(26, 39, P.stone.base); px(30, 39, P.stone.base)
  R(27, 41, 29, 42, P.stone.hi)
  -- gutter trough on a bracket post, spilling into barrel A
  local post = c:rect(15, 26, 15, 46)
  local gut = c:line({ { 15, 22 }, { 21, 26 } }, 2)
  local lip = c:rect(14, 21, 15, 22)
  ink(post, gut, lip)
  c:part(post, "wood", { band = 1, nopop = true })
  c:fillMask(gut, P.stone.base); c:fillMask(lip, P.stone.base)
  gut:each(function(x, y) if not gut:has(x, y - 1) then px(x, y, P.stone.hi) elseif not gut:has(x, y + 1) then px(x, y, P.stone.shade) end end)
  px(14, 21, P.stone.hi)
  R(21, 27, 21, 29, P.sea.hi); R(22, 28, 22, 29, P.sea.base)
  px(16, 38, P.wood.hi)
  return c
end

-------------------------------------------------------------- level 3
local function drawL3()
  newc()
  shadow(29, 14)
  local cx, yb = 28, 46
  -- right post and downpipe first (behind the barrel)
  local rp = c:rect(40, 23, 41, 46)
  local dp = c:rect(15, 23, 16, 32):add(c:rect(17, 31, 18, 32))
  ink(rp, dp)
  c:part(rp, "wood", { band = 1, nopop = true })
  c:fillMask(dp, P.stone.base)
  dp:each(function(x, y) if x == 15 then px(x, y, P.stone.hi) elseif x == 16 and y < 31 then px(x, y, P.stone.shade) end end)
  R(17, 31, 18, 31, P.stone.hi); R(17, 32, 18, 32, P.stone.shade)
  R(15, 28, 16, 28, P.stone.shade)
  barrel(cx, yb, 10, 20, { hoops = { 30, 36, 43 } })
  -- front tap, water drips into the bucket
  local tp = c:rect(32, 37, 34, 38):add(c:rect(34, 39, 34, 40))
  c:rim(tp, P.ink); c:fillMask(tp, P.stone.shade); px(32, 37, P.stone.hi); px(33, 37, P.stone.base)
  px(34, 41, P.sea.hi)
  -- bucket
  local bk = c:rrect(29, 42, 37, 46, 1)
  c:rim(bk, P.ink)
  cyl(bk, 33, 4, P.wood, { t1 = .7 })
  R(29, 44, 37, 44, P.stone.shade); px(31, 44, P.stone.hi)
  R(29, 42, 37, 42, P.sea.base); px(32, 42, P.sea.hi)
  -- rain gauge on the right post
  local tube = c:rect(42, 27, 43, 37)
  local cap = c:rect(41, 25, 44, 26)
  c:rim(HP.mask():add(tube):add(cap), P.ink)
  c:fillMask(tube, P.sky.hi); c:fillMask(c:rect(42, 31, 43, 37), P.sea.base)
  px(42, 31, P.sea.hi); px(43, 27, P.sky.base)
  for _, yy in ipairs{ 28, 30, 32, 34, 36 } do px(41, yy, P.stone.deep) end
  c:fillMask(cap, P.gold.base); R(41, 25, 44, 25, P.gold.hi); R(43, 26, 44, 26, P.gold.shade)
  -- the little roof
  local F = c:poly{ { 14, 23 }, { 20, 16 }, { 34, 16 }, { 40, 23 } }
  local S = c:poly{ { 40, 23 }, { 34, 16 }, { 37, 16 }, { 43, 21 } }:cut(F)
  c:rim(HP.mask():add(F):add(S), P.ink)
  c:fillMask(F, ROOF.base); c:fillMask(S, ROOF.shade)
  for y = 18, 22, 2 do F:each(function(x, yy) if yy == y and (x + y) % 5 ~= 0 then dk(x, yy, ROOF) end end) end
  F:each(function(x, y) if not F:has(x, y - 1) then px(x, y, ROOF.hi) elseif not F:has(x - 1, y) then px(x, y, lerp(ROOF.hi, ROOF.base, .35)) end end)
  F:each(function(x, y) if not F:has(x, y + 1) then px(x, y, lerp(ROOF.shade, ROOF.deep, .4)) end end)
  S:each(function(x, y) if not S:has(x, y + 1) and not F:has(x, y + 1) then px(x, y, ROOF.deep) end end)
  R(14, 23, 40, 23, ROOF.deep); px(14, 23, ROOF.shade)
  return c
end

-------------------------------------------------------------- ready
local function lid(cx, topy, rx, dx, dy, kx)
  local l = E(cx + dx, topy + dy, rx, 2)
  local knob = c:rect(kx + dx, topy - 3 + dy, kx + 1 + dx, topy - 2 + dy)
  c:rim(HP.mask():add(l):add(knob), P.ink)
  c:part(l, "wood", { band = 1, nopop = true })
  px(cx - rx + 2 + dx, topy - 1 + dy, P.wood.hi); px(cx - rx + 3 + dx, topy - 1 + dy, P.wood.hi)
  c:part(knob, "wood", { band = 1, nopop = true })
  if dy < 0 then R(cx - rx + 1 + dx, topy + 3 + dy, cx + rx - 1 + dx, topy + 3 + dy, P.sea.shade) end
end
local function drop2(x, y, a, b)
  px(x, y, a or P.sea.hi); px(x + 1, y, b or P.sea.hi); px(x, y + 1, b or P.sea.base); px(x + 1, y + 1, P.sea.shade)
end
local function drop1(x, y) px(x, y, P.sea.base); px(x, y + 1, P.sea.shade) end
local function spark(sx, sy)
  px(sx, sy - 2, P.sea.hi); px(sx, sy + 2, P.sea.hi); px(sx - 2, sy, P.sea.hi); px(sx + 2, sy, P.sea.hi)
  px(sx, sy - 1, P.sea.base); px(sx, sy + 1, P.sea.base); px(sx - 1, sy, P.sea.base); px(sx + 1, sy, P.sea.base)
  px(sx, sy - 3, P.sea.shade); px(sx, sy + 3, P.sea.shade); px(sx - 3, sy, P.sea.shade); px(sx + 3, sy, P.sea.shade)
  px(sx, sy, P.cream)
end
local ADY, ADX = { 0, -1, 0, -2 }, { 0, 1, -1, 0 }
local BDY, BDX = { -1, 0, -2, 0 }, { 1, 0, 0, -1 }
local SPL2 = { { 27, 26, 39, 27 }, { 26, 23, 40, 25 }, { 28, 25, 38, 24 }, { 27, 22, 41, 27 } }
local SPK2 = { { 9, 36 }, { 48, 33 }, { 9, 27 }, { 48, 40 } }
local function ready2(k)
  drawL2()
  lid(22, 28, 5, ADX[k], ADY[k], 23)
  lid(34, 30, 5, BDX[k], BDY[k], 33)
  -- tap drip
  if k == 1 then px(42, 45, P.sea.base) elseif k == 2 then px(42, 45, P.sea.base); px(42, 46, P.sea.hi)
  elseif k == 3 then px(40, 46, P.sea.hi); px(44, 46, P.sea.hi); px(41, 47, P.sea.hi); px(43, 47, P.sea.hi) else px(42, 45, P.sea.hi) end
  -- flung droplets
  local s = SPL2[k]
  drop2(s[1], s[2]); drop2(s[3], s[4])
  -- gutter water falling off the lip
  drop1(14 - (k % 2), 23 + k * 2)
  local p = SPK2[k]; spark(p[1], p[2])
  badge(51, 6 + BOB[k])
  return c
end
local DROP3 = { 33, 36, 39, 42 }
local SPK3 = { { 48, 32 }, { 9, 34 }, { 48, 41 }, { 9, 26 } }
local function ready3(k)
  drawL3()
  -- water pulse running down the downpipe, then dripping from its mouth
  local py = ({ 24, 26, 28, 30 })[k]
  px(15, py, P.sea.hi); px(16, py, P.sea.base); px(15, py + 1, P.sea.base)
  px(17, 32, P.sea.base); px(18, 32, P.sea.hi)
  local dy = DROP3[k] + 1
  if k < 4 then drop1(18, dy + 1) else px(17, 46, P.sea.hi); px(19, 46, P.sea.hi); px(18, 47, P.sea.hi) end
  if k == 1 then drop1(18, 34) end
  -- tap drip, splash and ripple in the bucket
  if k == 1 then px(34, 40, P.sea.hi)
  elseif k == 2 then px(34, 41, P.sea.base)
  elseif k == 3 then px(31, 40, P.sea.hi); px(37, 40, P.sea.hi); px(35, 39, P.sea.hi); px(30, 39, P.sea.base) end
  R(30 + k, 42, 31 + k, 42, P.sea.hi)
  -- water surface bubbling under the roof: droplets jump up
  local jx = ({ 22, 27, 32, 25 })[k]
  px(jx, 25, P.sea.hi); px(jx + 1, 24, P.sea.hi); px(jx + 4 - k, 25 - (k % 2), P.sea.base)
  R(20 + k * 3, 26, 21 + k * 3, 26, P.cream)
  -- eave drip
  drop1(38, 24 + k * 2)
  -- gauge glint
  px(43, 27 + (k % 2) * 4, P.cream)
  local p = SPK3[k]; spark(p[1], p[2])
  badge(51, 6 + BOB[k])
  return c
end

local function cat(a, b) end
local outdir = out
local l1 = {}
drawL1(false, 0); local base1 = c
local f2, f3 = {}, {}
for k = 1, 4 do f2[k] = ready2(k) end
saveStrip(f2, W, H, "rain_barrel-ready-l2", "ready")
for k = 1, 4 do f3[k] = ready3(k) end
saveStrip(f3, W, H, "rain_barrel-ready-l3", "ready")
