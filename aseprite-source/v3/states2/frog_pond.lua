-- frog_pond state sprites, 72x56, anchor (36,46). Hearth Pop v3. Run:
-- AppRun -b --script-param out=/tmp/ase/states2/frog_pond/ --script /tmp/ase/states2/frog_pond.lua
local W, H, NAME = 72, 56, "frog_pond"
local CX, FY = 36, 46
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
local function reeds(xs, ybase, hs)
  local all, list = HP.mask(), {}
  for i, x in ipairs(xs) do
    local h = hs[i]
    local stem, top = c:rect(x, ybase - h, x, ybase), c:rect(x, ybase - h - 3, x, ybase - h - 1)
    list[#list + 1] = { stem, top, x, ybase - h - 3 }
    all:add(stem):add(top)
  end
  c:rim(all, P.ink)
  for _, p in ipairs(list) do c:fillMask(p[1], P.moss.shade); c:fillMask(p[2], P.wood.shade); px(p[3], p[4], P.wood.base) end
end

local DARKPAD = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep }
local function lilypad(cx, cy, rx, ry, notch, T)
  T = T or DARKPAD
  local m = E(cx, cy, rx, ry)
  -- soft cast shadow on the water
  m:copy():shift(1, 1):cut(m):each(function(x, y) local v = c:get(x, y); if v == P.sea.base or v == P.sea.shade or v == P.sea.hi then px(x, y, P.sea.deep) end end)
  c:fillMask(m, T.base)
  m:each(function(x, y)
    if not m:has(x, y - 1) or not m:has(x - 1, y) then px(x, y, T.hi)
    elseif not m:has(x, y + 1) or not m:has(x + 1, y) then px(x, y, T.shade) end
  end)
  if notch then   -- wedge of water cut into the pad, front right
    local nx, ny = cx + notch[1], cy + ry
    for i = 0, 2 do px(nx + (i > 0 and 1 or 0), ny - i, P.sea.base) px(nx, ny - i, P.sea.base) end
    px(nx + 1, ny - 2, T.shade)
  end
  return m
end

local function frog(x, y, big)   -- (x,y) = bottom centre; 9 wide
  local body = E(x, y - 3, 4, 3)
  local eyeL, eyeR = c:rect(x - 3, y - 7, x - 2, y - 6), c:rect(x + 2, y - 7, x + 3, y - 6)
  local legL, legR = c:rect(x - 5, y - 1, x - 3, y), c:rect(x + 3, y - 1, x + 5, y)
  ink(body, eyeL, eyeR, legL, legR)
  c:fillMask(legL, P.moss.shade); c:fillMask(legR, P.moss.shade)
  ball(body, x, y - 3, 4, 3, P.moss, { nospec = true })
  c:fillMask(eyeL, P.moss.base); c:fillMask(eyeR, P.moss.base)
  px(x - 3, y - 7, P.cream); px(x - 2, y - 7, P.ink); px(x + 2, y - 7, P.cream); px(x + 3, y - 7, P.ink)
  px(x - 3, y - 6, P.moss.base); px(x + 3, y - 6, P.moss.shade)
  R(x - 2, y - 3, x + 2, y - 3, P.moss.deep)   -- wide mouth
  px(x - 3, y - 2, P.petal.base); px(x + 3, y - 2, P.petal.base)
  R(x - 1, y - 1, x + 1, y, P.cream)           -- pale belly
  px(x - 2, y - 5, P.moss.hi)
end

local function bubble(x, y)
  local m = pt{ { x, y - 1 }, { x - 1, y }, { x, y }, { x + 1, y }, { x, y + 1 } }
  c:rim(m, P.sea.deep); c:fillMask(m, P.sky.hi); px(x - 1, y, P.cream); px(x, y, P.sea.base)
end
local function ripple(cx, cy, rx, ry, gap)
  E(cx, cy, rx, ry):edge():each(function(x, y)
    local v = c:get(x, y)
    if (v == P.sea.base or v == P.sea.shade) and (x * 3 + y) % (gap or 3) ~= 0 then px(x, y, P.sea.hi) end
  end)
end

