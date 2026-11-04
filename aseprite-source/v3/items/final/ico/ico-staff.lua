-- ico-staff (final, Opus). A wizard's walking staff on the diagonal: slim knotty ash shaft (grain lines, two knots
-- with a paler ring), a leather grip wrapped in twisted cord, an iron foot cap, a gold collar with a bevel and a bright
-- edge, and three curled wooden claws gripping a glass orb. Orb: deep-blue rim, pale core, a swirl of light inside,
-- one bright specular and a cream glint. AO on the shaft under collar and grip, contact shadow under each claw.
-- quirk: a tiny mushroom has sprouted from the upper knot.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-staff")
local WD = { "#40242a", "#64382e", "#8c5436", "#b47848", "#d69c62", "#f0c288" }
local LT = { "#2e1c2a", "#4a2a34", "#6e3e3e", "#945a4a", "#b87c5e" }        -- leather
local CD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }                   -- gold cord
local GD = { "#5e3420", "#8f4a1f", "#c27424", "#e8a030", "#f8cc58", "#fff0a8" }
local FE = { "#2e2c47", "#464766", "#74758c", "#aaa9b8", "#e2e0e6" }
local OB = { "#1f2a5e", "#2a4a8a", "#3a72b8", "#56a0d8", "#8ccfee", "#c8f0fa" }
local MU = { "#7a2238", "#b52e3f", "#e8493b", "#ff8a5c" }
local wt, ot, gt = { r = { name = "wood" } }, { r = { name = "orb" } }, { r = { name = "gold" } }

local F = A.frame(8, 59, 32, -34)       -- u up the shaft from the foot, v>0 lower-right
local function seg(u0, u1, wf, v0, v1)
  local ax, ay = F.W(u0, v0 or 0) local bx, by = F.W(u1, v1 or 0)
  return X.cyl(ax, ay, bx, by, wf)
end
-- shaft (slight taper, a little bend)
local sm, sn, ST, SS = seg(1.5, 43, function(t) return 2.25 - t * 0.4 end)
local gripm = HP.mask() sm:each(function(x, y) local u = F.UV(x, y) if u > 11 and u < 21 then gripm:set(x, y) end end)
local gm2 = seg(11, 21, function() return 2.6 end) gripm:add(gm2) sm:add(gm2)
local _, sn2, _, SS2 = seg(1.5, 43, function(t) return 2.6 end, nil, nil) for k, v in pairs(sn2) do if not sn[k] then sn[k] = v SS[k] = SS2[k] end end
local capm, capn = seg(0, 4.6, function() return 2.7 end)
local colm, coln, CT, CS = seg(37.5, 42.5, function(t) return 3.4 - abs(t - 0.5) * 1.0 end)
local bias = {}
-- grain: long dark lines that wobble across the shaft
sm:each(function(x, y) local k = K(x, y) local u = F.UV(x, y)
  local g = SS[k] * 1.6 + sin(u * 0.32) * 0.35
  if abs(g - floor(g + 0.5)) < 0.1 and abs(SS[k]) < 0.75 then bias[k] = -1 end end)
X.ao(bias, sm, colm, 2, -1) X.ao(bias, sm, capm, 1, -1)
local wood = sm:copy():cut(gripm)
local widx = A.shade(c, wood, sn, WD, { amb = 0.06, wrap = 0.25, bias = bias, tok = wt })
-- knots: dark eye with a pale ring, swelling the silhouette by a pixel
for _, kk in ipairs{ { 7.5, 1 }, { 29, -1 } } do
  local kx, ky = F.W(kk[1], kk[2] * 2.4)
  local kx2, ky2 = floor(kx + .5), floor(ky + .5)
  local km, kn = A.oval(kx2, ky2, 1.4, 1.4, 0, 1)
  km:each(function(x, y) local k = K(x, y) sm:set(x, y) end)
  A.shade(c, km, kn, WD, { amb = 0.1, tok = wt })
  c:put(kx2, ky2, WD[1], wt) c:put(kx2 - 1, ky2 - 1, WD[6], wt)
end
-- leather grip + twisted gold cord
local gb = {}
X.ao(gb, gripm, wood, 1, -1)
local gidx = A.shade(c, gripm, sn, LT, { cuts = { 0.24, 0.44, 0.64, 0.82 }, amb = 0.06, bias = gb, tok = wt })
gripm:each(function(x, y) local k = K(x, y) local u = F.UV(x, y)
  local ph = (u + SS[k] * 1.8) % 3.4
  if ph < 1.1 then local i = (gidx[k] or 3) c:put(x, y, CD[max(1, min(4, i - 1))], wt)
  elseif ph < 1.7 then c:put(x, y, LT[1], wt) end end)
