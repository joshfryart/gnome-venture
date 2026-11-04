-- wayfarer-s-staff (lean D3o_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }
local NAME = "wayfarer-s-staff"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, ramp, R, amb, bias) local n = X.pillow(m, R or 4); G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local WOOD = { "#2f1d1c", "#4e3022", "#744a2e", "#9a6a40", "#c08c58", "#e0b480" }
local LEATH= { "#3a2018", "#5e3426", "#8a5236", "#b07448", "#cf9660", "#e8b87c" }
local CLOTH= { "#5a1830", "#7e2440", "#a63a50", "#c85a62", "#e48478", "#f6b09a" }
local BRASS= { "#5a4018", "#8a6422", "#b88a30", "#dcb048", "#f0d070", "#fff2a8" }
c:groundShadow(22, 58, 8, 2)
-- staff shaft: gentle S curve from foot to the top
local sm, sn = G.tube({ {22, 56}, {26, 40}, {36, 26}, {38, 8} }, function(t) return 1.6 + 0.5 * sin(t * 9) * 0.5 + 0.3 * t end)
tone(sm, WOOD, 2, 0.1)
-- grain
sm:each(function(x, y) if X.hash(x, y, 3) > 0.85 and sm:has(x - 1, y) and sm:has(x + 1, y) then c:px(x, y, WOOD[2]) end end)
-- upper fork: short side branch
local bm = G.tube({ {37, 18}, {41, 15}, {46, 14}, {49, 10} }, function(t) return 1.1 + 0.2 * (1 - t) end)
tone(bm, WOOD, 1.5, 0.1)
c:px(49, 9, WOOD[5]) c:px(48, 9, WOOD[4])
-- leather grip wraps
sm:each(function(x, y) if y >= 30 and y <= 42 then
  local d = (y + floor(x * 0.6)) % 4
  if d == 0 then c:px(x, y, LEATH[2]) elseif d == 1 then c:px(x, y, LEATH[4]) elseif d == 2 then c:px(x, y, LEATH[3]) else c:px(x, y, LEATH[5]) end
end end)
-- brass ferrule
sm:each(function(x, y) if y >= 52 then c:px(x, y, (x - 22 < 1) and BRASS[5] or ((x - 22 < 2) and BRASS[3] or BRASS[1])) end end)
c:px(21, 53, BRASS[6]) c:px(21, 54, BRASS[5])
-- bundle hanging off the branch: cloth sack on a knot
G.line(c, { {49, 10}, {49, 13}, {50, 15} }, LEATH[3])
local sack = c:ellipse(50, 23, 6, 7)
sack:add(c:poly{ {46, 17}, {54, 17}, {52, 20}, {48, 20} })
tone(sack, CLOTH, 7, 0.1)
-- folds and stitching
for _, p in ipairs{ {47, 24}, {48, 26}, {49, 27}, {52, 22}, {53, 24} } do c:px(p[1], p[2], CLOTH[1]) end
for i = 0, 2 do c:px(48 + i * 2, 20, LEATH[6]) end
c:px(47, 20, CLOTH[6]) c:px(47, 21, CLOTH[6]) c:px(48, 21, CLOTH[6])
-- cinch knot
c:fillMask(c:rect(49, 16, 51, 17), LEATH[4]) c:px(49, 16, LEATH[6]) c:px(51, 17, LEATH[2])
-- quirk: a bright feather tucked in
G.line(c, { {53, 18}, {55, 14}, {57, 11} }, "#3a9a8a")
c:px(56, 12, "#8ee0c8") c:px(57, 12, "#3a9a8a") c:px(55, 13, "#8ee0c8") c:px(57, 10, "#c4f0e0")
-- knot glint
c:px(35, 24, WOOD[6])
G.fin(c, NAME)
