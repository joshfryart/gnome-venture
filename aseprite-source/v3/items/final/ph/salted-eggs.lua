-- salted-eggs (lean P1b_O8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "salted-eggs" }
local CLAY = { "#3b1f1c", "#6a3a2a", "#94552f", "#bd7a3e", "#dd9f55", "#f4c880" }
local EGG  = { "#6f7f98", "#9aaabc", "#c4d2d8", "#e2eae6", "#f5f8ef", "#f2f6ff" }
local YOLK = { "#a8331a", "#d9561b", "#f0801f", "#ffa92e", "#ffd25a", "#fff1a0" }
local SALT = { "#8b94b4", "#b9c0d8", "#dde2ee", "#f2f6ff" }
c:groundShadow(32, 54, 21, 3)
-- crock body
local body = HP.mask()
for y = 31, 53 do
  local t = (y - 31) / 22
  local hw = 17.5 - 4 * (t ^ 1.6) + (t < 0.15 and 1.5 or 0)
  for x = floor(32 - hw + 0.5), floor(32 + hw - 0.5) do body:set(x, y) end
end
local bn = X.pillow(body, 15)
-- eggs first (behind rim)
local function egg(cx, cy, rx, ry, ang)
  local m, n = G.oval(cx, cy, rx, ry, ang, 1.1)
  G.toneN(c, m, n, EGG, { amb = 0.1, wrap = 0.25 })
  return m
end
egg(24, 22, 7.5, 9.5, -0.2)
egg(38, 20, 7.5, 9.5, 0.15)
-- cracked front egg with yolk
local em = egg(31, 24, 8, 9.5, 0)
local top = HP.mask() top:add(c:ellipse(31, 17, 6, 3.4))
top:clip(em)
c:fillMask(top, EGG[5])
local yk, yn = G.oval(31.5, 17.5, 3.2, 2.6, 0, 1.3)
G.toneN(c, yk, yn, YOLK, { amb = 0.1, wrap = 0.3 })
c:px(30, 16, YOLK[6])
for _, p in ipairs{ {25,19},{26,17},{27,18},{28,16},{29,15},{34,15},{35,16},{36,15},{37,17},{37,19} } do c:px(p[1], p[2], EGG[6]) end
for _, p in ipairs{ {25,20},{27,19},{29,16},{34,16},{36,17},{38,19} } do c:px(p[1], p[2], EGG[1]) end
-- crock
G.toneN(c, body, bn, CLAY, { amb = 0.08, wrap = 0.2 })
-- bands + grain
for x = 15, 49 do for _, y in ipairs{ 38, 46 } do if body:has(x, y) then c:px(x, y, CLAY[2]) if body:has(x, y + 1) then c:px(x, y + 1, CLAY[5]) end end end end
-- rim + salt crust
local rim = HP.mask() rim:add(c:ellipse(32, 31, 19.5, 4.2))
local rn = X.pillow(rim, 5)
G.toneN(c, rim, rn, CLAY, { amb = 0.2, wrap = 0.3 })
local inner = HP.mask() inner:add(c:ellipse(32, 31.5, 16.5, 2.8))
c:fillMask(inner, SALT[1])
inner:each(function(x, y) c:px(x, y, X.hash(x, y, 5) > 0.45 and SALT[3] or SALT[2]) end)
for _, p in ipairs{ {18,32},{22,33},{28,33},{36,33},{42,33},{46,32} } do c:px(p[1], p[2], SALT[1]) end
-- salt crystals dripping on the crock + rim
for _, p in ipairs{ {19,30},{24,29},{41,29},{46,31},{22,36},{27,40},{44,40},{40,36},{37,50} } do c:px(p[1], p[2], SALT[4]) c:px(p[1] + 1, p[2], SALT[3]) end
-- glaze highlight
for y = 36, 50 do c:px(19, y, CLAY[6]) end
for y = 39, 47 do c:px(20, y, CLAY[5]) end
G.save(c, "salted-eggs")
