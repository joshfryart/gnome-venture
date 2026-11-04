-- mung-bean: a slim curved dark pod split to show four olive-green beans with pale seams. quirk: one bean already has a white sprout tail.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mung-bean")
local PD = D.R("#8a6a4a", "#5a3e2e", "#3a2622", "#241616")
local IN = D.R("#f0e4b0", "#d4c48a", "#a89460", "#6e5c3c")
local BN = D.R("#d4e890", "#8ca84a", "#587a3a", "#2e4a2c")
local pts = { {8,50}, {22,54}, {42,40}, {56,14} }
local pod = H.sweep(pts, function(t) return 5.6 * sin(pi * min(1, t * .96 + .03)) ^ .55 + .4 end)
B.lit(c, pod, PD, 3)
D.speck(c, pod, "#8a6a4a", 3, .9)
local inner = H.sweep(pts, function(t) return max(0, 4.0 * sin(pi * min(1, t * .96 + .03)) ^ .6 - .3) end)
inner:clip(pod)
B.lit(c, inner, IN, 2.6)
local function bz(t) local u = 1 - t
  return u^3*pts[1][1] + 3*u*u*t*pts[2][1] + 3*u*t*t*pts[3][1] + t^3*pts[4][1],
         u^3*pts[1][2] + 3*u*u*t*pts[2][2] + 3*u*t*t*pts[3][2] + t^3*pts[4][2] end
for i, t in ipairs{ .22, .4, .58, .76 } do
  local x, y = bz(t)
  B.lit(c, c:ellipse(floor(x), floor(y), 2.4, 2.4), BN, 2.2)
  c:px(floor(x) + 1, floor(y), "#f0e4b0")
  c:px(floor(x) - 1, floor(y) - 1, "#fff4d6")
end
-- sprouting tail on bean 3
local x, y = bz(.58)
D.stem(c, { {floor(x) + 2, floor(y) + 2}, {floor(x) + 5, floor(y) + 4}, {floor(x) + 7, floor(y) + 7} }, 1, "#fff4d6", "#fff4d6")
-- stalk stub
D.stem(c, { {8,50}, {5,54}, {5,58} }, 2, "#5a9a46", "#a0d070")
-- beak
c:px(57, 12, "#241616") c:px(58, 10, "#241616")
D.fin()
