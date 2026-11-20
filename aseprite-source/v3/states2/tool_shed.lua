-- tool_shed state sprites 72x56, anchor (36,46)
dofile("/tmp/ase/states2/kit_tc.lua")
local out = app.params.out or "/tmp/ase/states2/tool_shed/"
local W, H, AX, AY = 72, 56, 36, 46
local function new() return newc(W, H, "tool_shed") end
local PINK = P.petal

-------------------------------------------------- props
local function sparrow(x, y, flip)
  local body = E(x + 3, y + 2, 3, 2)
  local tail = flip and c:rect(x + 7, y + 2, x + 8, y + 3) or c:rect(x - 2, y + 2, x - 1, y + 3)
  local legs = HP.mask():set(x + 2, y + 5):set(x + 4, y + 5)
  ink(body, tail)
  c:fillMask(legs, P.ink)
  c:fillMask(body, P.wood.base)
  c:fillMask(tail, P.wood.shade)
  R(x + 1, y + 3, x + 5, y + 4, P.cream)
  R(x + 1, y + 1, x + 5, y + 1, P.wood.shade)
  px(flip and x + 1 or x + 5, y + 2, P.wood.shade)
  px(flip and x or x + 6, y + 1, P.wood.hi)
  px(flip and x - 1 or x + 6, y + 2, P.gold.base)
  px(flip and x + 1 or x + 5, y + 1, P.ink)
end
local function pegSpade(x, y)  -- a spade leaning: stands upright, 1px handle, stone blade
  R(x, y, x, y + 7, P.wood.base); px(x, y, P.wood.hi)
  R(x - 1, y + 8, x + 1, y + 10, P.stone.base); px(x - 1, y + 8, P.stone.hi); px(x + 1, y + 10, P.stone.shade)
end
local function wateringCan(x, y)  -- (x,y) top-left, 7x5
  local body = c:rect(x, y + 1, x + 4, y + 4)
  local spout = c:poly{ { x + 5, y + 3 }, { x + 7, y }, { x + 7, y + 1 }, { x + 5, y + 4 } }
  local handle = HP.mask():set(x + 1, y):set(x + 2, y):set(x + 3, y)
  ink(body, spout, handle)
  c:part(body, "sea", { band = 1, pop = { x = x + 1, y = y + 2, horizontal = true } })
  c:fillMask(spout, P.sea.shade)
  c:fillMask(handle, P.sea.deep)
end
local function leafIcon() end

-- crossed hammer + saw icon, 7x7 at (x,y)
local ICON = {
  "HHH...S",
  "HHH..SS",
  ".Hw.SS.",
  "..wSs..",
  ".gSwS..",
  "gg..w..",
  "gg...w.",
}
local function toolsIcon(x, y)
  c:paint(ICON, x, y, { H = P.stone.deep, w = P.wood.shade, S = P.stone.shade, s = P.stone.hi, g = P.ember.base })
  px(x, y, P.stone.shade)
end

