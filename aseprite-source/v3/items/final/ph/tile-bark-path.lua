-- tile-bark-path (lean W2_34)
-- Square path tile of overlapping curled bark chips, dark gaps, moss specks, a tiny sprout (quirk), earthy raised rim.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tile-bark-path" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local BARK = { "#2e1a1c", "#4a2a24", "#6e4030", "#93603c", "#b98349", "#dca868" }
local MOSS = { "#2f5a3a", "#58903f", "#9ccd5c" }
local tile = c:rrect(8, 10, 55, 53, 4)
local dirt = tile:copy()
c:fillMask(dirt, BARK[1])
local R = function(s) return X.hash(s, s * 3 + 1, 77) end
local chips = {}
for i = 1, 34 do
  local cx = 10 + R(i) * 44
  local cy = 12 + R(i + 50) * 40
  local a = R(i + 100) * pi
  chips[#chips + 1] = { cx, cy, cos(a), sin(a), 6 + R(i + 150) * 5, 2.4 + R(i + 200) * 1.6 }
end
table.sort(chips, function(p, q) return p[2] < q[2] end)
for i, ch in ipairs(chips) do
  local m = G.rell(ch[1], ch[2], ch[3], ch[4], ch[5], ch[6]):clip(tile)
  if m:count() > 0 then
    local sh = m:copy():shift(1, 1):cut(m)
    c:fillMask(sh:clip(tile), BARK[1])
    local n = X.pillow(m, ch[6] + 1)
    local v = X.light(n, { amb = 0.1, wrap = 0.2 })
    local tint = 0.12 * (R(i + 300) - 0.5)
    for k, val in pairs(v) do v[k] = max(0, min(1, val + tint)) end
    G.tone(c, m, v, BARK, { 0.2, 0.38, 0.54, 0.7, 0.86 })
    -- grain lines along chip axis
    m:each(function(x, y)
      local b = -(x - ch[1]) * ch[4] + (y - ch[2]) * ch[3]
      if floor(b + 20) % 3 == 0 and abs(b) < ch[6] - 1 and X.hash(x, y, i) > 0.35 then c:px(x, y, BARK[2 + floor(X.hash(x, y, 5) * 2)]) end
    end)
  end
end
-- moss specks
for i = 1, 9 do
  local x, y = floor(12 + R(i + 400) * 40), floor(14 + R(i + 450) * 36)
  if tile:has(x, y) then c:px(x, y, MOSS[2]) c:px(x + 1, y, MOSS[3]) c:px(x, y + 1, MOSS[1]) end
end
-- rim: lighter lip top-left, shadow bottom-right
tile:edge():each(function(x, y) end)
for x = 12, 51 do c:px(x, 10, BARK[4]) c:px(x, 53, BARK[1]) end
for y = 14, 49 do c:px(8, y, BARK[4]) c:px(55, y, BARK[1]) end
-- sprout quirk
c:px(44, 31, MOSS[1]) c:px(44, 30, MOSS[2]) c:px(44, 29, MOSS[2]) c:px(43, 28, MOSS[3]) c:px(42, 28, MOSS[2]) c:px(45, 28, MOSS[3]) c:px(46, 27, MOSS[2])
G.fin(c, "tile-bark-path")
