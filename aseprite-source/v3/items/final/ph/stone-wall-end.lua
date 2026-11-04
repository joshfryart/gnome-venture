-- stone-wall-end (lean W2_29)
local NAME = "stone-wall-end"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local STONE = { "#2f2a3d", "#4a4459", "#6c657a", "#8f889a", "#b6aebb", "#d9d2d6" }
local WARM  = { "#3d3238", "#5e4d50", "#85706a", "#a8917f", "#c9b496", "#e6d6b4" }
local MOSS  = { "#1f3d33", "#2f5e3c", "#4b8545", "#78ae56", "#a8d06c" }
local SPEC = "#fff6f2"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- brick-coursed wall run: top coping strip (lit), mortar, per-brick tone, top-left light, bottom-right shade
local function bricks(x0, y0, x1, y1, seed, vertical)
  local m = c:rect(x0, y0, x1, y1)
  m:each(function(x, y)
    local ry = y - y0
    local row = floor(ry / 5)
    local off = (row % 2) * 4 + floor(X.hash(row, 3, seed) * 3)
    local bx = x - x0 + off
    local col = floor(bx / 8)
    local h = X.hash(col, row, seed + 7)
    local ramp = (h > 0.78) and WARM or STONE
    local lvl = 3 + floor(h * 2.4) % 3 - 1
    local colr = ramp[max(2, min(5, lvl))]
    local mort = (ry % 5 == 4) or (bx % 8 == 7)
    if not vertical and ry < 3 then colr = STONE[5 - (ry == 2 and 1 or 0)]; if ry == 0 then colr = STONE[6] end
    elseif mort then colr = STONE[1]
    else
      if ry % 5 == 0 or bx % 8 == 0 then colr = ramp[min(6, lvl + 1)] end
      if ry % 5 == 3 then colr = ramp[max(1, lvl - 1)] end
      if X.hash(x, y, seed + 2) > 0.9 then colr = ramp[max(1, lvl - 1)] end
    end
    if x >= x1 - 1 then colr = STONE[2] end            -- right edge in shade
    if y >= y1 - 1 and not vertical then colr = STONE[1] end  -- base AO
    c:px(x, y, colr)
  end)
  return m
end
local function dome(mask, R, ramp, bias)
  local n = X.pillow(mask, R)
  G.tone(c, mask, X.light(n, { amb = 0.1, wrap = 0.2 }), ramp, { 0.2, 0.38, 0.55, 0.72, 0.87 })
  return n
end
local function tuft(x, y, n)
  for i = 0, n - 1 do c:px(x + i, y, MOSS[3 - (i % 2)]) c:px(x + i, y - 1 - (i % 2), MOSS[4 - (i % 2)]) end
end

c:groundShadow(33, 46, 22, 3)
bricks(9, 28, 44, 43, 33, false)
-- rounded boulder end-cap, split by a crack, with a sprouting seedling (quirk)
local rock = c:ellipse(46, 33, 10, 13)
rock:add(c:rect(40, 27, 46, 43))
dome(rock, 9, WARM)
for i = 0, 2 do c:px(41 + i, 21 + i, SPEC) end
c:px(40, 24, WARM[6]) c:px(41, 23, WARM[6])
for _, p in ipairs{ {47,24},{47,25},{48,26},{48,27},{47,28},{47,29},{46,30},{47,31} } do c:px(p[1], p[2], WARM[1]) end
c:px(48, 28, WARM[2]) c:px(48, 29, WARM[2])
for _, p in ipairs{ {49,24},{50,24},{50,23},{46,23} } do c:px(p[1], p[2], MOSS[3]) end
c:px(47, 23, MOSS[4]) c:px(48, 23, MOSS[4])
-- seedling poking from the crack
c:px(47, 22, MOSS[3]) c:px(47, 21, MOSS[3]) c:px(46, 20, MOSS[4]) c:px(45, 20, MOSS[5]) c:px(48, 20, MOSS[4]) c:px(49, 19, MOSS[5]) c:px(48, 19, MOSS[3])
-- ivy running up the wall
for _, p in ipairs{ {12,40},{12,39},{13,38},{13,37},{12,36},{12,35},{11,34} } do c:px(p[1], p[2], MOSS[2]) end
c:px(11, 38, MOSS[4]) c:px(14, 36, MOSS[4]) c:px(11, 35, MOSS[4]) c:px(13, 34, MOSS[5])
tuft(18, 28, 3)
G.fin(c, NAME)
