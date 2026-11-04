-- wing-dust (lean W2_40)
-- Corked glass phial, round belly, half full of iridescent scale dust; a tiny insect wing tucked behind the cork.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function L(n,o) return X.light(n, o or { amb = 0.1, wrap = 0.25 }) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wing-dust" }
local GLASS = { "#4a5f8e", "#7a93c4", "#a9c3e4", "#cfe3f2", "#e9f4fa", "#f4fbff" }
local CORK = { "#4e2f2a", "#7a4a35", "#a2683f", "#c58b52", "#e0ae72" }
local WING = { "#3f7f86", "#5fb0ae", "#8fd8c8", "#c4f0e0" }
c:groundShadow(32, 53, 13, 2)
-- wing behind cork
local wm = G.rell(41, 15, 0.8, -0.6, 8, 3.2)
G.tone(c, wm, L(X.pillow(wm, 3)), WING, { 0.3, 0.55, 0.8 })
G.line(c, { {35,18},{46,11} }, WING[1])
G.line(c, { {38,18},{44,14} }, WING[4])
-- glass
local body = c:ellipse(32, 40, 13, 12)
local neck = c:rect(29, 24, 35, 31)
local lip = c:rect(28, 22, 36, 24)
local glass = HP.mask():add(body):add(neck):add(lip)
local n = X.pillow(glass, 9)
G.tone(c, glass, L(n, { amb = 0.2, wrap = 0.3 }), GLASS, { 0.12, 0.25, 0.4, 0.58, 0.8 })
-- dust (iridescent speckle with domed top)
local PAL = { "#b58be0", "#e58fc9", "#8fd6c4", "#f3d36b", "#8fa6ee", "#d9b6f2" }
local inner = glass:copy():shrink(1)
local dust = HP.mask()
inner:each(function(x, y)
  local top = 38 + 1.6 * sin(x * 0.7) - 0.05 * (x - 32)^2 * 0
  if y >= top and y < 53 then dust:set(x, y) end
end)
local dn = X.pillow(dust, 8)
local dv = L(dn, { amb = 0.2, wrap = 0.3 })
dust:each(function(x, y)
  local h = X.hash(x, y, 3)
  local base = PAL[1 + floor(h * 6) % 6]
  local v = dv[K(x, y)] or 0.5
  if v < 0.3 then base = "#6b4f9e" elseif v > 0.85 and h > 0.5 then base = "#fff4fb" end
  c:px(x, y, base)
end)
-- dust surface ridge
dust:each(function(x, y) if not dust:has(x, y - 1) then c:px(x, y, "#fff0fa") end end)
-- glass highlights
for y = 33, 46 do c:px(22, y, GLASS[6]) end
c:px(23, 32, GLASS[6]) c:px(24, 31, GLASS[5]) c:px(30, 26, GLASS[6]) c:px(30, 27, GLASS[6])
for x = 36, 41 do c:px(x, 50, GLASS[3]) end
-- cork
local cork = c:rect(29, 16, 35, 22)
G.tone(c, cork, L(X.pillow(cork, 4)), CORK, { 0.2, 0.4, 0.6, 0.8 })
for _, p in ipairs{ {30,18},{33,19},{31,21},{34,17} } do c:px(p[1], p[2], CORK[1]) end
c:px(30, 17, CORK[5])
-- sparkles floating up
c:sparkle(18, 22) c:sparkle(47, 30) c:px(21, 14, "#fff4fb") c:px(51, 40, "#f3d36b")
G.fin(c, "wing-dust")