-- a pond: grassy bank, earth lip, water. cyw = water centre y (bank bottom at FY)
local function pond(rx, ry, cyw)
  local bank = E(CX, cyw + 1, rx + 3, ry + 2)
  local water = E(CX, cyw, rx, ry)
  cast(CX + 4, FY, rx + 6, 3)
  c:rim(bank, P.ink)
  c:part(bank, "moss", { band = 2, nopop = true })
  -- grass flecks on the bank
  bank:each(function(x, y) if not water:copy():grow(1):has(x, y) and (x * 7 + y * 3) % 11 == 0 then px(x, y, P.moss.hi) end end)
  -- earth lip around the water: upper half
  local lip = water:copy():grow(1):cut(water)
  lip:each(function(x, y) px(x, y, y <= cyw + 1 and P.wood.base or P.wood.shade) end)
  c:fillMask(water, P.sea.base)
  local shadeBand = water:copy():cut(water:copy():shift(2, 2))
  c:fillMask(shadeBand, P.sea.shade)
  water:each(function(x, y)
    if not water:has(x + 1, y) and not shadeBand:has(x, y) and (x - CX) + (y - cyw) * 2 > 0 then px(x, y, P.sea.hi) end
  end)
  R(CX - 8, cyw - ry + 3, CX - 3, cyw - ry + 3, P.sea.hi)
  R(CX + 3, cyw + ry - 3, CX + 12, cyw + ry - 3, P.sky.hi)
  R(CX + 5, cyw + 1, CX + 7, cyw + 1, P.sea.hi)
  -- near-bank pebbles
  for _, p in ipairs{ { CX - rx - 1, cyw + ry - 1 }, { CX - rx + 6, cyw + ry + 1 }, { CX + rx - 8, cyw + ry + 1 }, { CX + rx, cyw + ry - 2 } } do pebble(p[1], p[2]) end
  return water, bank
end

local function stone(cx, cy, rx, ry)
  local m = E(cx, cy, rx, ry)
  c:rim(m, P.ink)
  ball(m, cx, cy, rx, ry, P.stone, { nospec = true })
  px(cx - 2, cy - 1, P.cream)
  -- wet ring where it meets the water
  E(cx, cy + ry, rx + 2, 1):edge():each(function(x, y) if c:get(x, y) == P.sea.base or c:get(x, y) == P.sea.shade then px(x, y, P.sea.hi) end end)
  return m
end

local function dragonfly(x, y, up)
  local body = c:rect(x, y, x + 3, y)
  local w = up and pt{ { x + 1, y - 1 }, { x + 2, y - 1 }, { x + 1, y - 2 } } or pt{ { x + 1, y + 1 }, { x + 2, y + 1 }, { x + 1, y + 2 } }
  ink(body, w)
  c:fillMask(w, P.sky.hi); c:fillMask(body, P.ember.base); px(x + 3, y, P.ember.shade); px(x, y, P.dusk.base)
end

