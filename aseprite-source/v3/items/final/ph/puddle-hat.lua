-- puddle-hat (lean W2_15)
-- Straw hat dropped brim-down in a puddle: ringed woven brim, domed crown with a red band, ripple rings, a drip, a lily scrap.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "puddle-hat" }
local abs, sqrt, floor = math.abs, math.sqrt, math.floor
local WATER = { "#1f3f78", "#2b5a9c", "#3f7fbe", "#63a4d6", "#96cdea", "#d4f0f6" }
local STRAW = { "#7a4a1e", "#a8692a", "#d08f35", "#eab04a", "#f6cf6c", "#fff0a8" }
local RED   = { "#5a1428", "#8a1f36", "#b8323f", "#dc5650", "#f08a6e" }
local LILY  = { "#1d4a35", "#2f6e46", "#4c9a52", "#80c468" }
-- puddle
local pud = c:ellipse(32, 47, 23, 9)
local pn = X.pillow(pud, 9)
local pv = X.light(pn, { amb = 0.5, wrap = 0.4 })
pud:each(function(x, y) local d = ((x - 32) / 23)^2 + ((y - 47) / 9)^2
  if X.hash(x, y, 3) > 0.86 then pv[K(x, y)] = pv[K(x, y)] + 0.12 end end)
G.tone(c, pud, pv, WATER, { 0.2, 0.38, 0.55, 0.72, 0.9 })
-- sky glint streaks on water
for _, s in ipairs{ {46, 50, 4}, {14, 46, 3}, {40, 53, 3} } do for i = 0, s[3] - 1 do c:px(s[1] + i, s[2], WATER[6]) end end
-- ripple ring around hat
local rr = c:ellipse(32, 44, 21, 7)
rr:cut(rr:copy():shrink(1))
rr:each(function(x, y) if y > 41 and X.hash(x, y, 8) > 0.25 then c:px(x, y, WATER[5]) end end)
-- brim
local brim = c:ellipse(32, 41, 18, 6)
local bn = X.pillow(brim, 5)
local bv = X.light(bn, { amb = 0.3, wrap = 0.3 })
brim:each(function(x, y)
  local d = sqrt(((x - 32) / 18)^2 + ((y - 41) / 6)^2)
  if floor(d * 8) % 2 == 0 then bv[K(x, y)] = bv[K(x, y)] - 0.13 end
  if (x + floor(d * 8)) % 5 == 0 then bv[K(x, y)] = bv[K(x, y)] + 0.07 end end)
G.tone(c, brim, bv, STRAW, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- water lapping over the front lip of the brim
local lap = c:ellipse(32, 41, 18, 6)
lap:each(function(x, y) if y >= 45 or (y >= 44 and X.hash(x, y, 2) > 0.5) then c:px(x, y, (x % 3 == 0) and WATER[4] or WATER[3]) end end)
for x = 20, 44 do if X.hash(x, 44, 6) > 0.55 then c:px(x, 44, WATER[5]) end end
-- crown (dome, clipped at brim)
local crown = c:ellipse(32, 35, 10, 12)
crown:cut(c:rect(0, 40, 63, 63))
local cn = X.pillow(crown, 9)
local cv = X.light(cn, { amb = 0.15, wrap = 0.25 })
crown:each(function(x, y) if (x + y) % 4 == 0 then cv[K(x, y)] = cv[K(x, y)] - 0.07 end
  if y < 33 and (x - y) % 5 == 0 then cv[K(x, y)] = cv[K(x, y)] + 0.06 end end)
G.tone(c, crown, cv, STRAW, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- red band
local band = crown:copy()
band:cut(c:rect(0, 0, 63, 33)) band:cut(c:rect(0, 37, 63, 63))
local bnn = X.pillow(crown, 9)
G.tone(c, band, X.light(bnn, { amb = 0.15, wrap = 0.25 }), RED, { 0.25, 0.45, 0.65, 0.85 })
for x = 23, 41 do if crown:has(x, 37) then c:px(x, 38, STRAW[1]) end end
-- knot on band
c:px(36, 34, RED[5]) c:px(37, 34, RED[4]) c:px(36, 35, RED[3])
-- crown specular + glint
c:px(27, 28, STRAW[6]) c:px(28, 28, STRAW[6]) c:px(27, 29, STRAW[5]) c:sparkle(25, 30)
-- drip from brim edge (quirk) + landing ring
c:px(15, 44, WATER[4]) c:px(15, 45, WATER[5])
-- lily scrap
c:fillMask(c:ellipse(52, 50, 3, 1), LILY[3]) c:px(51, 50, LILY[4]) c:px(54, 50, LILY[1]) c:px(53, 51, LILY[2])
G.fin(c, "puddle-hat")
