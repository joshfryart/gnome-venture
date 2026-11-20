-- compost_bin state sprites 64x56, anchor (32,46)
dofile("/tmp/ase/states2/kit_tc.lua")
local out = app.params.out or "/tmp/ase/states2/compost_bin/"
local W, H, AX, AY = 64, 56, 32, 46
local function new() return newc(W, H, "compost_bin") end
local THATCH = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local CARD = { hi = "#f0cf9a", base = "#d9a76a", shade = "#b9814d", deep = "#8a5a38" }
local X0, X1, YT, D = AX - 11, AX + 7, AY - 8, 4

-------------------------------------------------- worm
-- vertical worm, 3 wide: base (bx,by) at the hole, h tall, tipdx bends the top 2 rows
local function worm(bx, by, h, tipdx, eyes)
  tipdx = tipdx or 0
  local m = HP.mask()
  for i = 0, h - 1 do
    local sh = (i >= h - 2) and tipdx or 0
    local y = by - i
    if i == h - 1 then m:set(bx + 1 + sh, y):set(bx + sh, y):set(bx + 2 + sh, y)
    else m:set(bx + sh, y):set(bx + 1 + sh, y):set(bx + 2 + sh, y) end
  end
  ink(m)
  c:fillMask(m, P.petal.base)
  local base = { }
  for i = 0, h - 1 do
    local sh = (i >= h - 2) and tipdx or 0
    local y = by - i
    px(bx + 2 + sh, y, P.petal.shade)
    if i % 2 == 1 and i < h - 2 then R(bx + sh, y, bx + 2 + sh, y, P.petal.shade) end
    if i == h - 1 then px(bx + sh, y, P.petal.hi) end
  end
  if eyes and h >= 4 then
    local sh = tipdx; local ey = by - (h - 2)
    px(bx + sh, ey, P.ink); px(bx + 2 + sh, ey, P.ink)
    px(bx + 1 + sh, ey + 1, P.petal.deep)
    px(bx + sh, ey + 1, P.petal.hi)
  end
end
local function hole(x, y, w) R(x, y, x + w - 1, y, HEAP.deep) end

-------------------------------------------------- heap + bin
local function heapPaint(cx, cy, rx, ry, front, tex)
  local heap = E(cx, cy, rx, ry):cut(front)
  return heap
end
local function scrap(x, y, kind)
  if kind == "egg" then R(x, y, x + 1, y, P.cream); px(x, y - 1, P.cream); px(x + 1, y, "#e8c48a")
  elseif kind == "carrot" then R(x, y, x + 2, y, P.ember.hi); px(x + 2, y, P.ember.base); px(x - 1, y, P.moss.base)
  elseif kind == "peel" then R(x, y, x + 2, y, P.gold.hi); px(x + 1, y + 1, P.gold.shade)
  elseif kind == "leaf" then R(x, y, x + 1, y, P.moss.base); px(x, y - 1, P.moss.hi); px(x + 2, y, P.moss.shade)
  elseif kind == "apple" then R(x, y, x + 1, y, P.ember.base); px(x, y, P.ember.hi); px(x + 1, y + 1, P.ember.shade) end
end

