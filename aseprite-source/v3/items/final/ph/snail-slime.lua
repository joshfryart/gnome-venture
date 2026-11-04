-- snail-slime (lean D2o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, bias, o) local n = X.pillow(m, R) local v = X.light(n, o or { amb = 0.1, wrap = 0.25 }) local k = #ramp - 1 local cuts = {} for i = 1, k do cuts[i] = 0.12 + 0.76 * (i - 1) / max(1, k - 1) end if bias then for k, b in pairs(bias) do bias[k] = floor(b + 0.5) end end G.tone(c, m, v, ramp, cuts, bias) return n, v end
local function tube(c, p, wf, ramp, o) local m, n, T, S = G.tube(p, wf) G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp) return m, n, T, S end
local function disc(c, x, y, r, hex) c:fillMask(c:ellipse(x, y, r, r), hex) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "snail-slime" }
local SH = { "#4a2a2a", "#7a3f2e", "#a85c34", "#d68a45", "#f0b862", "#ffe49a" }
local TL = { "#1d5e66", "#2a8c8a", "#4fbfae", "#86e0c0", "#c2f5dc", "#f0fff0" }
local BD = { "#5a4a4a", "#826a62", "#a88c7c", "#c9ad98", "#e4cdb6", "#f8e8d4" }
-- slime puddle
local pud = c:ellipse(30, 51, 26, 4)
local pb = {}
shade(c, pud, TL, 5, pb)
c:fillMask(c:ellipse(30, 51, 22, 2), TL[4])
for x = 14, 44, 6 do c:px(x, 51, TL[5]) end
-- foot and head
local foot = c:ellipse(32, 45, 22, 5)
local head = c:ellipse(11, 41, 5, 5)
shade(c, foot:copy():add(head), BD, 5)
for x = 18, 50, 4 do c:px(x, 47, BD[2]) end
tube(c, { {9,38}, {7,33}, {6,29}, {6,24} }, function(t) return 1.3 - 0.3 * t end, BD)
tube(c, { {13,37}, {14,33}, {14,28}, {15,23} }, function(t) return 1.3 - 0.3 * t end, BD)
disc(c, 6, 23, 2, BD[5]) c:px(6, 22, BD[1]) c:px(5, 22, BD[6])
disc(c, 15, 22, 2, BD[5]) c:px(15, 21, BD[1]) c:px(14, 21, BD[6])
c:px(9, 43, BD[1]) c:px(10, 43, BD[1])
-- shell with true spiral grooves
local cx, cy = 35, 29
local shell = c:ellipse(cx, cy, 15, 14)
local sb = {}
shell:each(function(x, y)
  local dx, dy = x - (cx - 2), y - (cy + 1)
  local r = sqrt(dx * dx + dy * dy)
  local th = atan(dy, dx)
  local ph = (r / 4.2 - th / (2 * pi)) % 1
  if ph < 0.2 then sb[K(x, y)] = -2 elseif ph > 0.5 and ph < 0.62 then sb[K(x, y)] = 1 end
end)
shade(c, shell, SH, 9, sb)
c:px(26, 21, SH[6]) c:px(27, 20, SH[6]) c:px(28, 20, SH[6]) c:px(25, 22, SH[5])
-- slime bubbles on puddle
for _, b in ipairs{ {44,50,2}, {20,52,1} } do disc(c, b[1], b[2], b[3], TL[5]) c:px(b[1] - 1, b[2] - 1, TL[6]) end
-- slime thread dripping from the foot (quirk)
G.line(c, { {24,48}, {24,50} }, TL[4]) c:px(24, 49, TL[5])
G.fin(c, "snail-slime")
