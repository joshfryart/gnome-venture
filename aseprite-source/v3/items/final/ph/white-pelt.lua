-- white-pelt (lean P1b_O18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local function cl(i, n) return max(1, min(n, i)) end
local NAME = "white-pelt"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local WH  = { "#7f84ac", "#a9aed0", "#cfd4e8", "#e8ecf6", "#f7f9fd", "#fcfdff" }
local LEA = { "#4a3030", "#6e4a3e", "#946a50" }
local BLK = { "#14121c", "#262034", "#3a3050", "#5a4e78" }
local tk, tt = { r = { name = "fur" } }, { r = { name = "tail" } }
c:groundShadow(30, 52, 24, 3)
local M = HP.mask()
M:add(c:ellipse(31, 32, 16, 10))
M:add(c:line({ {21, 26}, {14, 15} }, 6)) M:add(c:line({ {21, 38}, {14, 49} }, 6))
M:add(c:line({ {41, 26}, {47, 15} }, 6)) M:add(c:line({ {41, 38}, {47, 49} }, 6))
M:add(c:ellipse(13, 32, 7, 5)) M:add(c:ellipse(7, 32, 3, 2))
M:add(c:ellipse(12, 26, 2, 2)) M:add(c:ellipse(12, 38, 2, 2))
-- ragged edge
local M2 = M:copy()
M:grow(1):cut(M):each(function(x, y) if X.hash(x, y, 3) > 0.62 then M2:set(x, y) end end)
M:edge():each(function(x, y) if X.hash(x, y, 8) < 0.22 then M2.s[K(x, y)] = nil end end)
-- tail (ermine black tip)
local TP = { {44, 33}, {48, 34}, {51, 38}, {52, 44} }
local tm, tn, tT = G.tube(TP, function(t) return 3.4 - 1.2 * t end)
local tw, tb = HP.mask(), HP.mask()
tm:each(function(x, y) if tT[K(x, y)] > 0.68 then tb:set(x, y) else tw:set(x, y) end end)
local tv = X.light(tn, { amb = 0.1, wrap = 0.3 })
local cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 }
X.tone(c, tw, tv, WH, { cuts = cuts, tok = tt })
X.tone(c, tb, tv, BLK, { cuts = cuts, tok = tt })
-- leather underside rim
c:fillMask(M2:shift(1, 2):cut(M2), LEA[1])
c:fillMask(M2:shift(0, 1):cut(M2), LEA[2])
c:fillMask(M2:shift(-1, 1):cut(M2):cut(M2:shift(0, 1)), LEA[3])
-- fur
local n = X.pillow(M2, 7)
local bias = {}
M2:each(function(x, y)
  local s = (x + y * 3) % 7
  local h = X.hash(x, y, 2)
  if s == 0 and h > 0.35 then bias[K(x, y)] = -1 elseif s == 3 and h > 0.5 then bias[K(x, y)] = 1 end
end)
G.toneN(c, M2, n, WH, { tok = tk, bias = bias, amb = 0.12, wrap = 0.3 })
-- spine parting + glints
for x = 22, 42, 2 do c:px(x, 32, WH[2]) end
c:px(24, 25, "#fffdf6") c:px(25, 25, "#fffdf6") c:px(24, 26, "#fffdf6") c:px(23, 24, WH[5]) c:px(26, 26, WH[5])
G.save(c, NAME)