-- iron foot cap
local cidx = A.shade(c, capm, capn, FE, { cuts = { 0.24, 0.44, 0.64, 0.82 }, tok = gt })
-- gold collar under the head (bevelled band, bright edge row)
local colb = {}
local colidx = A.shade(c, colm, coln, GD, { amb = 0.08, wrap = 0.2, tok = gt })
colm:each(function(x, y) local u = F.UV(x, y) local k = K(x, y)
  if u < 38.3 then c:put(x, y, GD[max(1, (colidx[k] or 3) - 2)], gt) end
  if u > 40.6 and (CS[k] or 0) < 0.2 then c:put(x, y, GD[6], gt) end end)
-- orb
local ox, oy = F.W(51, 0)
local om = c:ellipse(ox, oy, 8, 8)
local on = X.sphere(ox - 0.3, oy - 0.3, 8, om)
local ob = {}
local oidx = A.shade(c, om, on, OB, { amb = 0.04, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 }, bias = ob, tok = ot })
-- glass: darker rim ring, pale core, inner light swirl
om:edge():each(function(x, y) local k = K(x, y) A.step(c, oidx, OB, x, y, -1, ot) end)
local rim = X.rim(on)
om:each(function(x, y) local k = K(x, y)
  local dx, dy = x - ox, y - oy
  local r = sqrt(dx * dx + dy * dy)
  if r > 3.2 and r < 4.3 and dx + dy > 2.5 and dx > -1 and dy > -1 then c:put(x, y, OB[4], ot) end   -- inner caustic (lower-right)
  if rim[k] > 0.72 and r > 6 then c:put(x, y, OB[4], ot) end                          -- bounce
end)
local sx, sy = floor(ox - 3 + .5), floor(oy - 3.5 + .5)
c:put(sx, sy, OB[6], ot) c:put(sx + 1, sy, OB[6], ot) c:put(sx, sy + 1, OB[6], ot) c:put(sx - 1, sy + 1, OB[5], ot)
c:put(sx + 1, sy - 1, A.CREAM, ot) c:put(sx + 2, sy - 1, A.CREAM, ot)
c:put(floor(ox + 0.5), floor(oy + 0.5), OB[6], ot)
-- three curled wood claws gripping the orb (from the collar up round the sides)
local claws = {
  { { F.W(42, -2.4) }, { F.W(43.5, -8.8) }, { F.W(48.5, -10.6) }, { F.W(52.5, -7.6) } },
  { { F.W(42, 2.4) }, { F.W(43.5, 8.8) }, { F.W(48.5, 10.6) }, { F.W(52.5, 7.6) } },
}
for i, cp in ipairs(claws) do
  local pts = { { cp[1][1], cp[1][2] }, { cp[2][1], cp[2][2] }, { cp[3][1], cp[3][2] }, { cp[4][1], cp[4][2] } }
  local cm, cnn, CTt = A.tube(pts, function(t) return 2.0 - t * 0.7 end)
  local cb = {}
  cm:each(function(x, y) local k = K(x, y) if CTt[k] < 0.15 then cb[k] = -1 end end)
  local cidx2 = A.shade(c, cm, cnn, WD, { amb = 0.08, wrap = 0.25, bias = cb, tok = wt })
  -- contact shadow on the orb beside each claw
  A.touch(om:copy():cut(cm), cm):each(function(x, y)
    if F.UV(x, y) > 41.5 then local cmx, cmy = x, y
      local _, v = F.UV(x, y)
      A.step(c, oidx, OB, x, y, -2, ot) end end)
end
-- quirk: tiny mushroom on the upper knot (red cap, cream spots, pale stalk)
local mx, my = F.W(29, -2.6)
mx, my = floor(mx + .5), floor(my + .5)
A.map(c, {
  ".rRR.",
  "rRcRr",
  "dRrrd",
  "..s..",
  "..S..",
}, mx - 4, my - 6, { r = MU[3], R = MU[4], c = A.CREAM, d = MU[2], s = "#e8d4b0", S = "#b8a080" }, wt)
A.save(c, "ico-staff")
