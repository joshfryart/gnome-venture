-- plantain (final pass, Opus, aC35_2). One long, slim, ripening plantain on the diagonal: angular faceted
-- skin (four flat faces with lit ridges), butter-yellow ripening to green at the neck, dark sugar spots,
-- a dry black blossom nub at the tip, a woody stalk with a pale cut end (end grain), AO where stalk meets fruit,
-- one specular on the top face, cool reflected light on the underside rim.
-- quirk: a loop of market twine is knotted round the stalk, one frayed end dangling.
local NAME = "plantain"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local YEL = { "#5a3428", "#93582a", "#cc8a26", "#ebb631", "#f8d858", "#fff1a4" }
local GRN = { "#2c4630", "#4c6a2e", "#7c962e", "#acbb3c", "#d2d660", "#ecf0a0" }
local SPOT = { "#3e2420", "#5e3424" }
local COOL = "#7a7092"
local STALK = { "#2f2822", "#4a3e2c", "#6a5a36", "#8c7c46", "#ad9e5e", "#cfc086" }
local TW = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- body: tube along a gentle arc, tip lower-left, neck upper-right
local bp = { { 11, 52 }, { 13, 37 }, { 27, 20 }, { 45, 15 } }
local bm, bn, BT, BS = A.tube(bp, function(t) return 1.1 + 4.0 * sin(pi * (0.06 + 0.8 * t)) ^ 0.55 end)
-- stalk
local sp = { { 44, 15 }, { 47, 14 }, { 50, 13 }, { 53, 12 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.45 end)
sm:cut(bm)
-- faceted normals: four flat faces across the fruit
local fn = {}
bm:each(function(x, y) local k = K(x, y)
  local s = BS[k]
  local f = max(0, min(3, floor((s + 1) / 2 * 4)))
  local q = ({ -0.72, -0.26, 0.24, 0.7 })[f + 1]
  local a = bn[k]
  local l = sqrt(a[1] * a[1] + a[2] * a[2])
  local px, py = 0, 0
  if l > 1e-6 then px, py = a[1] / l * (s < 0 and -1 or 1), a[2] / l * (s < 0 and -1 or 1) end
  fn[k] = { A.norm(px * q, py * q, sqrt(1 - q * q)) }
end)
local bias = {}
X.ao(bias, bm, sm, 2, -1)
local btok = { r = { name = "body" } }
local v = X.light(fn, { amb = 0.08, wrap = 0.25 })
local bidx = {}
bm:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs(A.CUTS) do if v[k] >= t then i = j + 1 end end
  if BS[k] > 0.86 then i = i - 1 end
  i = max(1, min(6, i + (bias[k] or 0)))
  bidx[k] = i
  local t = BT[k]
  local ramp = YEL
  if t > 0.86 or (t > 0.74 and X.hash(x, y, 3) < (t - 0.74) / 0.12) then ramp = GRN end
  c:put(x, y, ramp[i], btok)
end)
-- ridges: facet borders catch the light (lit side) or sink (shade side)
bm:each(function(x, y) local k = K(x, y)
  local s, t = BS[k], BT[k]
  if t < 0.07 or t > 0.97 then return end
  local ramp = (t > 0.8) and GRN or YEL
  if abs(s + 0.5) < 0.09 then c:put(x, y, ramp[min(6, bidx[k] + 1)], btok)
  elseif abs(s) < 0.07 then c:put(x, y, ramp[min(6, bidx[k] + 1)], btok)
  elseif abs(s - 0.5) < 0.08 then c:put(x, y, ramp[max(1, bidx[k] - 1)], btok) end
end)
-- sugar spots: small irregular dark flecks on the yellow part
for _, q in ipairs{ { 17, 38, 2 }, { 21, 33, 1 }, { 15, 44, 1 }, { 27, 26, 2 }, { 24, 31, 1 }, { 33, 22, 1 }, { 19, 41, 1 }, { 30, 25, 1 }, { 14, 47, 1 }, { 23, 36, 1 } } do
  local x, y, s = q[1], q[2], q[3]
  if bm:has(x, y) then c:put(x, y, SPOT[2], btok) end
  if s == 2 and bm:has(x + 1, y) then c:put(x + 1, y, SPOT[1], btok) end
  if s == 2 and bm:has(x, y + 1) then c:put(x, y + 1, SPOT[2], btok) end
end
-- cool reflected light on the underside rim
bm:edge():each(function(x, y) local k = K(x, y) if BS[k] > 0.6 and BT[k] > 0.2 and BT[k] < 0.8 then c:put(x, y, COOL, btok) end end)
-- blossom-end nub: dry and dark
bm:each(function(x, y) local k = K(x, y) if BT[k] < 0.05 then c:put(x, y, BS[k] < 0 and SPOT[2] or SPOT[1], btok) end end)
c:put(10, 54, SPOT[1], btok) c:put(11, 54, SPOT[2], btok)
-- specular on the top face
local spk = A.specAt(bm, fn, 30)
local sx, sy = 19, 32
c:put(sx, sy, "#fffbe0", btok) c:put(sx + 1, sy - 1, "#fffbe0", btok) c:put(sx + 2, sy - 2, YEL[6], btok)

-- stalk with end grain
local stok = { r = { name = "stalk" } }
A.shade(c, sm, sn, STALK, { tok = stok, amb = 0.12, wrap = 0.3 })
-- fibre lines along the stalk
sm:each(function(x, y) local k = K(x, y) if abs(SS[k] - 0.35) < 0.15 and x % 3 ~= 0 then c:put(x, y, STALK[3], stok) end end)
-- cut end
for _, q in ipairs{ { 53, 11, "#d8c890" }, { 53, 12, "#e8dcaa" }, { 53, 13, "#c4b07a" }, { 54, 11, "#c4b07a" }, { 54, 12, "#a89464" }, { 54, 13, "#8c7a50" } } do
  c:put(q[1], q[2], q[3], stok)
end
c:put(53, 12, "#8c7a50", stok)  -- pith dot
c:put(54, 12, "#e8dcaa", stok)

-- quirk: twine wrapped round the stalk (twist), frayed end dangling
local ttok = { r = { name = "twine" } }
for y = 10, 16 do
  local x = 49 + ((y >= 14) and 0 or 0)
  if y >= 11 and y <= 15 then
    c:put(x, y, TW[(y % 2 == 0) and 3 or 2], ttok)
    c:put(x + 1, y, TW[(y % 2 == 0) and 2 or 1], ttok)
  end
end
c:put(49, 11, TW[4], ttok)
local dang = { { 50, 16 }, { 50, 17 }, { 51, 18 }, { 51, 19 }, { 51, 20 }, { 52, 21 }, { 52, 22 } }
for i, p in ipairs(dang) do c:put(p[1], p[2], TW[(i % 2 == 0) and 3 or 2], ttok) end
c:put(51, 23, TW[4], ttok) c:put(53, 23, TW[3], ttok) c:put(52, 23, TW[2], ttok)

A.save(c, NAME)
