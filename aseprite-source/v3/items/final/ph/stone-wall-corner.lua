-- stone-wall-corner (lean W2_29)
local NAME = "stone-wall-corner"
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

c:groundShadow(34, 55, 22, 3)
bricks(16, 22, 54, 36, 11, false)
bricks(16, 36, 30, 54, 5, true)
c:fillMask(c:rect(16, 52, 30, 54), STONE[1])
-- corner post cap: big squared capstone
local cap = c:rrect(12, 12, 33, 30, 3)
dome(cap, 6, STONE)
for i = 0, 3 do c:px(16 + i, 14, STONE[6]) end
c:px(15, 15, SPEC) c:px(16, 15, SPEC)
c:fillMask(c:rect(14, 29, 31, 30), STONE[1])
-- moss crowns the cap, drips down the post
for _, p in ipairs{ {22,13},{23,13},{24,13},{25,14},{26,14},{20,14} } do c:px(p[1], p[2], MOSS[4]) end
c:px(25, 15, MOSS[3]) c:px(26, 15, MOSS[2]) c:px(24, 14, MOSS[5])
c:px(20, 31, MOSS[3]) c:px(20, 32, MOSS[2]) c:px(21, 31, MOSS[4])
tuft(38, 36, 3)
-- quirk: a tiny pink flower sprouting at the foot of the inner corner
c:px(37, 53, MOSS[3]) c:px(37, 52, MOSS[3]) c:px(37, 51, MOSS[2])
c:px(36, 50, "#f2a0c0") c:px(38, 50, "#f2a0c0") c:px(37, 49, "#f2a0c0") c:px(37, 51, "#f2a0c0") c:px(37, 50, "#ffe27a")
c:px(38, 53, MOSS[4]) c:px(39, 52, MOSS[4])
G.fin(c, NAME)
