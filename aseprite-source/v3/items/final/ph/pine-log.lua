-- pine-log (lean W2_14)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pine-log" }
local sin, pi, abs, sqrt = math.sin, math.pi, math.abs, math.sqrt
local BARK = { "#2e1c18", "#4a2c22", "#6b4130", "#8a5a3c", "#a9764a", "#c6955f" }
local WOOD = { "#a8672f", "#c98a45", "#e0a95e", "#efc67e", "#f7dc9e", "#fdeec4" }
local NEED = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local CUT = { 0.2, 0.38, 0.55, 0.72, 0.87 }
c:groundShadow(29, 50, 20, 3)
-- body
local bm, bn = G.tube({ {15,36}, {27,35}, {39,34}, {49,33} }, function(t) return 10.5 - 1.5 * t end)
local v = X.light(bn, { amb = 0.1, wrap = 0.2 })
local bias = {}
bm:each(function(x, y) if (x * 3 + y) % 7 == 0 and X.hash(x, y, 3) > 0.35 then bias[K(x, y)] = -1 end end)
G.tone(c, bm, v, BARK, CUT, bias)
-- bark plates: darker vertical-ish fissures along the length
for _, f in ipairs{ {21,28,30}, {30,27,29}, {39,28,26} } do
  for y = 0, 12 do c:px(f[1] + math.floor(y * 0.15), f[2] + y, BARK[1]) end
end
-- end face (left)
local face = c:ellipse(14, 36, 5, 11)
local fn = X.pillow(face, 12)
G.tone(c, face, X.light(fn, { amb = 0.55, wrap = 0.1 }), WOOD, CUT)
face:each(function(x, y)
  local d = sqrt(((x - 14) / 5) ^ 2 + ((y - 36) / 11) ^ 2)
  if (d * 5) % 1 < 0.28 and d > 0.12 then c:px(x, y, WOOD[1]) end
end)
c:px(14, 36, BARK[2]) c:px(13, 35, BARK[3])
c:fillMask(face:copy():edge(), BARK[3])
-- branch stub with ring (quirk: sprouting needles)
local st = c:ellipse(35, 26, 3, 2)
c:fillMask(st, WOOD[2]) c:px(35, 26, WOOD[1]) c:px(34, 25, WOOD[5])
for _, nd in ipairs{ {-3,-4}, {-1,-6}, {1,-6}, {3,-4}, {0,-7} } do
  c:line({ {35, 25}, {35 + nd[1], 25 + nd[2]} }, 1, NEED[3 + (nd[1] % 2)])
end
-- bark highlight upper-left
for x = 19, 41 do c:px(x, 26 + math.floor((x - 19) * -0.05), BARK[6]) end
G.fin(c, "pine-log")
