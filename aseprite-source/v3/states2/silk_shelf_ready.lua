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
local function drawL2(o)
  o = o or {}
  newc()
  K.cast(AX - 10, AX + 7, AY, 4, 18, 4)
  hutch(AX - 3, AY, { "rack", "tray", "tray", "tray" }, { rh = 6, trayopt = o.trayopt })
  basket(AX + 12, AY - 3)
  leaf(AX + 16, AY + 3); tuft(13, AY + 2); flower(15, AY - 2, P.petal.base)
  return c
end
local function drawL3(o)
  o = o or {}
  newc()
  K.cast(AX - 12, AX + 9, AY, 4, 22, 4)
  local x0, x1, yt = hutch(AX - 2, AY, { "tray", "tray", "tray", "tray" }, { rh = 9, ov = 5, trayopt = o.trayopt })
  post(x0 - 4, yt + 2, AY); post(x1 + 4, yt + 2, AY)
  skein(x0 - 1, yt + 3)
  basket(AX + 13, AY - 3)
  tuft(10, AY + 2); flower(12, AY - 2, P.petal.base); leaf(AX + 15, AY + 3)
  return c
end

local BOB = { 0, -1, 0, 1 }
local function readyLevel(lv, k)
  local wob = ({ 0, 1, 0, -1 })[k]
  local n = (lv == 2) and 4 or 4
  local to = {}
  local first = (lv == 2) and 2 or 1
  for i = first, 4 do to[i] = { glow = (k + i) % 2 == 1, wob = (i % 2 == 0) and wob or -wob } end
  local x0, yt, sx0, sp, tx
  if lv == 2 then
    drawL2({ trayopt = to })
    x0 = AX - 3 - 10; yt = AY - 24; tx = x0 - 3
    sp = { { 46, AY - 24 }, { 49, AY - 14 }, { 54, AY - 20 }, { 51, AY - 8 } }
  else
    drawL3({ trayopt = to })
    x0 = AX - 2 - 10; yt = AY - 24; tx = 47
    sp = { { 49, AY - 22 }, { 52, AY - 12 }, { 47, AY - 28 }, { 53, AY - 6 } }
  end
  sx0 = x0 + 2
  for i = first, 4 do
    local sy = yt + 2 + 6 * (i - 1)
    local on = (k + i) % 2 == 0
    local gx = (i % 2 == 0) and wob or -wob
    for _, bx in ipairs{ sx0 + 2 + gx, sx0 + 9 - gx } do
      local col = on and P.gold.hi or P.gold.base
      px(bx + 1, sy, col); px(bx + 2, sy, col)
      px(bx - 1, sy + 1, col); px(bx + 4, sy + 1, col)
    end
  end
  thread(tx, yt + 1, ({ 0, 2, 0, -2 })[k], 16)
  c:sparkle(sp[k][1], sp[k][2])
  K.badge(W, BOB[k])
  return c
end
for _, lv in ipairs{ 2, 3 } do
  local rf = {}
  for k = 1, 4 do rf[k] = readyLevel(lv, k) end
  K.strip(out, "silk_shelf-ready-l" .. lv, rf, W, H, "ready")
end