-------------------------------------------------- the shed (L1 as in the finished scene)
local function shedBody(o)
  o = o or {}
  local x, y = AX, AY
  local x0, x1, yt, d = x - 12, x + 9, y - 14, 4
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 21, 3, 6, d)
  local pieces = { front, side, F, S }
  local rake
  if not o.norake then
    rake = c:rect(x + 17, y - 16, x + 17, y):add(c:rect(x + 15, y - 17, x + 19, y - 17))
    pieces[#pieces + 1] = rake
  end
  ink(table.unpack(pieces))
  local Wt = wallTones(P.wood.base, P.wood.hi)
  paintWalls(front, side, Wt, 7)
  for xx = x0 + 3, x1 - 1, 4 do R(xx, yt, xx, y, lerp(P.wood.base, P.wood.shade, .6)) end
  for xx = x0 + 1, x1, 4 do px(xx, yt + 3, P.wood.hi) px(xx, y - 3, P.wood.hi) end
  side:each(function(xx, yy) if (yy + rise(xx - x1)) % 3 == 0 then px(xx, yy, Wt.sdark) end end)
  paintRoof(F, S, SHEDR, { h = 3, w = 4, light = 14, dark = 8, seed = 7 })
  eaveShadow(x0, x1, yt, d, Wt, 1)
  plinth(x0, x1, y, d, 1)
  door(x - 5, x + 1, y - 10, y, { ramp = { hi = P.wood.hi, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }, frame = P.wood.deep, arch = 0 })
  R(x - 4, y - 6, x, y - 6, P.wood.base)
  if not o.nowindow then window(x + 4, y - 11, 3, 3, { frame = P.wood.deep, sill = P.wood.hi, sillsh = Wt.eave, nobar = true }) end
  if not o.norake then
    R(x + 17, y - 16, x + 17, y, P.wood.base) px(x + 17, y - 16, P.wood.hi)
    R(x + 15, y - 17, x + 19, y - 17, P.stone.base) px(x + 15, y - 17, P.stone.hi) px(x + 19, y - 17, P.stone.shade)
  end
  return Wt
end

-- tool rack on the front wall (L2/L3)
local function toolRack()
  local x, y = AX, AY
  local board = c:rect(x + 3, y - 12, x + 8, y - 11)
  ink(board)
  c:fillMask(board, P.wood.deep); R(x + 3, y - 12, x + 8, y - 12, P.wood.hi)
  -- hanging tools: spade, saw, hammer
  R(x + 4, y - 10, x + 4, y - 4, P.wood.hi); R(x + 3, y - 4, x + 5, y - 2, P.stone.base); px(x + 3, y - 4, P.stone.hi); px(x + 5, y - 2, P.stone.shade)
  R(x + 6, y - 10, x + 6, y - 9, P.ember.base); R(x + 6, y - 8, x + 7, y - 4, P.stone.hi); px(x + 7, y - 5, P.stone.shade); px(x + 7, y - 7, P.stone.shade)
  R(x + 8, y - 10, x + 8, y - 5, P.wood.base); R(x + 7, y - 4, x + 9, y - 3, P.stone.deep); px(x + 7, y - 4, P.stone.shade)
  px(x + 3, y - 11, P.gold.hi); px(x + 8, y - 11, P.gold.hi)
end

-- lean-to wing on the left
local LEANR = { hi = P.sea.hi, base = P.sea.base, shade = P.sea.shade, deep = P.sea.deep }
local function leanTo(wide, tall)
  local y = AY
  local xl = 23 - wide            -- first wall column (wall runs xl..22)
  local yt = y - (tall or 11)
  local wall = c:rect(xl, yt, 22, y)
  local F = c:poly{ { xl - 1, yt + 1 }, { xl + 2, yt - 4 }, { 25, yt - 4 }, { 25, yt + 1 } }
  ink(wall, F)
  local WL = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }
  c:fillMask(wall, WL.base)
  for yy = yt + 3, y - 1, 3 do R(xl, yy, 22, yy, WL.shade) end       -- horizontal boards
  for yy = yt + 2, y - 1, 3 do for xx = xl + 1, 22, 5 do px(xx, yy, P.wood.base) end end
  paintRoof(F, c:rect(0, 0, 0, 0):cut(c:rect(0, 0, 0, 0)), SHEDR, { h = 3, w = 4, light = 14, dark = 8, seed = 3 })
  R(xl, yt + 1, 22, yt + 1, WL.deep)
  R(xl, y, 22, y, P.stone.shade)
  return xl
end
local function leanDoor(xl)
  local dx = xl + 2
  door(dx, dx + 2, AY - 8, AY, { ramp = { hi = P.wood.hi, base = P.wood.base, shade = P.wood.shade, deep = P.wood.deep }, frame = P.wood.deep, arch = 0, nostep = true })
  px(dx + 2, AY - 4, P.gold.hi)
