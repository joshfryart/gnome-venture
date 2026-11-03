-- ico-axe (final, Opus). Woodcutter's felling axe on the diagonal: slim S-curved hickory haft with a flared
-- butt knob, grain lines and pale end grain poking out above the head; forged steel head with a flat cheek,
-- a ground bevel strip and a bright honed edge, a dark eye shadow where the haft enters, specular on the bevel.
-- AO on the haft under the head. quirk: a fresh wood chip is flying off the cutting edge.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-axe")
local WD = { "#4a2a28", "#6e3f2e", "#935a36", "#b97a4a", "#d89c62", "#f0c286" }
local ST = { "#2e2c47", "#464766", "#686a88", "#9294ad", "#bec0d2", "#e4e6f0" }
local htok, stok = { r = { name = "haft" } }, { r = { name = "steel" } }

-- haft: cubic tube, butt lower-left, top upper-right
local P = { { 13, 56 }, { 21, 47 }, { 33, 28 }, { 44, 12 } }
local function hw(t)
  if t < 0.06 then return 2.9 end
  if t < 0.12 then return 2.9 - (t - 0.06) / 0.06 * 1.0 end
  return 1.9 - (t - 0.12) * 0.35
end
local hm, hn, HT, HS, samp = A.tube(P, hw)

-- head geometry in (u along haft, v toward blade) around the haft point at t=0.86
local function at(t) local s = samp[floor(t * 160) + 1] return s end
local s0 = at(0.86)
local ux, uy = -s0.tx, -s0.ty            -- along haft, pointing up (toward top)
if uy > 0 then ux, uy = -ux, -uy end
local vx, vy = -uy, ux                   -- perpendicular
if vx < 0 then vx, vy = -vx, -vy end     -- blade to the right
local function W(u, v) return { s0.x + u * ux + v * vx, s0.y + u * uy + v * vy } end
local headPts = {
  W(4.6, -6.2), W(5.0, -3.4), W(4.2, 3.6), W(3.4, 6.5), W(4.4, 10.5), W(6.6, 14.8), W(7.6, 17.4),
  W(4.5, 18.6), W(-1, 19.2), W(-6, 18.4), W(-10.6, 16.0), W(-11.6, 13.6), W(-7.8, 11.6), W(-4.6, 8.0),
  W(-3.6, 5.0), W(-4.8, 3.6), W(-5.0, -3.4), W(-4.6, -6.2),
}
local head = c:poly(headPts)
local haftVis = hm:copy():cut(head)
local bias = {}
X.ao(bias, haftVis, head, 2, -1)
haftVis:each(function(x, y) local k = K(x, y)
  local s = HS[k]
  local g = (s * 2.6 + math.sin(HT[k] * 19) * 0.35)
  if abs(g - floor(g + 0.5)) < 0.12 and HT[k] > 0.1 then bias[k] = (bias[k] or 0) - 1 end
end)
local hidx = A.shade(c, haftVis, hn, WD, { amb = 0.05, wrap = 0.2, bias = bias, tok = htok })
haftVis:each(function(x, y) local k = K(x, y)
  if HT[k] > 0.105 and HT[k] < 0.125 then A.step(c, hidx, WD, x, y, -2, htok) end end)
haftVis:each(function(x, y) local k = K(x, y)
  if HT[k] > 0.965 then c:put(x, y, HS[k] < 0.3 and WD[6] or WD[5], htok) end end)

-- steel head: pillow bevel; cheek thins toward the edge (tilt grows with v); ground bevel past v=13
local hnrm = X.pillow(head, 2.0)
local HV = {}
head:each(function(x, y) local k = K(x, y)
  local rx, ry = x - s0.x, y - s0.y
  local u, v = rx * ux + ry * uy, rx * vx + ry * vy
  HV[k] = { u, v }
  local nn = hnrm[k]
  local tl = v > 13.6 and 0.95 or max(0, v - 3) / 10 * 0.32
  local tu = (u > 0 and 0.12 or -0.05)
  hnrm[k] = { A.norm(nn[1] + vx * tl - ux * tu, nn[2] + vy * tl - uy * tu, nn[3]) }
end)
local hidx2 = A.shade(c, head, hnrm, ST, { amb = 0.08, wrap = 0.2, tok = stok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
-- bevel shoulder: bright lip then the darker ground strip
head:each(function(x, y) local k = K(x, y) local u, v = HV[k][1], HV[k][2]
  if v > 12.6 and v <= 13.6 then c:put(x, y, ST[2], stok)
  elseif v > 13.6 then c:put(x, y, u > -1.5 and ST[5] or (u > -6.5 and ST[4] or ST[3]), stok) end
end)
-- honed edge: brightest rim along the far side
head:edge():each(function(x, y) local k = K(x, y)
  if HV[k][2] > 15.4 or (HV[k][2] > 13 and HV[k][1] < -9.5) then c:put(x, y, ST[6], stok) end end)
-- eye: the haft's wedge slot on the top face + a dark seat line where the haft leaves the head
head:each(function(x, y) local k = K(x, y) local u, v = HV[k][1], HV[k][2]
  if u < -4.0 and abs(v) < 2.6 then A.step(c, hidx2, ST, x, y, -1, stok) end
end)
-- poll: a separate darker face, split from the cheek by a ridge line
head:each(function(x, y) local k = K(x, y) local u, v = HV[k][1], HV[k][2]
  if v < -3.4 then A.step(c, hidx2, ST, x, y, -1, stok)
  elseif v < -2.4 then A.step(c, hidx2, ST, x, y, 1, stok) end
end)
-- neck ridge: shade line where the cheek drops from the eye boss
head:each(function(x, y) local k = K(x, y) local u, v = HV[k][1], HV[k][2]
  if v > 3.4 and v <= 4.4 then A.step(c, hidx2, ST, x, y, -1, stok) end
end)
-- specular streak along the bevel + one glint
for i = -8, 4, 1 do
  local p = W(i, 14.6 + (i < -5 and (i + 5) * -0.2 or 0)) local x, y = floor(p[1] + .5), floor(p[2] + .5)
  if head:has(x, y) and i > -3 and i < 3 then c:put(x, y, ST[6], stok) end
end
do local p = W(1.2, 14.6) c:put(floor(p[1] + .5), floor(p[2] + .5), A.CREAM, stok) end
-- quirk: a wood chip flying off the edge (3 px wedge + 1 px grain), with 2 speed ticks
do
  local p = W(-6, 23.5) local x, y = floor(p[1] + .5), floor(p[2] + .5)
  A.map(c, { ".ab", "abc", "bc." }, x - 1, y - 1, { a = WD[6], b = WD[5], c = WD[3] })
end
A.save(c, "ico-axe")
