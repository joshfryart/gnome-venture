-- stone-wall-cross (lean W2_29)
local NAME = "stone-wall-cross"
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

c:groundShadow(32, 55, 24, 3)
bricks(25, 8, 39, 24, 21, true)
bricks(25, 38, 39, 54, 9, true)
bricks(7, 24, 57, 38, 17, false)
c:fillMask(c:rect(25, 52, 39, 54), STONE[1])
-- central pillar: round capstone with an iron ring (quirk) and a worn rune
local cap = c:ellipse(32, 25, 10, 9)
dome(cap, 7, WARM)
c:px(27, 20, SPEC) c:px(28, 20, SPEC) c:px(27, 21, WARM[6])
local IR = { "#1d1a24", "#3a3646", "#59546a", "#8a859a" }
for a = 0, 15 do
  local ang = a / 16 * 6.2832
  local x, y = floor(32 + math.cos(ang) * 5 + 0.5), floor(26 + math.sin(ang) * 4.5 + 0.5)
  c:px(x, y, (x < 32 and y < 26) and IR[4] or ((x >= 32 and y >= 26) and IR[1] or IR[3]))
end
c:px(32, 22, IR[2]) c:px(32, 21, IR[2]) c:px(31, 21, IR[4])
-- worn rune below ring
c:px(31, 28, WARM[2]) c:px(32, 29, WARM[2]) c:px(33, 28, WARM[2])
-- moss in the north crotch and a lichen patch
tuft(26, 9, 4) c:px(28, 10, MOSS[2])
for _, p in ipairs{ {44,28},{45,28},{45,29},{46,28} } do c:px(p[1], p[2], MOSS[3]) end
c:px(12, 32, MOSS[4]) c:px(13, 32, MOSS[3]) c:px(12, 33, MOSS[2])
G.fin(c, NAME)
