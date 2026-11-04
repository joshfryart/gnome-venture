-- crayfish-claw (final, Opus single pass). A detached cooked crayfish claw on the diagonal: carpus stub with a
-- pale flesh cross-section at the torn base, a tan membrane ring at the wrist, an elongated bumpy palm (tubercles
-- = lit dot over a shade dot), a hinge knob, and two slim curved fingers with toothed inner edges and paler tips.
-- quirk: a small grey pebble is held in the pincer's grip.
local NAME = "crayfish-claw"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.pi
local c = A.new(NAME)
local SH = { "#3d1420", "#6e1f2a", "#a3302c", "#d24c2e", "#f07a3e", "#ffb46a" }
local TIP = { "#5a2a24", "#8f4a2c", "#c47a3e", "#e8a65a", "#f8cf86", "#fff0c0" }
local MEM = { "#6b4a35", "#a8805a", "#d8b486" }
local FL = { "#c9826e", "#eab09a", "#f8d8c0" }
local ST = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }

-- claw axis: base lower-left -> tips upper-right
local ox, oy = 11, 53
local ax, ay = 0.69, -0.72
local l = sqrt(ax*ax + ay*ay) ax, ay = ax / l, ay / l
local px, py = -ay, ax                       -- +v = lower-right (shade side)
local function P(u, v) return { ox + u * ax + v * px, oy + u * ay + v * py } end

-- fingers first (palm and hinge sit over their roots)
local fx = { P(31, 2.6), P(41, 4.2), P(50, 3.6), P(58, 1.2) }
local fixm, fixn, FXT, FXS = A.tube(fx, function(t) return 2.9 * (1 - t) ^ 0.75 + 0.45 end)
local dc = { P(30, -2.8), P(39, -6.4), P(48, -5.8), P(56, -1.4) }
local dacm, dacn, DT, DS = A.tube(dc, function(t) return 2.6 * (1 - t) ^ 0.75 + 0.45 end)
dacm:cut(fixm)
local palmP = { P(11, 0), P(18, 0.2), P(26, 0.2), P(33, 0) }
local palm, paln, PT, PS = A.tube(palmP, function(t) return 3.9 + 2.1 * sin(pi * min(1, t * 0.95 + 0.08)) ^ 0.8 end)
local carP = { P(0, 0), P(4, 0), P(8, 0), P(11.5, 0) }
local car, carn, CT, CS = A.tube(carP, function(t) return 3.1 + t * 0.5 end)
car:cut(palm)
fixm:cut(palm) dacm:cut(palm)

-- quirk: pebble held between the fingers
local pc = P(46.5, -0.6)
local peb = A.rell(pc[1], pc[2], 0.8, 0.6, 2.6, 2.1)
peb:cut(fixm):cut(dacm)

local function finger(m, n, T, S, nm)
  local tok = { r = { name = nm } }
  local idx = A.shade(c, m, n, SH, { amb = 0.08, wrap = 0.28, tok = tok, bias = X.ao({}, m, palm, 1, -1) })
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.72 then c:put(x, y, TIP[max(1, min(6, idx[k] + (T[k] > 0.86 and 1 or 0)))], tok) end
  end)
  return idx, tok
end
local fidx, ftok = finger(fixm, fixn, FXT, FXS, "fixed")
local didx, dtok = finger(dacm, dacn, DT, DS, "dactyl")
-- teeth on the inner edges (pale nubs stepping into the gap)
for i = 0, 5 do
  local t = 0.14 + i * 0.1
  local a = A.bez(fx, t) local ax2, ay2 = A.bez(fx, t)
  local x, y = A.bez(fx, t) local w = 2.9 * (1 - t) ^ 0.75 + 0.45
  local xi, yi = floor(x - px * (w + 0.9) + .5), floor(y - py * (w + 0.9) + .5)
  if not peb:has(xi, yi) and not dacm:has(xi, yi) then c:put(xi, yi, i % 2 == 0 and TIP[4] or TIP[3], ftok) end
  x, y = A.bez(dc, t + 0.04) w = 2.6 * (1 - t - 0.04) ^ 0.75 + 0.45
  xi, yi = floor(x + px * (w + 0.9) + .5), floor(y + py * (w + 0.9) + .5)
  if i % 2 == 1 and not peb:has(xi, yi) and not fixm:has(xi, yi) then c:put(xi, yi, TIP[3], dtok) end
