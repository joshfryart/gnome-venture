-- nav-crafting (final pass, Opus aC2r1_1). A slim claw hammer crossed over a cherry-handled wood chisel (an X).
-- Hammer: bevelled steel head (pillow light, bright top bevel, specular streak, polished striking face, split claw),
-- ash handle with grain lines and a pale end cap. Chisel: flat steel blade with a honed bevel at the tip, brass ferrule
-- with grooves, cherry handle with grain and a domed butt. Contact shadow + AO where the hammer crosses the chisel.
-- quirk: a curl of wood shaving still clings to the chisel's edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("nav-crafting")
local STEEL = { "#262840", "#43465f", "#686c88", "#9296ae", "#c3c6d6", "#eceef6" }
local ASH   = { "#4a2a26", "#6e3e2e", "#935a3a", "#b97a4a", "#d89c62", "#efc488" }
local CHER  = { "#46202a", "#6e3032", "#98463a", "#bf6444", "#dc8a5a", "#f2b680" }
local BRASS = { "#6a3a1c", "#9a5e20", "#c8862a", "#eaae3a", "#fad468", "#fff2b0" }
local SHAVE = { "#a8703e", "#d8a868", "#f4d49c" }

local function lerp(a, b, t) return a + (b - a) * t end
-- ---------- chisel geometry (tip upper-left, butt lower-right)
local E, F = { 17, 19 }, { 51, 53 }
local cp = { E, { lerp(E[1], F[1], 1/3), lerp(E[2], F[2], 1/3) }, { lerp(E[1], F[1], 2/3), lerp(E[2], F[2], 2/3) }, F }
local function cw(t)
  if t < 0.03 then return 1.3 end
  if t < 0.50 then return 1.7 end
  if t < 0.585 then return 2.6 end
  if t < 0.94 then return 2.1 + 0.8 * (t - 0.585) / 0.355 end
  return 2.9 * sqrt(max(0, 1 - ((t - 0.94) / 0.062) ^ 2)) + 0.2
end
local cm, cn, CT, CS, csamp = A.tube(cp, cw)
-- flatten the blade (a bar, not a rod)
cm:each(function(x, y) local k = K(x, y) if CT[k] < 0.5 then local q = cn[k] local l = sqrt(q[1]^2*0.25 + q[2]^2*0.25 + q[3]^2)
  cn[k] = { q[1]*0.5/l, q[2]*0.5/l, q[3]/l } end end)

-- ---------- hammer geometry
local hp = { { 12, 54 }, { 20, 45 }, { 31, 32 }, { 40, 21 } }
local function hw(t)
  if t < 0.05 then return 2.0 + 0.4 * sqrt(max(0, 1 - ((0.05 - t) / 0.05) ^ 2)) - 0.4 * ((0.05 - t) / 0.05) ^ 2 end
  if t < 0.3 then return 2.2 end
  return 2.2 - 0.6 * (t - 0.3) / 0.7
end
local hm, hn, HT, HS, hsamp = A.tube(hp, hw)
-- head: bevelled steel block across the handle top, striking face upper-left, claw curling back lower-right
local hdp = { { 33.6, 15.8 }, { 37.7, 19.1 }, { 44.2, 23.8 }, { 46.2, 31.4 } }
local function dw(t)
  if t < 0.06 then return 3.9 end
  if t < 0.22 then return 3.9 - 1.0 * (t - 0.06) / 0.16 end
  if t < 0.5 then return 2.9 + 0.6 * (t - 0.22) / 0.28 end
  return 3.5 * ((1 - t) / 0.5) ^ 0.85 + 0.5
end
local dm, _, DT, DS, dsamp = A.tube(hdp, dw)
-- split claw: cut a 1 px notch down the centre of the last third
local notch = HP.mask()
dm:each(function(x, y) local k = K(x, y) local t, s = DT[k], DS[k]
  local wd = dw(t)
  if t > 0.68 and abs(s) * (wd + 0.5) < 0.62 then notch:set(x, y) end end)
dm:cut(notch)
hm:cut(dm)

-- ---------- paint chisel (under), with AO + contact shadow from the hammer
local all = hm:copy():add(dm)
local cb = A.bias()
A.ao(cb, cm, all, 1, -1)
A.cast(cb, cm, all, 1, 2, -1)
local bladeM, ferM, chM = HP.mask(), HP.mask(), HP.mask()
cm:each(function(x, y) local t = CT[K(x, y)]
  if t < 0.5 then bladeM:set(x, y) elseif t < 0.585 then ferM:set(x, y) else chM:set(x, y) end end)