end
local function chimneyPipe()
  local x, y = AX, AY
  local pipe = c:rect(x - 8, y - 29, x - 6, y - 21)
  local cap = c:rect(x - 9, y - 31, x - 5, y - 30)
  ink(pipe, cap)
  c:fillMask(pipe, P.stone.base); R(x - 6, y - 29, x - 6, y - 22, P.stone.shade); R(x - 8, y - 29, x - 8, y - 22, P.stone.hi)
  c:fillMask(cap, P.stone.shade); R(x - 9, y - 31, x - 5, y - 31, P.stone.hi); R(x - 7, y - 31, x - 7, y - 31, P.ink)
  R(x - 8, y - 25, x - 6, y - 25, P.stone.shade)
end

-------------------------------------------------- levels
local function drawL1(opt)
  opt = opt or {}
  new()
  castShadow(AX - 12, AX + 9, AY, 4, 9, 4)
  shedBody()
  return c
end

local function drawL2()
  new()
  castShadow(AX - 12, AX + 9, AY, 4, 9, 4)
  local xl = leanTo(7, 12)
  shedBody({ nowindow = true })
  chimneyPipe()
  toolRack()
  leanDoor(xl + 1)
  wateringCan(xl + 8, AY + 1)
  return c
end

local function drawL3()
  new()
  castShadow(AX - 12, AX + 9, AY, 4, 9, 4)
  -- extended wing: 11 wide with a window beside the door
  local xl = leanTo(10, 13)
  shedBody({ nowindow = true, norake = true })
  toolRack()
  local Wt = wallTones(P.wood.base, P.wood.hi)
  window(xl + 1, AY - 8, 3, 3, { frame = P.wood.deep, sill = P.wood.hi, sillsh = Wt.eave, nobar = true, glow = true })
  leanDoor(xl + 5)
  chimneyPipe()
  -- ridge: weathervane (gold arrow) on a short post
  local ridgeY = AY - 21
  R(AX + 1, ridgeY - 7, AX + 1, ridgeY, P.ink)
  R(AX - 3, ridgeY - 6, AX + 5, ridgeY - 6, P.ink)
  R(AX - 2, ridgeY - 5, AX + 4, ridgeY - 5, P.ink)
  px(AX, ridgeY - 3, P.ink)
  R(AX - 1, ridgeY - 4, AX + 3, ridgeY - 4, P.ink)
  px(AX + 1, ridgeY - 5, P.gold.base); R(AX, ridgeY - 4, AX + 2, ridgeY - 4, P.gold.base); px(AX - 2, ridgeY - 5, P.gold.hi); px(AX + 4, ridgeY - 5, P.gold.shade)
  R(AX + 1, ridgeY - 3, AX + 1, ridgeY, P.wood.shade)
  -- hanging lamp from the eave, right of the door
  local lx = AX + 6
  R(lx + 1, AY - 14, lx + 1, AY - 13, P.ink)
  local cap = c:rect(lx, AY - 12, lx + 2, AY - 12)
  local body = c:rect(lx, AY - 11, lx + 2, AY - 8)
  ink(cap, body)
  c:fillMask(cap, P.stone.shade); c:fillMask(body, P.gold.hi); px(lx + 1, AY - 10, P.cream); R(lx + 2, AY - 11, lx + 2, AY - 8, P.gold.base)
  -- workbench outside, right
  local bx = 50
  local top = c:rect(bx, AY - 6, bx + 9, AY - 5)
  local legs = c:rect(bx + 1, AY - 4, bx + 1, AY):add(c:rect(bx + 8, AY - 4, bx + 8, AY))
  ink(top, legs)
  c:part(legs, "wood", { band = 1, nopop = true })
  c:part(top, "wood", { band = 1, pop = { x = bx + 1, y = AY - 6, horizontal = true } })
  -- vice + saw on the bench top
  local vice = c:rect(bx + 7, AY - 9, bx + 9, AY - 7)
  ink(vice); c:part(vice, "stone", { band = 1, nopop = true })
  R(bx + 1, AY - 8, bx + 5, AY - 7, P.stone.base); R(bx + 1, AY - 8, bx + 5, AY - 8, P.stone.hi); px(bx + 6, AY - 7, P.ember.base) ; px(bx, AY - 7, P.ember.base)
  -- spare wheelbarrow, in front of the wing
  local wx = 12
  local tray = c:poly{ { wx, AY + 1 }, { wx + 9, AY + 1 }, { wx + 7, AY + 5 }, { wx + 2, AY + 5 } }
  local wheel = E(wx + 11, AY + 5, 2, 2)
  local leg = c:rect(wx + 2, AY + 6, wx + 2, AY + 7):add(c:rect(wx + 7, AY + 6, wx + 7, AY + 7))
  local handle = c:rect(wx - 3, AY, wx, AY)
  ink(tray, wheel, leg, handle)
  c:fillMask(leg, P.wood.deep); c:fillMask(handle, P.wood.base)
  c:part(tray, "moss", { band = 1, pop = { x = wx + 2, y = AY + 2, horizontal = true } })
  R(wx, AY + 1, wx + 9, AY + 1, P.moss.hi)
  c:fillMask(wheel, P.wood.shade); px(wx + 11, AY + 5, P.stone.base)
  return c
