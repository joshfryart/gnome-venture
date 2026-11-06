-- wild-rice (lean W2_38)
-- Tall slim rice plant: jointed stalk, open drooping panicle of awned grains (upper branches rise, lower ones hang), two arching blades, tiny water ripple.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wild-rice" }
local sin, cos, pi = math.sin, math.cos, math.pi
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a8d870" }
local STEM  = { "#4a5a30", "#76843e", "#a4ac58", "#d2cc82" }
local GRAIN = { "#2e2020", "#4e3428", "#74503a", "#a07c50", "#cfa86a", "#f0d490" }
local tok = { r = { name = "rice" } }
c:groundShadow(33, 55, 14, 2)
c:fillMask(c:ellipse(33, 55, 12, 1.5), "#6a8ec0") c:fillMask(c:ellipse(32, 55, 7, 1), "#a8c8e8")
local function tone(m, n, ramp, cuts) G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), ramp, cuts, nil, tok) end
-- blades
local function blade(pts, w)
  local m, n = G.tube(pts, function(t) return w * (1 - t) ^ 0.7 + 0.5 end)
  tone(m, n, LEAF, { 0.2, 0.38, 0.55, 0.72, 0.87 })
  for i = 1, 3 do local p = pts[i]; c:px(math.floor(p[1] + 0.5), math.floor(p[2] + 0.5), LEAF[6]) end
end
blade({ { 31, 54 }, { 24, 46 }, { 16, 44 }, { 9, 50 } }, 2.4)
blade({ { 34, 54 }, { 41, 42 }, { 49, 38 }, { 56, 40 } }, 2.2)
-- stalk
local sm, sn = G.tube({ { 32, 54 }, { 32, 44 }, { 33, 30 }, { 33, 16 } }, function(t) return 1.6 - t * 0.5 end)
tone(sm, sn, STEM, { 0.3, 0.6, 0.85 })
for _, y in ipairs{ 48, 38, 28 } do c:px(31, y, STEM[1]) c:px(32, y, STEM[1]) c:px(34, y, STEM[1]) c:px(33, y + 1, STEM[2]) end
-- panicle branches: {from, ctrl, to}, grains hang at the tips
local br = {
  { 33, 17, 36, 10, 38, 7 }, { 33, 17, 29, 10, 28, 6 },
  { 33, 20, 41, 18, 45, 25 }, { 33, 22, 25, 19, 21, 27 },
  { 33, 25, 40, 26, 41, 35 }, { 33, 27, 26, 28, 24, 37 },
}
local function grain(x, y, a)
  local m, n = G.tube({ { x, y }, { x + cos(a) * 1.5, y + sin(a) * 1.5 }, { x + cos(a) * 3, y + sin(a) * 3 }, { x + cos(a) * 5, y + sin(a) * 5 } },
    function(t) return 1.5 * sin(pi * (t * 0.85 + 0.12)) ^ 0.6 + 0.2 end)
  tone(m, n, GRAIN, { 0.2, 0.38, 0.55, 0.72, 0.87 })
  c:px(math.floor(x + cos(a) * 6 + 0.5), math.floor(y + sin(a) * 6 + 0.5), GRAIN[3])      -- awn
end
for _, b in ipairs(br) do
  local ax, ay, cx, cy, ex, ey = table.unpack(b)
  local pts = {}
  for i = 0, 3 do local t = i / 3; local u = 1 - t
    pts[#pts + 1] = { u * u * ax + 2 * u * t * cx + t * t * ex, u * u * ay + 2 * u * t * cy + t * t * ey } end
  local m, n = G.tube(pts, function(t) return 0.8 end)
  tone(m, n, STEM, { 0.3, 0.6, 0.85 })
  local drop = ey >= 20
  grain(ex, ey, drop and pi / 2 or -pi / 2 + (ex - ax) * 0.03)
  if drop then grain(pts[3][1], pts[3][2] + 1, pi / 2 + (ex < ax and 0.5 or -0.5)) end
end
-- quirk: one grain has burst, showing pale kernel
c:px(41, 33, GRAIN[6]) c:px(42, 34, GRAIN[5])
G.fin(c, "wild-rice")