local vC = X.light(cn, { amb = 0.06, wrap = 0.22 })
-- ferrule/handle meet: dark ring
chM:each(function(x, y) local k = K(x, y) if CT[k] < 0.61 then cb[k] = (cb[k] or 0) - 1 end end)
bladeM:each(function(x, y) local k = K(x, y) if CT[k] > 0.47 then cb[k] = (cb[k] or 0) - 1 end end)
local bi = X.tone(c, bladeM, vC, STEEL, { cuts = A.CUTS, bias = cb })
local fi = X.tone(c, ferM, vC, BRASS, { cuts = A.CUTS, bias = cb })
local ci = X.tone(c, chM, vC, CHER, { cuts = A.CUTS, bias = cb })
-- honed bevel at the tip: one tone brighter, dark edge line behind it
bladeM:each(function(x, y) local t = CT[K(x, y)]
  if t < 0.075 then A.step(c, bi, STEEL, x, y, 1) elseif t < 0.1 then A.step(c, bi, STEEL, x, y, -1) end end)
-- ferrule grooves
ferM:each(function(x, y) local t = CT[K(x, y)] if abs(t - 0.542) < 0.012 then A.step(c, fi, BRASS, x, y, -2) end end)
-- cherry grain
chM:each(function(x, y) local k = K(x, y) local s = CS[k]
  if (abs(s + 0.3) < 0.13 or abs(s - 0.42) < 0.12) and X.hash(x, y, 3) > 0.3 and CT[k] < 0.93 then A.step(c, ci, CHER, x, y, -1) end end)
-- specular streak along the blade's lit edge
for i = 22, 66, 4 do local s = csamp[i] local x, y = floor(s.x - s.px * s.w * 0.5 + .5), floor(s.y - s.py * s.w * 0.5 + .5)
  if bladeM:has(x, y) and not all:has(x, y) then c:put(x, y, STEEL[6]) end end
do local s = csamp[floor(0.545 * 160) + 1] c:put(floor(s.x - s.px * 1.6 + .5), floor(s.y - s.py * 1.6 + .5), BRASS[6]) end

-- ---------- paint hammer handle
local hb = A.bias()
A.ao(hb, hm, dm, 2, -1)
local hi = A.shade(c, hm, hn, ASH, { bias = hb })
hm:each(function(x, y) local k = K(x, y) local s, t = HS[k], HT[k]
  if t > 0.05 and (abs(s - 0.05) < 0.12 or abs(s - 0.6) < 0.1) and X.hash(x, y, 7) > 0.28 then A.step(c, hi, ASH, x, y, -1) end
  if t < 0.03 then A.step(c, hi, ASH, x, y, 2) end   -- pale end grain at the butt
end)
for i = 30, 110, 6 do local s = hsamp[i] local x, y = floor(s.x - s.px * s.w * 0.55 + .5), floor(s.y - s.py * s.w * 0.55 + .5)
  if hm:has(x, y) and i % 12 == 6 then c:put(x, y, ASH[6]) end end

-- ---------- paint hammer head (bevelled block)
local dn = X.pillow(dm, 1.7)
local db = A.bias()
local di = A.shade(c, dm, dn, STEEL, { bias = db })
dm:each(function(x, y) local k = K(x, y) local t, s = DT[k], DS[k]
  if t < 0.045 then A.step(c, di, STEEL, x, y, 1)                 -- polished striking face
  elseif t < 0.075 then A.step(c, di, STEEL, x, y, -2) end        -- face rim
  if t > 0.66 and abs(s) * (dw(t) + 0.5) < 1.7 then A.step(c, di, STEEL, x, y, -1) end   -- shade inside the claw split
end)
-- eye: the handle wedge shows as a dark slot on the top of the head
for _, p in ipairs{ { 39, 20 }, { 40, 21 }, { 40, 20 } } do if dm:has(p[1], p[2]) then c:put(p[1], p[2], STEEL[2]) end end
c:put(39, 21, ASH[3])
-- specular streak along the top bevel + glint
for i = 14, 70, 3 do local s = dsamp[i] local x, y = floor(s.x - s.px * s.w * 0.6 + .5), floor(s.y - s.py * s.w * 0.6 + .5)
  if dm:has(x, y) then c:put(x, y, STEEL[6]) end end
do local s = dsamp[20] c:put(floor(s.x - s.px * s.w * 0.6 + .5), floor(s.y - s.py * s.w * 0.6 + .5), A.CREAM) end

-- ---------- quirk: wood shaving curl clinging to the chisel edge
local curl = c:ellipse(13, 14, 3, 3):cut(c:ellipse(13, 14, 1, 1))
curl:cut(c:rect(14, 15, 20, 20))
curl:add(c:line({ { 14, 17 }, { 16, 18 } }, 1))
curl:each(function(x, y)
  local tone = (x + y < 26) and 3 or ((x - y > 0) and 1 or 2)
  if not cm:has(x, y) then c:put(x, y, SHAVE[tone]) end
end)
A.save(c, "nav-crafting")
