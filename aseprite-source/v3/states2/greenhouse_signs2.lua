-- greenhouse EMPTY state, pass 2 (small sign). 72x64, anchor (36,54).
-- small leaf-shaped board on a thin stake, a seedling in a tiny pot sitting on the leaf, a white butterfly.
local G = dofile("/tmp/ase/states2/signs2_kbgt_kit.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/greenhouse/"
local px, R, ink, lerp = G.px, G.R, G.ink, G.lerp
local M, W, E, CREAM, INK = P.moss, P.wood, P.ember, P.cream, P.ink
local LEAF_L = lerp(M.hi, CREAM, .45)

local PEG = { { 26, 51 }, { 46, 51 }, { 25, 56 }, { 47, 56 } }

local function stake(dx)
  local s = G.segMask(31, 52, 31 + dx, 49)
  ink(s) G.c:fillMask(s, W.base) px(31, 52, W.shade)
end

local function leaf(dx)
  -- a leaf tilted up to the right: round base lower left (where the stake holds it), tip upper right
  local m = G.pts{ { 45, 39 } }:add(G.c:rect(43, 40, 45, 40)):add(G.c:rect(28, 41, 45, 41)):add(G.c:rect(25, 42, 45, 46))
    :add(G.c:rect(26, 47, 43, 47)):add(G.c:rect(29, 48, 38, 48))
  m = m:shift(dx, 0)
  G.c:rim(m, INK)
  G.c:fillMask(m, M.hi)
  m:each(function(x, y)
    local lx = x - dx
    if (not m:has(x, y - 1) and lx < 43) or (lx == 25 and y < 46) then px(x, y, LEAF_L)
    elseif not m:has(x, y + 1) or (lx == 45 and y > 42) then px(x, y, M.base) end
  end)
  -- midrib from the tip, and two vein stubs below the word
  px(44 + dx, 40, M.base) px(43 + dx, 41, M.base) px(31 + dx, 47, M.base) px(36 + dx, 47, M.base) px(33 + dx, 48, M.base)
  G.text(26 + dx, 42, M.deep)
  -- seedling sprouting from the leaf's top edge
  local b = dx
  local sp = G.pts{ { 29 + b, 36 }, { 29 + b, 37 }, { 30 + b, 37 }, { 31 + b, 38 }, { 31 + b, 39 }, { 32 + b, 37 }, { 33 + b, 37 }, { 33 + b, 36 } }
  ink(sp)
  px(31 + b, 38, M.shade) px(31 + b, 39, M.shade)
  px(29 + b, 36, M.hi) px(29 + b, 37, M.base) px(30 + b, 37, M.base)
  px(33 + b, 36, M.hi) px(33 + b, 37, M.base) px(32 + b, 37, M.base)
end

local function butterfly(f)
  local p = ({ { 49, 36 }, { 50, 38 }, { 49, 41 }, { 47, 37 } })[f]
  local x, y = p[1], p[2]
  px(x, y, INK)
  if f % 2 == 1 then px(x - 1, y, CREAM) px(x + 1, y, CREAM) px(x - 1, y - 1, CREAM)
  else px(x - 1, y - 1, CREAM) px(x + 1, y - 1, CREAM) end
end

local function empty(f)
  local c = G.new(72, 64, "greenhouse-empty")
  local dx = ({ 0, 1, 1, 0 })[f]
  G.miniPlot(23, 48, 49, 58, 11)
  G.pegsBack(PEG)
  G.shadow2(G.c:poly{ { 32, 53 }, { 44, 53 }, { 46, 55 }, { 34, 55 } })
  stake(dx)
  leaf(dx)
  G.pegsFront(PEG)
  G.tinyPebble(38, 56) G.tinyTuft(23, 53) G.tinyTuft(49, 54)
  G.flower(29, 55, P.sky.hi, P.gold.hi)   -- borage-blue
  butterfly(f)
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "greenhouse")
