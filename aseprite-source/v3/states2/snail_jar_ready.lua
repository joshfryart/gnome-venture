-- snail_jar state sprites, 56x56, anchor (28,46). Hearth Pop v3. Run:
-- AppRun -b --script-param out=/tmp/ase/states2/snail_jar/ --script /tmp/ase/states2/snail_jar.lua
local W, H, NAME = 56, 56, "snail_jar"
local CX, FY = 28, 46
-- shared helpers (Hearth Pop v3)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out
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
local function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end
local function pt(list) local m = HP.mask() for _, q in ipairs(list) do m:set(q[1], q[2]) end return m end
local WIN = { hi = P.sky.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }
local SH, SH2 = "#6f8c7a", "#5b7868"   -- cool hard cast shadow on grass
local INTERIOR = "#3b2c48"
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
local function cast(cx, cy, rx, ry)   -- hard cool ellipse, darker contact row under it
  local m = E(cx, cy, rx, ry)
  c:fillMask(m, SH)
  m:each(function(x, y) if not m:has(x, y + 1) or not m:has(x - 1, y + 1) then px(x, y, SH2) end end)
  return m
end
-- 3x5 pixel font
local G = { B = { "11.", "1.1", "11.", "1.1", "11." }, U = { "1.1", "1.1", "1.1", "1.1", "111" }, I = { "111", ".1.", ".1.", ".1.", "111" },
  L = { "1..", "1..", "1..", "1..", "111" }, D = { "11.", "1.1", "1.1", "1.1", "11." } }
local function word(x, y, hex)   -- BUILD, 19 x 5, (x,y) = top-left
  for i, ch in ipairs{ "B", "U", "I", "L", "D" } do
    local g, ox = G[ch], x + (i - 1) * 4
    for r = 1, 5 do for k = 1, 3 do if g[r]:sub(k, k) == "1" then px(ox + k - 1, y + r - 1, hex) end end end
  end
end
local function sparkle(x, y)   -- gold-armed plus with a cream heart, readable on any ground
  px(x, y - 2, P.gold.base) px(x, y + 2, P.gold.base) px(x - 2, y, P.gold.base) px(x + 2, y, P.gold.base)
  px(x, y - 1, P.cream) px(x, y + 1, P.cream) px(x - 1, y, P.cream) px(x + 1, y, P.cream) px(x, y, P.cream)
end
local function mini(x, y) px(x, y, P.cream) px(x - 1, y, P.gold.base) px(x + 1, y, P.gold.base) px(x, y - 1, P.gold.base) px(x, y + 1, P.gold.base) end
local function badge(dy)   -- gold "!" badge in the top-right corner, 9 px across
  local cx, cy = W - 6, 6 + dy
  local disc = E(cx, cy, 4, 4)
  ink(disc)
  c:part(disc, "gold", { band = 2, pop = { x = cx - 2, y = cy - 3, horizontal = true } })
  R(cx, cy - 2, cx, cy + 1, P.cream); px(cx, cy + 3, P.cream)
  R(cx - 1, cy - 2, cx - 1, cy - 2, P.cream); R(cx + 1, cy - 2, cx + 1, cy - 2, P.cream)
end
local function stake(x, y0, y1) local m = c:rect(x, y0, x, y1); ink(m); c:part(m, "wood", { band = 1, nopop = true }); px(x, y0, P.wood.hi) end
local function string(x0, y0, x1, y1) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), P.cream) end
local function flower(x, y, col, ctr)
  local head = pt{ { x, y - 1 }, { x - 1, y }, { x, y }, { x + 1, y }, { x, y + 1 } }
  local stem = c:rect(x, y + 2, x, y + 3)
  c:rim(HP.mask():add(head):add(stem), P.ink)
  c:fillMask(stem, P.moss.base); c:fillMask(head, col or P.petal.base); px(x, y, ctr or P.gold.hi)
end
local function pebble(x, y)  -- 3x2 lit dome
  local m = c:rect(x, y, x + 2, y + 1); c:rim(m, P.ink); c:fillMask(m, P.stone.base); R(x, y, x + 1, y, P.stone.hi); px(x + 2, y + 1, P.stone.shade)
end
local function leafbit(x, y, big)   -- little flying leaf, top-left
  local m = big and pt{ { x + 1, y }, { x + 2, y }, { x, y + 1 }, { x + 1, y + 1 }, { x + 2, y + 1 }, { x + 3, y + 1 }, { x + 2, y + 2 } } or pt{ { x, y }, { x + 1, y }, { x + 1, y + 1 }, { x + 2, y + 1 } }
  c:rim(m, P.ink); c:fillMask(m, P.moss.base); px(x + (big and 1 or 0), y + (big and 0 or 0), P.moss.hi)
