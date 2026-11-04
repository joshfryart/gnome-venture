-- spotted-hide (lean W2_20)
-- Tanned spotted hide stretched on a wooden pole, hung by two cords: four leg stubs, short tail, rosette spots, stitched hem on one leg (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spotted-hide" }
local HIDE = { "#6a3a22", "#8f5a2c", "#b57a38", "#d49c4c", "#ecc070", "#f8dc98" }
local SPOT = { "#2e1a18", "#4a2a20", "#6a4026" }
local WOOD = { "#4a2a22", "#6e4030", "#945a3c", "#bb7f50" }
local ht = { r = { name = "hide" } }
-- pole
c:fillMask(c:rect(8, 7, 56, 9), WOOD[3])
c:fillMask(c:rect(8, 7, 56, 7), WOOD[4]) c:fillMask(c:rect(8, 9, 56, 9), WOOD[2])
c:px(8, 8, WOOD[1]) c:px(56, 8, WOOD[1])
-- hide body: torso + 4 legs + tail
local m = c:poly{ {26,13},{38,13},{44,17},{52,16},{54,22},{47,27},{46,33},{52,40},{49,46},{43,42},{40,46},{38,52},{34,56},{32,52},{30,56},{26,52},{24,46},{21,42},{15,46},{12,40},{18,33},{17,27},{10,22},{12,16},{20,17} }
local n = X.pillow(m, 7)
local bias = {}
m:each(function(x, y) if X.hash(x, y, 3) > 0.9 then bias[K(x, y)] = -1 end end)
-- spots: rosettes (dark ring + warm core)
local spots = { {28,20,3},{38,22,3},{21,26,2},{44,30,2},{32,30,3},{25,36,3},{39,38,3},{31,44,2},{16,40,1},{49,41,1},{14,19,1},{50,20,1},{33,15,1} }
local spm = HP.mask()
for _, s in ipairs(spots) do spm:add(c:ellipse(s[1], s[2], s[3], s[3])) end
spm:cut(m:copy():shrink(1):add(HP.mask()) and HP.mask() or HP.mask())
G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), HIDE, { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias, ht)
for _, s in ipairs(spots) do
  local cx, cy, r = s[1], s[2], s[3]
  local sp = c:ellipse(cx, cy, r, r):clip(m:copy():shrink(1))
  c:fillMask(sp, SPOT[2])
  if r >= 2 then c:fillMask(c:ellipse(cx, cy, r - 1, r - 1), SPOT[1]) end
  c:px(cx - r, cy - 1, SPOT[3])
end
-- tail tuft at bottom
c:px(32, 57, HIDE[2]) c:px(32, 58, SPOT[2]) c:px(32, 59, SPOT[1])
-- cords from pole to the front legs
G.line(c, { {17,10},{16,14},{14,19} }, "#d8c8a0") G.line(c, { {47,10},{48,14},{50,19} }, "#d8c8a0")
c:px(14, 19, "#8a7a58") c:px(50, 19, "#8a7a58")
-- stitched hem on lower-left leg (quirk)
for _, p in ipairs{ {16,43},{18,45},{20,47} } do c:px(p[1], p[2], "#e8dcc0") end
-- highlight
c:px(24, 20, HIDE[6]) c:px(25, 20, HIDE[6]) c:px(23, 21, HIDE[5])
G.fin(c, "spotted-hide")
