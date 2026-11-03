-- broken-fine-mesh-net (aB11_1, Opus single pass). Slim landing net: ash handle with a twisted twine grip and
-- pale end grain, a steam-bent ash hoop (torus-lit) lashed to the handle, and a linen mesh bag hanging below the
-- hoop: twine diamond lattice over the shadowed inside of the bag, darker toward the bottom. broken: the hoop is
-- cracked through on the upper right (gap + splinters, a flying splinter), and the bag is torn open at the bottom
-- with loose twine ends dangling. AO where hoop meets handle and under the rim. quirk: a tiny frog sits on the rim.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_1.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = D.start(debug.getinfo(1, "S").source)
local A, T, IN = D.ASH, D.TWINE, D.NETIN
local hx, hy, R = 36, 22, 11.5       -- hoop centre and mid radius

-- mesh bag: the hoop opening plus a sack hanging down-right below it
local bag = c:ellipse(hx, hy, 11, 11)
bag:add(D.tube({ { hx - 2, hy + 4 }, { hx + 1, hy + 14 }, { hx + 6, hy + 20 }, { hx + 10, hy + 22 } },
  function(t) return 8.5 * (1 - t) ^ 0.7 + 1.6 end))
-- tear at the bottom of the sack: a real notch
local tear = c:poly({ { hx + 5, hy + 25 }, { hx + 8, hy + 19 }, { hx + 10, hy + 21 }, { hx + 12, hy + 26 } })
bag:cut(tear)
local bn = X.pillow(bag, 4)
local bv = X.light(bn, { amb = 0.1, wrap = 0.3 })
D.paintMask(c, bag, function(x, y)
  local k = K(x, y)
  local v = bv[k]
  local depth = max(0, min(1, (y - (hy - 6)) / 26))
  local lat = ((x + y) % 4 == 0) or ((x - y) % 4 == 0)
  if lat then
    local i = floor(v * 4.2 + 2.6 - depth * 2.2)
    return T[max(1, min(6, i))]
  end
  local i = floor(v * 3 + 2.2 - depth * 2)
  if (x + y) % 4 == 2 and (x - y) % 4 == 2 then i = i - 1 end   -- knot shadows in the cell centres
  return IN[max(1, min(6, i))]
end)
-- dangling twine ends at the tear
for _, s in ipairs{ { { hx + 6, hy + 24 }, { hx + 6, hy + 27 } }, { { hx + 9, hy + 21 }, { hx + 10, hy + 24 } }, { { hx + 11, hy + 24 }, { hx + 13, hy + 27 } } } do
  local m = c:line(s, 1)
  m:each(function(x, y) c:px(x, y, (y % 2 == 0) and T[4] or T[3]) end)
end
c:px(hx + 6, hy + 28, T[5]) c:px(hx + 13, hy + 28, T[5])

-- handle (ash) with grain, behind the hoop joint
local hm, hT, hS = D.cyl(c, 10, 57, 27, 33, function(t) return 1.35 - 0.2 * t end, A)
local hl = sqrt(17 * 17 + 24 * 24)
hm:each(function(x, y) local k = K(x, y)
  if abs(hS[k] - 0.15) < 0.14 and X.hash(floor(hT[k] * hl / 4), 1, 5) > 0.4 then c:px(x, y, A[3]) end
end)
-- twisted twine grip (lower third)
local gm, gT, gS = D.cyl(c, 11, 55, 17, 47, function() return 1.85 end, T)
local gl = 10
gm:each(function(x, y) local k = K(x, y)
  local ph = (floor(gT[k] * gl * 1.4 + gS[k] * 1.6) % 3)
  if ph == 0 then c:px(x, y, gS[k] > 0.2 and T[1] or T[2]) elseif ph == 1 and gS[k] < 0 then c:px(x, y, T[6]) end
end)
-- pale end grain at the butt
c:px(9, 58, A[6]) c:px(10, 58, A[5]) c:px(9, 57, A[5])

-- hoop ring (torus normals) with a crack gap upper-right
local ring, rn = HP.mask(), {}
local crackA = -0.62
for y = hy - 14, hy + 14 do for x = hx - 14, hx + 14 do
  local dx, dy = x - hx, y - hy
  local d = sqrt(dx * dx + dy * dy)
  local rho = (d - R) / 1.35
  if abs(rho) <= 1 then
    local a = atan(dy, dx)
    if abs(a - crackA) > 0.06 then
      ring:set(x, y)
      local nr = max(-0.95, min(0.95, rho))
      rn[K(x, y)] = { dx / d * nr, dy / d * nr, sqrt(1 - nr * nr) }
    end
  end
end end
local rbias = {}
-- AO on the ring where it meets the handle lashing
ring:each(function(x, y) if (x - 27) ^ 2 + (y - 33) ^ 2 < 10 then rbias[K(x, y)] = -1 end end)
D.toneN(c, ring, rn, A, { bias = rbias, amb = 0.12, wrap = 0.3 })
-- grain flecks along the ring
ring:each(function(x, y)
  local d = sqrt((x - hx) ^ 2 + (y - hy) ^ 2)
  if abs(d - R) < 0.3 and X.hash(x, y, 3) > 0.7 then c:px(x, y, A[3]) end
end)
-- splinters at the crack (pale fresh wood)
local cx0, cy0 = hx + floor(cos(crackA) * R + 0.5), hy + floor(sin(crackA) * R + 0.5)
c:px(cx0 + 1, cy0 - 1, A[6]) c:px(cx0 + 2, cy0 - 1, A[5]) c:px(cx0 - 1, cy0 - 1, A[6])
c:px(cx0, cy0, A[2])
-- flying splinter (the chip)
c:px(cx0 + 5, cy0 - 4, A[6]) c:px(cx0 + 6, cy0 - 5, A[4]) c:px(cx0 + 7, cy0 - 5, A[3])

-- twine lashing where the hoop meets the handle
local lm, lT, lS = D.cyl(c, 25, 36, 29, 31, function() return 1.9 end, T)
lm:each(function(x, y) local k = K(x, y)
  if floor(lT[k] * 6.4 + lS[k] * 1.2) % 2 == 0 then c:px(x, y, lS[k] > 0 and T[2] or T[3]) end
end)

-- quirk: a tiny frog sitting on top of the rim
local fx, fy = hx - 4, 7
c:paint({
  ".e..e.",
  "egggge",
  "gglggd",
  ".gddd.",
}, fx, fy, { e = D.GREEN[5], g = D.GREEN[4], l = D.GREEN[6], d = D.GREEN[2] })
c:px(fx + 1, fy + 1, D.INK) c:px(fx + 4, fy + 1, D.INK)
c:px(fx + 3, fy + 2, D.GREEN[3])

D.fin(c)