-- main bin with heap. o.hy = heap centre y offset, o.hry = heap ry, o.noTopRight clips the top plane
local function mainBin(o)
  o = o or {}
  local x, y = AX, AY
  local front, side = c:rect(X0, YT, X1, y), sideWall(X1, YT, y, D)
  local heap = E(x - 1, y - (o.hc or 10), 9, o.hry or 4):cut(front)
  local top = topPlane(X0, X1, YT, D):cut(heap)
  if o.noside then side = HP.mask() end
  ink(front, side, heap, top)
  c:fillMask(front, LEAFD.base) c:fillMask(side, LEAFD.shade) c:fillMask(top, LEAFD.hi)
  for xx = X0 + 1, X1, 4 do R(xx, YT + 1, xx + 2, y - 1, P.moss.base) R(xx, YT + 1, xx, y - 1, P.moss.hi) end
  R(X0, y - 4, X1, y - 4, LEAFD.shade)
  side:each(function(xx, yy) if (yy + rise(xx - X1)) % 3 == 1 then px(xx, yy, LEAFD.deep) end end)
  R(X0, YT, X1, YT, P.moss.hi)
  R(X0, y, X1, y, LEAFD.deep)
  ball(heap, x - 1, y - (o.hc or 10) - 1, 9, o.hry or 4, HEAP, { nospec = true })
  local hy = y - (o.hc or 10)
  for _, p in ipairs{ { x - 6, hy - 2 }, { x - 2, hy - 3 }, { x + 3, hy - 2 }, { x + 6, hy }, { x - 8, hy } } do lt(p[1], hy and p[2], HEAP) lt(p[1] + 1, p[2], HEAP) end
  return heap, front
end

-- second compartment (right): front cx0..cx1, lid or tier on top
local function compartment(cx0, cx1, o)
  o = o or {}
  local y = AY
  local front, side = c:rect(cx0, YT, cx1, y), sideWall(cx1, YT, y, D)
  ink(front, side)
  c:fillMask(front, LEAFD.base) c:fillMask(side, LEAFD.shade)
  for xx = cx0 + 1, cx1, 4 do R(xx, YT + 1, xx + 2, y - 1, P.moss.base) R(xx, YT + 1, xx, y - 1, P.moss.hi) end
  R(cx0, y - 4, cx1, y - 4, LEAFD.shade)
  side:each(function(xx, yy) if (yy + rise(xx - cx1)) % 3 == 1 then px(xx, yy, LEAFD.deep) end end)
  R(cx0, y, cx1, y, LEAFD.deep)
  R(cx0, YT, cx1, YT, P.moss.hi)
  px(cx0, YT + 3, P.gold.hi); px(cx0, YT + 4, P.gold.base)    -- hinge
end
local function lid(cx0, cx1)
  local ly = YT - 2
  local face = c:rect(cx0 - 1, ly, cx1 + 1, YT - 1)
  local sd = sideWall(cx1 + 1, ly, YT - 1, D)
  local tp = topPlane(cx0 - 1, cx1 + 1, ly, D)
  ink(face, sd, tp)
  c:fillMask(face, P.wood.base); R(cx0 - 1, YT - 1, cx1 + 1, YT - 1, P.wood.shade)
  c:fillMask(sd, P.wood.shade)
  c:fillMask(tp, P.wood.hi)
  R(cx0 - 1, ly, cx1 + 1, ly, P.wood.hi)
  -- plank seams on the lid top and a knob handle
  tp:each(function(xx, yy) if (xx + yy) % 5 == 0 then px(xx, yy, lerp(P.wood.hi, P.wood.base, .6)) end end)
  local mx = (cx0 + cx1) // 2
  px(mx, ly - 1, P.stone.base); px(mx + 1, ly - 1, P.stone.shade)
end

-------------------------------------------------- levels
local function drawL1()
  new()
  castShadow(X0, X1, AY, D, 4, 3)
  local heap = mainBin()
  px(AX + 5, AY - 13, P.ember.base); px(AX - 8, AY - 11, P.moss.base)
  return c
end

local function pitchfork(x, y0)   -- stuck in the heap, handle up
  R(x, y0 + 3, x, y0 + 11, P.wood.base); px(x, y0 + 3, P.wood.hi)
  R(x - 2, y0 + 2, x + 2, y0 + 2, P.stone.shade)
  R(x - 2, y0, x - 2, y0 + 1, P.stone.base); R(x, y0, x, y0 + 1, P.stone.base); R(x + 2, y0, x + 2, y0 + 1, P.stone.base)
  px(x - 2, y0, P.stone.hi)
end

