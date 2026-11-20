-- tortoise_run state sprites, 64x48, anchor (32,38). Hearth Pop v3.
local L = dofile("/tmp/ase/states2/lib_tb.lua")
local P, HP = L.P, L.HP
local out = app.params.out or "/tmp/ase/states2/tortoise_run/"
local c
local px, R, E = L.px, L.R, L.E
local lerp, dk, lt, ink, ball = L.lerp, L.dk, L.lt, L.ink, L.ball
local floor = math.floor
local W, H = 64, 48
local X, Y = 32, 38
local STRAW = L.STRAW
local OLIVE = { hi = "#e0e08a", base = "#aebd50", shade = "#728f3f", deep = "#3f5a3a" }
local SHELLB = { hi = P.wood.hi, base = P.wood.base, shade = P.wood.shade, deep = P.wood.deep }
local function rise(i) return (i + 1) // 2 end
local function sideWall(x1, yt, yb, d)
  local m = HP.mask()
  for i = 1, d do local s = rise(i); for yy = yt - s, yb - s do m:set(x1 + i, yy) end end
  return m
end

-- a tortoise: dome shell with scutes, head (nods by hy), tail, optional legs. facing right.
local function tort(cx, cy, T, hy, legs)
  hy = hy or 0
  local shell = E(cx, cy, 5, 3)
  local head = c:rect(cx + 5, cy + hy, cx + 7, cy + 1 + hy)
  local neck = c:rect(cx + 4, cy + 1, cx + 5, cy + 2)
  local tail = HP.mask():set(cx - 6, cy + 2):set(cx - 7, cy + 2)
  local lg = HP.mask()
  if legs then lg:set(cx - 3, cy + 4):set(cx - 2, cy + 4):set(cx + 2, cy + 4):set(cx + 3, cy + 4):set(cx - 3, cy + 3):set(cx + 3, cy + 3) end
  L.shadeUnder(E(cx + 2, cy + 4, 5, 1), .22)
  c:rim(shell:copy():add(head):add(neck):add(tail):add(lg), P.ink)
  c:fillMask(lg, P.wood.shade) c:fillMask(neck, P.wood.base)
  ball(shell, cx, cy, 5, 3, T)
  for yy = cy - 2, cy + 2 do dk(cx - 2, yy, T) dk(cx + 2, yy, T) end
  px(cx, cy - 1, T.hi) px(cx - 1, cy, T.shade) px(cx + 1, cy, T.shade)
  c:fillMask(head, P.wood.hi) px(cx + 7, cy + hy, P.wood.base) px(cx + 5, cy + 1 + hy, P.wood.base) px(cx + 6, cy + 1 + hy, P.wood.base)
  px(cx + 6, cy + hy, P.ink)                       -- eye
  c:fillMask(tail, P.wood.base)
  return shell
end

local function dish(cx, cy)
  local o = E(cx, cy, 4, 2)
  ink(o)
  c:fillMask(o, P.stone.base) R(cx - 3, cy - 1, cx + 2, cy - 1, P.stone.hi)
  local w = E(cx, cy, 3, 1)
  c:fillMask(w, P.sea.base) R(cx - 2, cy, cx + 2, cy, P.sea.shade) px(cx - 2, cy - 1, P.sea.hi) px(cx - 1, cy - 1, P.sea.hi) px(cx + 1, cy - 1, P.cream)
end
local function rock(cx, cy, rx, ry, moss)
  local m = E(cx, cy, rx, ry)
  ink(m)
  ball(m, cx, cy, rx, ry, P.stone, { spec = true })
  px(cx + 1, cy + ry - 1, P.stone.deep)
  if moss then R(cx - rx + 2, cy - ry + 1, cx - rx + 3, cy - ry + 1, P.moss.base) px(cx - rx + 2, cy - ry + 2, P.moss.shade) end
  return m
end

