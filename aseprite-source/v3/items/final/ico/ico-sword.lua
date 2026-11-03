-- ico-sword (final, Opus). Slim arming sword on the diagonal, tip upper-right.
-- Blade: diamond cross-section (lit upper-left bevel, shaded lower-right bevel), a sunk fuller with a dark
-- groove and lit lip, bright honed edge on the lit side, cool reflected light on the shade edge, a specular
-- streak and one glint near the tip. Gold crossguard with down-swept quillons and a ruby boss; leather grip
-- wrapped in a twisted cord (diagonal bands); gold pommel ball. AO on the blade and grip where they meet the guard.
-- quirk: the end of the grip cord has come loose and dangles.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-sword")
local ST = { "#2e2c47", "#464766", "#686a88", "#9294ad", "#bec0d2", "#e4e6f0" }
local GD = { "#6a3418", "#9a5520", "#cf8524", "#f0b030", "#ffd45a", "#fff0a0" }
local LT = { "#2a1714", "#43251c", "#613722", "#814d2a", "#a46a36", "#c98a4a" }
local CORD = { "#6a2e2a", "#a04a34", "#d27448", "#f0a06a" }
local RUBY = { "#5e1530", "#a0203a", "#e8493b", "#ff9a7a" }
local BOUNCE, SPEC = "#7a8cc0", "#fff4d6"
local btok, gtok, ltok, ctok = { r = { name = "blade" } }, { r = { name = "gold" } }, { r = { name = "leath" } }, { r = { name = "cord" } }

local F = A.frame(12, 52, 1, -1)           -- u from the pommel toward the tip, v>0 lower-right
local UMAX = 57
-- blade mask: u 17..UMAX, half width 2.7, tapering to the point over the last 9
local bm, BV = HP.mask(), {}
for y = 0, 63 do for x = 0, 63 do
  local u, v = F.UV(x, y)
  if u >= 16.5 and u <= UMAX then
    local w = 2.75
    if u > UMAX - 10 then w = 2.75 * ((UMAX - u) / 10) ^ 0.8 + 0.15 end
    if abs(v) <= w then bm:set(x, y) BV[K(x, y)] = { u, v, w } end
  end
end end
-- diamond section, toned per diagonal row j (v = j * 0.707 at 45 degrees): crisp bevels and fuller
local bidx = {}
local ROW = { [-3] = 6, [-2] = 5, [-1] = 5, [0] = 2, [1] = 4, [2] = 3, [3] = 2 }
bm:each(function(x, y) local k = K(x, y) local u, v = BV[k][1], BV[k][2]
  local j = floor(v / 0.7071 + 0.5)
  local i = ROW[j] or 3
  local inFuller = u > 20.5 and u < 44
  if not inFuller and (j == 0 or j == 1) then i = (j == 0) and 4 or 3 end
  if u < 18.6 then i = max(1, i - 1) end
  bidx[k] = i
  c:put(x, y, ST[i], btok)
end)
bm:edge():each(function(x, y) local k = K(x, y) local u, v = BV[k][1], BV[k][2]
  if u > 19 and v > 0.5 and u < UMAX - 3 then c:put(x, y, BOUNCE, btok) end end)
-- specular streak on the lit bevel + glint near the tip
for u = 25, 37 do local x, y = F.W(u, -1.414) c:put(floor(x + .5), floor(y + .5), ST[6], btok) end
do local x, y = F.W(49, -1.414) c:put(floor(x + .5), floor(y + .5), SPEC, btok) end

-- grip: leather cylinder u 4.5..15, cord wraps as diagonal bands
local ax, ay = F.W(4.5, 0) local bx, by = F.W(15.2, 0)
local gm, gn, GT, GS = X.cyl(ax, ay, bx, by, function(t) return 1.9 - abs(t - 0.5) * 0.5 end)
gm:cut(bm)
local gidx = A.shade(c, gm, gn, LT, { amb = 0.1, wrap = 0.25, tok = ltok })
gm:each(function(x, y) local k = K(x, y)
  local u = F.UV(x, y)
  local ph = (u + GS[k] * 1.3) / 2.2
  local f = ph - floor(ph)
  local i = gidx[k] or 3
  if f < 0.22 then c:put(x, y, LT[max(1, i - 2)], ltok)            -- gap between turns
  elseif f < 0.5 then c:put(x, y, CORD[min(4, max(1, i - 1))], ctok) -- cord turn
  end
end)

