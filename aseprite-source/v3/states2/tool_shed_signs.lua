-- tool_shed EMPTY state only (BUILD-sign pass). 72x56, anchor (36,46)
dofile("/tmp/ase/states2/_sk4_kit.lua")
local out = app.params.out or "/tmp/ase/states2/tool_shed/"
local W, H, AX, AY = 72, 56, 36, 46

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

-- crossed hammer + saw, about 15x10, ink outlined so it reads at 1x
local function toolsIcon(x, y)
  -- saw: wide blade from top-left to lower-right, red handle at the lower right
  local blade = c:poly{ { x - 2, y }, { x, y - 1 }, { x + 10, y + 6 }, { x + 8, y + 8 } }
  local sh = c:rrect(x + 9, y + 6, x + 12, y + 9, 1)
  local hole = c:rect(x + 10, y + 7, x + 11, y + 8)
  sh:cut(hole)
  -- hammer: handle from lower-left up to the head at the upper right
  local hh = c:line({ { x + 2, y + 9 }, { x + 9, y + 2 } }, 1):add(c:line({ { x + 3, y + 9 }, { x + 10, y + 2 } }, 1))
  local head = c:poly{ { x + 8, y }, { x + 10, y - 1 }, { x + 14, y + 3 }, { x + 12, y + 4 } }
  ink(blade, sh, hh, head)
  c:fillMask(blade, P.stone.hi)
  blade:each(function(xx, yy) if not blade:has(xx - 1, yy + 1) or not blade:has(xx, yy + 1) then px(xx, yy, ((xx + yy) % 2 == 0) and P.stone.shade or P.stone.base) end end)
  c:fillMask(sh, P.ember.base); sh:each(function(xx, yy) if not sh:has(xx + 1, yy) or not sh:has(xx, yy + 1) then px(xx, yy, P.ember.shade) end end)
  px(x + 10, y + 6, P.ember.hi)
  R(x + 10, y + 7, x + 11, y + 8, P.wood.hi)
  c:rim(hh, P.ink, blade)    -- the hammer lies on top of the saw: ink line where it crosses
  c:fillMask(hh, P.wood.base); hh:each(function(xx, yy) if not hh:has(xx + 1, yy) then px(xx, yy, P.wood.shade) end end)
  c:fillMask(head, P.stone.deep); head:each(function(xx, yy) if not head:has(xx, yy - 1) then px(xx, yy, P.stone.shade) end end)
  px(x + 10, y, P.stone.base)
end

local LITE = lerp(P.wood.hi, P.cream, .45)
local GRAIN = lerp(P.wood.hi, P.wood.base, .55)
local function plank(x0, y0, x1, y1, grainRows, keep)
  local M = c:rect(x0, y0, x1, y1)
  return M
end

local SW = { 0, 1, 0, -1 }       -- hanging trowel swing
local SP = { { 47, 44, false }, { 49, 41, false }, { 51, 44, false }, { 49, 41, true } }

