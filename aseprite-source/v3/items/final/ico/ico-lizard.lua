local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-lizard: green lizard in an S-curve seen from above, tongue out. quirk: its tail has a yellow stripe and curls at the tip.
local c = D.new("ico-lizard")
local m, T = D.H.sweep({{44,14},{40,34},{14,24},{16,52}}, function(t) return 6 - 4.2 * t end, 80)
local function bz(t) local u = 1 - t
  return u^3*44 + 3*u*u*t*40 + 3*u*t*t*14 + t^3*16, u^3*14 + 3*u*u*t*34 + 3*u*t*t*24 + t^3*52 end
local function leg(t, dx, dy)
  local x, y = bz(t) x, y = floor(x + .5), floor(y + .5)
  D.lit(c:line({{x, y}, {x + dx, y + dy}, {x + dx * 1.6, y + dy * 0.7}}, 3), D.GREEN, 1.5) end
leg(0.2, 11, -4) leg(0.2, -11, 6) leg(0.55, 10, 6) leg(0.55, -9, -7)
D.lit(m, D.GREEN, 5)
m:each(function(x, y) local t = T[D.X.K(x, y)] or 0
  if t > 0.62 and t < 0.7 then D.px(x, y, D.GOLD[4]) end
  if t > 0.15 and t < 0.55 and (x + y) % 5 == 0 then D.px(x, y, D.GREEN[2]) end end)
D.lit(D.ell(46, 12, 5, 5), D.GREEN, 3)
D.fill(c:rect(46, 10, 47, 12), INK) D.px(46, 10, CR)
D.px(49, 10, INK)
D.ln(46, 7, 47, 3, D.RED[4]) D.px(45, 1, D.RED[4]) D.px(49, 1, D.RED[4])
D.fin()