----------------------------------------------------------------- empty
local SWAY = { 0, 1, 1, 0 }
local function drawEmpty(k)
  newc()
  cast(38, 47, 28, 3)
  -- cracked dry mud plot
  local mud = c:rrect(7, 28, 65, 46, 8)
  c:rim(mud, P.ink); c:fillMask(mud, P.wood.hi)
  mud:each(function(x, y)
    if not mud:has(x, y + 1) or not mud:has(x + 1, y) then px(x, y, P.wood.base) end
  end)
  local cracks = { { { 10, 34 }, { 14, 37 }, { 13, 41 }, { 17, 44 } }, { { 62, 33 }, { 58, 36 }, { 60, 40 }, { 55, 44 } }, { { 20, 29 }, { 22, 31 }, { 20, 34 } },
    { { 52, 29 }, { 51, 32 }, { 54, 34 } }, { { 10, 43 }, { 13, 45 } }, { { 62, 42 }, { 60, 45 } }, { { 28, 45 }, { 31, 44 }, { 34, 46 } }, { { 42, 45 }, { 45, 43 } }, { { 14, 31 }, { 17, 32 } }, { { 58, 30 }, { 56, 32 } } }
  for _, cr in ipairs(cracks) do local m = c:line(cr, 1); m:each(function(x, y) if c:get(x, y) == P.wood.hi then px(x, y, P.wood.base) end end) end
  for _, p in ipairs{ { 24, 44 }, { 48, 31 }, { 36, 44 }, { 16, 40 }, { 56, 41 } } do px(p[1], p[2], P.cream) end
  -- puddle with a wet earth outline
  local pud = E(36, 35, 21, 7)
  c:fillMask(pud, P.wood.deep)
  local inner = pud:copy():shrink(1)
  c:fillMask(inner, P.sea.base)
  c:fillMask(inner:copy():cut(inner:copy():shift(2, 1)), P.sea.shade)
  inner:each(function(x, y) if not inner:has(x + 1, y) and (x - 36) + (y - 35) * 2 > 0 then px(x, y, P.sea.hi) end end)
  -- ripple ring around the pad
  local rr = { 17, 18, 19, 20 }
  ripple(36, 35, rr[k], 6, 4)
  -- stakes and string line
  stake(9, 23, 30); stake(63, 23, 30)
  string(9, 23, 63, 23); string(63, 23, 62, 43); string(62, 43, 10, 43); string(10, 43, 9, 23)
  stake(10, 43, 47); stake(62, 43, 47)
  -- reeds, flowers, stones
  reeds({ 3, 5 }, 44, { 12, 16 })
  flower(68, 41, P.gold.base); flower(66, 46, P.petal.base); flower(26, 49, P.sky.hi); flower(46, 50, P.gold.base)
  pebble(18, 47); pebble(52, 47); pebble(69, 47)
  -- the lily-pad sign floats on the puddle
  local dx, dy = SWAY[k], ({ 0, 0, 1, 0 })[k]
  local pad = lilypad(36 + dx, 34 + dy, 16, 6, { 4 }, { hi = P.moss.hi, base = P.moss.base, shade = P.moss.shade })
  pad:each(function(x, y) if y >= 31 + dy and y <= 37 + dy and pad:has(x, y) and c:get(x, y) == P.moss.base then px(x, y, P.moss.hi) end end)
  local tx = 36 + dx - 13
  c:paint({ ".s.s.", "sksks", "sssss", "s...s" }, tx, 32 + dy, { s = P.moss.deep, k = P.ink })
  word(tx + 7, 32 + dy, P.ink)
  -- dragonfly loop
  local D = { { 14, 14 }, { 24, 11 }, { 34, 14 }, { 24, 17 } }
  dragonfly(D[k][1], D[k][2], k % 2 == 1)
  return c
end

----------------------------------------------------------------- levels
local function drawL1(o)
  o = o or {}
  newc()
  local water = pond(19, 8, 35)
  reeds({ 9, 11, 13 }, 40, { 13, 17, 12 })
  -- pads: back-right with the frog, front-left with a flower
  lilypad(28, 38, 5, 2, { 2 })
  px(27, 37, P.petal.base); px(28, 37, P.petal.hi); px(29, 37, P.petal.base); px(28, 36, P.petal.base); px(28, 38, P.gold.base)
  lilypad(45, 33, 6, 3, { 3 })
  frog(45, 32 - (o.hop or 0))
  lilypad(40, 40, 3, 1)
  if o.extra then o.extra() end
  return c
end

local function drawL2()
  newc()
  local water = pond(21, 9, 34)
  reeds({ 9, 11, 13 }, 40, { 13, 17, 12 })
  lilypad(30, 40, 5, 2, { 2 })
  px(29, 39, P.petal.base); px(30, 39, P.petal.hi); px(31, 39, P.petal.base); px(30, 38, P.petal.base); px(30, 40, P.gold.base)
  lilypad(46, 32, 6, 3, { 3 })
  frog(46, 31)
  lilypad(52, 39, 3, 1); lilypad(39, 41, 3, 1); lilypad(24, 30, 4, 2, { 2 })
  -- third spot: a stone with a frog
  stone(30, 31, 5, 3)
  frog(30, 29)
  -- little plank bridge from the near bank to the stone
  local plank = c:line({ { 14, 41 }, { 25, 35 } }, 3)
  c:rim(plank, P.ink); c:fillMask(plank, P.wood.base)
  plank:each(function(x, y) if not plank:has(x, y - 1) then px(x, y, P.wood.hi) elseif not plank:has(x, y + 1) then px(x, y, P.wood.shade) end end)
  for _, p in ipairs{ { 17, 40 }, { 20, 38 }, { 23, 36 } } do px(p[1], p[2], P.wood.shade) end
  flower(58, 40, P.petal.base); flower(60, 44, P.gold.base)
  return c
end

