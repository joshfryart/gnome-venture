-- sprinkler-can (lean D2o_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sprinkler-can" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function tshade(m, n, ramp, o) o = o or {}
  local v = X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return v
end
local MET = { "#2c3a52", "#475b78", "#6a82a0", "#8fa8c0", "#b7cde0", "#e4f0f8" }
local GRN = { "#1f4a34", "#2f6b44", "#4b9650", "#7cc460" }
c:groundShadow(28, 54, 13, 2)
-- spout (behind body)
local sm, sn = G.tube({ {34, 47}, {40, 40}, {46, 30}, {50, 23} }, function(t) return 2.6 - 1.0 * t end)
tshade(sm, sn, MET)
-- rose head
local rose = G.rell(52, 21, 0.83, 0.55, 5.2, 2.6)
shade(rose, MET, 3)
for _, p in ipairs{ {49,23},{51,22},{53,21},{55,20},{50,21},{52,19},{54,18} } do rose:has(p[1], p[2]) c:px(p[1], p[2], MET[1]) end
c:px(50, 19, MET[6])
-- body
local body = c:rrect(16, 29, 37, 52, 3)
shade(body, MET, 7)
-- top opening
local rim = c:ellipse(26.5, 29, 10.5, 2.6)
rim:each(function(x, y) c:px(x, y, MET[1]) end)
c:ellipse(26.5, 29.6, 8.5, 1.6):each(function(x, y) c:px(x, y, "#16202c") end)
rim:edge():each(function(x, y) c:px(x, y, (y < 29 and x < 27) and MET[6] or MET[3]) end)
-- hoops, rivets, grain streak
for _, y in ipairs{ 34, 46 } do
  for x = 17, 36 do
    if body:has(x, y) then c:px(x, y, MET[2]) end
    if body:has(x, y + 1) then c:px(x, y + 1, (x < 24) and MET[5] or MET[3]) end
  end
end
for _, y in ipairs{ 40 } do for x = 20, 33, 4 do c:px(x, y, MET[5]) c:px(x + 1, y + 1, MET[1]) end end
for y = 36, 44 do c:px(20, y, MET[6]) end
-- handle arc
local hm, hn = G.tube({ {18, 30}, {13, 11}, {37, 9}, {35, 30} }, function(t) return 1.7 end)
hm:cut(c:ellipse(26.5, 29, 10, 2.4):copy():shrink(0))
tshade(hm, hn, MET)
-- quirk: a painted seedling decal
local d = { {27,41,GRN[2]}, {27,42,GRN[2]}, {27,43,GRN[1]}, {26,40,GRN[3]}, {25,39,GRN[4]}, {28,39,GRN[3]}, {29,38,GRN[4]}, {26,44,"#6b3f28"}, {27,44,"#6b3f28"}, {28,44,"#6b3f28"} }
for _, p in ipairs(d) do c:px(p[1], p[2], p[3]) end
-- water drops
for _, p in ipairs{ {57,27}, {59,31}, {56,34}, {60,26}, {58,38} } do c:px(p[1], p[2], "#6cc0f0") c:px(p[1], p[2] + 1, "#2f86c8") end
c:px(57, 26, "#f0fbff")
G.fin(c, "sprinkler-can")
