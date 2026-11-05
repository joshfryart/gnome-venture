-- feast-dunewhisper-pilaf (lean P1b_O0)
-- quirk: the steam curls into a wind-swirl and a ripple crest is blown across the rice dune. Teal bowl, saffron rice, carrot / pistachio / raisin flecks.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "feast-dunewhisper-pilaf" }
local pi, sin, cos, floor, max, min, abs, sqrt = math.pi, math.sin, math.cos, math.floor, math.max, math.min, math.abs, math.sqrt
local RICE = { "#8a5a1c", "#b87d24", "#e0a52f", "#f5c94c", "#ffe283", "#fff6c4" }
local TEAL = { "#14304a", "#1d5068", "#2a7a8a", "#47a8a8", "#84d2c0", "#c8f0e0" }
local WOOD = { "#4a2a16", "#6e4222", "#966434", "#c0904e" }
c:groundShadow(32, 54, 25, 4)
-- bowl
local bm, bn = G.oval(32, 46, 26, 12, 0, 0.8)
G.toneN(c, bm, bn, TEAL, { amb = 0.1, wrap = 0.3, tok = { r = { name = "bowl" } } })
local inner = G.oval(32, 44, 21, 8.5, 0, 1)
c:fillMask(inner, TEAL[1])
c:fillMask(inner:copy():shrink(1):cut(inner:copy():shrink(1):shift(0, 2)), TEAL[2]) -- inner back-wall
-- rim glint
for x = 12, 22 do if bm:has(x, 37 + floor((x - 12) * 0.0)) then end end
c:px(14, 42, TEAL[6]) c:px(15, 41, TEAL[6]) c:px(16, 40, TEAL[5]) c:px(13, 43, TEAL[5])
-- dune mound
local mound = HP.mask()
local ridgeX = 27
for x = 9, 55 do
  local dx = x - ridgeX
  local L, p = (dx < 0) and 19 or 28, (dx < 0) and 1.15 or 1.05
  local h = 26 * (1 - (abs(dx) / L) ^ p)
  if h > 0 then
    local top = floor(46 - h + 0.5)
    local bot = floor(46 + 5 * sqrt(max(0, 1 - ((x - 32) / 24) ^ 2)) + 0.5)
    for y = top, bot do mound:set(x, y) end
  end
end
local mn = X.pillow(mound, 12)
local bias = {}
mound:each(function(x, y) local k = K(x, y)
  if x > ridgeX + 1 then bias[k] = -1 end
  if x <= ridgeX and x > ridgeX - 6 then bias[k] = 1 end
  if x > ridgeX + 1 then
    -- wind ripples along the lee slope
    local r = (y + (x - ridgeX) * 0.55) % 4.5
    if r < 0.8 then bias[k] = (bias[k] or 0) + 1 elseif r > 3.7 then bias[k] = (bias[k] or 0) - 1 end
  end
end)
G.toneN(c, mound, mn, RICE, { bias = bias, amb = 0.12, wrap = 0.25, tok = { r = { name = "rice" } } })
-- rice grains
mound:each(function(x, y)
  local h = X.hash(x, y, 12)
  if h > 0.86 and mound:has(x + 1, y) then c:px(x, y, RICE[5]) c:px(x + 1, y, RICE[6]) c:px(x, y + 1, RICE[2])
  elseif h < 0.05 then c:px(x, y, RICE[2]) end
end)
-- toppings
local function top(x, y, base, hi, lo, w)
  c:fillMask(c:rect(x, y, x + (w or 2), y + 1), base) c:px(x, y, hi) c:px(x + (w or 2), y + 1, lo)
end
top(18, 37, "#f07a1c", "#ffb35a", "#b04a10", 2) top(33, 27, "#f07a1c", "#ffb35a", "#b04a10", 2)
top(40, 36, "#f07a1c", "#ffb35a", "#b04a10", 2) top(24, 30, "#f07a1c", "#ffb35a", "#b04a10", 1)
top(21, 43, "#7ab648", "#c4e87c", "#3e7a2c", 1) top(36, 41, "#7ab648", "#c4e87c", "#3e7a2c", 1) top(46, 42, "#7ab648", "#c4e87c", "#3e7a2c", 1)
top(29, 34, "#6a2c5e", "#b068a0", "#33122e", 1) top(44, 38, "#6a2c5e", "#b068a0", "#33122e", 1) top(15, 42, "#6a2c5e", "#b068a0", "#33122e", 1)
-- wooden spoon stuck in the lee slope
local sm, sn = G.tube({ {42,33}, {46,26}, {51,19}, {56,11} }, function(t) return 1.9 - 0.4 * t end)
G.toneN(c, sm, sn, WOOD, { cuts = { 0.3, 0.6, 0.85 }, tok = { r = { name = "spoon" } } })
local bowl = G.oval(41, 35, 3.6, 2.6, 0.5, 1)
bowl:each(function(x, y) if mound:has(x, y) or true then c:px(x, y, WOOD[(x + y) % 3 == 0 and 4 or 3]) end end)
c:px(40, 34, WOOD[4]) c:px(43, 37, WOOD[1])
-- steam swirl (wind whisper)
local st = G.tube({ {26,19}, {22,14}, {30,9}, {26,4} }, function(t) return 1.5 - 0.6 * t end)
G.toneN(c, st, select(2, G.tube({ {26,19}, {22,14}, {30,9}, {26,4} }, function(t) return 1.5 - 0.6 * t end)), { "#cfc8d8", "#e8e2ee", "#f8f4fb" }, { cuts = { 0.4, 0.75 }, tok = { r = { name = "steam" } } })
c:line({ {30,6}, {34,4}, {36,7} }, 1):each(function(x, y) c:px(x, y, "#e8e2ee") end)
G.save(c, "feast-dunewhisper-pilaf")
