-- sky-talon (lean P1b_O9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local NAME = "sky-talon"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ICE = { "#33468a", "#5379bd", "#85a9dd", "#b4d3f0", "#dff0fa", "#fbfdf4" }
local GOLD = { "#4a2a2a", "#7a4a30", "#a8703a", "#d19a4a", "#eec26a", "#fbe49a" }
local FEA = { "#2a6a82", "#3f93a0", "#6cbfb4", "#a2dcc2", "#d2f0d6", "#f2fbe8" }
c:groundShadow(30, 56, 12, 2)
-- feather tuft hanging from the wrap (quirk), behind
local fm, fn = G.blade(40, 20, 50, 28, 46, 42, function(t) return 3.4 * sin(pi * min(1, t * 1.05)) ^ 0.7 end)
G.toneN(c, fm, fn, FEA, { amb = 0.1 })
fm:each(function(x, y) end)
-- talon
local tm, tn, T, S = G.tube({ {42, 12}, {46, 30}, {34, 46}, {14, 54} }, function(t) return max(0.4, 5.6 * (1 - t) ^ 0.85 + 0.3) end)
G.toneN(c, tm, tn, ICE, { amb = 0.1, wrap = 0.2 })
tm:each(function(x, y)
  local k = K(x, y)
  -- ridge groove along the talon
  if abs(S[k] + 0.2) < 0.13 and T[k] > 0.12 and T[k] < 0.88 then c:px(x, y, ICE[2]) end
  if abs(S[k] + 0.55) < 0.1 and T[k] > 0.15 and T[k] < 0.7 then c:px(x, y, ICE[6]) end
end)
-- feather midrib
G.line(c, { {40, 21}, {45, 27}, {46, 38} }, FEA[1])
-- gold cord wrap at base
local wm = HP.mask()
tm:each(function(x, y) if T[K(x, y)] < 0.2 then wm:set(x, y) end end)
local wn = X.pillow(wm, 4)
G.toneN(c, wm, wn, GOLD, { amb = 0.1 })
wm:each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, GOLD[2]) elseif (x + y) % 4 == 2 then c:px(x, y, GOLD[5]) end end)
-- base knot cap
local km, kn = G.oval(42, 12, 5.5, 3.2, -0.3, 0.9)
G.toneN(c, km, kn, GOLD, { amb = 0.1 })
c:px(40, 11, GOLD[6]) c:px(41, 11, GOLD[6])
-- tip glint
c:px(17, 52, ICE[6]) c:px(36, 40, ICE[6]) c:px(35, 41, ICE[6])
G.save(c, NAME)
