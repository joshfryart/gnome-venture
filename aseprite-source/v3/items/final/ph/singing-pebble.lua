-- singing-pebble (lean D2o_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c
local function shade(m, ramp, R, o) local n = X.pillow(m, R) return G.toneN(c, m, n, ramp, o), n end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "singing-pebble" }
local PEB = { "#2e3a4a", "#46586a", "#647c88", "#86a0a4", "#a9c2bc", "#cfe0d0" }
local GOLD = { "#6b3c14", "#98591a", "#c98524", "#eaaa2f", "#f9cf55", "#fff0a0" }
local INK = "#1e1a26"
c:groundShadow(27, 53, 17, 3)
local m, n = G.oval(27, 42, 17, 13, -0.12, 0.8)
local idx, tok = G.toneN(c, m, n, PEB)
local l = X.light(n, { amb = 0.08, wrap = 0.25 })
m:each(function(x, y)
  local h = X.hash(x, y, 4)
  if abs((x - 27) + 1.6 * (y - 42) + 3) < 1.2 and h > 0.25 then c:px(x, y, PEB[5])
  elseif h > 0.92 then c:px(x, y, l[K(x, y)] > 0.5 and PEB[5] or PEB[2])
  elseif h < 0.04 then c:px(x, y, PEB[2]) end
end)
-- face: closed happy eyes, open singing mouth
for _, ex in ipairs{ 20, 33 } do c:px(ex - 1, 39, INK) c:px(ex, 38, INK) c:px(ex + 1, 39, INK) end
c:fillMask(c:ellipse(27, 45, 4, 3), INK)
c:fillMask(c:ellipse(27, 46, 2, 1):clip(c:rect(0, 46, 63, 63)), "#c85a6a")
c:px(27, 47, "#e88a96")
c:px(18, 43, "#d98a8f") c:px(19, 43, "#d98a8f") c:px(35, 43, "#d98a8f") c:px(36, 43, "#d98a8f")
c:px(21, 33, PEB[6]) c:px(22, 33, PEB[6]) c:px(20, 34, PEB[5])
-- quirk: a beamed pair of notes drifting up
c:fillMask(c:ellipse(44, 24, 2, 1.5), GOLD[4]) c:fillMask(c:ellipse(53, 20, 2, 1.5), GOLD[4])
c:fillMask(c:rect(45, 11, 46, 23), GOLD[3]) c:fillMask(c:rect(54, 8, 55, 19), GOLD[3])
c:fillMask(c:line({ {45, 11}, {55, 8} }, 2), GOLD[4])
c:px(43, 23, GOLD[6]) c:px(52, 19, GOLD[6]) c:px(45, 13, GOLD[6]) c:px(46, 22, GOLD[2]) c:px(55, 18, GOLD[2])
G.save(c, "singing-pebble")
