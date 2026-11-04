-- tomato-chutney (lean D3o_5)
-- A squat wide-mouth glass jar of chunky brown-red chutney, gingham cloth cap tied with twine, cream tomato label.
-- quirk: a sticky drip has run down the outside of the jar from under the cloth.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tomato-chutney" }
local sin, cos, pi, sqrt, abs, floor = math.sin, math.cos, math.pi, math.sqrt, math.abs, math.floor
local function sh(m, ramp, R, amb, wrap, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, bias, tok)
  return n, v
end
local GL = { "#4a6a8e", "#7a9cbc", "#a8c8de", "#cce2ee", "#e6f4f8", "#fffff6" }
local CH = { "#3a1216", "#5e1c1a", "#8c3418", "#b84c1e", "#dc7228", "#f4a444" }
local RE = { "#6a1424", "#a02034", "#d03a40", "#ee6a58" }
local CR = { "#a09088", "#d4c4b0", "#efe4cc", "#fff8e4" }
c:groundShadow(32, 56, 17, 2)
local jar = c:rrect(15, 18, 49, 55, 6)
local jn = sh(jar, GL, 14, 0.2, 0.4)
-- chutney inside
local inner = c:rrect(17, 24, 47, 53, 4)
local cn, cv = sh(inner, CH, 13, 0.08, 0.3)
inner:each(function(x, y)
  local h = X.hash(floor(x / 2), floor(y / 2), 5)
  if h > 0.8 and cv[K(x, y)] > 0.35 then c:px(x, y, CH[5]) c:px(x + 1, y, CH[4]) elseif h < 0.12 then c:px(x, y, CH[1]) end
end)
-- tomato chunks
for _, p in ipairs{ {22, 44}, {40, 34}, {35, 49}, {24, 31} } do
  c:fillMask(c:ellipse(p[1], p[2], 2.5, 1.8), RE[3]) c:px(p[1] - 1, p[2] - 1, RE[4]) c:px(p[1] + 1, p[2] + 1, RE[1])
end
-- glass streaks
for y = 30, 50 do c:px(19, y, GL[5]) end
c:px(19, 51, GL[4]) c:px(20, 29, GL[6]) c:px(20, 30, GL[6])
for y = 28, 44 do c:px(45, y, GL[3]) end
-- label
c:fillMask(c:rect(24, 36, 40, 47), CR[3])
c:fillMask(c:rect(24, 47, 40, 47), CR[1]) c:fillMask(c:rect(40, 36, 40, 47), CR[2]) c:fillMask(c:rect(24, 36, 40, 36), CR[4])
c:fillMask(c:ellipse(32, 42, 3, 3), RE[3]) c:px(31, 41, RE[4]) c:px(33, 44, RE[1]) c:px(31, 39, "#4b9650") c:px(32, 39, "#4b9650") c:px(33, 39, "#4b9650")
c:px(26, 38, CR[1]) c:px(27, 38, CR[1]) c:px(37, 45, CR[1]) c:px(38, 45, CR[1])
-- drip (quirk)
local dm, dn = G.tube({ {45, 27}, {45, 31}, {46, 35}, {45, 39} }, function(t) return 1.6 - 0.5 * t end)
G.tone(c, dm, X.light(dn, { amb = 0.1, wrap = 0.3 }), CH, nil)
c:fillMask(c:ellipse(45, 40, 1.5, 1.8), CH[3]) c:px(44, 39, CH[5])
-- cloth cap, gingham
local cloth = c:ellipse(32, 17, 17, 4)
for x = 13, 51 do
  local bot = 27 + 2 * sin(x * 0.75)
  for y = 17, floor(bot) do if abs(x - 32) <= 19 then cloth:set(x, y) end end
end
cloth:cut(c:rect(0, 0, 63, 12))
local cn2, cv2 = X.pillow(cloth, 9), nil
cv2 = X.light(cn2, { amb = 0.2, wrap = 0.35 })
local m1, m2, m3 = HP.mask(), HP.mask(), HP.mask()
cloth:each(function(x, y)
  local a, b = floor(x / 4) % 2, floor(y / 4) % 2
  if a == 0 and b == 0 then m3:set(x, y) elseif a == 1 and b == 1 then m2:set(x, y) else m1:set(x, y) end
end)
local CLR = { "#6a1424", "#a02034", "#d03a40", "#ee6a58", "#ff9a80", "#ffd0c0" }
local CLC = { "#9a8a94", "#cfc0c0", "#f0e4dc", "#fff6ee", "#fffff6", "#fffff6" }
local CLM = { "#7a2c40", "#bc4858", "#e0707a", "#f4a0a0", "#ffc8c4", "#ffe4e0" }
G.tone(c, m3, cv2, CLM) G.tone(c, m2, cv2, CLC) G.tone(c, m1, cv2, CLR)
-- twine
for x = 14, 50 do
  local y = 28 + floor(sin(x * 0.75) * 0.0 + 0.5)
  if cloth:has(x, y) or x < 50 then c:px(x, 28, (x % 3 == 0) and "#8a6a40" or "#c9a566") end
end
for x = 14, 50 do c:px(x, 29, (x % 3 == 1) and "#6a4e30" or "#a8884e") end
c:fillMask(c:ellipse(22, 29, 2, 2), "#c9a566") c:px(22, 29, "#6a4e30")
c:line({ {22, 30}, {19, 34}, {20, 37} }, 1):each(function(x, y) c:px(x, y, "#a8884e") end)
c:line({ {22, 30}, {25, 33}, {24, 36} }, 1):each(function(x, y) c:px(x, y, "#c9a566") end)
G.fin(c, "tomato-chutney")
