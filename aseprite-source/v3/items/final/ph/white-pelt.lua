-- white-pelt (lean W2_38)
-- Fluffy winter pelt seen from above: long body, small head left, four dangling paws, bushy tail with dark tip, tufted edge, leather peeking lower-right.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "white-pelt" }
local abs, sin, cos, sqrt = math.abs, math.sin, math.cos, math.sqrt
local FUR = { "#7f78a8", "#a9a4c8", "#cdcae0", "#e8e6f0", "#f8f6fa", "#fffafc" }
local LEA = { "#5a3a30", "#8a5c3e", "#b98456" }
local tok = { r = { name = "fur" } }
c:groundShadow(34, 50, 20, 3)
local body = c:ellipse(33, 32, 15, 9)
local parts = {
  c:ellipse(17, 28, 6, 5), c:ellipse(18, 27, 4, 3),           -- head + snout lump
  c:ellipse(24, 19, 4, 3), c:ellipse(40, 19, 4, 3),           -- front/back paws up
  c:ellipse(24, 45, 4, 4), c:ellipse(41, 45, 4, 4),           -- lower paws
  c:ellipse(51, 36, 8, 5),                                    -- tail
}
-- ears
local ears = c:ellipse(15, 22, 2, 2):add(c:ellipse(20, 22, 2, 2))
for _, p in ipairs(parts) do body:add(p) end
body:add(ears)
-- tufted edge: ragged by hash
local m = HP.mask()
body:each(function(x, y) m:set(x, y) end)
body:edge():each(function(x, y) if X.hash(x, y, 7) > 0.55 then m:cut(c:rect(x, y, x, y)) end end)
local tufts = body:edge():grow(1)
tufts:each(function(x, y) if X.hash(x, y, 9) > 0.8 and not body:has(x, y) then m:set(x, y) end end)
-- leather underside, offset lower-right
local lea = m:copy():shift(1, 2); lea:cut(m)
c:fillMask(lea, LEA[2]) lea:edge():each(function(x, y) c:px(x, y, LEA[1]) end)
local n = X.pillow(m, 8)
local v = X.light(n, { amb = 0.18, wrap = 0.4 })
G.tone(c, m, v, FUR, { 0.15, 0.3, 0.5, 0.72, 0.9 }, nil, tok)
-- fur strokes
m:each(function(x, y)
  if X.hash(x, y, 2) > 0.86 and v[K(x, y)] > 0.3 then c:px(x, y, FUR[3]) c:px(x + 1, y + 1, FUR[2]) end
  if X.hash(x, y, 5) > 0.93 then c:px(x, y, FUR[6]) end
end)
-- dark tail tip (quirk), nose, eyes
c:fillMask(c:ellipse(57, 37, 2.2, 2.2):cut(c:ellipse(52, 36, 5, 4)), "#3a2a3a")
c:px(58, 36, "#5a4a5a")
c:px(12, 29, "#3a2a3a") c:px(13, 29, "#3a2a3a") c:px(15, 26, "#3a2a3a") c:px(19, 26, "#3a2a3a")
c:px(16, 28, "#e8a0a8") c:px(15, 22, "#e8b0b8") c:px(20, 22, "#e8b0b8")
-- paw claws hint
for _, p in ipairs{ {23,48}, {25,48}, {40,48}, {42,48}, {23,16}, {25,16}, {39,16}, {41,16} } do c:px(p[1], p[2], FUR[1]) end
G.fin(c, "white-pelt")
