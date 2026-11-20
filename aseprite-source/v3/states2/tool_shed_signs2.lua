-- tool_shed EMPTY state, pass 2 (SMALLER). 72x56, anchor (36,46)
-- one nailed plank on a short post, a tiny hammer lying on top, a trowel swinging on a nail, a sparrow hopping
dofile("/tmp/ase/states2/_sk5_kit.lua")
local out = app.params.out or "/tmp/ase/states2/tool_shed/"
local W, H, AX, AY = 72, 56, 36, 46
local LITE = lerp(P.wood.hi, P.cream, .45)

local SW = { 0, 1, 0, -1 }                     -- trowel swing
local BIRD = { { 39, 43 }, { 40, 42 }, { 41, 43 }, { 40, 43 } }

local function bird(x, y, k)
  -- 3x2 sparrow body, beak to the right, hop frame lifts it 1 px
  local m = HP.mask():set(x, y):set(x + 1, y):set(x + 2, y):set(x, y + 1):set(x + 1, y + 1):set(x + 2, y - 1)
  ink(m)
  c:fillMask(m, P.wood.hi); px(x, y, P.wood.base); px(x, y + 1, P.cream); px(x + 1, y + 1, P.cream); px(x + 2, y - 1, P.wood.base)
  px(x + 3, y - 1, P.gold.base)
end

local function drawEmpty(k)
  newc(W, H, "tool_shed")
  local m = smallPlot(AX - 13, 38, AX + 13, 48, 3)
  smallFootprint(AX - 11, 41, AX + 11, 47, 3)
  -- cool shadow of plank + post on the earth (lower right)
  local sh = HP.mask()
  for xx = AX - 7, AX + 12 do sh:set(xx, 39) end
  for i = 0, 5 do sh:set(AX + 1 + i, 41 + i // 3) end
  sh:clip(m:shrink(1)); shadeUnder(sh, .45)
  -- post (2 wide), foot at the back of the plot
  local post = c:rect(AX - 1, 26, AX, 41)
  ink(post)
  c:fillMask(post, P.wood.base); R(AX - 1, 26, AX - 1, 41, P.wood.hi); R(AX, 26, AX, 41, P.wood.shade)
  R(AX - 3, 42, AX + 2, 42, EARTH.hi)
  -- the plank: pale wood, lit top, shade bottom, end grain + thickness on the right/bottom
  local pl = c:rect(AX - 10, 29, AX + 10, 35)
  slab(pl, P.wood.hi, P.wood.shade)
  R(AX - 10, 29, AX + 10, 29, LITE)
  R(AX - 10, 35, AX + 10, 35, P.wood.base)
  R(AX + 10, 30, AX + 10, 35, P.wood.base)
  word(AX - 9, 30, P.ink)
  -- tiny claw hammer lying on the plank top: wood handle, dark iron head on the right
  glyph({ "....SS", "hhhhSs", "....ss" }, AX - 9, 25, { h = P.wood.base, s = P.stone.shade, S = P.stone.hi })
  -- trowel hanging from a nail under the plank's left end, swinging 1 px
  local s = SW[k]
  px(AX - 7, 37, P.stone.hi)
  local tx = AX - 7 + s
  glyph({ "h.", "bb", "b." }, tx, 38, { h = P.wood.base, b = P.stone.hi })
  px(tx + 1, 39, P.stone.shade)
  -- ground: two pebbles, one flower, two tufts
  pebble(AX - 11, 43, 2); pebble(AX + 7, 41, 3)
  tuft(AX - 11, 47); tuft(AX + 12, 46, true)
  flower(AX - 4, 44, P.gold.base)
  -- life: a sparrow hopping across the front of the plot
  local b = BIRD[k]
  bird(b[1], b[2], k)
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "tool_shed")
