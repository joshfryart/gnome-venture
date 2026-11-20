-- butterfly_bush state sprites, 64x56, anchor (32,46). Hearth Pop v3.
local L = dofile("/tmp/ase/states2/lib_tb.lua")
local P, HP = L.P, L.HP
local out = app.params.out or "/tmp/ase/states2/butterfly_bush/"
local c
local px, R, E = L.px, L.R, L.E
local lerp, dk, lt, ink, ball = L.lerp, L.dk, L.lt, L.ink, L.ball
local LEAFD = L.LEAFD
local W, H = 64, 56
local X, Y = 32, 46

local function bloom(x, y, big)
  R(x, y, x + 1, y + 1, P.dusk.hi) px(x, y, P.cream) px(x + 1, y + 1, P.dusk.base)
end
local function bloomP(x, y)
  R(x, y, x + 1, y + 1, P.petal.hi) px(x, y, P.cream) px(x + 1, y + 1, P.petal.base)
end

-- a butterfly: centre (x,y). open = 0 wings spread, 1 half
local function bfly(x, y, pal, open) if NOBF then return end
  local lw, rw
  if open == 0 then
    lw = c:rect(x - 3, y - 2, x - 1, y):add(c:rect(x - 2, y + 1, x - 1, y + 2))
    rw = c:rect(x + 1, y - 2, x + 3, y):add(c:rect(x + 1, y + 1, x + 2, y + 2))
  else
    lw = c:rect(x - 2, y - 2, x - 1, y):add(c:rect(x - 2, y + 1, x - 1, y + 1))
    rw = c:rect(x + 1, y - 2, x + 2, y):add(c:rect(x + 1, y + 1, x + 1, y + 1))
  end
  local body = c:rect(x, y - 1, x, y + 2)
  local ant = HP.mask():set(x - 1, y - 3):set(x + 1, y - 3)
  c:rim(lw:copy():add(rw):add(body):add(ant), P.ink)
  c:fillMask(lw, pal.base) c:fillMask(rw, pal.base)
  px(open == 0 and x - 3 or x - 2, y - 2, pal.hi) px(x + (open == 0 and 3 or 2), y + (open == 0 and 0 or 1), pal.shade)
  if open == 0 then px(x - 2, y - 1, P.cream) px(x + 2, y - 1, pal.hi) end
  c:fillMask(body, P.dusk.deep) px(x, y - 1, P.dusk.shade)
  c:fillMask(ant, P.ink)
end
local PAL = { gold = P.gold, pink = P.petal, sky = P.sea, ember = P.ember }

local function trellis()
  local lx, rx_ = X - 12, X + 11
  local posts = c:rect(lx, Y - 29, lx + 1, Y - 2):add(c:rect(rx_, Y - 29, rx_ + 1, Y - 2))
  local bar = c:rect(lx, Y - 29, rx_ + 1, Y - 28)
  local mid = c:rect(lx, Y - 22, rx_ + 1, Y - 21)
  local diag = HP.mask()
  for i = 0, 22 do diag:set(lx + 2 + i, Y - 27 + (i % 6)) end
  ink(posts, bar, mid)
  c:fillMask(posts, P.wood.base) R(lx, Y - 29, lx, Y - 2, P.wood.hi) R(lx + 1, Y - 27, lx + 1, Y - 2, P.wood.shade) R(rx_, Y - 29, rx_, Y - 2, P.wood.hi) R(rx_ + 1, Y - 27, rx_ + 1, Y - 2, P.wood.shade)
  c:fillMask(bar, P.wood.base) R(lx, Y - 29, rx_ + 1, Y - 29, P.wood.hi) R(lx, Y - 28, rx_ + 1, Y - 28, P.wood.shade)
  c:fillMask(mid, P.wood.base) R(lx, Y - 22, rx_ + 1, Y - 22, P.wood.hi) R(lx, Y - 21, rx_ + 1, Y - 21, P.wood.shade)
  for xx = lx + 4, rx_ - 2, 4 do R(xx, Y - 27, xx, Y - 23, P.wood.shade) px(xx - 1, Y - 27, P.wood.base) end
  -- finials
  px(lx, Y - 30, P.wood.hi) px(lx + 1, Y - 30, P.wood.base) px(rx_, Y - 30, P.wood.hi) px(rx_ + 1, Y - 30, P.wood.base)
end

