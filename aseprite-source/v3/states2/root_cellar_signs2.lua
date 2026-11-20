-- root_cellar EMPTY state, pass 2 (SMALLER). 72x56, anchor (36,46)
-- a small dusk-purple arrow stuck in the soil pointing down, BUILD on the bar, a carrot in the head; it rocks 1 px; a molehill puffs
dofile("/tmp/ase/states2/_sk5_kit.lua")
local out = app.params.out or "/tmp/ase/states2/root_cellar/"
local W, H, AX, AY = 72, 56, 36, 46

local SWAY = { 0, 1, 1, 0 }
local PUFF = { {}, { { 45, 43, EARTH.hi } }, { { 44, 42, P.stone.hi }, { 47, 42, EARTH.hi } }, { { 43, 43, EARTH.hi }, { 48, 41, P.stone.hi } } }

local function arrow(dx)
  local M = c:rect(AX - 10 + dx, 28, AX + 10 + dx, 34)   -- bar holding the word
  for r = 0, 7 do
    for x = AX - 7 + r, AX + 7 - r do M:set(x + dx, 35 + r) end   -- head, 15 wide down to a 1 px tip
  end
  return M
end

local function drawEmpty(k)
  newc(W, H, "root_cellar")
  local m = smallPlot(AX - 13, 38, AX + 13, 48, 13)
  smallFootprint(AX - 11, 41, AX + 11, 47, 3)
  -- cool shadow of the arrow on the earth, lower right of its foot
  local sh = HP.mask()
  for i = 0, 7 do sh:set(AX + 3 + i, 45 + i // 4) end
  sh:clip(m:shrink(1)); shadeUnder(sh, .45)
  -- the arrow: thickness on the bottom only, lit top/left rim, shade on the right slopes
  local dx = SWAY[k]
  local M = arrow(dx)
  local D = M:copy():shift(0, 1):cut(M)
  ink(M, D)
  c:fillMask(D, P.dusk.deep)
  c:fillMask(M, P.dusk.base)
  M:edge():each(function(x, y)
    if not M:has(x, y - 1) or not M:has(x - 1, y) then px(x, y, P.dusk.hi) else px(x, y, P.dusk.shade) end
  end)
  word(AX - 9 + dx, 29, P.cream, P.dusk.deep)
  -- tiny carrot in the head
  glyph({ "g.g", ".g.", "OOo", ".Oo", ".o." }, AX - 1 + dx, 35, { g = P.moss.base, O = lerp(P.ember.hi, P.gold.base, .35), o = P.ember.base })
  -- soil heaped round the buried tip
  local mound = c:rect(AX - 3, 44, AX + 3, 44):add(c:rect(AX - 1, 43, AX + 1, 43))
  ink(mound)
  c:fillMask(mound, EARTH.base); R(AX - 2, 44, AX - 1, 44, EARTH.hi); px(AX - 1, 43, EARTH.hi); R(AX + 1, 44, AX + 3, 44, EARTH.shade)
  -- ground: pebbles, a carrot-top sprout, one flower, tufts
  pebble(AX - 10, 43, 3); pebble(AX + 6, 46, 2)
  tuft(AX - 11, 47); tuft(AX + 12, 46, true)
  flower(AX - 6, 44, P.cream)
  -- life: a molehill heaves and puffs crumbs
  local mh = c:rect(AX + 9, 44, AX + 11, 44):add(c:rect(AX + 10, 43, AX + 10, 43))
  ink(mh); c:fillMask(mh, EARTH.base); px(AX + 9, 44, EARTH.hi)
  for _, p in ipairs(PUFF[k]) do px(p[1], p[2], p[3]) end
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "root_cellar")
