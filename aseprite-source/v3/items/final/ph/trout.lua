-- trout (lean D3o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "trout" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CU = { 0.2, 0.38, 0.55, 0.72, 0.87 }
local function sh(m, ramp, R, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, CU, bias, tok)
  return n, v
end
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local BACK = { "#1f3a2a", "#2f5a38", "#4a7e44", "#6ba04e", "#93c260", "#c4e08a" }
local MID = { "#6a3a4a", "#a05a5a", "#d07a6a", "#e89a82", "#f6bc9c", "#ffdcc0" }
local BEL = { "#6a6a7a", "#9a98a6", "#c4c0c6", "#e6e0da", "#f8f0e0", "#fffaf0" }
local FIN = { "#4a3a2a", "#7a5a38", "#a8794a", "#cc9a5a", "#e4b878", "#f4d49a" }
local function cy(x) return 34 - 3 * ((x - 8) / 44) ^ 2 end
local function hh(x)
  local t = (x - 8) / 44
  return max(2.2, 8.5 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.7)
end
local function top(x) return cy(x) - hh(x) end
local function bot(x) return cy(x) + hh(x) end
-- fins behind the body
sh(c:poly{ {51, cy(51) - 2}, {60, cy(60) - 9}, {57, cy(57)}, {60, cy(60) + 9}, {51, cy(51) + 2} }, FIN, 4)
sh(c:poly{ {22, top(22) + 1}, {27, top(27) - 7}, {35, top(35) - 5}, {37, top(37) + 1} }, FIN, 4)
sh(G.rell(45, top(45) - 0.5, 1, 0, 2.5, 1.6), FIN, 1.5)
sh(c:poly{ {37, bot(37) - 1}, {41, bot(41) + 5}, {46, bot(46) + 3}, {45, bot(45) - 1} }, FIN, 3)
sh(c:poly{ {24, bot(24) - 1}, {25, bot(25) + 4}, {30, bot(30) + 3}, {30, bot(30) - 1} }, FIN, 3)
local body, back, mid, bel = HP.mask(), HP.mask(), HP.mask(), HP.mask()
for x = 8, 52 do
  local h, m = hh(x), cy(x)
  for y = floor(m - h + 0.5), floor(m + h - 0.5) do
    body:set(x, y)
    local r = (y - m) / h
    if r < -0.35 then back:set(x, y) elseif r < 0.18 then mid:set(x, y) else bel:set(x, y) end
  end
end
local n = X.pillow(body, 8)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
G.tone(c, back, v, BACK, CU)
G.tone(c, mid, v, MID, CU)
G.tone(c, bel, v, BEL, CU)
-- spots
body:each(function(x, y)
  if x > 18 and x < 51 then
    local h = X.hash(x, y, 5)
    if back:has(x, y) and h > 0.86 then c:px(x, y, "#1c2a1c") end
    if mid:has(x, y) and h > 0.93 then c:px(x, y, "#d8383a") end
    if mid:has(x, y) and h < 0.04 then c:px(x, y, "#27343a") end
  end
end)
-- pectoral fin
sh(G.rell(20, cy(20) + 4, 0.8, 0.5, 4.5, 1.8), FIN, 2)
-- gill cover, mouth, eye
for yy = floor(cy(19)) - 6, floor(cy(19)) + 5 do c:px(19 + ((yy - floor(cy(19))) % 11 == 0 and 0 or ((abs(yy - cy(19)) > 4) and 0 or 1)) , yy, MID[2]) end
c:px(8, floor(cy(8)) + 1, BACK[1]) c:px(9, floor(cy(9)) + 2, BACK[1]) c:px(10, floor(cy(10)) + 2, BACK[1])
local ey = floor(cy(13)) - 2
c:fillMask(c:ellipse(13, ey, 2.4, 2.4), "#e8c860")
c:fillMask(c:ellipse(13, ey, 1.2, 1.2), "#1a1a22")
c:px(12, ey - 1, "#f4fbff")
-- bubbles (quirk)
c:px(7, 26, "#bfe6ff") c:px(8, 26, "#e8f6ff") c:px(7, 27, "#8fb6e0") c:px(8, 27, "#bfe6ff")
c:px(10, 21, "#bfe6ff") c:px(11, 21, "#f4fbff")
G.fin(c, "trout")