end

-------------------------------------------------- empty plot (4 frames)
local SWAY = { 0, 1, 1, 0 }
local function drawEmpty(k)
  new()
  -- plot of cleared earth with a hard cast shadow behind it
  local plot = c:rrect(12, 32, 60, 51, 6)
  c:fillMask(plot:copy():shift(2, 2):cut(plot), SHD_A)
  ink(plot)
  c:part(plot, HEAP, { band = 2, nopop = true })
  for _, p in ipairs{ { 18, 40 }, { 24, 48 }, { 33, 41 }, { 41, 49 }, { 52, 44 }, { 56, 40 }, { 46, 38 }, { 20, 45 } } do px(p[1], p[2], P.wood.base) px(p[1] + 1, p[2], P.wood.base) end
  for _, p in ipairs{ { 29, 47 }, { 38, 44 }, { 49, 47 }, { 17, 37 } } do px(p[1], p[2], HEAP.deep) end
  -- string line round the footprint, stakes on top
  local BLp, BRp, FRp, FLp = { 22, 38 }, { 50, 38 }, { 52, 47 }, { 20, 47 }
  stringLine{ BLp, BRp }; stringLine{ BRp, FRp }; stringLine{ FRp, FLp }; stringLine{ FLp, BLp }
  stake(22, 33, 39); stake(50, 33, 39); stake(52, 42, 48); stake(20, 42, 48)
  -- peg shadows
  -- signpost: post, then the BUILD plank
  local post = c:rect(35, 24, 37, 38)
  ink(post); c:part(post, "wood", { band = 1, nopop = true })
  local dx = SWAY[k]
  local bx, by = 24 + dx, 8
  local board = c:rect(bx, by, bx + 24, by + 16)
  c:fillMask(board:copy():shift(1, 1):cut(board), SHD_A)
  ink(board)
  c:fillMask(board, P.wood.hi)
  R(bx, by, bx + 24, by, P.wood.base); R(bx, by + 16, bx + 24, by + 16, P.wood.shade)
  R(bx, by, bx, by + 16, P.wood.base); R(bx + 24, by, bx + 24, by + 16, P.wood.shade)
  R(bx + 1, by + 1, bx + 23, by + 1, lerp(P.wood.hi, P.cream, .5))
  px(bx + 1, by + 1, P.stone.hi); px(bx + 23, by + 1, P.stone.hi); px(bx + 1, by + 15, P.stone.hi); px(bx + 23, by + 15, P.stone.base)
  toolsIcon(bx + 9, by + 3)
  buildText(bx + 3, by + 10, P.ink)
  -- sparrow hopping along the front of the plot
  local SP = { { 44, 46, false }, { 46, 43, false }, { 48, 46, false }, { 46, 43, true } }
  sparrow(SP[k][1], SP[k][2], SP[k][3])
  -- stones and flowers
  pebble(14, 46, 3); pebble(55, 45, 3); pebble(29, 49, 2)
  flower(16, 42, P.sky.hi); flower(55, 41, P.gold.base)
  flower(26, 45, P.petal.base)
  return c