local function drawL2()
  new()
  local CX0, CX1 = X1 + 1, X1 + 6
  castShadow(X0, CX1, AY, D, 4, 3)
  mainBin({ hc = 12, hry = 6, noside = true })
  compartment(CX0, CX1)
  lid(CX0, CX1)
  local hy = AY - 12
  scrap(AX - 7, hy - 1, "egg"); scrap(AX - 2, hy - 4, "carrot"); scrap(AX + 4, hy - 2, "peel"); scrap(AX + 7, hy + 1, "leaf"); scrap(AX - 6, hy + 2, "apple")
  pitchfork(AX + 2, hy - 15)
  return c
end

local function drawL3()
  new()
  local CX0, CX1 = X1 + 1, X1 + 9
  castShadow(X0 - 4, CX1, AY, D, 4, 3)
  -- pail of scraps on the left (compost tea tap pipe into it)
  mainBin({ hc = 12, hry = 6, noside = true })
  compartment(CX0, CX1)
  -- tier: warm timber box with vents, on top of the right compartment
  local ty = YT - 9
  local tf = c:rect(CX0, ty, CX1, YT - 1)
  local ts = sideWall(CX1, ty, YT - 1, D)
  local F, S = hipRoof(CX0, CX1, ty - 1, ty - 7, 1, 2, D)
  ink(tf, ts, F, S)
  local Wt = wallTones(P.wood.base, P.wood.hi)
  c:fillMask(tf, Wt.base); c:fillMask(ts, Wt.sbase)
  for xx = CX0 + 2, CX1 - 1, 3 do R(xx, ty, xx, YT - 1, lerp(P.wood.base, P.wood.shade, .6)) end
  mottle(tf, Wt.base, Wt.lite, Wt.dark, 4, 6)
  ts:each(function(xx, yy) if (yy + rise(xx - CX1)) % 3 == 0 then px(xx, yy, Wt.sdark) end end)
  paintRoof(F, S, THATCH, { h = 3, w = 5, light = 12, dark = 8, seed = 2 })
  eaveShadow(CX0, CX1, ty, D, Wt, 1)
  for _, vx in ipairs{ CX0 + 1, CX0 + 5 } do R(vx, ty + 2, vx + 1, ty + 4, P.wood.deep); R(vx, ty + 2, vx + 1, ty + 3, INTERIOR); px(vx, ty + 2, P.ink); R(vx, ty + 5, vx + 1, ty + 5, P.wood.hi) end
  R(CX0, YT - 1, CX1, YT - 1, P.wood.shade)
  -- worm popping out of the heap
  local hy = AY - 12
  hole(AX - 5, hy - 6, 3)
  worm(AX - 5, hy - 7, 8, 0, true)
  scrap(AX + 2, hy - 4, "carrot"); scrap(AX + 5, hy - 1, "peel"); scrap(AX - 8, hy, "egg"); scrap(AX - 1, hy + 2, "leaf")
  -- pail of scraps at the left, tap pipe from the bin
  local px0 = X0 - 5
  local pail = c:poly{ { px0, AY - 5 }, { px0 + 5, AY - 5 }, { px0 + 4, AY }, { px0 + 1, AY } }
  local han = c:rect(px0, AY - 8, px0 + 5, AY - 8):add(c:rect(px0, AY - 7, px0, AY - 6)):add(c:rect(px0 + 5, AY - 7, px0 + 5, AY - 6))
  ink(pail, han)
  c:part(pail, "stone", { band = 1, pop = { x = px0 + 1, y = AY - 4, horizontal = true } })
  R(px0, AY - 5, px0 + 5, AY - 5, P.stone.hi)
  c:fillMask(han, P.stone.shade)
  R(px0 + 1, AY - 6, px0 + 4, AY - 6, P.moss.base); px(px0 + 2, AY - 6, P.ember.base); px(px0 + 4, AY - 6, P.gold.hi); px(px0 + 1, AY - 7, P.moss.hi)
  R(X0 - 1, AY - 3, X0 - 1, AY - 3, P.stone.shade)
  return c
