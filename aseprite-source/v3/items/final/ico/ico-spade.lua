-- ico-spade (final, Opus). Garden spade on the diagonal: pointed steel blade lower-left with a pressed centre rib,
-- a dished face (lit on the far side), a folded tread along the shoulders and a bright honed edge; tapered steel
-- socket with a rivet and a dark collar ring; slim ash shaft with grain lines; T-grip with pale end grain.
-- AO on the shaft under socket and grip, contact shadow on the blade under the socket.
-- quirk: a clod of soil is stuck to the blade and something has already sprouted in it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-spade")
local WD = { "#4a2a28", "#6e3f2e", "#935a36", "#b97a4a", "#d89c62", "#f0c286" }
local ST = { "#2e2c47", "#464766", "#686a88", "#9294ad", "#bec0d2", "#e4e6f0" }
local SO = { "#2e1a1c", "#4a2c24", "#6b4130", "#8c5a3c" }
local GR = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local BOUNCE = "#7a8cc0"
local wtok, stok, ktok = { r = { name = "wood" } }, { r = { name = "steel" } }, { r = { name = "sock" } }

local F = A.frame(13, 54, 36, -44)           -- u up the tool from the blade tip, v>0 lower-right
local function seg(u0, v0, u1, v1, wf)
  local ax, ay = F.W(u0, v0) local bx, by = F.W(u1, v1)
  return X.cyl(ax, ay, bx, by, wf)
end
-- masks
local blade = c:poly{ F.P(0, 0), F.P(1.6, -3.2), F.P(4.2, -6.2), F.P(8.5, -8.0), F.P(14, -8.6), F.P(19, -8.4),
  F.P(20.6, -7.4), F.P(20.6, 7.4), F.P(19, 8.4), F.P(14, 8.6), F.P(8.5, 8.0), F.P(4.2, 6.2), F.P(1.6, 3.2) }
local sm, sn, STt, SS = seg(19.2, 0, 28.6, 0, function(t) return 3.3 - t * 0.9 end)
local hm, hn, HT, HS = seg(27.5, 0, 51.5, 0, function() return 1.75 end)
local gm, gn, GT, GS = seg(53.2, -7.2, 53.2, 7.2, function() return 2.2 end)

-- shaft (under socket + grip)
local hv = hm:copy():cut(sm):cut(gm)
local bias = {}
X.ao(bias, hv, sm, 2, -1) X.ao(bias, hv, gm, 2, -1)
hv:each(function(x, y) local k = K(x, y)
  local u = F.UV(x, y)
  local g = HS[k] * 2.2 + math.sin(u * 0.45) * 0.3
  if abs(g - floor(g + 0.5)) < 0.13 and abs(HS[k]) < 0.8 then bias[k] = (bias[k] or 0) - 1 end
end)
A.shade(c, hv, hn, WD, { amb = 0.05, wrap = 0.22, bias = bias, tok = wtok })
-- T-grip
local gb = {}
local gidx = A.shade(c, gm, gn, WD, { amb = 0.06, wrap = 0.22, bias = gb, tok = wtok })
gm:each(function(x, y) local k = K(x, y)
  local t, s = GT[k], GS[k]
  if t < 0.07 or t > 0.93 then c:put(x, y, s < 0.2 and WD[6] or WD[5], wtok)
  elseif (t < 0.11 or t > 0.89) then c:put(x, y, WD[3], wtok)
  elseif abs(s - 0.1) < 0.16 and (t < 0.35 or t > 0.62) then A.step(c, gidx, WD, x, y, -1, wtok) end
end)
-- end-grain ring dots
do local x, y = F.W(53.2, -6.8) c:put(floor(x + .5), floor(y + .5), WD[4], wtok) end
-- grip-shaft seat: dark row on the grip where the shaft enters it
gm:each(function(x, y) local u, v = F.UV(x, y) if u < 52 and abs(v) < 2.3 then A.step(c, gidx, WD, x, y, -1, wtok) end end)