local function drawEmpty(k)
  newc(W, H, "tool_shed")
  local m = plot(16, 35, 57, 52, 3)
  -- footprint
  footprint({ { 21, 40 }, { 52, 40 }, { 53, 49 }, { 20, 49 } }, 5)
  -- post shadow + sign shadow on the earth (cool, lower right)
  local sh = HP.mask()
  for i = 0, 7 do sh:set(38 + i, 42 + i // 2); sh:set(38 + i, 43 + i // 2) end
  for xx = 27, 52 do sh:set(xx, 37) end
  for xx = 28, 53 do sh:set(xx, 38) end
  sh:clip(m:shrink(1)); shadeUnder(sh, .45)
  -- post (3 wide), with a cap above the sign
  local post = c:rect(35, 2, 37, 42)
  ink(post)
  c:fillMask(post, P.wood.base); R(35, 2, 35, 42, P.wood.hi); R(37, 2, 37, 42, P.wood.shade)
  for yy = 6, 40, 5 do px(36, yy, P.wood.shade) end
  R(35, 2, 37, 2, LITE)
  -- earth heaped round the post foot
  R(33, 42, 39, 42, EARTH.hi); px(32, 43, EARTH.base); px(40, 43, EARTH.base); R(34, 43, 38, 43, EARTH.base)
  R(35, 42, 37, 42, P.wood.shade)
  -- two planks nailed across the post
  local top = c:rect(21, 5, 51, 15):cut(c:rect(21, 5, 21, 5))
  local bot = c:rect(20, 17, 50, 27):cut(c:rect(50, 27, 50, 27))
  local gap = c:rect(22, 16, 49, 16)
  local D = top:copy():add(bot):add(gap):shift(1, 1):cut(top):cut(bot):cut(gap)
  ink(top, bot, D, gap)
  c:fillMask(D, P.wood.deep)
  c:fillMask(gap, P.ink)
  for _, pl in ipairs{ { top, 5, 15, 21, 51 }, { bot, 17, 27, 20, 50 } } do
    local M, y0, y1, x0, x1 = pl[1], pl[2], pl[3], pl[4], pl[5]
    c:fillMask(M, P.wood.hi)
    R(x0, y0, x1, y0, LITE)                         -- lit top edge
    R(x0, y1, x1, y1, P.wood.base)                  -- shade edge
    R(x1, y0 + 1, x1, y1, P.wood.base)              -- end grain on the right
    px(x0, y0 + 1, LITE)
  end
  -- wood grain streaks, kept out of the lettering box and the icon
  for _, g in ipairs{ { 23, 8, 4 }, { 41, 7, 6 }, { 44, 12, 5 }, { 24, 13, 3 }, { 22, 22, 2 }, { 46, 20, 2 }, { 25, 26, 6 }, { 38, 26, 5 } } do
    R(g[1], g[2], g[1] + g[3] - 1, g[2], GRAIN)
  end
  px(28, 10, P.wood.base); px(29, 10, GRAIN)            -- a knot
  -- nails: heads with a lit pixel, at the plank ends
  for _, n in ipairs{ { 23, 7 }, { 49, 7 }, { 23, 13 }, { 49, 13 }, { 22, 19 }, { 48, 19 }, { 22, 25 }, { 48, 25 } } do
    px(n[1], n[2], P.stone.shade); px(n[1], n[2] - 1 + 1, P.stone.shade)
    px(n[1], n[2], P.stone.hi)
    px(n[1] + 1, n[2], P.stone.deep)
  end
  -- icon on the top plank, BUILD burnt into the bottom plank
  toolsIcon(29, 6)
  word(26, 20, P.ink)
  -- spare nails driven into the post below the sign
  for _, ny in ipairs{ 32, 36 } do R(38, ny, 39, ny, P.stone.base); px(39, ny, P.stone.hi); px(38, ny + 1, P.stone.deep) end
  -- trowel hanging by a loop from a nail on the post's left, swinging 1 px
  local s = SW[k]
  px(34, 31, P.stone.hi); px(34, 32, P.stone.deep)
  local tx = 31 + s
  c:fillMask(c:line({ { 33, 32 }, { tx, 33 } }, 1), P.cream)
  local handle = c:rect(tx, 33, tx, 35)
  local blade = c:poly{ { tx - 1, 36 }, { tx + 1, 36 }, { tx + 1, 38 }, { tx, 39 }, { tx - 1, 38 } }
  ink(handle, blade)
  c:fillMask(handle, P.wood.base); px(tx, 33, P.wood.hi)
  c:fillMask(blade, P.stone.base); px(tx - 1, 36, P.stone.hi); px(tx - 1, 37, P.stone.hi); px(tx + 1, 37, P.stone.shade); px(tx + 1, 38, P.stone.shade); px(tx, 39, P.stone.shade)
  -- ground details: nails, wood shavings, pebbles, tufts, flowers
  R(26, 46, 28, 46, P.stone.base); px(26, 46, P.stone.hi)
  R(44, 39, 44, 40, P.stone.shade)
  chip(30, 44); chip(41, 48); chip(24, 42, P.wood.base)
  pebble(18, 46, 3); pebble(54, 43, 2)
  tuft(17, 39); tuft(57, 47, true); tuft(29, 52, true); tuft(48, 52)
  flower(15, 43, P.gold.base); daisy(56, 39); flower(24, 51, P.gold.hi)
  -- sparrow hopping across the front
  local sp = SP[k]
  sparrow(sp[1], sp[2], sp[3])
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "tool_shed")
