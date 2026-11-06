-- hollowheart-tree (lean E2_02)
local NAME = "hollowheart-tree"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, nm, o)
  o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = CUTS, tok = { r = { name = nm or "p" } } })
  return idx, n
end
local function px(x, y, col, nm) c:put(x, y, col, { r = { name = nm or "d" } }) end
local function spec(m, n, col)
  local x, y = G.specAt(m, n, 30)
  if x then px(x, y, col or "#fff4dc", "spec") end
end
c:groundShadow(32, 58, 24, 2)
local TR = { "#2a1a1c", "#4a2c26", "#6c4034", "#8f5c40", "#b5805a", "#d8a67c" }
local GR = { "#14391f", "#1f5a2a", "#2e7a32", "#4a9c3c", "#76bf4c", "#aee070" }
local OR = { "#a8321c", "#d4521c", "#f07a20", "#ffa030", "#ffc850", "#ffe890" }
local trunk = c:poly{ {23,30}, {41,30}, {43,46}, {51,58}, {13,58}, {21,46} }
local ti = shade(trunk, TR, 9, "trunk")
trunk:each(function(x, y) if (x % 4 == 1) and y > 32 and y < 56 and X.hash(x, y, 3) > 0.35 then px(x, y, TR[2], "bark") end end)
trunk:each(function(x, y) if (x % 4 == 3) and y > 32 and y < 50 and X.hash(x, y, 8) > 0.7 then px(x, y, TR[5], "bark") end end)
-- hollow heart
local heart = HP.mask()
heart:add(c:ellipse(28, 40, 4, 4)); heart:add(c:ellipse(36, 40, 4, 4)); heart:add(c:poly{ {24,42}, {40,42}, {32,52} })
heart:grow(1):each(function(x, y) px(x, y, "#2a1218", "rim") end)
shade(heart, OR, 5, "heart", { amb = 0.3, wrap = 0.5 })
for _, p in ipairs{ {27,38},{28,37},{26,39} } do px(p[1], p[2], OR[6], "hl") end
-- canopy
local can = HP.mask()
can:add(c:ellipse(32, 19, 15, 11)); can:add(c:ellipse(18, 25, 11, 9)); can:add(c:ellipse(46, 25, 11, 9)); can:add(c:ellipse(32, 13, 10, 8))
-- AO on trunk under canopy
trunk:each(function(x, y) if can:shift(0, 3):has(x, y) and not can:has(x, y) then px(x, y, TR[1], "ao") end end)
local ci = shade(can, GR, 11, "can")
can:each(function(x, y) local h = X.hash(x, y, 6)
  if h > 0.86 then px(x, y, GR[1], "cl") elseif h < 0.1 and y < 26 then px(x, y, GR[6], "cl") end end)
for _, p in ipairs{ {22,28},{33,31},{44,29},{12,29} } do for dx = 0, 2 do px(p[1] + dx, p[2], GR[1], "cl") end end
-- fireflies
for _, p in ipairs{ {52,38},{12,36},{50,44} } do px(p[1], p[2], "#ffe890", "ff") px(p[1] + 1, p[2], "#ffc850", "ff") end
G.save(c, NAME)
