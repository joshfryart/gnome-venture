-- wasp-stinger (lean E2_17)
local NAME = "wasp-stinger"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function ell(cx, cy, rx, ry, a)
  a = a or 0
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy - max(rx, ry)) - 1, floor(cy + max(rx, ry)) + 1 do for x = floor(cx - max(rx, ry)) - 1, floor(cx + max(rx, ry)) + 1 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u, v = (dx * ca + dy * sa) / rx, (-dx * sa + dy * ca) / ry
    if u * u + v * v <= 1 then m:set(x, y) end
  end end
  return m
end
local function shade(m, ramp, tok, R, amb, wrap)
  local n = X.pillow(m, R)
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = amb or 0.1, wrap = wrap or 0.2 })
  return n
end
local function dot(x, y, col, tok) c:put(floor(x), floor(y), col, tok) end
local YEL = { "#5a3a10", "#9a6a14", "#d49a1c", "#f4c42c", "#ffe066", "#fff6b0" }
local BLK = { "#14101c", "#2a2038", "#443658", "#6a5a88" }
local NEE = { "#1c1424", "#3a2c4c", "#6a5a88", "#a898c8", "#e0d8f4" }
c:groundShadow(34, 59, 16, 3)
-- banded abdomen tip (upper left), a plump segmented cone
local ab = HP.mask() ab:add(ell(22, 20, 13, 11, 0.75))
local an = X.pillow(ab, 11)
local at = { r = { name = "abd" } }
G.toneN(c, ab, an, YEL, { tok = at, cuts = CUTS, amb = 0.08, wrap = 0.2 })
local blk = HP.mask()
for _, off in ipairs{ -5, 3 } do
  ab:each(function(x, y) local d = (x + y) * 0.7071 - 29.7 - off if abs(d) < 2.2 then blk:set(x, y) end end)
end
local bn = X.light(an, { amb = 0.08, wrap = 0.2 })
blk:each(function(x, y) local l = bn[K(x, y)] c:put(x, y, BLK[1 + min(3, floor((l or 0.5) * 4))], at) end)
local sx, sy = G.specAt(ab, an, 26) if sx then dot(sx, sy, YEL[6], at) dot(sx + 1, sy, YEL[5], at) end
-- the needle: dark, tapering, curved toward lower right, with a groove glint
local nm, nn, T = G.tube({ {28,28}, {40,34}, {44,44}, {52,56} }, function(u) return 3.6 * (1 - u) ^ 0.9 + 0.6 end)
local nt = { r = { name = "needle" } }
G.toneN(c, nm, nn, NEE, { tok = nt, cuts = CUTS, amb = 0.06, wrap = 0.2 })
nm:each(function(x, y) local t = T[K(x, y)] if t > 0.1 and t < 0.85 and abs(nn[K(x, y)] and 0 or 0) == 0 and (x * 3 + y) % 9 == 0 then c:put(x, y, NEE[5], nt) end end)
-- sheath ring where the needle meets the body
for _, p in ipairs{ {26,27,BLK[2]},{27,26,BLK[2]},{28,25,BLK[1]},{27,28,BLK[1]},{29,29,BLK[1]} } do dot(p[1], p[2], p[3], nt) end
-- barbs: tiny hooks along the needle
for _, b in ipairs{ { {41,38},{44,38},{42,40} }, { {44,44},{47,44},{45,47} }, { {47,50},{50,49},{48,52} } } do
  c:poly(b):each(function(x, y) c:put(x, y, NEE[3], nt) end) dot(b[2][1], b[2][2], NEE[5], nt)
end
-- quirk: a glossy droplet of venom hanging from the tip
local dm = ell(54, 59, 2, 2.4)
local dt = { r = { name = "venom" } }
dm:each(function(x, y) c:put(x, y, "#6ad04a", dt) end)
dot(54, 61, "#2a7a2e", dt) dot(55, 60, "#2a7a2e", dt) dot(53, 58, "#e8ffb0", dt) dot(53, 59, "#b8f080", dt)
G.save(c, NAME)
