-- feast-maizehollow-mole (final, Opus single pass). A round terracotta cazuela on a small foot ring, brimming with glossy
-- dark chocolate-chili mole scattered with sesame; a roasted drumstick glazed in mole rises out to the upper right, and a
-- dried red chili hangs over the left rim. Material: per-pixel bowl light (6-tone terracotta, violet-brown shade), bevelled
-- lip, a painted cream kernel-dot band and a dark slip line, unglazed foot; mole with a long wet specular and sesame
-- specks; crisp skin specks, cream bone knob; wrinkled chili with a waxy streak. AO under the lip and where parts meet.
-- quirk: one fat drip of mole has run down the outside of the bowl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local norm = A.norm
local c = A.new("feast-maizehollow-mole")

local TERRA = { "#471d24", "#77322a", "#a64d2e", "#c96e39", "#e3954f", "#f5c07a" }
local MOLE  = { "#1d0c12", "#371418", "#55221f", "#773526", "#9a5434", "#c88a5c" }
local MEAT  = { "#4a1e18", "#7a3420", "#a8552a", "#cf7f3a", "#e8a95a", "#f8d690" }
local BONE  = { "#8a7262", "#b49c86", "#d6c2a8", "#ecdcc2", "#f8eedc", "#fffaf0" }
local CHILI = { "#2c0a16", "#561020", "#86182a", "#b22a2e", "#d84e3c", "#f2885c" }
local SPEC, SES, DOT, DOTS = "#fff4d6", "#f2e0b6", "#f4e2c0", "#c9a184"
local cx, ry0 = 30, 30

c:groundShadow(cx, 47, 16, 3)

-- foot ring
local foot = c:rect(cx - 6, 43, cx + 6, 46)
A.vcyl(c, foot, TERRA, cx - 6, cx + 6, { amb = 0.05, bias = (function() local b = {} foot:each(function(x, y) b[K(x, y)] = y == 43 and -2 or -1 end) return b end)() })

-- bowl body: lower half of an ellipsoid
local RX, RY = 21, 14
local body = A.pmask(cx - RX - 1, ry0, cx + RX + 1, ry0 + RY + 1, function(x, y)
  local u, v = (x - cx) / (RX + 0.4), (y - ry0) / (RY + 0.4) return u*u + v*v <= 1 end)
local bn, bb = {}, {}
body:each(function(x, y)
  local u, v = (x - cx) / (RX + 0.4), (y - ry0) / (RY + 0.4)
  bn[K(x, y)] = { norm(u, v * 0.9, sqrt(max(0.05, 1 - u*u - v*v)) + 0.2) }
  if y <= ry0 + 1 then bb[K(x, y)] = -1 end
end)
local bidx = A.shade(c, body, bn, TERRA, { amb = 0.1, wrap = 0.35, bias = bb })
-- painted band: dark slip line + cream kernel dots following the curve
body:each(function(x, y)
  local u = (x - cx) / RX
  local yb = ry0 + 6 + floor(u * u * -2.5 + 0.5)
  local i = bidx[K(x, y)] or 3
  if y == yb + 3 then c:put(x, y, TERRA[max(1, i - 2)]) end
  if y == yb and (x + 1) % 4 < 2 and abs(u) < 0.92 then c:put(x, y, i >= 3 and DOT or DOTS) end
  if y == yb + 1 and (x + 1) % 4 == 0 and abs(u) < 0.92 then c:put(x, y, i >= 3 and DOTS or TERRA[2]) end
end)
-- cool bounce lower right + clay glint
local rimL = X.rim(bn)
body:edge():each(function(x, y) if rimL[K(x, y)] > 0.62 and y > ry0 + 3 then c:put(x, y, "#8a4a5a") end end)
c:put(cx - 15, ry0 + 4, TERRA[6]) c:put(cx - 14, ry0 + 4, TERRA[6]) c:put(cx - 15, ry0 + 5, TERRA[5])

-- lip ring
local lo = A.emask(cx, ry0, RX + 0.6, 6)
local li = A.emask(cx, ry0 + 0.4, RX - 2.4, 4.4)
local lip = lo:copy():cut(li)
local ln = {}
lip:each(function(x, y) local u, v = (x - cx) / (RX + 0.6), (y - ry0) / 6 local rr = sqrt(u*u + v*v) local s = (rr - 0.88) / 0.12
  ln[K(x, y)] = { norm(u / rr * s, v / rr * s * 0.8, 1) } end)
A.shade(c, lip, ln, TERRA, { amb = 0.14, wrap = 0.3 })
-- inside wall above the sauce, then mole
li:each(function(x, y) c:put(x, y, y < ry0 - 1 and TERRA[2] or TERRA[1]) end)
local sauce = A.emask(cx, ry0 + 1.1, RX - 3.2, 3.5)
local sn, sb = {}, {}
sauce:each(function(x, y) local u, v = (x - cx) / (RX - 3.2), (y - ry0 - 1.1) / 3.5
  sn[K(x, y)] = { norm(u * 0.35 + sin(x * 0.7) * 0.08, v * 0.3, 1) }
  if not sauce:has(x, y - 1) then sb[K(x, y)] = -2 end end)
