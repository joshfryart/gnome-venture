-- Silk shelf state sprites (64x64, ground centre at (32,54)). Hearth Pop v3.
local K = dofile("/tmp/ase/states2/qs_common.lua")
local HP, P = K.HP, K.P
local out = app.params.out or "/tmp/ase/states2/silk_shelf/"
local W, H = 64, 64
local AX, AY = 32, 54
local c
local px, E, R, ink, lerp = K.px, K.E, K.R, K.ink, K.lerp
local floor = math.floor
local function newc() c = K.newc(W, H, "silk_shelf") return c end
local SOIL = { hi = "#d6b080", base = "#b98a5c", shade = "#996a48", deep = "#6f4535" }
local BACK = "#e6d0a0"
local SILK = "#fff4d6"

local function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  c:rim(HP.mask():add(head):add(stem), P.ink)
  c:fillMask(stem, P.moss.base); c:fillMask(head, col); px(x, y, P.gold.hi)
end
local function stone(x, y) K.sprite({ ".hh.", "hbbs", "ssss" }, x, y, { h = P.stone.hi, b = P.stone.base, s = P.stone.shade }) end
local function leaf(x, y) K.sprite({ ".ml", "mmm", "sm." }, x, y, { m = P.moss.base, l = P.moss.hi, s = P.moss.shade }) end
local function tuft(x, y) px(x, y, P.moss.base) px(x + 1, y - 1, P.moss.hi) px(x + 2, y, P.moss.base) end

---------------------------------------------------------------- shelf compartments
local COC = { ".hh.", "hbbs" }
local function cocoon(x, y, glow)
  c:paint(COC, x, y, { h = P.cream, b = "#f6dfae", s = "#e8c48a" })
  if glow then px(x + 1, y, "#fffbea"); px(x + 2, y, "#fff4d6") end
end
local function comp(kind, sx0, sx1, sy, y, o)
  R(sx0, sy, sx1, sy + 3, BACK)
  R(sx0, sy, sx1, sy, lerp(BACK, K.DUSKSH, .35)) R(sx0, sy, sx0, sy + 3, lerp(BACK, K.DUSKSH, .25))
  R(sx0, sy + 4, sx1, sy + 4, P.wood.hi)
  local sb = math.min(sy + 5, y); R(sx0, sb, sx1, sb, P.wood.shade)
  if kind == "tray" then
    R(sx0 + 1, sy + 3, sx1 - 1, sy + 3, P.moss.base)
    for xx = sx0 + 2, sx1 - 2, 3 do px(xx, sy + 3, P.moss.hi) end
    px(sx0 + 1, sy + 3, P.moss.shade); px(sx1 - 1, sy + 3, P.moss.shade)
    local w = (o and o.wob) or 0
    cocoon(sx0 + 2 + w, sy + 1, o and o.glow); cocoon(sx0 + 9 - w, sy + 1, o and o.glow)
    px(sx0 + 7, sy + 2, P.moss.hi); px(sx0 + 7, sy + 1, P.moss.base)
  elseif kind == "door" then
    R(sx0, sy, sx1, sy + 3, P.wood.base)
    local mx = (sx0 + sx1) // 2
    R(mx, sy, mx, sy + 3, P.wood.deep)
    R(sx0, sy, sx1, sy, P.wood.shade)
    for xx = sx0 + 2, sx1 - 1, 3 do if xx ~= mx and xx ~= mx - 1 then R(xx, sy + 1, xx, sy + 3, P.wood.shade) end end
    px(mx - 1, sy + 2, P.gold.hi); px(mx + 1, sy + 2, P.gold.hi)
  elseif kind == "rack" then
    R(sx0, sy + 1, sx1, sy + 1, P.wood.deep)
    for i, xx in ipairs{ sx0 + 2, sx0 + 5, sx0 + 8, sx0 + 11 } do
      local len = ({ 3, 2, 3, 2 })[i]
      R(xx, sy + 2, xx, sy + 1 + len, SILK); px(xx + 1, sy + 2, "#e8c48a")
      px(xx, sy + 1 + len, P.petal.base)
    end
  end
end
-- comps: list top to bottom; yt = top of wall
local function hutch(x, y, comps, o)
  o = o or {}
  local x0, x1, d = x - 10, x + 7, 4
  local n = #comps
  local yt = y - 6 * n
  local front, side = c:rect(x0, yt, x1, y), K.sideWall(x1, yt, y, d, 1)
  local rh = o.rh or 6
  local F, S = K.hipRoof(x0, x1, yt - 1, yt - 1 - rh, o.ov or 2, 6, d)
  ink(front, side, F, S)
  local Wt = K.wallTones(P.wood.base, P.wood.hi)
  K.paintWalls(front, side, Wt, 17)
  side:each(function(xx, yy) if (xx - x1) % 2 == 1 then px(xx, yy, Wt.sdark) end end)
  K.paintRoof(F, S, P.dusk, { h = 2, w = 3, light = 0, dark = 0 })
  K.eaveShadow(x0, x1, yt, d, Wt, 1)
  for i, kd in ipairs(comps) do comp(kd, x0 + 2, x1 - 2, yt + 2 + 6 * (i - 1), y, (kd == "tray" and (o.trayopt and o.trayopt[i])) or nil) end
  for yy = yt + 1, y - 1, 4 do K.dk(x0, yy, "wood") K.dk(x1, yy + 2, "wood") end
  K.rimLight(front, P.wood.hi, P.wood.base)
  return x0, x1, yt