end
local function save(canvas, name)
  HP.report(canvas, true); HP.assertClean(canvas)
  canvas:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local function saveStrip(frames, name, tag)
  for _, f in ipairs(frames) do HP.assertClean(f) end
  HP.sheet{ cellw = W, cellh = H, frames = frames, tags = { { name = tag, from = 1, to = #frames } } }
    :save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local BODY = { hi = P.cream, base = "#f6dfae", shade = "#e8c48a", deep = P.wood.hi }

-- a snail: (x,y) = left foot corner on the ground row y, 11 wide. dir=1 faces right. w = stalk wiggle (0/1)
local SPIRAL = { { 0, 0 }, { 0, 1 }, { -1, 1 }, { -1, 0 }, { -1, -1 }, { 0, -2 }, { 1, -2 }, { 2, -1 }, { 2, 0 }, { 2, 1 }, { 1, 2 }, { 0, 2 } }
local function snail(x, y, dir, w)
  w = w or 0
  local function X(dx) return dir > 0 and x + dx or x + 10 - dx end
  local foot, neck, stalks = HP.mask(), HP.mask(), HP.mask()
  for dx = 0, 10 do foot:set(X(dx), y):set(X(dx), y - 1) end
  for dx = 8, 10 do neck:set(X(dx), y - 2):set(X(dx), y - 3):set(X(dx), y - 4) end
  local s1, s2 = X(8) + w * dir, X(10) + w * dir
  stalks:set(X(8), y - 5):set(X(10), y - 5):set(s1, y - 6):set(s2, y - 6)
  local shell = E(X(4), y - 4, 3, 3)
  ink(foot, neck, stalks, shell)
  c:fillMask(foot, BODY.base); c:fillMask(neck, BODY.base)
  R(math.min(X(0), X(10)), y, math.max(X(0), X(10)), y, BODY.shade)
  c:fillMask(stalks, BODY.shade); px(s1, y - 6, P.ink); px(s2, y - 6, P.ink)
  px(X(9), y - 3, P.ink)   -- eye dot on the head
  px(X(10), y - 1, P.petal.base)   -- cheek
  ball(shell, X(4), y - 4, 3, 3, P.gold, { nospec = true })
  for i, p in ipairs(SPIRAL) do px(X(4) + p[1] * dir, y - 4 + p[2], i <= 4 and P.ember.deep or P.ember.shade) end
  px(X(2), y - 6, P.gold.hi); px(X(3), y - 6, P.gold.hi)
end

-- a standing leaf with a stem: base at (x,y) bottom, height h
local function leaf(x, y, h, rx)
  local stem = c:rect(x, y - 2, x, y)
  local blade = E(x, y - 2 - h // 2, rx, h // 2)
  ink(stem, blade)
  c:fillMask(stem, P.moss.shade)
  ball(blade, x, y - 2 - h // 2, rx, h // 2, P.moss, { nospec = true })
  R(x, y - 1 - h, x, y - 3, P.moss.shade)  -- midrib
  px(x - 1, y - 2 - h // 2 - 1, P.moss.hi)
end

local function ladder(xa, xb, ytop, ybot, rungs)
  local rails = c:line({ { xa, ybot }, { xa - 1, ytop } }, 1):add(c:line({ { xb, ybot }, { xb - 1, ytop } }, 1))
  local rg = HP.mask()
  for _, ry in ipairs(rungs) do rg:add(c:rect(xa + 1 - (ybot - ry) // 8, ry, xb - 1 - (ybot - ry) // 8, ry)) end
  c:fillMask(rails, P.wood.shade); c:fillMask(rg, P.wood.base)
  rails:each(function(x, y) if x == xa or x == xa - 1 then px(x, y, P.wood.base) end end)
  px(xa - 1, ytop, P.wood.hi)
end

local function drop(x, y, big)   -- shiny glaze drop on the glass, (x,y) = top-centre
  local m = big and pt{ { x, y }, { x - 1, y + 1 }, { x, y + 1 }, { x + 1, y + 1 }, { x - 1, y + 2 }, { x, y + 2 }, { x + 1, y + 2 }, { x, y + 3 } }
    or pt{ { x, y }, { x - 1, y + 1 }, { x, y + 1 }, { x, y + 2 } }
  c:rim(m, P.ink); c:fillMask(m, P.gold.base)
  px(x, y + 1, P.gold.hi); if big then px(x + 1, y + 2, P.gold.shade); px(x, y + 3, P.gold.shade) else px(x, y + 2, P.gold.shade) end
  px(x - 1, y + (big and 2 or 1), P.cream)
end

-- the jar. content(x0,x1,soilTop,yb) draws what is inside; returns geometry
local function jarBase(hw, yt, content, o)
  o = o or {}
  local x0, x1, yb = CX - hw, CX + hw, FY - 2
  cast(CX + 4, FY + 1, hw + 6, 3)
  local slab = E(CX, FY - 1, hw + 3, 2)
  c:rim(slab, P.ink); c:part(slab, "stone", { band = 1, nopop = true })
  local body = c:rrect(x0, yt, x1, yb, 2)
  local mouth = E(CX, yt, hw - 1, 1)
  local lidT, lidS
  if o.lid then
    local lx0, lx1, ly = CX - 1 + (o.lidx or 0), CX + hw + 2 + (o.lidx or 0), yt - 2
    lidT = E((lx0 + lx1) // 2, ly, (lx1 - lx0) // 2, 1); lidS = c:rect(lx0, ly + 1, lx1, ly + 2)
    o.lm = { lx0, lx1, ly }
  end
  if lidT then ink(body, mouth, lidT, lidS) else ink(body, mouth) end
  cyl(body, CX, hw, WIN, { t1 = .8, t2 = .3 })
  local soilTop = yb - 4
  local soil = c:rect(x0 + 1, soilTop, x1 - 1, yb):clip(body)
  cyl(soil, CX, hw, P.wood, { t1 = 2 })
  R(x0 + 1, soilTop, x1 - 1, soilTop, P.wood.hi)
  for i = 0, hw * 2 - 3, 4 do px(x0 + 2 + i, soilTop + 2 + (i // 4) % 2, P.wood.deep) end
  px(x0 + 3, soilTop + 1, P.stone.base); px(x1 - 3, soilTop + 3, P.stone.base)
  content(x0, x1, soilTop, yb)
  if not o.roof then
    c:fillMask(mouth, WIN.deep); mouth:each(function(a, b) if not mouth:has(a, b - 1) then px(a, b, P.sky.hi) end end)
  end
  -- glass shine over everything inside
  R(x0 + 2, yt + 3, x0 + 2, yt + 3 + (yb - yt) // 2, P.cream); px(x0 + 3, yt + 3, P.cream)
  px(x1 - 2, yt + 5, WIN.hi); px(x1 - 2, yt + 6, WIN.hi)
  px(x0 + 2, yt + 5 + (yb - yt) // 2 + 1, P.cream)
  -- cooler glass edge on the shade side
  if lidT then
    local lx0, lx1, ly = o.lm[1] + (o.dx or 0), o.lm[2] + (o.dx or 0), o.lm[3]
    local lt = E((lx0 + lx1) // 2, ly, (lx1 - lx0) // 2, 1)
    local ls = c:rect(lx0, ly + 1, lx1, ly + 2)
    c:fillMask(ls, P.wood.shade); R(lx0, ly + 2, lx1, ly + 2, P.wood.deep)
    c:fillMask(lt, P.wood.base); lt:each(function(a, b) if not lt:has(a, b - 1) or not lt:has(a - 1, b) then px(a, b, P.wood.hi) end end)
    px(lx1, ly + 1, P.wood.deep)
  end
  return x0, x1, yt, yb, soilTop
end

local function bulb(x, y, col)
  local m = c:rect(x, y, x + 1, y + 2); c:rim(m, P.ink); c:fillMask(m, col); px(x, y, P.cream)
end
local function fairy(x0, x1, y0, sag, cols)
  local pts, n = {}, 0
  local line = HP.mask()
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = y0 + floor(sag * sin(t * math.pi) + .5)
    line:set(x, y)
  end
  c:fillMask(line, P.ink)
  local i = 0
  for x = x0 + 3, x1 - 3, 4 do
    local t = (x - x0) / (x1 - x0); local y = y0 + floor(sag * sin(t * math.pi) + .5)
    i = i + 1; bulb(x, y + 1, cols[(i - 1) % #cols + 1])
  end
end

----------------------------------------------------------------- pieces
local function plot()
  local m = E(28, 41, 20, 6)
  c:rim(m, P.ink); c:fillMask(m, P.wood.base)
  m:each(function(x, y)
    if (not m:has(x, y + 1) and x > 20) or (not m:has(x + 1, y) and y > 41) then px(x, y, P.wood.shade) end
    if (not m:has(x, y - 1) or not m:has(x - 1, y)) and x < 30 then px(x, y, P.wood.hi) end
  end)
  for _, p in ipairs{ { 15, 41 }, { 31, 43 }, { 37, 40 }, { 24, 38 }, { 19, 44 }, { 26, 45 }, { 34, 37 }, { 12, 42 }, { 41, 42 } } do R(p[1], p[2], p[1] + 2, p[2], P.wood.shade) end
  for _, p in ipairs{ { 21, 39 }, { 33, 41 }, { 17, 44 }, { 29, 38 } } do px(p[1], p[2], P.wood.hi) end
  return m
end

local SWAY = { 0, 1, 1, 0 }
local function signBoard(dx)
  -- interior x 24..53 (30), y 18..26 (9); pole from the snail's shell up to the board
  local bx0, by0 = 22 + dx, 18
  local pole = c:line({ { 50, 44 }, { 50 + dx, 28 } }, 1)
  ink(pole); c:fillMask(pole, P.wood.shade)
  local board = c:rect(bx0, by0, bx0 + 31, by0 + 8)
  ink(board)
  c:fillMask(board, P.wood.base)
  R(bx0, by0, bx0 + 31, by0, P.wood.hi); R(bx0 + 1, by0 + 8, bx0 + 31, by0 + 8, P.wood.shade); R(bx0 + 31, by0, bx0 + 31, by0 + 8, P.wood.shade)
  R(bx0 + 1, by0 + 1, bx0 + 30, by0 + 7, P.cream)   -- paper face
  R(bx0 + 1, by0 + 7, bx0 + 30, by0 + 7, "#f6dfae"); R(bx0 + 30, by0 + 1, bx0 + 30, by0 + 7, "#f6dfae")
  -- tiny jar icon
  c:paint({ ".LLL.", "sSSSs", "sSmSs", "sbbbs", ".sss." }, bx0 + 3, by0 + 2,
    { L = P.wood.base, s = P.sea.deep, S = P.sea.hi, m = P.moss.base, b = P.wood.shade })
  word(bx0 + 11, by0 + 2, P.ink)
  
  -- two nails
  px(bx0 + 1, by0 + 1, P.stone.shade); px(bx0 + 30, by0 + 1, P.stone.shade)
end

local function drawEmpty(k)
  newc()
  cast(30, 49, 8, 2)
  plot()
  stake(14, 29, 36); stake(42, 29, 36)
  string(14, 29, 42, 29); string(42, 29, 44, 43); string(44, 43, 12, 43); string(12, 43, 14, 29)
  stake(12, 43, 47); stake(44, 43, 47)
  -- pebbles, flowers
  pebble(18, 43); pebble(32, 42)
  flower(8, 47, P.petal.base); flower(24, 49, P.gold.base); flower(36, 49, P.sky.hi)
  -- snail carrying the sign (faces the plot)
  signBoard(SWAY[k])
  snail(44, 50, -1, ({ 0, 0, 1, 1 })[k])
  -- a leaf blowing past
  local L = { { 4, 22 }, { 9, 18 }, { 15, 21 }, { 10, 25 } }
  leafbit(L[k][1], L[k][2], k % 2 == 1)
  return c
end

local STALK = 0
local function contentL1(x0, x1, st, yb)
  leaf(x1 - 3, st, 9, 2)
  snail(x0 + 3, st - 1, 1, STALK)
end
local function drawL1(wig)
  newc()
  jarBase(8, 28, contentL1, { lid = true, dx = wig or 0 })
  flower(8, 49, P.petal.base); flower(47, 48, P.gold.base)
  return c
end

local function drawL2(o)
  o = o or {}
  newc()
  local x0, x1, yt, yb, st = jarBase(10, 24, function(x0, x1, st)
    ladder(x0 + 3, x0 + 8, st - 14, st, { st - 3, st - 7, st - 11 })
    leaf(x1 - 3, st, 13, 2)
    snail(x0 + 7, st - 1, 1, o.stalk or 0)
  end, { lid = true, dx = o.dx or 0 })
  drop(x1 - 3, yt + 4, true); drop(x0 + 5, yt + 10, false); drop(x1 - 2, yt + 13, false)
  flower(8, 49, P.petal.base); flower(48, 48, P.gold.base); pebble(47, 44)
  return c
end

local function drawL3(o)
  o = o or {}
  newc()
  local x0, x1, yt, yb, st = jarBase(12, 22, function(x0, x1, st)
    ladder(x0 + 3, x0 + 8, st - 16, st, { st - 3, st - 7, st - 11, st - 15 })
    leaf(x1 - 3, st, 14, 2)
    leaf(x1 - 9, st, 7, 1)
    snail(x0 + 7, st - 1, 1, o.stalk or 0)
  end, { roof = true })
  -- cap roof: collar, cone, knob
  local collar = c:rect(x0 - 1, yt - 3, x1 + 1, yt - 1)
  local apex, base = yt - 13, yt - 4
  local cone = HP.mask()
  for y = apex, base do
    local hwr = floor((y - apex) * (hwc or 14) / (base - apex) + .5)
    for x = CX - hwr, CX + hwr do cone:set(x, y) end
  end
  local knob = c:rect(CX - 1, apex - 3, CX + 1, apex - 1)
  ink(collar, cone, knob)
  c:fillMask(cone, P.ember.base)
  cone:each(function(x, y)
    if x > CX then px(x, y, P.ember.shade) elseif x == CX then px(x, y, P.ember.shade) end
    if x < CX - 2 and y < apex + 5 then end
  end)
  cone:each(function(x, y) if (y - apex) % 3 == 2 and (x + y) % 2 == 0 then local v = c:get(x, y); px(x, y, x > CX and P.ember.deep or P.ember.shade) end end)
  cone:each(function(x, y) if x < CX - 1 and x >= CX - 3 and y < apex + 6 then px(x, y, P.ember.hi) end end)
  c:fillMask(collar, P.wood.base); R(x0 - 1, yt - 3, x1 + 1, yt - 3, P.wood.hi); R(x0 - 1, yt - 1, x1 + 1, yt - 1, P.wood.shade); R(x1 - 2, yt - 3, x1 + 1, yt - 2, P.wood.shade)
  c:fillMask(knob, P.gold.base); px(CX - 1, apex - 3, P.gold.hi); px(CX + 1, apex - 1, P.gold.shade)
  -- fairy lights draped over the glass
  local lc = { P.petal.base, P.gold.base, P.ember.base, P.moss.base }; local rot = o.rot or 0
  fairy(x0 + 1, x1 - 1, yt + 3, 3, { lc[(rot) % 4 + 1], lc[(rot + 1) % 4 + 1], lc[(rot + 2) % 4 + 1], lc[(rot + 3) % 4 + 1] })
  drop(x1 - 3, yt + 11, true); drop(x0 + 5, yt + 15, false)
  flower(8, 49, P.petal.base); flower(11, 47, P.gold.base); flower(48, 48, P.sky.hi); flower(51, 46, P.petal.base)
  return c
end

-- ready
local BOB = { 0, -1, 0, 1 }
local STK = { 0, 1, 1, 0 }
local function drawReady2(k)
  drawL2{ stalk = STK[k], dx = ({ 0, 1, 0, -1 })[k] }
  local x, y = 30, ({ 25, 27, 29, 31 })[k]
  for yy = 24, y - 1 do px(x, yy, P.cream) end
  drop(x, y, true)
  if k >= 3 then R(x - 2, 43, x + 1, 43, P.gold.base); px(x - 1, 43, P.gold.hi) end
  local S = { { 45, 31 }, { 11, 32 }, { 46, 41 }, { 10, 40 } }
  sparkle(S[k][1], S[k][2]); mini(S[(k % 4) + 1][1], S[(k % 4) + 1][2] - 9)
  badge(BOB[k])
  return c
end
local function drawReady3(k)
  drawL3{ stalk = STK[k], rot = k - 1 }
  local x, y = 29, ({ 29, 30, 31, 32 })[k]
  for yy = 28, y - 1 do px(x, yy, P.cream) end
  drop(x, y, true)
  if k >= 3 then R(x - 2, 43, x + 1, 43, P.gold.base); px(x - 1, 43, P.gold.hi) end
  local S = { { 46, 30 }, { 9, 32 }, { 46, 40 }, { 9, 40 } }
  sparkle(S[k][1], S[k][2]); mini(S[(k % 4) + 1][1], S[(k % 4) + 1][2] - 9)
  badge(BOB[k])
  return c
end

----------------------------------------------------------------- output
for lv, fn in ipairs{ false, drawReady2, drawReady3 } do
  if fn then
    local rs = {}
    for k = 1, 4 do rs[k] = fn(k) end
    saveStrip(rs, "snail_jar-ready-l" .. lv, "ready")
  end
end