-- crossguard: two down-swept quillons along v, centred at u = 16
local cg = HP.mask()
local cgn, CGs = {}, {}
local function quillon(side)
  local p = { F.P(16, 0), F.P(16, side * 4), F.P(15.6, side * 6.5), F.P(14.8, side * 8.6) }
  local m, n, T, S = A.tube(p, function(t) return t > 0.86 and 1.9 or 1.45 end)
  for k, v in pairs(n) do cgn[k] = v CGs[k] = T[k] end
  cg:add(m)
end
quillon(-1) quillon(1)
-- boss block at the centre (bevelled diamond)
local boss = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local u, v = F.UV(x, y)
  if abs(u - 16) + abs(v) * 0.9 <= 2.6 then boss:set(x, y) end
end end
local bsn = X.pillow(boss, 1.6)
local gb = {}
X.ao(gb, cg:copy():cut(boss), boss, 1, -1)
cg:cut(boss)
local cidx = A.shade(c, cg, cgn, GD, { amb = 0.1, wrap = 0.3, bias = gb, tok = gtok })
A.shade(c, boss, bsn, GD, { amb = 0.12, wrap = 0.3, tok = gtok })
-- quillon end knobs: bright cap
for _, sd in ipairs({ -1, 1 }) do local x, y = F.W(14.8, sd * 8.6) local xi, yi = floor(x + .5), floor(y + .5)
  if sd < 0 then c:put(xi, yi, GD[6], gtok) else c:put(xi, yi, GD[3], gtok) end end
-- ruby set in the boss
do local x, y = F.W(16, 0) local xi, yi = floor(x + .5), floor(y + .5)
  c:put(xi, yi, RUBY[3], gtok) c:put(xi - 1, yi, RUBY[4], gtok) c:put(xi, yi + 1, RUBY[2], gtok) c:put(xi - 1, yi + 1, RUBY[3], gtok)
  c:put(xi, yi - 1, RUBY[3], gtok) c:put(xi + 1, yi, RUBY[2], gtok) c:put(xi - 1, yi - 1, SPEC, gtok) end
-- contact: dark row on the blade and grip where they touch the guard
A.touch(bm, cg:copy():add(boss)):each(function(x, y) c:put(x, y, ST[1], btok) end)
A.touch(gm, cg:copy():add(boss)):each(function(x, y) c:put(x, y, LT[1], ltok) end)

-- pommel ball
do
  local px, py = F.W(2.4, 0)
  local pm = c:ellipse(px, py, 2.6, 2.6)
  pm:cut(gm)
  local pn = X.sphere(px, py, 2.6, pm)
  local pidx = A.shade(c, pm, pn, GD, { amb = 0.1, wrap = 0.25, tok = gtok })
  A.touch(gm, pm):each(function(x, y) c:put(x, y, LT[1], ltok) end)
  c:put(floor(px - 1.2 + .5), floor(py - 1.2 + .5), GD[6], gtok)
  c:put(floor(px - 0.6 + .5), floor(py - 1.5 + .5), SPEC, gtok)
end

-- quirk: loose cord end dangling from the grip (2 px wide, twisted)
do
  local p = { F.P(6.5, 1.6), F.P(6.0, 3.5), F.P(4.5, 5.5), F.P(5.5, 8.0) }
  local cm = A.tube(p, function(t) return 1.0 - t * 0.2 end)
  cm:cut(gm)
  cm:each(function(x, y) local f = ((x + y) % 3)
    c:put(x, y, f == 0 and CORD[1] or (f == 1 and CORD[3] or CORD[2]), ctok) end)
end
A.save(c, "ico-sword")