end
local function basket(x, y)  -- leaf basket 9 wide
  local m = c:rrect(x, y, x + 8, y + 5, 1)
  local leaves = c:rect(x + 1, y - 2, x + 7, y)
  ink(m, leaves)
  c:fillMask(leaves, P.moss.base); px(x + 2, y - 2, P.moss.hi); px(x + 3, y - 2, P.moss.hi); px(x + 6, y - 1, P.moss.shade)
  c:part(m, "wood", { band = 2, pop = { x = x + 2, y = y + 1, horizontal = true } })
  for yy = y + 1, y + 5 do for xx = x + 1, x + 7 do if (xx + yy) % 3 == 0 and m:has(xx, yy) and c:get(xx, yy) ~= P.wood.hi then px(xx, yy, P.wood.deep) end end end
  R(x, y, x + 8, y, P.gold.shade)
end
local function skein(cx, y0)   -- hanging silk hank: cord, tie, loop
  local cord = c:rect(cx, y0, cx, y0 + 2)
  local ring = HP.mask():add(E(cx, y0 + 7, 3, 4)):cut(E(cx, y0 + 7, 1, 2))
  ink(cord, ring)
  R(cx, y0, cx, y0 + 2, P.wood.deep)
  c:fillMask(ring, SILK)
  ring:each(function(xx, yy) if xx >= cx + 1 and (yy % 2 == 0) then px(xx, yy, "#e8c48a") end end)
  R(cx - 1, y0 + 3, cx + 1, y0 + 3, P.petal.base)
end
local function post(x, y0, y1)
  local m = c:rect(x, y0, x + 1, y1)
  ink(m); c:part(m, "wood", { band = 1, nopop = true })
