-- yogurt (lean W2_40)
-- Squat glazed crock with swirled yogurt peak, one blueberry on top, a spoon leaning in, a drip down the side.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function L(n,o) return X.light(n, o or { amb = 0.1, wrap = 0.25 }) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "yogurt" }
local CER = { "#2f4f7a", "#40699a", "#5a8cc0", "#82b4dc", "#b2d6ee", "#e6f4fb" }
local YOG = { "#9aa0c8", "#c3c4e0", "#e2dff0", "#f6f1f6", "#fffaf8" }
local SPN = { "#6d6a7c", "#9c9aab", "#cfcdd6", "#f2f1f5" }
c:groundShadow(32, 52, 18, 2)
-- crock body: wide, rounded bottom
local body = HP.mask()
for y = 34, 51 do
  local t = (y - 34) / 17
  local h = 17 * (1 - t^3.2 * 0.38) * sqrt(1 - max(0, t - 0.7)^2 * 6)
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do body:set(x, y) end
end
local n = X.pillow(body, 11)
local v = L(n, { amb = 0.12, wrap = 0.25 })
G.tone(c, body, v, CER, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- glaze band + dots
for x = 16, 48 do if body:has(x, 41) then c:px(x, 41, CER[1]) end if body:has(x, 42) then c:px(x, 42, CER[5]) end end
for _, p in ipairs{ {22,46},{28,47},{35,46},{41,45} } do c:px(p[1], p[2], CER[5]) end
-- rim
local rim = c:ellipse(32, 34, 17, 4)
G.tone(c, rim, L(X.pillow(rim, 5)), CER, { 0.2, 0.4, 0.6, 0.8, 0.9 })
-- yogurt surface
local surf = c:ellipse(32, 34, 14, 2.6)
c:fillMask(surf, YOG[2])
-- swirled peak
local peak = HP.mask()
for y = 22, 34 do
  local t = (y - 22) / 12
  local h = 12 * sin(min(1, t * 1.2 + 0.05) * pi / 2) ^ 0.7
  if y < 25 then h = max(0, (y - 21) * 1.2) end
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do peak:set(x, y) end
end
local pn = X.pillow(peak, 8)
G.tone(c, peak, L(pn, { amb = 0.25, wrap = 0.3 }), YOG, { 0.25, 0.5, 0.72, 0.9 })
-- swirl lines
for _, s in ipairs{ {26,30,35,28}, {27,33,38,31}, {29,26,35,25} } do G.line(c, { {s[1],s[2]},{(s[1]+s[3])/2,s[2]-1},{s[3],s[4]} }, YOG[1]) end
-- curled tip
G.line(c, { {32,21},{33,20},{34,21} }, YOG[2])
-- blueberry quirk
local bb = c:ellipse(35, 25, 3, 2.8)
G.tone(c, bb, L(X.pillow(bb, 3)), { "#1d1f4a", "#2f3a86", "#4a5cb4", "#7e8fd8" }, { 0.3, 0.55, 0.8 })
c:px(35, 24, "#aab8f0") c:px(36, 26, "#1d1f4a")
-- spoon leaning in from right
local sh = G.tube({ {42,31},{45,27},{48,22},{51,15} }, function(t) return 1.1 end)
G.tone(c, sh, L(X.pillow(sh, 2)), SPN, { 0.3, 0.6, 0.85 })
local sb = G.rell(41, 32, 0.7, -0.7, 3.4, 2.2)
G.tone(c, sb, L(X.pillow(sb, 2.5)), SPN, { 0.3, 0.55, 0.8 })
-- drip down the side
for y = 35, 40 do c:px(21, y, YOG[3]) c:px(22, y, YOG[4]) end
c:px(21, 41, YOG[2]) c:px(22, 41, YOG[3]) c:px(22, 42, YOG[3]) c:px(22, 40, YOG[5])
-- glint
c:px(21, 36, CER[6]) c:px(22, 44, CER[6]) c:px(20, 38, CER[6])
G.fin(c, "yogurt")
