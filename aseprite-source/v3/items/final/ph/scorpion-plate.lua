-- scorpion-plate (lean P1b_O8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scorpion-plate" }
local AMB = { "#3a1a0e", "#6a3512", "#9a5a18", "#c88626", "#eab444", "#fbe28a" }
local DRK = { "#1e0e0e", "#3a1a14", "#5a2c1a", "#80482a" }
local VEN = { "#1c6a2a", "#34a43a", "#7ede4a", "#d4ff90" }
local function tube(pts, w0, w1, ramp)
  local m, n = G.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  G.toneN(c, m, n, ramp or AMB, { amb = 0.1, wrap = 0.22 })
  return m
end
-- claws: arm + pincer blades
local function claw(sx)
  local x = function(v) return 32 + sx * (v - 32) end
  tube({ {x(26),24}, {x(18),24}, {x(12),22}, {x(10),16} }, 2.0, 1.6, DRK)
  local pm, pn = G.oval(x(10), 11, 4.8, 6.2, 0.15 * sx, 1)
  G.toneN(c, pm, pn, AMB, { amb = 0.1, wrap = 0.25 })
  -- gap between pincers
  local gm = HP.mask() gm:add(c:poly{ {x(10),4}, {x(9),9}, {x(11),11}, {x(12),7} })
  c:fillMask(gm, DRK[1])
  c:px(x(9), 9, AMB[6])
end
claw(1) claw(-1)
-- tail first part (behind body): curls up the right side
local tail = { {32,46}, {50,56}, {60,40}, {46,16} }
local tm, tn, tT = G.tube(tail, function(t) return 3.2 - 1.4 * t end)
G.toneN(c, tm, tn, AMB, { amb = 0.1, wrap = 0.22 })
tm:each(function(x, y) local t = tT[K(x, y)] if floor(t * 8) % 2 == 0 and t < 0.92 then c:px(x, y, AMB[2]) end end)
-- stinger
local st = HP.mask() st:add(c:poly{ {43,15}, {49,15}, {44,8} })
G.toneN(c, st, X.pillow(st, 2.5), DRK, { amb = 0.3, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
c:px(44, 9, AMB[6])
-- quirk: venom drop
c:fillMask(c:ellipse(44, 5, 1.2, 1.5), VEN[3]) c:px(44, 4, VEN[4]) c:px(45, 6, VEN[2])
-- segmented body (mesosoma plates)
for i = 0, 5 do
  local y = 33 + i * 3.2
  local rx = 9.8 - i * 0.9
  local m, n = G.oval(32, y, rx, 2.8, 0, 1.2)
  G.toneN(c, m, n, AMB, { amb = 0.1, wrap = 0.2 })
  c:fillMask(c:rect(floor(32 - rx + 1), floor(y + 2), floor(32 + rx - 1), floor(y + 2)), AMB[1])
end
-- carapace
local cp, cn = G.oval(32, 24, 10.5, 8.5, 0, 1.1)
G.toneN(c, cp, cn, AMB, { amb = 0.1, wrap = 0.2 })
c:fillMask(c:rect(30, 21, 34, 21), AMB[2])
c:px(29, 19, AMB[6]) c:px(30, 19, AMB[6]) c:px(28, 20, AMB[5])
-- eyes
c:px(29, 22, DRK[1]) c:px(35, 22, DRK[1]) c:px(29, 21, AMB[6]) c:px(35, 21, AMB[6])
-- little legs peeking
for _, p in ipairs{ {21,31},{20,35},{21,39},{43,31},{44,35},{43,39} } do
  local s = p[1] < 32 and -1 or 1
  c:px(p[1], p[2], DRK[3]) c:px(p[1] + s, p[2] + 1, DRK[3]) c:px(p[1] + 2 * s, p[2] + 2, DRK[2])
end
G.save(c, "scorpion-plate")