end
local function thread(x0, y0, s, len)  -- swinging silk thread with a gold bead
  local pts = {}
  for i = 0, len do pts[#pts + 1] = { x0 + floor(s * (i / len) ^ 2 + .5), y0 + i } end
  local m = HP.mask() for _, p in ipairs(pts) do m:set(p[1], p[2]) end
  c:rim(m, P.ink); c:fillMask(m, SILK)
  local b = pts[#pts]; px(b[1], b[2], P.gold.base)
end

---------------------------------------------------------------- pieces
local function drawL1(o)
  newc(); o = o or {}
  K.cast(AX - 10, AX + 7, AY, 4, 12, 4)
  hutch(AX, AY, { "tray", "tray", "door" }, { trayopt = o.trayopt })
  tuft(15, AY + 2); tuft(47, AY + 3); flower(17, AY - 2, P.petal.base)
  return c
end
local function drawL2()
  newc()
  K.cast(AX - 10, AX + 7, AY, 4, 18, 4)
  hutch(AX - 3, AY, { "rack", "tray", "tray", "tray" }, { rh = 6 })
  basket(AX + 12, AY - 3)
  leaf(AX + 16, AY + 3); tuft(13, AY + 2); flower(15, AY - 2, P.petal.base)
  return c
end
local function drawL3()
  newc()
  K.cast(AX - 12, AX + 9, AY, 4, 22, 4)
  local x0, x1, yt = hutch(AX - 2, AY, { "tray", "tray", "tray", "tray" }, { rh = 9, ov = 5 })
  post(x0 - 4, yt + 2, AY); post(x1 + 4, yt + 2, AY)
  skein(x0 - 1, yt + 3)
  basket(AX + 13, AY - 3)
  tuft(10, AY + 2); flower(12, AY - 2, P.petal.base); leaf(AX + 15, AY + 3)
  return c
end

local BOB = { 0, -1, 0, 1 }
local function drawReady(k)
  local wob = ({ 0, 1, 0, -1 })[k]
  local to = { [1] = { glow = k % 2 == 1, wob = wob }, [2] = { glow = k % 2 == 1, wob = -wob } }
  drawL1({ trayopt = to })
  -- halo glow round the cocoons (hard pixels), pulsing
  local x0, yt = AX - 10, AY - 18
  local sx0 = x0 + 2
  for i = 1, 2 do
    local sy = yt + 2 + 6 * (i - 1)
    local on = (k + i) % 2 == 0
    local gx = (i == 1) and wob or -wob
    for _, bx in ipairs{ sx0 + 2 + gx, sx0 + 9 - gx } do
      local col = on and P.gold.hi or P.gold.base
      px(bx + 1, sy, col); px(bx + 2, sy, col)
      px(bx - 1, sy + 1, col); px(bx + 4, sy + 1, col)
    end
  end
  -- swinging silk thread at the left of the shelf
  thread(x0 - 3, yt + 1, ({ 0, 2, 0, -2 })[k], 16)
  local SP = { { 28, AY - 17 }, { 36, AY - 11 }, { 25, AY - 6 }, { 40, AY - 21 } }
  c:sparkle(SP[k][1], SP[k][2])
  K.badge(W, BOB[k])
  return c
end

-- empty
local ICON = { "uuuuuuu", "wmmwccw", "wwwwwww", "wmmwccw", "wwwwwww" }
local function spoolSign(dx, ph)
  local cx = AX + dx
  local top = 12
  local postm = c:rect(AX - 1, 35, AX, 48)
  local fl1, fl2 = c:rrect(cx - 15, top, cx + 14, top + 3, 1), c:rrect(cx - 15, top + 21, cx + 14, top + 24, 1)
  local body = c:rect(cx - 11, top + 4, cx + 10, top + 20)
  ink(postm, fl1, fl2, body)
  c:part(postm, "wood", { band = 1, nopop = true })
  c:fillMask(body, P.petal.base)
  for yy = top + 4, top + 20 do for xx = cx - 11, cx + 10 do
    if (yy - top) % 2 == 0 then px(xx, yy, P.petal.shade) end
    if xx >= cx + 9 then px(xx, yy, P.petal.deep) end
  end end
  for yy = top + 4, top + 20 do px(cx - 11, yy, P.petal.hi) end
  R(cx - 10, top + 6, cx + 9, top + 18, SILK)
  R(cx - 10, top + 18, cx + 9, top + 18, "#e8c48a")
  c:paint(ICON, cx - 3, top + 7, { u = P.dusk.base, w = "wood.base", m = P.moss.base, c = P.cream })
  px(cx - 3, top + 7, P.dusk.hi)
  K.build(cx - 9, top + 12, P.ink)
  c:part(fl1, "wood", { band = 2, pop = { x = cx - 12, y = top, horizontal = true } })
  c:part(fl2, "wood", { band = 2, nopop = true })
end
local function drawEmpty(k)
  newc()
  local m = E(32, 46, 27, 8)
  ink(m)
  c:part(m, SOIL, { band = 3, nopop = true })
  for _, p in ipairs{ { 10, 47 }, { 18, 50 }, { 27, 52 }, { 38, 52 }, { 47, 50 }, { 53, 47 }, { 22, 43 }, { 42, 43 }, { 33, 41 } } do
    R(p[1], p[2], p[1] + 3, p[2], SOIL.hi); R(p[1] + 1, p[2] + 1, p[1] + 3, p[2] + 1, SOIL.shade)
  end
  local function sl(x0, y0, x1, y1) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), P.cream) end
  sl(14, 41, 50, 41); sl(50, 41, 52, 47); sl(52, 47, 12, 47); sl(12, 47, 14, 41)
  local function stake(x, y1) local mm = c:rect(x, y1 - 5, x, y1); ink(mm); c:part(mm, "wood", { band = 1, nopop = true }) end
  stake(14, 45); stake(50, 45); stake(12, 51); stake(52, 51)
  px(14, 40, P.wood.hi); px(50, 40, P.wood.hi); px(12, 46, P.wood.hi); px(52, 46, P.wood.hi)
  stone(18, 50); stone(44, 51); K.sprite({ "hb", "ss" }, 22, 43, { h = P.stone.hi, b = P.stone.base, s = P.stone.shade })
  flower(8, 47, P.cream); flower(56, 48, P.petal.base); flower(28, 51, P.gold.base)
  R(AX + 1, 49, AX + 8, 50, K.SHADOW)
  -- silk tail swings from the spool
  local sw = ({ 0, 1, 2, 1 })[k]
  local tail = HP.mask()
  local tp = { { 44, 36 }, { 47, 38 }, { 47 + sw // 2, 41 }, { 47 + sw, 44 }, { 47 + sw, 47 } }
  for i = 1, #tp - 1 do tail:add(c:line({ tp[i], tp[i + 1] }, 1)) end
  c:rim(tail, P.ink); c:fillMask(tail, P.petal.base)
  spoolSign(({ 0, 1, 0, -1 })[k])
  -- life: a moth flutters, a mulberry leaf blows past
  local mp = { { 54, 22 }, { 55, 20 }, { 56, 21 }, { 55, 23 } }
  if k % 2 == 1 then K.sprite({ "c...c", "cc.cc", ".cbc." }, mp[k][1], mp[k][2], { c = P.cream, b = P.wood.shade })
  else K.sprite({ ".cbc.", "cc.cc", "c...c" }, mp[k][1], mp[k][2], { c = P.cream, b = P.wood.shade }) end
  local LP = { { 3, 30 }, { 6, 27 }, { 9, 29 }, { 11, 26 } }
  leaf(LP[k][1], LP[k][2])
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
K.strip(out, "silk_shelf-empty", fr, W, H, "empty")
K.save(out, "silk_shelf-l1", drawL1())
K.save(out, "silk_shelf-l2", drawL2())
K.save(out, "silk_shelf-l3", drawL3())
local rf = {}
for k = 1, 4 do rf[k] = drawReady(k) end
K.strip(out, "silk_shelf-ready", rf, W, H, "ready")
