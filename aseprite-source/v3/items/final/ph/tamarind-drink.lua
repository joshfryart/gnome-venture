-- tamarind-drink (lean P1b_O16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function pick(r, v, cuts) cuts = cuts or {.22,.4,.56,.72,.86} local i = 1 for _, t in ipairs(cuts) do if v > t then i = i + 1 end end return r[min(i, #r)] end

local c = HP.canvas{ w=64, h=64, scale=1, name="tamarind-drink" }
local DRINK = { "#1f0f10", "#3f1c17", "#6a2d1f", "#984528", "#c26a34", "#e49a52" }
local GLASS = { "#5b7aa6", "#8fb2d6", "#bcdcee", "#e6f6fb", "#fffaf0" }
local ICE   = { "#8fb6d8", "#bfe0f0", "#e8f8fc" }
c:groundShadow(32, 57, 15, 2)
local function hw(y) return 14 - (y - 16) * 0.075 end
local glass, liq, ice = HP.mask(), HP.mask(), HP.mask()
for y = 16, 56 do for x = floor(32 - hw(y)), floor(32 + hw(y)) do glass:set(x, y) end end
for y = 21, 54 do local h = hw(y) - 2.2 for x = floor(32 - h + 0.5), floor(32 + h) do liq:set(x, y) end end
glass:each(function(x, y)
  local d = (x - 32 + hw(y)) / (2 * hw(y))
  local col = GLASS[2]
  if d < 0.1 then col = GLASS[3] elseif d > 0.9 then col = GLASS[1] end
  if y == 16 or y == 17 then col = GLASS[4] end
  c:px(x, y, col)
end)
liq:each(function(x, y)
  local d = (x - 32 + hw(y)) / (2 * hw(y))
  local v = 0.82 - d * 0.75 + (y - 38) * -0.005 + (X.hash(x, y, 2) - 0.5) * 0.1
  if y <= 22 then v = 0.95 end
  c:px(x, y, pick(DRINK, v))
end)
-- ice cubes
for _, q in ipairs{ {26,27}, {35,30}, {29,38} } do
  for y = q[2], q[2] + 4 do for x = q[1], q[1] + 4 do
    local col = ICE[2] if x == q[1] or y == q[2] then col = ICE[3] elseif x == q[1] + 4 or y == q[2] + 4 then col = ICE[1] end
    c:px(x, y, col) end end
  c:px(q[1] + 1, q[2] + 1, "#fffaf0")
end
-- glass streak
for y = 24, 50 do c:px(21 + floor((y - 24) * 0.07), y, GLASS[5]) end
-- straw
local sm = G.tube({ {40,7}, {38,20}, {36,38}, {33,52} }, function() return 1.5 end)
sm:each(function(x, y) c:px(x, y, (floor(y / 3) % 2 == 0) and "#d8344a" or "#fff4ea") end)
c:px(39, 8, "#fffaf0")
-- tamarind pod garnish hooked on the rim (quirk)
local gm, gn = G.tube({ {14,12}, {19,8}, {26,9}, {30,15} }, function(t) return 1.3 + 1.6 * sin(pi * t) end)
local gv = X.light(gn, { amb = 0.1, wrap = 0.25 })
local SH = { "#4a3226", "#7a5538", "#a67a50", "#cfa571", "#ecd09a" }
gm:each(function(x, y) c:px(x, y, pick(SH, gv[K(x, y)])) end)
c:px(22, 7, SH[5]) c:px(19, 9, SH[1])
G.save(c, "tamarind-drink")