local function drawL3()
  newc()
  local water = pond(24, 11, 32)
  reeds({ 6, 8, 10 }, 38, { 13, 17, 12 })
  lilypad(30, 40, 5, 2, { 2 })
  px(29, 39, P.petal.base); px(30, 39, P.petal.hi); px(31, 39, P.petal.base); px(30, 38, P.petal.base); px(30, 40, P.gold.base)
  lilypad(49, 33, 6, 3, { 3 })
  frog(49, 32)
  lilypad(54, 39, 3, 1); lilypad(41, 41, 3, 1)
  stone(24, 33, 5, 3)
  frog(24, 31)
  local plank = c:line({ { 12, 42 }, { 19, 38 } }, 3)
  c:rim(plank, P.ink); c:fillMask(plank, P.wood.base)
  plank:each(function(x, y) if not plank:has(x, y - 1) then px(x, y, P.wood.hi) elseif not plank:has(x, y + 1) then px(x, y, P.wood.shade) end end)
  for _, p in ipairs{ { 14, 41 }, { 17, 39 } } do px(p[1], p[2], P.wood.shade) end
  -- fountain: stone basin on a column with a jet of water
  local col = c:rect(36, 27, 38, 31)
  local basin = E(37, 26, 5, 2)
  ink(col, basin)
  cyl(col, 37, 1, P.stone, { t1 = 2 })
  c:fillMask(col, P.stone.base); R(38, 27, 38, 31, P.stone.shade); R(36, 27, 36, 31, P.stone.hi)
  ball(basin, 37, 26, 5, 2, P.stone, { nospec = true })
  local pool = E(37, 25, 3, 1); c:fillMask(pool, P.sea.base); R(35, 25, 36, 25, P.sea.hi)
  R(37, 15, 38, 24, P.sea.base); R(37, 15, 37, 24, P.sea.hi); R(37, 15, 37, 16, P.cream)
  for _, p in ipairs{ { 35, 16 }, { 34, 18 }, { 33, 20 }, { 33, 22 }, { 39, 16 }, { 40, 18 }, { 41, 20 }, { 41, 22 } } do px(p[1], p[2], P.sea.base) px(p[1], p[2] - 1, P.sea.hi) end
  for _, p in ipairs{ { 34, 17 }, { 40, 17 }, { 36, 14 }, { 38, 14 } } do px(p[1], p[2], P.cream) end
  ripple(37, 29, 7, 3, 3)
  -- a third frog on the near bank, flowers
  frog(56, 47 - 3)
  flower(12, 34, P.petal.base); flower(15, 31, P.gold.base); flower(60, 33, P.dusk.base); flower(62, 37, P.petal.base); flower(58, 29, P.gold.base)
  return c
end

----------------------------------------------------------------- ready
local BOB = { 0, -1, 0, 1 }
local HOP = { 0, 2, 3, 1 }
local function drawReady(k)
  drawL1{ hop = HOP[k] }
  -- bubbles rising
  local bub = { { 22, 38 - k * 2 }, { 33, 41 - ((k + 1) % 4) * 2 }, { 55, 38 - ((k + 2) % 4) * 2 } }
  bubble(22, 41 - (k - 1) * 2 - 1); bubble(33, 43 - ((k + 1) % 4) * 2); bubble(53, 42 - ((k + 2) % 4) * 2)
  -- ripples spread from where the frog sits
  ripple(45, 36, 4 + k * 2, 1 + k // 2, 3)
  -- a tadpole swims across the open water
  local T = { { 20, 36 }, { 23, 37 }, { 26, 37 }, { 29, 36 } }
  local tp = T[k]
  R(tp[1], tp[2], tp[1] + 1, tp[2] + 1, P.ink); px(tp[1] - 1, tp[2] + (k % 2), P.ink); px(tp[1] - 2, tp[2] + 1 - (k % 2), P.ink)
  -- sparkles
  local S = { { 55, 24 }, { 22, 27 }, { 58, 36 }, { 17, 38 } }
  sparkle(S[k][1], S[k][2]); mini(S[(k % 4) + 1][1], S[(k % 4) + 1][2] - 5)
  badge(BOB[k])
  return c
end

----------------------------------------------------------------- output
local es = {}
for k = 1, 4 do es[k] = drawEmpty(k) end
saveStrip(es, "frog_pond-empty", "empty")
save(drawL1(), "frog_pond-l1")
save(drawL2(), "frog_pond-l2")
save(drawL3(), "frog_pond-l3")
local rs = {}
for k = 1, 4 do rs[k] = drawReady(k) end
saveStrip(rs, "frog_pond-ready", "ready")
