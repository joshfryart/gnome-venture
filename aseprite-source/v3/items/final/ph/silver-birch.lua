-- silver-birch (lean D2o_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c
local function shade(m, ramp, R, o) local n = X.pillow(m, R) return G.toneN(c, m, n, ramp, o), n end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "silver-birch" }
local BARK = { "#6b6a8c", "#9a9ab8", "#c4c5d8", "#e4e3ea", "#f5f2ea", "#fdf9f0" }
local LEAF = { "#24493f", "#37675a", "#5b8e7a", "#86b394", "#b2d3b0", "#dceec0" }
LEAF[6] = "#dceec0"
local INK = "#3a3548"
c:groundShadow(32, 58, 12, 2)
local tm, tn, T = G.tube({ {32, 58}, {31, 48}, {33, 38}, {32, 24} }, function(t) return 2.4 - 1.0 * t + (t < 0.1 and 1.6 or 0) end)
G.toneN(c, tm, tn, BARK)
tm:each(function(x, y)
  if y < 54 and ((y % 6 == 2 and (x + y // 6) % 3 == 0) or X.hash(x, y, 5) > 0.9) then c:px(x, y, INK) c:px(x + 1, y, INK) end
end)
-- two branches under the crown
local b1 = G.tube({ {32, 32}, {28, 26}, {24, 22}, {21, 18} }, function(t) return 1 end)
local b2 = G.tube({ {33, 30}, {37, 25}, {41, 21}, {44, 17} }, function(t) return 1 end)
c:fillMask(b1, BARK[3]) c:fillMask(b2, BARK[2])
-- crown: overlapping blobs
local crown = HP.mask()
for _, e in ipairs{ {32, 15, 9, 7}, {21, 21, 8, 6}, {43, 20, 8, 6}, {26, 9, 7, 5}, {38, 9, 7, 5}, {32, 25, 8, 4} } do crown:add(c:ellipse(e[1], e[2], e[3], e[4])) end
local idx, tok = shade(crown, LEAF, 8, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
local cn = X.pillow(crown, 8)
local lv = X.light(cn, { amb = 0.08, wrap = 0.25 })
crown:each(function(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.86 and lv[K(x, y)] > 0.45 then c:px(x, y, LEAF[6]) elseif h < 0.1 and lv[K(x, y)] < 0.5 then c:px(x, y, LEAF[1]) end
end)
-- drooping twigs (silver birch weeping tips)
for _, x in ipairs{ 17, 23, 41, 47 } do
  local by
  for y = 0, 63 do if crown:has(x, y) then by = y end end
  if by then
    local L = 3 + floor(X.hash(x, 1, 2) * 3)
    for i = 1, L do c:px(x, by + i, i % 2 == 0 and LEAF[2] or LEAF[3]) end
    c:px(x, by + L, LEAF[5])
  end
end
-- quirk: one golden leaf drifting down
c:fillMask(c:poly{ {51, 36}, {53, 38}, {51, 41}, {49, 38} }, "#eaaa2f")
c:px(51, 38, "#fff0a0") c:px(51, 40, "#98591a")
G.save(c, "silver-birch")
