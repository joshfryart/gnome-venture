-- cricket-leg (final, Opus single pass). One detached cricket hind leg folded as a ">": a slim drumstick femur
-- (herringbone muscle chevrons, glossy chitin streak, pale hip knob with AO), a dark knee joint, a thin tibia
-- with a row of cream-tipped spines on its back edge and two end spurs, then a 3-segment tarsus with twin claws.
-- quirk: a single dewdrop clings under the knee, with a cream glint.
local NAME = "cricket-leg"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.pi
local c = A.new(NAME)
local BR = { "#2a1716", "#4c2a1f", "#744226", "#9e632f", "#c98d45", "#efbf72" }
local KN = { "#1f1218", "#3a2124", "#5b3328" }
local SP = { "#6b4a35", "#c9a477", "#fff4d6" }
local DEW = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

-- femur: hip upper-left -> knee right
local fp = { { 13, 13 }, { 22, 17 }, { 34, 26 }, { 46, 35 } }
local fw = function(t) return 1.9 + 2.9 * (1 - t) ^ 1.1 * min(1, 0.55 + t * 4) end
local fm, fn, FT, FS, fs = A.tube(fp, fw)
local flen = 0 for i = 2, #fs do flen = flen + sqrt((fs[i].x - fs[i-1].x)^2 + (fs[i].y - fs[i-1].y)^2) end
-- hip knob (trochanter), separate pale part
local hip = A.rell(11.5, 12, 0.8, 0.6, 3.0, 2.4)
local fbias = {}
X.ao(fbias, fm, hip, 1, -1)
fm:cut(hip)
local ftok = { r = { name = "femur" } }
local fidx = A.shade(c, fm, fn, BR, { amb = 0.08, wrap = 0.3, bias = fbias, tok = ftok })
-- herringbone chevrons (muscle ridges) on the femur face
fm:each(function(x, y) local k = K(x, y)
  local t, s = FT[k], FS[k]
  if t > 0.1 and t < 0.86 and abs(s) < 0.78 then
    local d = (t * flen - abs(s) * 3.2) % 3.4
    if d < 0.85 then A.step(c, fidx, BR, x, y, -1, ftok) end
  end
  if abs(s) < 0.09 and t > 0.08 and t < 0.9 then A.step(c, fidx, BR, x, y, -1, ftok) end
end)
-- glossy streak along the lit upper edge
for i = 0, 22 do local t = 0.08 + i * 0.024 local x, y = A.bez(fp, t)
  local w = fw(t) local px, py = 0.6, -0.8
  local xi, yi = floor(x + px * w * 0.55 + .5), floor(y + py * w * 0.55 + .5)
  if fm:has(xi, yi) then c:put(xi, yi, (i > 3 and i < 8) and A.CREAM or BR[6], ftok) end
end
local htok = { r = { name = "hip" } }
local HIP = { "#4c2a1f", "#866045", "#b8946a", "#d9bb8c", "#f0dcb0", "#fff0cc" }
A.shade(c, hip, A.body(hip, 11, 11.5, 3, 2, 0.7), HIP, { tok = htok })
c:put(11, 12, HIP[1], htok) c:put(12, 12, HIP[2], htok)   -- socket hole

-- knee joint
local knee = A.rell(46.5, 35.5, 1, 0, 2.6, 2.6)
local ktok = { r = { name = "knee" } }
knee:each(function(x, y) local d = (x - 45.8) + (y - 34.8) c:put(x, y, d < -1 and KN[3] or (d < 1.5 and KN[2] or KN[1]), ktok) end)
c:put(45, 34, BR[4], ktok)

-- tibia: knee -> down-left
local tp = { { 46, 37 }, { 41, 42 }, { 33, 47 }, { 24, 52 } }
local tm, tn, TT, TS, ts = A.tube(tp, function(t) return 1.55 - t * 0.35 end)
tm:cut(knee)
local tbias = {} X.ao(tbias, tm, knee, 1, -1)
local ttok = { r = { name = "tibia" } }
local tidx = A.shade(c, tm, tn, BR, { amb = 0.1, wrap = 0.3, bias = tbias, tok = ttok })
-- spines on the back (upper-left) edge, pointing toward the foot
local tlen = 0 for i = 2, #ts do tlen = tlen + sqrt((ts[i].x - ts[i-1].x)^2 + (ts[i].y - ts[i-1].y)^2) end
local stok = { r = { name = "spines" } }
for i = 1, 6 do
  local t = 0.12 + i * 0.12
  local x, y = A.bez(tp, t)
  local x2, y2 = A.bez(tp, t + 0.01)
  local ux, uy = x2 - x, y2 - y local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  local px, py = uy, -ux            -- toward upper-left side
  if px + py > 0 then px, py = -px, -py end
  for j = 1, 3 do
    local sx, sy = x + px * (1.2 + j) + ux * j * 0.9, y + py * (1.2 + j) + uy * j * 0.9
    local xi, yi = floor(sx + .5), floor(sy + .5)
    if not tm:has(xi, yi) then c:put(xi, yi, SP[j], stok) end
  end
end
-- end spurs
for _, q in ipairs{ { 23, 50, SP[2] }, { 22, 50, SP[3] }, { 25, 54, SP[2] }, { 24, 55, SP[3] } } do c:put(q[1], q[2], q[3], stok) end

-- tarsus: three segments heading left, joints darker
local segs = { { 21.5, 53, 2.2, 1.4 }, { 17.4, 54, 1.9, 1.25 }, { 13.8, 55, 1.6, 1.1 } }
local atok = { r = { name = "tarsus" } }
for i, s in ipairs(segs) do
  local m = A.rell(s[1], s[2], 1, -0.2, s[3], s[4])
  m:cut(tm)
  local idx = A.shade(c, m, A.body(m, s[1] - 0.4, s[2] - 0.4, s[3], 1, 0.8), BR, { tok = atok, amb = 0.12 })
  local bx = floor(s[1] + s[3] + 0.2)
  for yy = floor(s[2] - 1), floor(s[2] + 1) do if m:has(bx, yy) then c:put(bx, yy, BR[2], atok) end end
end
-- claws
for _, q in ipairs{ { 11, 54, BR[3] }, { 10, 53, BR[2] }, { 11, 56, BR[3] }, { 10, 57, BR[2] }, { 12, 55, BR[4] } } do c:put(q[1], q[2], q[3], atok) end

-- quirk: dewdrop hanging under the knee
local dtok = { r = { name = "dew" } }
local dm = A.rell(47, 42, 0, 1, 2.3, 1.9)
dm:add(A.rell(47, 40.2, 0, 1, 1, 0.8))
dm:each(function(x, y)
  local d = (x - 47) * 0.7 + (y - 42) * 0.7
  c:put(x, y, d > 1 and DEW[1] or (d > -0.3 and DEW[2] or DEW[3]), dtok)
end)
c:put(46, 41, A.CREAM, dtok) c:put(48, 43, DEW[4], dtok)

A.save(c, NAME)
