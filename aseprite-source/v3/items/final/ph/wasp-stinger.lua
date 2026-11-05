-- wasp-stinger (lean P1b_O18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local function cl(i, n) return max(1, min(n, i)) end
local NAME = "wasp-stinger"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local YEL = { "#6b4a12", "#a8731a", "#d9a424", "#f5c936", "#ffe35c", "#fff5a0" }
local BLK = { "#14101c", "#241a30", "#362848", "#4a3a60", "#65527e", "#8a76a2" }
local NDL = { "#4a3228", "#78583e", "#a8855a", "#d2b484", "#ecdcaa", "#fff6d8" }
local VEN = { "#1f4a2a", "#2f7a34", "#52b040", "#86d850", "#c0f078", "#f0ffc0" }
local tk = { r = { name = "p" } }
-- needle with barbs
local NP = { {32, 31}, {37, 38}, {41, 46}, {43, 52} }
local nm, nn, nT = G.tube(NP, function(t) return 1.7 * (1 - t) + 0.6 end)
G.toneN(c, nm, nn, NDL, { tok = tk })
for _, t in ipairs{ 0.38, 0.58, 0.78 } do
  local x, y = G.bez(NP, t)
  local x2, y2 = G.bez(NP, t + 0.01)
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  for _, s in ipairs{ -1, 1 } do
    local function q(a, b, col) c:put(floor(x + px * s * a - tx * b + 0.5), floor(y + py * s * a - ty * b + 0.5), col, tk) end
    q(1.6, 0, NDL[3]) q(2.4, 0.6, NDL[2]) q(2.9, 1.8, NDL[1])
  end
end
-- venom drop
local dm, dn = G.oval(43.5, 55.5, 2.5, 3.2, pi / 2, 1)
G.toneN(c, dm, dn, VEN, { tok = tk })
c:px(42, 54, VEN[6]) c:px(42, 55, VEN[5])
-- striped abdomen
local BP = { {9, 8}, {17, 16}, {26, 25}, {34, 33} }
local bm, bn, bT = G.tube(BP, function(t)
  if t < 0.3 then return 11 * sqrt(max(0, 1 - ((t - 0.3) / 0.3) ^ 2)) end
  return 11 * (1 - (t - 0.3) / 0.7) ^ 0.7
end)
local ym, km = HP.mask(), HP.mask()
bm:each(function(x, y)
  local t = bT[K(x, y)]
  local blk = (t >= 0.22 and t < 0.35) or (t >= 0.5 and t < 0.63) or (t >= 0.76 and t < 0.86) or t >= 0.93
  if blk then km:set(x, y) else ym:set(x, y) end
end)
local v = X.light(bn, { amb = 0.08, wrap = 0.25 })
local cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 }
X.tone(c, ym, v, YEL, { cuts = cuts, tok = tk })
X.tone(c, km, v, BLK, { cuts = cuts, tok = tk })
-- stripe seams (AO line where bands meet)
bm:each(function(x, y)
  local t = bT[K(x, y)]
  for _, e in ipairs{ 0.22, 0.35, 0.5, 0.63, 0.76, 0.86 } do
    if abs(t - e) < 0.012 then c:put(x, y, (x + y) % 2 == 0 and BLK[1] or YEL[1], tk) end
  end
end)
local sx, sy = G.specAt(bm, bn, 40)
if sx then c:px(sx, sy, "#fffbe0") c:px(sx + 1, sy, "#fffbe0") c:px(sx, sy + 1, YEL[6]) end
G.save(c, NAME)
