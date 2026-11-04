-- rice (final draft D12, Sonnet). One arching rice stalk with a drooping panicle of golden grains and fine awns, two long
-- blades, a few loose grains at the foot. quirk: a little red thread bow ties the harvest stalk.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rice")
local GR = D.R.gold
local LEAF = D.R.leaf
-- leaves
D.blade(c, 22, 58, 8, 32, 3, LEAF, { prof = function(t) return 1 - 0.8 * t end })
D.blade(c, 23, 58, 42, 48, 2.6, LEAF, { prof = function(t) return 1 - 0.7 * t end })
-- stalk
local p = { {22,58},{23,30},{34,10},{46,21} }
local sm = D.sw(c, p, function(t) return 1.4 end, { "#4f8a55", "#6aa062", "#86b86c", "#a8cf84", "#c8e0a0", "#e2f2bc" }, 1.2)
-- drooping panicle: extension down
local p2 = { {46,21},{52,26},{52,34},{48,42} }
local dm = D.sw(c, p2, function(t) return 1.2 - 0.5 * t end, { "#4f8a55", "#6aa062", "#86b86c", "#a8cf84", "#c8e0a0", "#e2f2bc" }, 1)
for i = 1, 11 do
  local t = i / 11
  local x, y = D.bez(p2, t)
  local side = (i % 2 == 0) and 1 or -1
  local gx, gy = x + side * 3, y + 1.2
  D.grain(c, floor(gx), floor(gy), 2.3, 3.4, side * 0.25, GR)
  D.ln(c, floor(gx + side), floor(gy + 3), floor(gx + side * 2), floor(gy + 6), GR[3])
end
for i = 1, 4 do
  local x, y = D.bez(p, 0.82 + i * 0.045)
  local gx = x + ((i % 2 == 0) and 3 or -3)
  D.grain(c, floor(gx), floor(y + 2), 2.1, 3.2, 0.2, GR)
end
-- loose grains
D.grain(c, 40, 56, 3.4, 1.8, 0.3, GR) D.grain(c, 49, 58, 3.4, 1.8, -0.2, GR) D.grain(c, 54, 54, 3.2, 1.8, 0.5, GR)
-- red thread bow
local R = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
c:fillMask(c:poly{ {20,43},{24,45},{20,48} }, R[3]) c:fillMask(c:poly{ {28,43},{24,45},{28,48} }, R[3])
c:px(24, 45, R[2]) c:px(24, 46, R[1]) c:px(21, 45, R[4]) c:px(23, 44, R[4]) c:px(23, 49, R[2]) c:px(25, 49, R[2])
D.fin()