end

-------------------------------------------------- empty plot
local ICON = {
  "....DDDD",
  "..DDHHGD",
  ".DGGGGGD",
  ".DGGvGGD",
  "DGGvGGD.",
  "DGvGGD..",
  "wD......",
}
local DXS = { 0, 1, 0, -1 }
local function leafIcon(x, y)
  c:paint(ICON, x, y, { D = P.moss.deep, G = P.moss.base, H = P.moss.hi, v = P.moss.shade, w = P.wood.shade })
end
local function drawEmpty(k)
  new()
  local plot = c:rrect(8, 31, 56, 51, 6)
  c:fillMask(plot:copy():shift(2, 2):cut(plot), SHD_A)
  ink(plot)
  c:part(plot, HEAP, { band = 2, nopop = true })
  for _, p in ipairs{ { 13, 40 }, { 20, 48 }, { 28, 44 }, { 38, 49 }, { 49, 43 }, { 52, 38 }, { 42, 36 }, { 15, 36 }, { 33, 47 } } do px(p[1], p[2], P.wood.base) px(p[1] + 1, p[2], P.wood.base) end
  for _, p in ipairs{ { 24, 41 }, { 45, 47 }, { 17, 44 }, { 35, 40 } } do px(p[1], p[2], HEAP.deep) end
  -- footprint string + stakes
  local BLp, BRp, FRp, FLp = { 20, 39 }, { 46, 39 }, { 48, 47 }, { 18, 47 }
  stringLine{ BLp, BRp }; stringLine{ BRp, FRp }; stringLine{ FRp, FLp }; stringLine{ FLp, BLp }
  stake(20, 34, 40); stake(46, 34, 40); stake(48, 42, 48); stake(18, 42, 48)
  -- stake behind the sign + leaning crate-lid sign
  local dx = DXS[k]
  stake(45, 9, 36)
  R(46, 10, 46, 35, P.wood.shade)
  local bx, by = 20 + dx, 11
  local function sh(r) return (r <= 3 and 2) or (r <= 8 and 1) or 0 end
  local board = HP.mask()
  for r = 0, 16 do for xx = bx + sh(r), bx + sh(r) + 24 do board:set(xx, by + r) end end
  c:fillMask(board:copy():shift(1, 1):cut(board), SHD_A)
  ink(board)
  c:fillMask(board, CARD.base)
  board:each(function(xx, yy)
    local r = yy - by
    if r == 0 then px(xx, yy, CARD.hi) end
    if r == 16 then px(xx, yy, CARD.shade) end
    if not board:has(xx - 1, yy) then px(xx, yy, CARD.hi) end
    if not board:has(xx + 1, yy) then px(xx, yy, CARD.shade) end
  end)
  -- corrugation dashes in the margins and a strip of tape
  for xx = bx + 5, bx + 20, 3 do px(xx + sh(1), by + 1, CARD.shade) end
  R(bx + 18 + sh(1), by, bx + 22 + sh(1), by + 1, P.cream)
  R(bx + 2 + sh(8), by + 15, bx + 5 + sh(8), by + 16, P.cream)
  leafIcon(bx + 8 + 1, by + 2 + 1)
  buildText(bx + 3, by + 10, P.ink)
  -- the sign's foot rests in a drift of earth
  pebble(bx + 3, by + 17, 3); pebble(bx + 19, by + 17, 3)
  -- life: a worm peeks out of the soil, leaf blows past
  local WH = { 2, 3, 3, 2 }
  local wx = 52
  hole(wx - 1, 46, 5)
  worm(wx, 45, WH[k] + 1, ({ 0, 1, 0, -1 })[k], false)
  local LP = { { 6, 43 }, { 21, 41 }, { 36, 44 }, { 51, 40 } }
  local lx, ly = LP[k][1], LP[k][2]
  local lm = c:rect(lx, ly, lx + 2, ly + 1)
  ink(lm)
  c:fillMask(lm, P.moss.base); px(lx, ly, P.moss.hi); px(lx + 2, ly + 1, P.moss.shade)
  px(lx - 1, ly + 1, P.wood.shade)
  -- stones, scraps, flowers
  pebble(10, 47, 3); pebble(54, 47, 2)
  scrap(14, 43, "egg"); scrap(36, 44, "leaf")
  flower(11, 38, P.petal.base); flower(55, 40, P.sky.hi)
  return c