local function arch()
  local ax, ay = X, Y - 21
  local ring = E(ax, ay, 17, 9):cut(E(ax, ay, 14, 6)):clip(c:rect(0, 0, W, ay))
  local posts = c:rect(ax - 17, ay, ax - 15, Y - 1):add(c:rect(ax + 15, ay, ax + 17, Y - 1))
  ink(ring, posts)
  c:fillMask(ring, P.wood.base) c:fillMask(posts, P.wood.base)
  ring:each(function(x, y) if not ring:has(x, y - 1) or not ring:has(x - 1, y) then px(x, y, P.wood.hi) elseif not ring:has(x + 1, y) or not ring:has(x, y + 1) then px(x, y, P.wood.shade) end end)
  R(ax - 17, ay, ax - 17, Y - 1, P.wood.hi) R(ax - 15, ay, ax - 15, Y - 1, P.wood.shade) R(ax + 15, ay, ax + 15, Y - 1, P.wood.hi) R(ax + 17, ay, ax + 17, Y - 1, P.wood.shade)
  return ring
end

-- the bush
local function bush(blobs)
  local masks, u = {}, HP.mask()
  for i, b in ipairs(blobs) do masks[i] = E(b[1], b[2], b[3], b[4]); u:add(masks[i]) end
  ink(u)
  for i, b in ipairs(blobs) do ball(masks[i], b[1], b[2], b[3], b[4], LEAFD, { nospec = true }) end
  -- bushes behind the lowest blob: darker seam where a upper blob meets
  local f = masks[#masks]
  for i = 1, #masks - 1 do
    masks[i]:each(function(xx, yy) if not masks[i]:has(xx, yy - 1) then end end)
  end
  local x0, y0, x1, y1 = u:bbox()
  L.leaves(u, LEAFD, x0, x1, y0 + 2, y1 - 1, 6, 4)
  return u
end

local L1B = function() local x, y = X, Y return { { x - 6, y - 12, 6, 5 }, { x + 6, y - 13, 6, 5 }, { x, y - 7, 11, 6 } } end
local L2B = function() local x, y = X, Y return { { x, y - 20, 5, 5 }, { x - 7, y - 14, 6, 6 }, { x + 7, y - 16, 6, 6 }, { x, y - 8, 12, 7 } } end

local function shadow(rx, o) local m = E(X + 4, Y + 1, rx, 3) L.shadow(m, E(X + 3, Y, rx - 3, 1)) end
local FL1 = function() local x, y = X, Y return { { x - 7, y - 14 }, { x + 3, y - 10 }, { x + 7, y - 16 }, { x - 2, y - 15 }, { x + 6, y - 6 }, { x - 8, y - 7 } } end

local function level1(bf)
  c = L.new(W, H)
  shadow(13)
  local u = bush(L1B())
  for _, f in ipairs(FL1()) do bloom(f[1], f[2]) end
  if bf ~= false then
    bfly(X - 9, Y - 15, PAL.gold, 0)
    bfly(X + 9, Y - 10, PAL.pink, 1)
  end
end

local function level2()
  c = L.new(W, H)
  shadow(15)
  trellis()
  bush(L2B())
  for _, f in ipairs{ { X - 7, Y - 14 }, { X + 3, Y - 10 }, { X + 9, Y - 18 }, { X - 2, Y - 19 }, { X + 8, Y - 7 }, { X - 10, Y - 7 }, { X - 3, Y - 24 }, { X + 5, Y - 14 } } do bloom(f[1], f[2]) end
  -- vine on the trellis
  for _, p in ipairs{ { X - 12, Y - 25 }, { X - 11, Y - 27 }, { X + 11, Y - 26 }, { X + 10, Y - 24 }, { X + 12, Y - 23 } } do px(p[1], p[2], P.moss.base) px(p[1] + 1, p[2], P.moss.shade) end
  bloomP(X - 13, Y - 26) bloomP(X + 11, Y - 27)
  bfly(X - 13, Y - 14, PAL.gold, 0)
  bfly(X + 13, Y - 12, PAL.pink, 1)
  bfly(X + 1, Y - 28, PAL.sky, 0)
end

local function level3()
  c = L.new(W, H)
  shadow(18)
  local ring = arch()
  bush(L2B())
  for _, f in ipairs{ { X - 7, Y - 14 }, { X + 3, Y - 10 }, { X + 9, Y - 18 }, { X - 2, Y - 19 }, { X + 8, Y - 7 }, { X - 10, Y - 7 }, { X - 3, Y - 24 }, { X + 5, Y - 14 }, { X - 5, Y - 5 }, { X + 2, Y - 3 } } do bloom(f[1], f[2]) end
  -- flowering arch: blooms and leaves along the ring and posts
  local n = 0
  local pts = {}
  ring:each(function(x, y) pts[#pts + 1] = { x, y } end)
  table.sort(pts, function(a, b) if a[1] ~= b[1] then return a[1] < b[1] end return a[2] < b[2] end)
  for i = 1, #pts, 1 do
    local p = pts[i]
    if p[1] % 4 == 0 and p[2] < Y - 22 or p[1] % 5 == 2 and p[2] == Y - 21 then
    end
  end
  for _, p in ipairs{ { -16, -20 }, { -14, -25 }, { -9, -29 }, { -3, -30 }, { 3, -30 }, { 9, -29 }, { 14, -25 }, { 16, -20 } } do
    local x, y = X + p[1], Y + p[2]
    px(x - 1, y + 1, P.moss.base) px(x + 2, y, P.moss.shade)
    if (p[1] // 3) % 2 == 0 then bloomP(x, y) else bloom(x, y) end
  end
  for _, p in ipairs{ { -16, -14 }, { 16, -13 }, { -16, -8 }, { 15, -7 } } do bloomP(X + p[1], Y + p[2]) end
  for _, p in ipairs{ { -17, -17 }, { 17, -16 }, { -15, -11 }, { 16, -10 }, { -17, -5 }, { 17, -4 } } do px(X + p[1], Y + p[2], P.moss.base) end
  bfly(X - 20, Y - 22, PAL.gold, 0)
  bfly(X + 19, Y - 22, PAL.pink, 1)
  bfly(X, Y - 33, PAL.sky, 0)
  bfly(X + 11, Y - 11, PAL.ember, 1)
end


local BOB = { 0, -1, 0, 1 }
local FLAP = { 0, 1, 0, 1 }
local PATH = {
  [2] = { A = { { 10, 28 }, { 14, 24 }, { 11, 19 }, { 15, 22 } }, B = { { 50, 30 }, { 52, 25 }, { 49, 20 }, { 51, 26 } }, C = { { 24, 10 }, { 30, 8 }, { 37, 10 }, { 31, 12 } },
          SP = { { 40, 30 }, { 22, 25 }, { 34, 17 }, { 44, 33 } } },
  [3] = { A = { { 8, 30 }, { 11, 25 }, { 7, 20 }, { 10, 24 } }, B = { { 53, 32 }, { 56, 27 }, { 53, 22 }, { 56, 26 } }, C = { { 25, 8 }, { 31, 6 }, { 38, 8 }, { 32, 10 } },
          SP = { { 40, 33 }, { 21, 22 }, { 44, 15 }, { 24, 36 } } },
}
local function ready(lv, k)
  NOBF = true
  if lv == 2 then level2() else level3() end
  NOBF = false
  local p = PATH[lv]
  local a, b, cc = p.A[k], p.B[k], p.C[k]
  bfly(a[1], a[2], PAL.gold, FLAP[k]); bfly(b[1], b[2], PAL.pink, 1 - FLAP[k]); bfly(cc[1], cc[2], PAL.sky, FLAP[k])
  for i = 0, 2 do
    local sx = a[1] - 3 + i * 3
    local sy = a[2] + 4 + ((k + i * 2) % 4) * 3
    px(sx, sy, P.gold.hi) px(sx + 1, sy, P.gold.base) px(sx, sy + 1, P.cream)
    local tx, ty = b[1] + 3 - i * 3, b[2] + 4 + ((k + i * 2 + 1) % 4) * 3
    px(tx, ty, P.cream) px(tx + 1, ty, P.sea.hi) px(tx + 1, ty + 1, P.sea.base)
  end
  L.spark(p.SP[k][1], p.SP[k][2])
  L.badge(BOB[k])
  return c
end
for lv = 2, 3 do
  local fr = {}
  for k = 1, 4 do fr[k] = ready(lv, k) HP.assertClean(fr[k]) end
  HP.sheet{ cellw = W, cellh = H, frames = fr, tags = { { name = "ready", from = 1, to = 4 } } }
    :save{ aseprite = out .. "butterfly_bush-ready-l" .. lv .. ".aseprite", png = out .. "butterfly_bush-ready-l" .. lv .. ".png", scale = 1 }
end
