-- pear (lean W2_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pear" }
local GR = { "#26452e", "#3b6a30", "#5f8f2f", "#92b438", "#c4d04c", "#eee77a" }
local BL = { "#6b4a1e", "#9a6a22", "#c88a30", "#e6b250" }
local LF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 }
c:groundShadow(31, 55, 11, 2)
local Y0, Y1 = 22, 53
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  if t < 0.35 then return 3.4 + 5.5 * (t / 0.35) ^ 1.3 end
  local u = (t - 0.35) / 0.65
  return 8.9 + 5.6 * sin(min(1, u * 1.15) * pi / 2) ^ 0.7 * (1 - u ^ 4) - 0.6
end
local body = HP.mask()
for y = Y0, Y1 do local h = hw(y) local cx = 32 - (Y1 - y) * 0.02
  for x = floor(cx - h + 0.5), floor(cx + h - 0.5) do body:set(x, y) end end
local n = X.pillow(body, 9)
local v = X.light(n, { amb = 0.08, wrap = 0.2 })
-- ripeness: green top, yellow-ish blush low-left via bias
local bias = {}
body:each(function(x, y)
  local k = K(x, y)
  if y > 36 and x < 30 and X.hash(x, y, 3) > 0.35 then bias[k] = 1 end
  if y < 30 then bias[k] = -1 end
end)
G.tone(c, body, v, GR, cuts, bias)
-- brown russet patch
local patch = HP.mask() patch:add(c:ellipse(27, 43, 5, 4))
patch:each(function(x, y) if X.hash(x, y, 7) > 0.25 and body:has(x, y) then c:px(x, y, BL[2 + floor(X.hash(x, y, 8) * 2)]) end end)
c:px(26, 41, BL[4]) c:px(25, 42, BL[3])
-- lenticels
for _, p in ipairs{ {36,38},{39,44},{34,48},{30,33},{40,50},{37,32} } do c:px(p[1], p[2], GR[1]) end
-- bloom spec
c:px(25, 34, "#fffbe0") c:px(26, 34, "#fffbe0") c:px(25, 35, GR[6]) c:px(27, 33, GR[6])
-- cool bounce lower-right
body:edge():each(function(x, y) if x > 38 and y > 40 then c:px(x, y, "#6fa0a0") end end)
-- stem curving right
G.line(c, { {32,22}, {32,19}, {33,16}, {35,14}, {37,13} }, BL[2])
G.line(c, { {33,22}, {33,19}, {34,16}, {36,14} }, BL[1])
c:px(32, 20, BL[3]) c:px(33, 17, BL[3])
c:px(31, 23, GR[1]) c:px(33, 23, GR[1]) c:px(32, 23, GR[1])
-- leaf off stem
local lm, ln = G.tube({ {36,15}, {42,9}, {47,8}, {52,12} }, function(t) return 0.8 + 3.0 * sin(pi * t) ^ 0.7 end)
G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.25 }), LF, cuts)
G.line(c, { {37,14}, {44,10}, {50,11} }, LF[6])
-- quirk: dew drop on belly
c:px(38, 41, "#d8f4f0") c:px(38, 42, "#8fd0c8") c:px(39, 42, "#5a9aa0")
G.fin(c, "pear")