-- the run. o.g = growth each side, o.n = floor depth
local function run(x, y, o)
  local d, n, g = 3, o.n, o.g
  local x0, x1 = x - 14 - g, x + 11 + g
  -- cast shadow
  local sh = HP.mask()
  for j = 1, 3 do for xx = x0 + j, x1 + d + j + 1 do sh:set(xx, y + j) end end
  for yy = y - n - 4, y do local t = (yy - (y - n - 4)) / (n + 4); for xx = x1 + d + 1, x1 + d + 1 + floor(t * 6 + .5) do sh:set(xx, yy) end end
  L.shadow(sh, c:rect(x0 + 1, y + 2, x1 + d, y + 2))
  local fb = c:rect(x0, y - 3, x1, y)
  local floorM = HP.mask() for j = 1, n do for xx = x0 + j // 2, x1 + math.min(d, j // 2 + 1) do floorM:set(xx, y - 3 - j) end end
  local back = c:rect(x0 + n // 2, y - n - 5, x1 + d, y - n - 4)
  local side = sideWall(x1, y - 3, y, d)
  local px0, px1 = x0 + n // 2, x1 + 2
  local posts = HP.mask()
  for _, p in ipairs{ { x0, y - 6 }, { x1 - 1, y - 6 }, { px0, y - n - 7 }, { px1, y - n - 7 } } do posts:add(c:rect(p[1], p[2], p[1] + 1, p[2] + 3)) end
  local rail = HP.mask()
  if n > 6 then rail = c:rect(x1 + d - 1, y - n - 4, x1 + d, y - 4) end
  ink(fb, floorM, back, side, posts, rail)
  c:fillMask(floorM, STRAW.base)
  for yy = y - n - 3, y - 4 do for xx = x0, x1 + d do if floorM:has(xx, yy) and (xx + yy * 2) % 6 == 0 then dk(xx, yy, STRAW) lt(xx + 1, yy - 1, STRAW) end end end
  R(x0 + n // 2, y - n - 3, x1 + d, y - n - 3, STRAW.shade)
  c:fillMask(back, P.wood.shade) R(x0 + n // 2, y - n - 5, x1 + d, y - n - 5, P.wood.base)
  c:fillMask(fb, P.wood.base) R(x0, y - 3, x1, y - 3, P.wood.hi) R(x0, y, x1, y, P.wood.shade)
  for xx = x0 + 3, x1, 5 do px(xx, y - 1, P.wood.shade) end
  c:fillMask(side, P.wood.shade) for i = 1, d do px(x1 + i, y - 3 - rise(i), P.wood.base) end
  if n > 6 then c:fillMask(rail, P.wood.shade) R(x1 + d - 1, y - n - 4, x1 + d - 1, y - 4, P.wood.base) end
  posts:each(function(a, b) px(a, b, ((a - x0) % 2 == 0) and P.wood.base or P.wood.shade) end)
  for _, p in ipairs{ { x0, y - 6 }, { x1 - 1, y - 6 }, { px0, y - n - 7 }, { px1, y - n - 7 } } do px(p[1], p[2], P.wood.hi) end
  return x0, x1
end

local function level1(hy)
  c = L.new(W, H)
  run(X, Y, { n = 6, g = 0 })
  tort(X - 1, Y - 5, P.moss, hy or 0, false)
end

local function level2()
  c = L.new(W, H)
  run(X, Y, { n = 10, g = 3 })
  rock(X - 11, Y - 11, 4, 3, true)
  tort(X + 2, Y - 10, OLIVE, 0, true)
  dish(X + 11, Y - 6)
  tort(X - 4, Y - 5, P.moss, 0, false)
end

local function level3()
  c = L.new(W, H)
  local x0, x1 = run(X, Y, { n = 13, g = 6 })
  -- shelter: a thatched dome with a dark arched door, at the back right
  local dx, dy = X + 11, Y - 12
  local dome = E(dx, dy, 7, 8):clip(c:rect(0, 0, W, dy))
  ink(dome)
  ball(dome, dx, dy, 7, 8, L.LEAFD == nil and P.gold or { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }, { nospec = true, t1 = .5 })
  for yy = dy - 7, dy - 1, 2 do for xx = dx - 7, dx + 7, 1 do if dome:has(xx, yy) and dome:has(xx - 1, yy) and (xx + yy) % 4 == 0 then dk(xx, yy, P.gold) end end end
  local door = c:rrect(dx - 2, dy - 6, dx + 2, dy, 2):clip(c:rect(0, 0, W, dy))
  c:fillMask(door, P.wood.deep) c:fillMask(door:shrink(1), L.INTERIOR) R(dx - 3, dy - 7, dx + 3, dy - 7, P.wood.hi)
  R(dx - 2, dy, dx + 2, dy, P.stone.base) R(dx - 2, dy, dx + 1, dy, P.stone.hi)
  -- a flag-lit crest: little leafy tuft on top
  px(dx, dy - 9, P.moss.base) px(dx + 1, dy - 10, P.moss.base) px(dx - 1, dy - 10, P.moss.hi) px(dx, dy - 10, P.moss.shade)
  -- basking rock with the third tortoise on top
  local bx, by = X - 11, Y - 10
  local br = E(bx, by, 8, 4)
  ink(br)
  ball(br, bx, by, 8, 4, P.stone, { spec = true, t1 = .5 })
  px(bx - 4, by + 1, P.stone.shade) px(bx + 3, by + 2, P.stone.shade) px(bx + 4, by + 1, P.stone.shade)
  tort(bx, by - 5, SHELLB, 0, false)
  dish(X + 11, Y - 5)
  tort(X + 3, Y - 8, OLIVE, 0, true)
  tort(X - 4, Y - 4, P.moss, 0, false)
  -- flowers outside the front boards
  L.flower(x0 - 3, Y - 2, P.petal.base, 1) L.flower(x0 - 6, Y + 1, P.gold.base) L.flower(x1 + 7, Y - 1, P.sky.hi, 1) L.flower(x1 + 4, Y + 3, P.petal.base)
end

-- ready: level 1 + nod, scute drop, sparkle, badge
local HY = { 0, 1, 0, 1 }
local SC = { { 29, 27 }, { 33, 21 }, { 37, 24 }, { 40, 30 } }
local SP = { { 24, 23 }, { 41, 18 }, { 25, 27 }, { 45, 25 } }
local BOB = { 0, -1, 0, 1 }
local function scute(x, y)
  local m = c:rrect(x, y, x + 3, y + 3, 1)
  c:rim(m, P.ink)
  c:fillMask(m, P.gold.base) R(x + 1, y, x + 2, y, P.gold.hi) px(x, y + 1, P.gold.hi) R(x + 1, y + 3, x + 3, y + 3, P.gold.shade) px(x + 3, y + 2, P.gold.shade)
  px(x + 1, y + 1, P.cream)
end
local function ready(k)
  level1(HY[k])
  scute(SC[k][1], SC[k][2])
  L.spark(SP[k][1], SP[k][2])
  L.badge(BOB[k])
  return c
end

-- empty: plot, boulder with a strapped BUILD sign
local ICON = { ".hggg..", "hgsgsww", "gsgsgwi", "ddddd..", ".w.w..." }
local function icon(x, y)
  local map = { h = P.moss.hi, g = P.moss.base, s = P.moss.shade, d = P.moss.deep, w = P.wood.shade, i = P.ink }
  c:paint(ICON, x, y, map)
  px(x + 6, y + 1, P.ink)
end
local function sign(dx, dy)
  local bx0, by0, bx1, by1 = 5 + dx, 11 + dy, 37 + dx, 21 + dy
  local board = c:rect(bx0, by0, bx1, by1)
  local straps = c:rect(bx0, by0 - 2, bx0 + 1, by1 + 2):add(c:rect(bx1 - 1, by0 - 2, bx1, by1 + 2))
  local tail = HP.mask():set(bx1 + 1, by1 + 3 + (dx == 1 and 0 or 0)):set(bx1 + 2, by1 + 3):set(bx1 + 2, by1 + 4)
  ink(board, straps, tail)
  c:fillMask(board, "#f0cfa0")
  R(bx0, by0, bx1, by0, P.cream) R(bx0, by1, bx1, by1, P.wood.base) R(bx0, by1 - 1, bx1, by1 - 1, "#dcae7e")
  px(bx0 + 3, by0 + 3, "#dcae7e") px(bx1 - 3, by1 - 2, "#dcae7e")
  c:fillMask(straps, L.ROPE.base)
  for _, sx in ipairs{ bx0, bx1 - 1 } do
    R(sx, by0 - 2, sx, by1 + 2, L.ROPE.hi) R(sx + 1, by0 - 2, sx + 1, by1 + 2, L.ROPE.shade)
    for yy = by0 - 1, by1 + 2, 2 do px(sx, yy, L.ROPE.base) px(sx + 1, yy - 1, L.ROPE.deep) end
  end
  c:fillMask(tail, L.ROPE.shade) px(bx1 + 1, by1 + 3, L.ROPE.base)
  icon(bx0 + 3, by0 + 3)
  L.build(bx0 + 11, by0 + 3, P.ink)
end
local function empty(k)
  c = L.new(W, H)
  local DX = { 0, 1, 1, 0 }
  local DY = { 0, 0, 0, 0 }
  -- plot
  local plot = L.plot(4, 29, 59, 43, 6)
  -- the boulder behind (cast shadow on the plot, lit upper left)
  L.shadeUnder(E(33, 32, 19, 3):clip(plot), .35)
  local bd = E(21, 16, 20, 13)
  ink(bd)
  ball(bd, 21, 16, 20, 13, P.stone, { spec = false, t1 = .58, t2 = .12 })
  for _, p in ipairs{ { 3, 20 }, { 6, 25 }, { 38, 12 }, { 37, 24 }, { 12, 28 }, { 18, 4 }, { 30, 3 } } do dk(p[1], p[2], P.stone) end
  R(7, 27, 9, 27, P.moss.base) R(8, 28, 10, 28, P.moss.shade) px(7, 26, P.moss.hi)
  R(34, 9, 36, 9, P.stone.hi) R(9, 6, 14, 6, P.stone.hi)
  sign(DX[k], DY[k])
  -- footprint stakes + string
  local t = 31
  L.string({ { 15, 29 }, { 49, 29 }, { 55, 35 }, { 9, 35 }, { 15, 29 } }, true)
  L.stake(14, 28, 34); L.stake(48, 28, 34); L.stake(8, 34, 40); L.stake(54, 34, 40)
  L.stone(45, 36, 4, 3); L.stone(20, 38, 3, 2); L.stone(41, 40, 3, 2)
  L.flower(10, 40, P.petal.base); L.flower(57, 40, P.gold.base, 0); L.flower(31, 40, P.sky.hi)
  px(26, 37, P.moss.base); px(27, 36, P.moss.base); px(36, 37, P.moss.base); px(37, 36, P.moss.base)
  -- life: a leaf blows past
  local LX = { { 43, 25 }, { 47, 23 }, { 52, 25 }, { 57, 22 } }
  L.leaf(LX[k][1], LX[k][2], k % 2 == 0)
  return c
end

local E4, R4 = {}, {}
for k = 1, 4 do E4[k] = empty(k) end
local c1 = (function() level1(0) return c end)()
local c2 = (function() level2() return c end)()
local c3 = (function() level3() return c end)()
for k = 1, 4 do R4[k] = ready(k) end
L.saveAll("tortoise_run", out, W, H, E4, c1, c2, c3, R4)
