-- rain_barrel EMPTY state, pass 2 (SMALLER). 56x56, anchor (28,46)
-- a blue enamel board hung on two rope loops from a tiny gallows post, a water-drop charm on its top, one drip falling
dofile("/tmp/ase/states2/_sk5_kit.lua")
local out = app.params.out or "/tmp/ase/states2/rain_barrel/"
local W, H, AX, AY = 56, 56, 28, 46

local SWAY = { 0, 1, 1, 0 }

local function drawEmpty(k)
  newc(W, H, "rain_barrel")
  local m = smallPlot(AX - 12, 38, AX + 12, 48, 9)
  smallFootprint(AX - 10, 41, AX + 10, 47, 3)
  -- puddle under the board's right corner
  R(AX + 5, 45, AX + 8, 45, P.sea.shade); px(AX + 6, 45, P.sea.base)
  -- cool shadow of the board on the earth
  local sh = HP.mask()
  for xx = AX - 9, AX + 11 do sh:set(xx, 40) end
  for i = 0, 3 do sh:set(AX + 10 + i // 2, 42 + i) end
  sh:clip(m:shrink(1)); shadeUnder(sh, .4)
  -- gallows: short post at the right, arm out to the left
  local post = c:rect(AX + 8, 24, AX + 9, 41)
  local arm = c:rect(AX - 5, 24, AX + 9, 25)
  ink(post, arm)
  c:fillMask(post, P.wood.base); R(AX + 9, 26, AX + 9, 41, P.wood.shade)
  c:fillMask(arm, P.wood.base); R(AX - 5, 24, AX + 9, 24, P.wood.hi); px(AX - 5, 25, P.wood.shade)
  R(AX + 6, 42, AX + 11, 42, EARTH.hi)
  -- two rope loops from the arm to the board
  local dx = SWAY[k]
  for _, rx in ipairs{ AX - 3, AX + 5 } do
    c:fillMask(c:line({ { rx, 26 }, { rx + dx, 29 } }, 1), P.gold.base)
    px(rx, 26, P.gold.shade)
  end
  -- the board: blue enamel, lit top/left edge, thickness on the bottom only
  local bx0, bx1, by0, by1 = AX - 10 + dx, AX + 10 + dx, 30, 36
  local bd = c:rect(bx0, by0, bx1, by1)
  local D = bd:copy():shift(0, 1):cut(bd)
  ink(bd, D)
  c:fillMask(D, P.sea.deep)
  c:fillMask(bd, P.sea.shade)
  R(bx0, by0, bx1, by0, P.sea.base); R(bx0, by0, bx0, by1, P.sea.base)
  px(AX - 3 + dx, by0, P.gold.base); px(AX + 5 + dx, by0, P.gold.base)     -- rope through the holes
  word(AX - 9 + dx, 31, P.cream, P.sea.deep)
  -- water-drop charm perched on the board's top left
  glyph({ ".a.", "aaa", "aAa" }, AX - 9 + dx, 26, { a = P.sky.hi, A = P.sky.shade })
  px(AX - 8 + dx, 28, P.sky.shade); px(AX - 9 + dx, 27, P.cream)
  -- life: a single drip falling from the board's corner into the puddle
  local ddx = AX + 7
  if k == 1 then px(ddx, 39, P.sky.hi)
  elseif k == 2 then px(ddx, 40, P.sky.hi); px(ddx, 41, P.sea.base)
  elseif k == 3 then px(ddx, 43, P.sky.hi)
  else px(ddx - 1, 44, P.sky.hi); px(ddx + 1, 44, P.sky.hi) end
  -- ground: two pebbles, one forget-me-not, two tufts
  pebble(AX - 9, 43, 3); pebble(AX - 1, 45, 2)
  tuft(AX - 10, 47); tuft(AX + 11, 47, true)
  flower(AX - 5, 43, P.sky.base)
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "rain_barrel")
