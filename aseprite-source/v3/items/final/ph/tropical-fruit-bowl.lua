-- tropical-fruit-bowl (lean D3o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tropical-fruit-bowl" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CU = { 0.2, 0.38, 0.55, 0.72, 0.87 }
local function sh(m, ramp, R, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, CU, bias, tok)
  return n, v
end
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local BOWL = { "#1c4a5c", "#23697a", "#2f8c92", "#4fb0a8", "#88d4c0", "#cbf2dc" }
local MAN = { "#6a1f2a", "#a8372c", "#d9602a", "#f08a30", "#f7b648", "#fde08a" }
local BAN = { "#6b4a12", "#a4761c", "#d4a62a", "#f0cc3e", "#fbe46a", "#fff6aa" }
local KIW = { "#2f6a2a", "#4d9a32", "#7cc23f", "#a8dc5a", "#d2f088", "#f0ffc0" }
c:groundShadow(32, 57, 19, 2)
local bm, bn = G.tube({ {40,32},{45,25},{50,22},{54,23} }, function(t) return 2.7 - 0.5 * t end)
G.tone(c, bm, X.light(bn, { amb = 0.1, wrap = 0.3 }), BAN, CU)
c:px(54, 23, BAN[1]) c:px(54, 24, BAN[1])
local mango = G.rell(22, 28, 0.8, -0.6, 9.5, 7.5)
sh(mango, MAN, 8)
c:px(15, 22, "#b9d24a") c:px(16, 21, "#b9d24a") c:px(17, 20, "#b9d24a")
c:px(26, 19, "#2f5a2a") c:px(26, 18, "#2f5a2a") c:px(27, 18, "#2f5a2a")
c:px(18, 25, "#fff0c8") c:px(19, 25, "#fff0c8") c:px(18, 26, MAN[6])
-- kiwi slice
c:fillMask(c:ellipse(38, 29, 7, 7), "#7a5a30")
local flesh = c:ellipse(38, 29, 6, 6)
sh(flesh, KIW, 7)
c:fillMask(c:ellipse(38, 29, 2, 2), "#f0f6d0")
for k = 0, 7 do
  local a = k * pi / 4
  c:px(floor(38 + cos(a) * 3.8 + 0.5), floor(29 + sin(a) * 3.8 + 0.5), "#2b2a22")
end
c:px(35, 25, KIW[6]) c:px(36, 24, KIW[6])
-- hibiscus tucked in the rim (quirk)
for _, p in ipairs{ {13,34},{14,33},{15,34},{14,35},{13,35},{15,33} } do c:px(p[1], p[2], "#e8508a") end
c:px(13, 34, "#f58ab0") c:px(14, 34, "#ffe060")
-- bowl
sh(c:rect(26, 53, 38, 57), BOWL, 4)
local body = c:ellipse(32, 38, 20, 17):cut(c:rect(0, 0, 63, 37))
sh(body, BOWL, 12)
body:each(function(x, y)
  if y <= 40 then c:px(x, y, (y == 38) and BOWL[6] or BOWL[5]) end
  if y == 41 then c:px(x, y, BOWL[1]) end
end)
for x = 17, 47 do
  local y = 47 + (floor(x / 3) % 2) * 2
  if body:has(x, y) then c:px(x, y, "#f27f5b") c:px(x, y + 1, "#c4543e") end
end
c:px(20, 43, BOWL[6]) c:px(21, 43, BOWL[6])
G.fin(c, "tropical-fruit-bowl")