end

-------------------------------------------------- ready
local BOB = { 0, -1, 0, 1 }
local function hammer(k)
  local HT = { 30, 33, 36, 33 }       -- head top
  local hy, hx = HT[k], 63
  local handle = c:line({ { hx + 7, hy - 7 }, { hx + 3, hy } }, 2)
  local head = c:rect(hx, hy, hx + 5, hy + 2)
  ink(handle, head)
  c:fillMask(handle, P.wood.base); px(hx + 7, hy - 7, P.wood.hi)
  c:fillMask(head, P.stone.base); R(hx, hy, hx + 5, hy, P.stone.hi); R(hx, hy + 2, hx + 5, hy + 2, P.stone.shade); px(hx + 5, hy + 1, P.stone.shade)
end
local function benchAndTool(k)
  local bx = 57
  local top = c:rect(bx, 42, bx + 13, 43)
  local legs = c:rect(bx + 1, 44, bx + 2, AY):add(c:rect(bx + 11, 44, bx + 12, AY))
  ink(top, legs)
  c:part(legs, "wood", { band = 1, nopop = true })
  c:part(top, "wood", { band = 1, pop = { x = bx + 1, y = 42, horizontal = true } })
  -- the worn spade lying on the bench: handle + blade
  local han = c:rect(bx + 1, 40, bx + 7, 40)
  local bl = c:rect(bx + 8, 39, bx + 11, 41)
  ink(han, bl)
  c:fillMask(han, P.wood.base); px(bx + 1, 40, P.wood.hi)
  c:fillMask(bl, P.stone.base); R(bx + 8, 39, bx + 11, 39, P.stone.hi); R(bx + 8, 41, bx + 11, 41, P.stone.shade)
  -- the crack that is being mended
  px(bx + 10, 40, P.ember.base)
end
local SPARKS = {
  {},
  {},
  { { 60, 35, P.gold.hi }, { 69, 35, P.gold.hi }, { 66, 32, P.cream } },
  { { 59, 32, P.gold.base }, { 69, 33, P.gold.hi }, { 62, 28, P.cream }, { 68, 29, P.gold.hi } },
}
local GLINT = { { 67, 37 }, { 61, 36 }, { 59, 34 }, { 68, 36 } }
local function drawReady(k)
  new()
  castShadow(AX - 12, AX + 9, AY, 4, 9, 4)
  shedBody()
  benchAndTool(k)
  hammer(k)
  for _, s in ipairs(SPARKS[k]) do R(s[1], s[2], s[1] + 1, s[2], s[3]); px(s[1], s[2] - 1, s[3]); px(s[1] + 1, s[2] + 1, P.gold.base) end
  if k <= 2 then c:sparkle(GLINT[k][1], GLINT[k][2]) end
  if k == 4 then c:sparkle(GLINT[4][1], GLINT[4][2]) end
  badge(66, 7 + BOB[k])
  return c
end

-------------------------------------------------- output
local function check(cv) HP.assertClean(cv) end
local function save1(cv, name) check(cv); cv:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 } end
local ef, rf = {}, {}
for k = 1, 4 do ef[k] = drawEmpty(k); rf[k] = drawReady(k) end
for k = 1, 4 do check(ef[k]); check(rf[k]) end
HP.sheet{ cellw = W, cellh = H, frames = ef, tags = { { name = "empty", from = 1, to = 4 } } }:save{ aseprite = out .. "tool_shed-empty.aseprite", png = out .. "tool_shed-empty.png", scale = 1 }
HP.sheet{ cellw = W, cellh = H, frames = rf, tags = { { name = "ready", from = 1, to = 4 } } }:save{ aseprite = out .. "tool_shed-ready.aseprite", png = out .. "tool_shed-ready.png", scale = 1 }
save1(drawL1(), "tool_shed-l1"); save1(drawL2(), "tool_shed-l2"); save1(drawL3(), "tool_shed-l3")
