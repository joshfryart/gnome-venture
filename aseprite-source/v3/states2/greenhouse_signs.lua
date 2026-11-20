-- greenhouse EMPTY state only (BUILD-sign craft pass). 72x64, anchor (36,54).
local G = dofile("/tmp/ase/states2/signs_kbgt_common.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/greenhouse/"
local px, R, ink, lerp = G.px, G.R, G.ink, G.lerp
local M, W, CREAM, INK = P.moss, P.wood, P.cream, P.ink
local LEAF_L = lerp(M.hi, CREAM, .45)

local STK = { { 11, 50 }, { 57, 48 }, { 11, 59 }, { 58, 59 } }
local X0, X1 = 19, 57

local function leafGeom(dx)
  local m, mid = HP.mask(), {}
  for x = X0, X1 do
    local t = (x - X0) / (X1 - X0)
    local h = 10 * (math.max(math.sin(math.pi * t ^ .7), 0)) ^ 1.2
    local cy = 29 - 3 * t * t
    mid[x + dx] = math.floor(cy + .5)
    for y = math.floor(cy - h + .5), math.floor(cy + h + .5) do m:set(x + dx, y) end
  end
  return m, mid
end

local function leaf(dx)
  local m, mid = leafGeom(dx)
  local thick = m:shift(1, 1):cut(m)
  local stem = G.pts{ { X0 - 1 + dx, 29 }, { X0 - 2 + dx, 30 }, { X0 - 3 + dx, 31 } }
  ink(m, thick, stem)
  G.c:fillMask(thick, M.shade)
  G.c:fillMask(stem, M.shade)
  G.c:fillMask(m, M.hi)
  -- clear zones: lettering (grown 2) and icon (grown 1)
  local clear = G.c:rect(23 + dx, 25, 45 + dx, 33):add(G.c:rect(30 + dx, 18, 38 + dx, 26))
  local body = m:shrink(1)
  local function vein(x, y, col)
    if body:has(x, y) and not clear:has(x, y) then px(x, y, col) end
  end
  -- midrib, and side veins sweeping toward the tip
  for x = X0 + dx, X1 + dx do vein(x, mid[x], M.base) end
  for _, xi in ipairs{ 21, 27, 33, 39, 45, 50 } do
    local x = xi + dx
    local cy = mid[x]
    for i = 1, 10 do
      vein(x + i, cy - i, M.base)
      vein(x + i, cy + i, M.base)
    end
  end
  -- edge light / shade
  m:edge():each(function(x, y)
    local lx = x - dx
    if y < (mid[x] or 28) and lx < X1 - 6 then px(x, y, LEAF_L) else px(x, y, M.base) end
  end)
  -- a light serration nick near the tip and a dew glint
  px(50 + dx, mid[50 + dx] - 4, CREAM)
  -- seedling icon
  local b = dx + 1
  R(31 + b, 24, 35 + b, 24, W.base) R(30 + b, 25, 36 + b, 25, W.shade) px(31 + b, 24, W.hi)
  px(33 + b, 22, M.shade) px(33 + b, 23, M.shade) px(33 + b, 24, M.deep)
  px(31 + b, 21, M.shade) px(32 + b, 21, M.base) px(32 + b, 22, M.shade) px(30 + b, 20, M.shade) px(31 + b, 20, M.base)
  px(34 + b, 21, M.shade) px(34 + b, 20, M.base) px(35 + b, 20, M.shade) px(35 + b, 19, M.base) px(36 + b, 19, M.shade) px(34 + b, 22, M.deep)
  -- BUILD in deep green
  G.text(25 + dx, 27, M.deep)
end

local function stake(dx)
  local s = G.segMask(15, 56, 15 + dx, 31):add(G.segMask(16, 56, 16 + dx, 31))
  ink(s)
  s:each(function(x, y) px(x, y, (s:has(x + 1, y)) and W.base or W.shade) end)
  px(15 + dx, 31, W.hi) px(15, 56, W.shade) px(16, 56, W.deep)
end

local function tie(dx)   -- twine wraps where leaf meets stake
  R(14 + dx, 33, 17 + dx, 33, CREAM) R(14 + dx, 34, 17 + dx, 34, W.hi) px(18 + dx, 34, CREAM) px(18 + dx, 35, CREAM) px(19 + dx, 36, W.hi)
end

local function butterfly(x, y, f)
  local body = G.pts{ { x, y }, { x, y + 1 } }
  local wings
  if f % 2 == 1 then wings = G.pts{ { x - 1, y - 1 }, { x - 2, y - 1 }, { x - 1, y }, { x + 1, y - 1 }, { x + 2, y - 1 }, { x + 1, y }, { x - 1, y + 1 }, { x + 1, y + 1 } }
  else wings = G.pts{ { x - 1, y - 1 }, { x - 1, y - 2 }, { x + 1, y - 1 }, { x + 1, y - 2 } } end
  ink(body, wings)
  G.c:fillMask(wings, CREAM) G.c:fillMask(body, INK)
  if f % 2 == 1 then px(x - 2, y - 1, P.gold.hi) px(x + 2, y - 1, P.gold.hi) end
end

local function empty(f)
  local c = G.new(72, 64, "greenhouse-empty")
  local dx = ({ 0, 1, 1, 0 })[f]
  G.plot(9, 44, 62, 62, 5, 11)
  G.tuft(10, 51) G.tuft(61, 51) G.tuft(26, 63) G.tuft(48, 45)
  G.stringBack(STK)
  -- leaf + stake shadow on the ground (lower right)
  G.shadow(G.c:ellipse(44 + dx, 57, 13, 2))
  G.shadow(G.segMask(17, 57, 26, 59)) G.shadow(G.segMask(18, 57, 27, 59))
  stake(dx)
  leaf(dx)
  tie(dx)
  G.stringFront(STK)
  G.pebble(24, 56, true) G.pebble(44, 52) G.pebble(51, 60)
  G.flower(22, 53, P.gold.base, P.ember.base)   -- marigold
  G.flower(48, 56, P.sky.hi, P.gold.hi)          -- borage-blue
  local bp = ({ { 60, 11 }, { 64, 15 }, { 61, 19 }, { 57, 14 } })[f]
  butterfly(bp[1], bp[2], f)
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "greenhouse")
