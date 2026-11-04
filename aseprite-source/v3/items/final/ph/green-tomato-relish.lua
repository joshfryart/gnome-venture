-- green-tomato-relish (dC10 first draft): squat jar of chunky green relish under a tied cloth cap, tomato label.
-- quirk: a whole green tomato with a star calyx sits beside the jar.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('green-tomato-relish')
c:groundShadow(30, 55, 20, 2.5)
local G = { '#24544a', '#3f7a3a', '#6a9a3e', '#8ab84a', '#b0d060', '#d8ec88' }
local body = c:rrect(10, 28, 41, 54, 6)
D.cyl(c, body, G, 10, 41)
body:each(function(x, y) local h = X.hash(x // 2, y // 2, 4)
  if h > 0.72 then c:px(x, y, G[5]) elseif h < 0.18 then c:px(x, y, G[2]) elseif h > 0.64 then c:px(x, y, '#f5d86a') end end)
for y = 31, 51 do c:px(11, y, '#d8f0e8') end c:px(13, 32, D.CREAM)
-- cloth cap
local cap = c:rrect(9, 20, 42, 29, 3)
D.cyl(c, cap, 'moss', 9, 42)
for x = 12, 40, 3 do c:px(x, 24, '#3f9150') end
for y = 27, 28 do for x = 9, 42 do c:px(x, y, '#d98322') end end
c:px(25, 29, '#8f4a1f')
-- twine knot and tails
c:px(24, 28, '#f5b82e') c:px(25, 28, '#f5b82e') c:px(26, 28, '#f5b82e')
B.ln(c, 25, 29, 21, 33, '#f5b82e') B.ln(c, 26, 29, 29, 34, '#d98322')
-- label
c:fillMask(c:rect(17, 36, 34, 48), '#fff4d6')
local tm = B.ell(25.5, 42.5, 4, 3.6, 0) B.lit(c, tm, G, 2)
c:px(25, 39, '#3f9150') c:px(26, 39, '#3f9150') c:px(24, 39, '#3f9150') c:px(25, 40, '#24544a')
c:px(23, 41, D.CREAM)
-- loose tomato
local tm2 = B.ell(51, 49, 7, 6, 0)
B.lit(c, tm2, { '#2a5a2a', '#43803a', '#66a844', '#88c456', '#aedc70', '#dcf6a0' }, 5)
local calyx = { {51,43},{51,44},{49,44},{53,44},{48,45},{54,45},{50,45},{52,45} }
for _, p in ipairs(calyx) do c:px(p[1], p[2], '#24544a') end
c:px(51, 42, '#3f9150') c:px(51, 41, '#7cc35a')
c:px(47, 47, D.CREAM) c:px(48, 47, D.CREAM)
D.fin()
