-- weeping-willow (lean D3o_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }
local NAME = "weeping-willow"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, ramp, R, amb, bias) local n = X.pillow(m, R or 4); G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local BARK = { "#26181c", "#42281f", "#64402b", "#876040", "#a98055", "#c8a074" }
local LEAF = { "#173a3a", "#215a48", "#2f7a52", "#4a9a58", "#74b866", "#a4d278" }
local WATER= { "#2a5a8a", "#3a7ab0", "#6aa8d0", "#a8d4e8" }
c:groundShadow(32, 56, 22, 3)
-- little pond ripple at the foot
c:fillMask(c:ellipse(46, 56, 8, 1.5), WATER[2]) c:fillMask(c:ellipse(46, 55, 5, 0.6), WATER[3]) c:px(44, 55, WATER[4])
-- leaning trunk with a flared root and a fork
local tm = G.tube({ {30, 56}, {31, 44}, {33, 34}, {32, 24} }, function(t) return 3.2 - 1.6 * t + 2.2 * max(0, 0.15 - t) / 0.15 end)
tone(tm, BARK, 3, 0.1)
tm:each(function(x, y) if X.hash(x, y, 9) > 0.8 and tm:has(x, y - 1) then c:px(x, y, BARK[2]) end
  if (x * 2 + y) % 5 == 0 and X.hash(x, y, 2) > 0.5 then c:px(x, y, BARK[5]) end end)
local fk = G.tube({ {32, 34}, {27, 30}, {22, 26}, {20, 21} }, function(t) return 1.5 - 0.5 * t end)
tone(fk, BARK, 1.5, 0.1)
-- quirk: knothole with two owl eyes
c:fillMask(c:ellipse(31, 46, 1.4, 2), BARK[1])
c:px(30, 45, "#ffe9a0") c:px(32, 45, "#ffe9a0")
-- crown: lumpy dome
local crown = HP.mask()
crown:add(c:ellipse(32, 16, 17, 8)) crown:add(c:ellipse(21, 20, 9, 6)) crown:add(c:ellipse(43, 20, 9, 6))
local cn = X.pillow(crown, 7)
local bias = {}
crown:each(function(x, y) if X.hash(x, y, 7) > 0.78 then bias[K(x, y)] = -1 end end)
G.tone(c, crown, X.light(cn, { amb = 0.1, wrap = 0.25 }), LEAF, CUTS, bias)
-- hanging strands
local cols = {}
for x = 13, 51 do
  if (x % 3) ~= 0 then
    local top = 24
    for y = 14, 28 do if crown:has(x, y) then top = y end end
    local edge = 1 - abs(x - 32) / 21
    local len = floor(8 + 20 * edge * (0.55 + 0.45 * X.hash(x, 1, 4)))
    if abs(x - 32) < 3 then len = 4 end
    for i = 1, len do
      local y = top + i
      local sx = x + floor(sin(i * 0.35 + x) * 0.9 + 0.5)
      local t = i / len
      local idx = 4
      if t > 0.75 then idx = 3 elseif X.hash(x, i, 3) > 0.7 then idx = 5 end
      if (x % 3) == 1 and t > 0.3 then idx = max(2, idx - 1) end
      if t > 0.9 then idx = 5 end
      c:px(sx, y, LEAF[idx])
      if i % 4 == 2 and (x % 2 == 0) then c:px(sx + 1, y, LEAF[idx]) end
    end
  end
end
-- highlight clump on the dome
c:fillMask(c:ellipse(26, 11, 4, 1.5), LEAF[6])
c:px(24, 13, LEAF[5]) c:px(30, 9, LEAF[6])
G.fin(c, NAME)
