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

local function drawL2(wh, wtip)
  new()
  local CX0, CX1 = X1 + 1, X1 + 6
  castShadow(X0, CX1, AY, D, 4, 3)
  mainBin({ hc = 12, hry = 6, noside = true })
  compartment(CX0, CX1)
  lid(CX0, CX1)
  local hy = AY - 12
  scrap(AX - 7, hy - 1, "egg"); scrap(AX - 2, hy - 4, "carrot"); scrap(AX + 4, hy - 2, "peel"); scrap(AX + 7, hy + 1, "leaf"); scrap(AX - 6, hy + 2, "apple")
  pitchfork(AX + 2, hy - 15)
  if wh then hole(AX - 8, hy - 5, 3); worm(AX - 8, hy - 6, wh, wtip, true) end
  return c
end

local function drawL3(wh, wtip)
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
  worm(AX - 5, hy - 7, wh or 8, wtip or 0, true)
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
local STEAM2 = {
  { { 28, 25, 2 }, { 27, 18, 3 }, { 29, 10, 3 } },
  { { 27, 24, 2 }, { 28, 16, 3 }, { 27, 9, 3 } },
  { { 28, 25, 3 }, { 27, 19, 3 }, { 28, 12, 3 }, { 29, 6, 2 } },
  { { 29, 24, 2 }, { 28, 17, 3 }, { 29, 10, 3 } },
}
local STEAM3 = {
  { { 36, 24, 2 }, { 35, 17, 2 }, { 37, 10, 3 } },
  { { 35, 23, 2 }, { 36, 15, 3 }, { 35, 8, 3 } },
  { { 36, 24, 3 }, { 35, 18, 2 }, { 36, 11, 3 }, { 37, 5, 2 } },
  { { 37, 23, 2 }, { 36, 16, 3 }, { 37, 9, 3 } },
}
local VENT = { {}, { { 47, 24 } }, { { 48, 21 }, { 46, 25 } }, { { 47, 22 } } }
local GS2 = { { 22, 28, true }, { 40, 31, false }, { 21, 31, false }, { 41, 27, true } }
local GS3 = { { 20, 28, true }, { 43, 22, false }, { 19, 31, false }, { 45, 20, true } }
local WH2 = { 3, 5, 5, 4 }
local WT2 = { 0, 1, -1, 0 }
local WH3 = { 5, 8, 8, 6 }
local WT3 = { 0, -1, 1, 0 }
local function ready(lv, k)
  if lv == 2 then
    drawL2(WH2[k], WT2[k])
    for _, s in ipairs(STEAM2[k]) do steamPuff(s[1], s[2], s[3]) end
    gsparkle(GS2[k][1], GS2[k][2], GS2[k][3])
  else
    drawL3(WH3[k], WT3[k])
    for _, s in ipairs(STEAM3[k]) do steamPuff(s[1], s[2], s[3]) end
    for _, s in ipairs(VENT[k]) do steamPuff(s[1], s[2], 1) end
    gsparkle(GS3[k][1], GS3[k][2], GS3[k][3])
  end
  badge(58, 7 + BOB[k])
  return c
end
local function check(cv) HP.assertClean(cv) end
for lv = 2, 3 do
  local fr = {}
  for k = 1, 4 do fr[k] = ready(lv, k); check(fr[k]) end
  HP.sheet{ cellw = W, cellh = H, frames = fr, tags = { { name = "ready", from = 1, to = 4 } } }:save{ aseprite = out .. "compost_bin-ready-l" .. lv .. ".aseprite", png = out .. "compost_bin-ready-l" .. lv .. ".png", scale = 1 }
end
