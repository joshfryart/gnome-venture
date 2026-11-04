-- green-bean (dC10 first draft): a slim curved pod with seed bumps, a stem cap and a curly tail.
-- quirk: the pod has split open at the belly and two pale beans peek out.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('green-bean')
local pts = { {10,44}, {20,20}, {40,34}, {54,12} }
local m, T = D.sweep(pts, function(t) return 1.2 + 3.4 * sin(pi * min(1, t * 1.05)) ^ 0.6 end, 90)
B.lit(c, m, 'moss', 2.6)
-- bumps
for _, t in ipairs{ 0.25, 0.42, 0.6, 0.78 } do
  local u = 1 - t
  local x = u^3*pts[1][1] + 3*u*u*t*pts[2][1] + 3*u*t*t*pts[3][1] + t^3*pts[4][1]
  local y = u^3*pts[1][2] + 3*u*u*t*pts[2][2] + 3*u*t*t*pts[3][2] + t^3*pts[4][2]
  c:px(floor(x - 1), floor(y - 1), '#c4e07a') c:px(floor(x), floor(y - 1), '#c4e07a')
  c:px(floor(x + 1), floor(y + 2), '#3f9150')
end
-- seam line along lower side
m:each(function(x, y) if m:has(x, y + 1) == false and (T[K(x, y)] or 0) > 0.1 then c:px(x, y, '#24544a') end end)
-- stem cap
D.rect(c, 5, 42, 11, 48, 'wood', 1)
c:px(5, 48, '#51302b') B.ln(c, 5, 48, 3, 52, '#7cc35a')
-- curly tail tip
B.ln(c, 54, 12, 56, 9, '#3f9150') c:px(57, 8, '#7cc35a') c:px(58, 9, '#7cc35a') c:px(58, 10, '#3f9150')
-- split with beans
local mid = H.ramp('moss')
c:fillMask(c:rect(26, 28, 36, 31):clip(m), '#24544a')
for _, bx in ipairs{ 28, 33 } do
  local bm = B.ell(bx, 29, 2.4, 1.8, 0)
  B.lit(c, bm, { '#7a8a48', '#a8b868', '#c4d488', '#dcea9c', '#eef6b8', '#fff4d6' }, 1.5)
end
c:px(26, 30, mid[6])
D.fin()