end
-- glossy streak on the dactyl's lit edge
for i = 0, 8 do local x, y = A.bez(dc, 0.1 + i * 0.06) local w = 2.6 * (1 - (0.1 + i * 0.06)) ^ 0.75 + 0.45
  c:put(floor(x - px * w * 0.5 + .5), floor(y - py * w * 0.5 + .5), i == 2 and A.CREAM or SH[6], dtok) end

-- carpus with the torn flesh end
local ctok = { r = { name = "carpus" } }
local cidx = A.shade(c, car, carn, SH, { amb = 0.08, wrap = 0.28, tok = ctok, bias = X.ao({}, car, palm, 1, -1) })
car:each(function(x, y) local k = K(x, y)
  if CT[k] < 0.1 then c:put(x, y, CS[k] < -0.3 and FL[3] or (CS[k] < 0.4 and FL[2] or FL[1]), ctok)
  elseif CT[k] < 0.16 then c:put(x, y, SH[2], ctok) end
end)
-- membrane ring at the wrist
local mtok = { r = { name = "membrane" } }
car:each(function(x, y) local k = K(x, y)
  if CT[k] > 0.84 then c:put(x, y, CS[k] < -0.3 and MEM[3] or (CS[k] < 0.5 and MEM[2] or MEM[1]), mtok) end end)

-- palm: bumpy shell
local ptok = { r = { name = "palm" } }
local pb = {}
local pn = A.body(palm, P(20, -1)[1], P(20, -1)[2], 6, 3, 0.35)
for k, a in pairs(paln) do local b = pn[k] pn[k] = { A.norm(a[1] * 0.6 + b[1] * 0.4, a[2] * 0.6 + b[2] * 0.4, a[3] * 0.6 + b[3] * 0.4) } end
local pidx = A.shade(c, palm, pn, SH, { amb = 0.08, wrap = 0.26, tok = ptok, bias = pb })
-- tubercles
palm:each(function(x, y) local k = K(x, y)
  if PT[k] > 0.08 and PT[k] < 0.92 and abs(PS[k]) < 0.8 and X.hash(x, y, 7) > 0.86 and palm:has(x + 1, y + 1) then
    A.step(c, pidx, SH, x, y, 2, ptok) A.step(c, pidx, SH, x + 1, y + 1, -2, ptok)
  end
end)
-- ridge line of the palm's lower (shade) keel
palm:each(function(x, y) local k = K(x, y) if PS[k] > 0.55 and PS[k] < 0.75 and PT[k] > 0.1 and PT[k] < 0.9 then A.step(c, pidx, SH, x, y, -1, ptok) end end)
-- specular
do local s = P(17, -3.4) c:put(floor(s[1] + .5), floor(s[2] + .5), A.CREAM, ptok) c:put(floor(s[1] + 1.5), floor(s[2] - 0.5), SH[6], ptok) end
-- hinge knob where the dactyl joins
local hc = P(31, -3.2)
local hm = A.rell(hc[1], hc[2], 1, 0, 1.6, 1.6)
local htok = { r = { name = "hinge" } }
hm:each(function(x, y) local d = (x - hc[1]) + (y - hc[2]) c:put(x, y, d < -0.8 and TIP[4] or (d < 0.8 and SH[3] or SH[1]), htok) end)
-- gap line where fingers meet the palm (ambient)
for _, u in ipairs{ 32.5, 33.5 } do local q = P(u, -0.2) local xi, yi = floor(q[1] + .5), floor(q[2] + .5)
  if palm:has(xi, yi) then c:put(xi, yi, SH[1], ptok) end end

-- pebble
local stok = { r = { name = "pebble" } }
local sidx = A.shade(c, peb, A.body(peb, pc[1] - 0.6, pc[2] - 0.6, 2.4, 1.5, 0.8), ST, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
c:put(floor(pc[1] - 0.6 + .5), floor(pc[2] - 1 + .5), "#f4f2f6", stok)

A.save(c, NAME)
