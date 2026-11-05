-- carob (lean P1b_O0)
-- quirk: the pod has one seed-bump swollen bigger than the rest. Scimitar pod + compound leaf of round leathery leaflets.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "carob" }
local pi, sin, cos, floor, max, min, abs, atan = math.pi, math.sin, math.cos, math.floor, math.max, math.min, math.abs, math.atan
local POD = { "#2a1410", "#4a2518", "#6e3a22", "#93522e", "#b87442", "#e0a56c" }
local LEAF = { "#173b30", "#1f5a3c", "#2f7d43", "#4fa04a", "#7cc058", "#b4de7c" }
local STEM = { "#3a2a1a", "#5d6b34", "#8aa046", "#bcd070" }
local ltok = { r = { name = "leaf" } }

-- compound leaf: rachis + 3 pairs round leaflets + terminal
local R = { {17,10}, {25,2}, {37,3}, {49,13} }
local function rp(t) return G.bez(R, t) end
local leaves = {}
for i, t in ipairs{ 0.18, 0.42, 0.66 } do
  for _, side in ipairs{ -1, 1 } do
    local x, y = rp(t)
    local x2, y2 = rp(t + 0.02)
    local a = atan(y2 - y, x2 - x) + side * 1.15
    local rx, ry = 7.5 - i * 0.6, 5.2 - i * 0.3
    leaves[#leaves + 1] = { x = x, y = y, a = a, rx = rx, ry = ry }
  end
end
do local x, y = rp(1) local x2, y2 = rp(0.97) local a = atan(y - y2, x - x2) leaves[#leaves + 1] = { x = x - 1, y = y, a = a, rx = 6.5, ry = 4.6 } end
local rm, rn = G.tube(R, function(t) return 0.9 end)
G.toneN(c, rm, rn, STEM, { cuts = { 0.3, 0.6, 0.85 }, tok = ltok })
for _, L in ipairs(leaves) do
  local dx, dy = cos(L.a), sin(L.a)
  local m, n = G.oval(L.x + dx * L.rx * 0.9, L.y + dy * L.rx * 0.9, L.rx, L.ry, L.a, 0.9)
  G.toneN(c, m, n, LEAF, { tok = ltok })
  for i = 0, floor(L.rx * 1.7) do
    local px, py = floor(L.x + dx * i + 0.5), floor(L.y + dy * i + 0.5)
    if m:has(px, py) then c:px(px, py, LEAF[5]) end
  end
  -- two veins
  for _, s in ipairs{ -1, 1 } do for i = 3, floor(L.rx * 1.4), 3 do
    local px, py = floor(L.x + dx * i - dy * s * (i * 0.28) + 0.5), floor(L.y + dy * i + dx * s * (i * 0.28) + 0.5)
    if m:has(px, py) then c:px(px, py, LEAF[3]) end end end
end
-- stem stub
local sm, sn = G.tube({ {14,18}, {15,14}, {16,12}, {17,10} }, function(t) return 1.6 end)
G.toneN(c, sm, sn, STEM, { cuts = { 0.3, 0.6, 0.85 }, tok = ltok })

-- pod
local pts = { {14,17}, {5,46}, {34,62}, {56,40} }
local len = 70
local m, n, T = G.tube(pts, function(t) return 1.8 + 4.4 * sin(pi * t) ^ 0.55 end)
local bias = {}
m:each(function(x, y) local k = K(x, y) local t = T[k]
  local f = (t * 13) % 1
  if f < 0.2 and t > 0.12 and t < 0.9 then bias[k] = -1
  elseif f > 0.45 and f < 0.75 and t > 0.12 and t < 0.9 then bias[k] = 1 end
  if t > 0.5 and t < 0.62 then if f > 0.25 and f < 0.9 then bias[k] = 1 end end -- swollen quirk seed
end)
local _, v = G.toneN(c, m, n, POD, { bias = bias, tok = { r = { name = "pod" } }, amb = 0.1 })
-- seam: dark line along lower/right rim
local inner = m:copy():shrink(1)
m:copy():cut(inner):each(function(x, y) local k = K(x, y) if n[k] and n[k][2] + n[k][1] > 0.5 then c:px(x, y, POD[1]) end end)
local sx, sy = G.specAt(m, n, 30)
if sx then c:px(sx, sy, "#fff0d6") c:px(sx + 1, sy, POD[6]) c:px(sx, sy + 1, POD[6]) end
G.save(c, "carob")