local sidx = A.shade(c, sauce, sn, MOLE, { amb = 0.12, wrap = 0.3, bias = sb })

-- dried chili hanging over the left rim (painted before the drumstick, after the bowl)
local cm, cnn, CT, CS = A.stem(c, { { 12, 26 }, { 9, 29 }, { 7, 34 }, { 8, 41 } },
  function(t) return max(0.5, 2.5 * (1 - t) ^ 0.7) end, CHILI, { amb = 0.1, wrap = 0.25 })
cm:each(function(x, y) local k = K(x, y)
  if CS[k] < -0.2 and CS[k] > -0.65 and CT[k] > 0.12 and CT[k] < 0.6 then c:put(x, y, CHILI[6]) end
  if floor(CT[k] * 18) % 5 == 2 and CS[k] > 0 then c:put(x, y, CHILI[3]) end end)
c:put(12, 24, "#6b7a34") c:put(13, 24, "#4f5e2a") c:put(13, 23, "#4f5e2a") c:put(12, 25, "#3a4822")

-- drumstick: glazed meat out of the sauce, slim bone, knuckle knob
local dm, dn, DT, DS = A.stem(c, { { cx + 3, ry0 + 1 }, { cx + 7, ry0 - 4 }, { cx + 11, ry0 - 8 }, { cx + 15, ry0 - 13 } },
  function(t) if t < 0.62 then return 4.3 - t * 2.2 end return 1.3 end, MEAT, { amb = 0.1, wrap = 0.3 })
dm:each(function(x, y) local k = K(x, y)
  local t, s = DT[k], DS[k]
  if t >= 0.62 then c:put(x, y, s < -0.2 and BONE[5] or (s < 0.4 and BONE[4] or BONE[2]))
  elseif t < 0.22 or s > 0.45 then c:put(x, y, s > 0.6 and MOLE[2] or MOLE[4])
  elseif X.hash(x, y, 5) > 0.8 then c:put(x, y, MEAT[2]) end
  if t > 0.56 and t < 0.64 then c:put(x, y, MEAT[2]) end
end)
for _, kn in ipairs({ { cx + 15.5, ry0 - 14.8, 1.7 }, { cx + 17.4, ry0 - 12.6, 1.6 } }) do
  local m, n = A.oval(kn[1], kn[2], kn[3], kn[3], 0, 1)
  A.shade(c, m, n, BONE, { amb = 0.15, wrap = 0.3 })
end
c:put(cx + 6, ry0 - 4, SPEC) c:put(cx + 7, ry0 - 5, MEAT[6])
-- mole pooled around the drumstick base
for _, p in ipairs({ { cx - 1, ry0 + 1 }, { cx, ry0 + 2 }, { cx + 6, ry0 + 2 }, { cx + 7, ry0 + 1 } }) do c:put(p[1], p[2], MOLE[3]) end

-- wet specular streak and sesame specks on the sauce
for x = cx - 12, cx - 6 do if sauce:has(x, ry0) then c:put(x, ry0, x < cx - 9 and MOLE[6] or MOLE[5]) end end
c:put(cx - 11, ry0, SPEC)
for _, p in ipairs({ { cx - 14, ry0 + 2 }, { cx - 6, ry0 + 3 }, { cx - 3, ry0 }, { cx + 10, ry0 + 3 }, { cx + 13, ry0 }, { cx - 9, ry0 + 2 }, { cx + 2, ry0 + 4 }, { cx + 15, ry0 + 2 } }) do
  if sauce:has(p[1], p[2]) and not dm:has(p[1], p[2]) then c:put(p[1], p[2], SES) end
end

-- quirk: a fat drip of mole running down the outside
local dx0 = cx + 9
for y = ry0 + 4, ry0 + 9 do c:put(dx0, y, y < ry0 + 7 and MOLE[4] or MOLE[3]) c:put(dx0 + 1, y, MOLE[2]) end
c:put(dx0, ry0 + 10, MOLE[3]) c:put(dx0 + 1, ry0 + 10, MOLE[2]) c:put(dx0 - 1, ry0 + 10, MOLE[4])
c:put(dx0, ry0 + 11, MOLE[2]) c:put(dx0 - 1, ry0 + 11, MOLE[3]) c:put(dx0 + 1, ry0 + 11, MOLE[1])
c:put(dx0 - 1, ry0 + 9, MOLE[5]) c:put(dx0, ry0 + 5, MOLE[5])
A.save(c, "feast-maizehollow-mole")