end

-------------------------------------------------- ready
local BOB = { 0, -1, 0, 1 }
local function steamPuff(cx, cy, r)
  local m = E(cx, cy, r, math.max(r - 1, 1))
  c:fillMask(m, P.cream)
  m:each(function(x, y) if not m:has(x + 1, y) or not m:has(x, y + 1) then px(x, y, P.sky.shade) end end)
  m:each(function(x, y) if (not m:has(x - 1, y) and not m:has(x, y - 1)) then px(x, y, "#ffffff" == "" and P.cream or P.cream) end end)
end
local STEAM = {   -- per frame: list of {cx, cy, r}
  { { 36, 28, 2 }, { 34, 20, 3 }, { 37, 12, 4 } },
  { { 35, 26, 2 }, { 36, 18, 3 }, { 35, 11, 4 } },
  { { 36, 28, 3 }, { 35, 22, 3 }, { 36, 15, 4 }, { 38, 9, 3 } },
  { { 37, 26, 2 }, { 36, 20, 3 }, { 37, 13, 4 } },
}
local WORMH = { 5, 8, 8, 6 }
local WTIP = { 0, -1, 1, 0 }
local function gsparkle(x, y, big)
  px(x, y, P.moss.hi); R(x - 1, y, x + 1, y, P.moss.hi); R(x, y - 1, x, y + 1, P.moss.hi)
  px(x, y, P.cream)
  if big then px(x, y - 2, P.moss.base); px(x, y + 2, P.moss.base); px(x - 2, y, P.moss.base); px(x + 2, y, P.moss.base) end
end
local GS = { { 40, 30, true }, { 17, 30, false }, { 41, 26, false }, { 15, 34, true } }
local function drawReady(k)
  new()
  castShadow(X0, X1, AY, D, 4, 3)
  mainBin()
  px(AX + 5, AY - 13, P.ember.base); px(AX - 8, AY - 11, P.moss.base)
  local hy = AY - 10
  hole(AX - 11, hy - 3, 3)
  worm(AX - 11, hy - 4, WORMH[k], WTIP[k], true)
  for _, s in ipairs(STEAM[k]) do steamPuff(s[1], s[2], s[3]) end
  gsparkle(GS[k][1], GS[k][2], GS[k][3])
  badge(58, 7 + BOB[k])
  return c
end

-------------------------------------------------- output
local function check(cv) HP.assertClean(cv) end
local function save1(cv, name) check(cv); cv:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 } end
local ef, rf = {}, {}
for k = 1, 4 do ef[k] = drawEmpty(k); rf[k] = drawReady(k) end
for k = 1, 4 do check(ef[k]); check(rf[k]) end
HP.sheet{ cellw = W, cellh = H, frames = ef, tags = { { name = "empty", from = 1, to = 4 } } }:save{ aseprite = out .. "compost_bin-empty.aseprite", png = out .. "compost_bin-empty.png", scale = 1 }
HP.sheet{ cellw = W, cellh = H, frames = rf, tags = { { name = "ready", from = 1, to = 4 } } }:save{ aseprite = out .. "compost_bin-ready.aseprite", png = out .. "compost_bin-ready.png", scale = 1 }
save1(drawL1(), "compost_bin-l1"); save1(drawL2(), "compost_bin-l2"); save1(drawL3(), "compost_bin-l3")