-- blade: pillow rim + dished face + pressed rib
local bn = X.pillow(blade, 2.0)
local BV = {}
blade:each(function(x, y) local k = K(x, y)
  local u, v = F.UV(x, y) BV[k] = { u, v }
  local nn = bn[k]
  local tilt = -v / 9 * 0.42
  if u > 2.5 and u < 17 and abs(v) < 1.5 then tilt = (v + 0.2) / 1.5 * 0.7 end
  if u > 18.4 then tilt = 0 end
  bn[k] = { A.norm(nn[1] + F.px * tilt - F.ux * (u > 18.4 and (u - 19.5) * 0.5 or 0), nn[2] + F.py * tilt - F.uy * (u > 18.4 and (u - 19.5) * 0.5 or 0), nn[3]) }
end)
local bb = {}
X.ao(bb, blade, sm, 2, -1)
local bidx = A.shade(c, blade, bn, ST, { amb = 0.1, wrap = 0.25, bias = bb, tok = stok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
-- folded tread: dark crease line under it, bright lip on top
blade:each(function(x, y) local k = K(x, y) local u, v = BV[k][1], BV[k][2]
  if u > 17.7 and u <= 18.6 and not sm:has(x, y) then c:put(x, y, ST[2], stok)
  elseif u > 19.8 and v < 2 and not sm:has(x, y) then c:put(x, y, ST[6], stok) end
end)
-- honed edge: bright on the lit side, cool bounce on the shade side
blade:edge():each(function(x, y) local k = K(x, y) local u, v = BV[k][1], BV[k][2]
  if u < 17 then
    if v < -1 then c:put(x, y, ST[6], stok) elseif v > 2 and u > 3 then c:put(x, y, BOUNCE, stok) end
  end
end)
-- specular streak along the rib + glint
for u = 6, 14 do local x, y = F.W(u, -1.1) c:put(floor(x + .5), floor(y + .5), ST[6], stok) end
do local x, y = F.W(12, -1.1) c:put(floor(x + .5), floor(y + .5), A.CREAM, stok) end

-- socket: tapered steel tube, collar ring at the top, rivet
local skb = {}
local skidx = A.shade(c, sm, sn, ST, { amb = 0.08, wrap = 0.22, tok = stok, bias = skb, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
sm:each(function(x, y) local k = K(x, y) local t = STt[k]
  if t > 0.8 and t < 0.92 then A.step(c, skidx, ST, x, y, -2, stok)
  elseif t >= 0.92 then A.step(c, skidx, ST, x, y, 1, stok)
  elseif t < 0.1 then A.step(c, skidx, ST, x, y, -1, stok) end
end)
for i = 0.15, 0.7, 0.05 do local x, y = F.W(19.2 + i * 9.4, -1.6) if i > 0.3 then c:put(floor(x + .5), floor(y + .5), ST[6], stok) end end
do local x, y = F.W(23.6, 0.3) x, y = floor(x + .5), floor(y + .5)
  c:put(x, y, ST[1], stok) c:put(x - 1, y, ST[5], stok) c:put(x, y - 1, ST[4], stok) end

-- quirk: soil clod stuck on the blade with a two-leaf sprout
local cx, cy = F.W(7.5, 2.6)
local clod = A.rell(cx, cy, F.ux, F.uy, 3.0, 2.6)
clod:each(function(x, y) -- contact shadow on the steel below-right
  local q = { x + 1, y + 1 }
  if blade:has(q[1], q[2]) and not clod:has(q[1], q[2]) then A.step(c, bidx, ST, q[1], q[2], -2, stok) end end)
local cn = X.pillow(clod, 2.0)
A.shade(c, clod, cn, SO, { amb = 0.06, wrap = 0.2, tok = ktok, cuts = { 0.3, 0.5, 0.7 } })
c:put(floor(cx) - 1, floor(cy), SO[2], ktok) c:put(floor(cx) + 1, floor(cy) + 1, SO[4], ktok)
local sx, sy = floor(cx + .5), floor(cy - 1.5)
A.map(c, {
  "ab.cd",
  "bb.dc",
  ".bed.",
  "..e..",
  "..e..",
}, sx - 2, sy - 5, { a = GR[4], b = GR[3], c = GR[2], d = GR[3], e = GR[1] }, ktok)
A.save(c, "ico-spade")
