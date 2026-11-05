-- feast-egg-pie (lean P1b_O1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local NAME = "feast-egg-pie"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local TIN = { "#3a3f66", "#5a6694", "#8794bd", "#b4c1dc", "#dbe5f2", "#f6faff" }
local CRUST = { "#5e2a1c", "#8c3f1e", "#b8601f", "#dd8a2c", "#f2b24a", "#ffd97a" }
local FILL = { "#b9742a", "#e0a032", "#f5c844", "#ffe27a", "#fff1b0", "#fffbe0" }
local WHITE = { "#8a86b0", "#b5b2d0", "#dcdaea", "#f3f1f6", "#fffaf0", "#fffaf0" }
local YOLK = { "#b8431a", "#e0661a", "#f58a1e", "#ffae24", "#ffd04a", "#ffe98a" }
c:groundShadow(32, 50, 22, 4)
local CX, CY = 32, 33
-- tin: fluted side
local side = c:ellipse(CX, CY + 9, 21, 11):add(c:rect(CX - 21, CY, CX + 21, CY + 9))
local sv = {}
side:each(function(x, y) local f = 0.9 - 0.8 * ((x - 11) / 42) ^ 0.9
  if (x % 4) == 0 then f = f - 0.2 end
  if y > CY + 9 then f = f - 0.12 * (y - CY - 9) / 3 end
  sv[K(x, y)] = max(0, min(1, f)) end)
X.tone(c, side, sv, TIN, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- crust top
local top = c:ellipse(CX, CY, 21, 11)
local n = X.pillow(top, 5)
G.toneN(c, top, n, CRUST, { amb = 0.2, wrap = 0.35 })
-- crimped rim
local inner = c:ellipse(CX, CY, 16, 8)
top:copy():cut(inner):each(function(x, y)
  local a = floor(atan(y - CY, (x - CX) / 1.9) * 9 / pi + 0.5)
  c:px(x, y, (a % 2 == 0) and CRUST[5] or CRUST[2])
  if (a % 2 == 0) and y < CY then c:px(x, y, CRUST[6]) end
end)
-- lattice over filling
inner:each(function(x, y)
  local a, b = (x + 2 * y) % 8, (x - 2 * y) % 8
  if a < 2 or b < 2 then c:px(x, y, (x + y < CX + CY) and CRUST[5] or CRUST[3])
    if a < 1 and b < 1 then c:px(x, y, CRUST[2]) end
  else c:px(x, y, FILL[(y > CY) and 2 or 3]) end
end)
-- wedge cut out (lower right): filling + egg
local wedge = HP.mask()
top:each(function(x, y) local a = atan(y - CY, (x - CX) / 1.9)
  if a > 0.05 and a < 0.85 and (x - CX) > 1 then wedge:set(x, y) end end)
local face = wedge:copy():grow(1):cut(wedge):clip(top)
face:each(function(x, y) c:px(x, y, (x + y) % 3 == 0 and CRUST[3] or CRUST[4]) end)
local fm = wedge:copy()
fm:each(function(x, y) local t = (y - CY) / 11
  c:px(x, y, FILL[3 + ((x + y) % 5 == 0 and 1 or 0)])
  if X.hash(x, y, 3) > 0.9 then c:px(x, y, FILL[2]) end end)
local eg = c:ellipse(46, 37, 6, 3.4)
G.toneN(c, eg, X.pillow(eg, 3), WHITE, {})
local yk = c:ellipse(46, 36, 2.6, 2)
G.toneN(c, yk, X.pillow(yk, 2), YOLK, {})
c:px(45, 35, "#fffaf0")
-- yolk peeking through a lattice hole (quirk)
c:fillMask(c:rect(24, 30, 25, 31), YOLK[3]) c:px(24, 30, YOLK[6]) c:px(25, 31, YOLK[1])
-- crust glints
c:px(22, 28, CRUST[6]) c:px(23, 27, CRUST[6]) c:px(36, 26, CRUST[6])
-- tin rim highlight
c:px(14, CY + 6, TIN[6]) c:px(14, CY + 7, TIN[6])
G.save(c, NAME)
