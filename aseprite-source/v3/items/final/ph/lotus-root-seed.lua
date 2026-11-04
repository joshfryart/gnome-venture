-- lotus-root-seed (aC21_3, Opus single pass). Three dark, hard lotus nuts (ellipsoid, tiny apical nub, matte shell
-- with one glint) on a torn scrap of round lotus leaf (blue-green, waxy bloom, radial veins from a pale navel, curled
-- rim). The front-right nut has cracked: a slim prickly petiole rises to a small peltate pad (cupped, radial veins,
-- pale navel, upturned rim) and a rolled young leaf spirals up beside it.
-- quirk: a single bead of water sits on the pad (the lotus effect), with its own tiny contact shadow.
local NAME = "lotus-root-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local atan = math.atan
local c = A.new2(NAME)
local LEAF = { "#15363e", "#1d5450", "#2a7258", "#409263", "#69b270", "#a3d491" }
local BLOOM, NAVEL, FIBRE = "#c4e6c8", "#d9eeb0", "#b9d79a"
local SEED = { "#26171d", "#3d2526", "#573a2e", "#765337", "#9a7446", "#c6a06a" }
local DROP = { "#2a5a86", "#4a9cc0", "#8fd6dc", "#d2f6ee" }
local ltok, ptok, stok, rtok, dtok = { r = { name = "leaf" } }, { r = { name = "pad" } }, { r = { name = "stem" } }, { r = { name = "roll" } }, { r = { name = "drop" } }

-- seeds (cx, cy, rx, ry, angle)
local seeds = { { 21, 50, 4.6, 3.1, -0.35 }, { 30, 54, 4.4, 3.0, 0.15 }, { 40, 50, 4.2, 3.2, -1.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
local allSeeds = HP.mask() for _, s in ipairs(seeds) do allSeeds:add(s.m) end

-- leaf scrap: flattened disc, torn twice
local lm = c:ellipse(29, 53, 22, 7.5)
local torn = A.tear(lm, 52, 64, 44, 42, 1.4, 3)
torn:add(A.tear(lm, 17, 42, 5, 52, 1.2, 9))
local ln = X.pillow(lm, 2.6)
local bias = {}
X.ao(bias, lm, allSeeds, 1, -1)
for _, s in ipairs(seeds) do A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- radial veins from the navel (in un-foreshortened space)
local NX, NY = 17, 55
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local dx, dy = x - NX, (y - NY) * 2.5
  local r = sqrt(dx * dx + dy * dy)
  if r < 2 then c:put(x, y, NAVEL, ltok) return end
  local a = atan(dy, dx)
  local f = (a / 0.3) % 1
  if r > 3 and (f < 0.12 or f > 0.94) then
    local i = lidx[k] or 3
    c:put(x, y, LEAF[min(6, i + 1)], ltok)
  elseif r > 4 and lidx[k] and lidx[k] >= 4 and X.hash(x, y, 5) > 0.9 then
    c:put(x, y, BLOOM, ltok)        -- waxy bloom specks on the lit face
  end
end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, FIBRE, ltok) end end)
-- curled near rim: lower edge rolls under (deep row)
lm:edge():each(function(x, y) if not torn:has(x, y) and y > 55 then c:put(x, y, LEAF[2], ltok) end end)

-- petiole: slim, gently S-curved, prickly
local sp = { { 40, 47 }, { 43, 38 }, { 35, 29 }, { 37, 20 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.15 end)
sm:cut(seeds[3].m)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), LEAF, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = stok })
sm:each(function(x, y) local k = K(x, y)
  if (floor(ST[k] * 40) % 4 == 0) and SS[k] > 0.3 then c:put(x, y, LEAF[1], stok) end   -- prickle dots
end)

-- rolled young leaf (scroll) from the same nut, twisting up to the right
local rp = { { 43, 48 }, { 48, 42 }, { 50, 34 }, { 47, 27 } }
local rm, rn, RT, RS = A.tube(rp, function(t) return 1.7 * (1 - t) ^ 0.6 + 0.35 end)
rm:cut(seeds[3].m)
local ridx = X.tone(c, rm, X.light(rn, { amb = 0.12, wrap = 0.3 }), LEAF, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, tok = rtok })
rm:each(function(x, y) local k = K(x, y)
  local f = (RT[k] * 22 + RS[k] * 2.2) % 3
  if f < 0.7 then c:put(x, y, LEAF[max(1, (ridx[k] or 3) - 2)], rtok) end      -- spiral roll line
end)

-- peltate pad, seen from the side: cupped disc, wavy margin
local PX, PY = 37, 16
local pm = c:ellipse(PX, PY, 11.5, 4.2)
for _, q in ipairs{ { 26, 16 }, { 48, 15 }, { 30, 12 }, { 45, 19 } } do pm.s[K(q[1], q[2])] = nil end
local pn = X.pillow(pm, 2.2)
local pbias = {}
-- dish: the far (upper) inner half sits in shade of the near rim
pm:each(function(x, y) local k = K(x, y)
  if y > PY - 1 and y < PY + 3 and abs(x - PX) < 8 then pbias[k] = -1 end
end)
local pidx = A.toneN(c, pm, pn, LEAF, { bias = pbias, tok = ptok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.18, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - PX, (y - PY) * 2.6
  local r = sqrt(dx * dx + dy * dy)
  if r < 1.6 then c:put(x, y, NAVEL, ptok) return end
  local f = ((atan(dy, dx) + 0.15) / 0.52) % 1
  if r > 2.5 and (f < 0.1 or f > 0.95) then c:put(x, y, LEAF[min(6, (pidx[k] or 3) + 1)], ptok) end
end)
-- upturned rim: lit top lip, underside row along the front
pm:edge():each(function(x, y)
  if y <= PY - 2 then c:put(x, y, x < PX + 4 and LEAF[6] or LEAF[5], ptok)
  elseif y >= PY + 3 then c:put(x, y, LEAF[2], ptok) end
end)
-- ambient row where petiole meets the pad
for x = 36, 38 do c:put(x, PY + 5, LEAF[1], stok) end

-- quirk: water bead on the pad
local DX, DY = 32, 14
c:put(DX + 2, DY + 2, LEAF[1], ptok) c:put(DX + 1, DY + 2, LEAF[2], ptok) c:put(DX + 2, DY + 1, LEAF[2], ptok)
for _, q in ipairs{ { 0, 0, 3 }, { 1, 0, 3 }, { 0, 1, 2 }, { 1, 1, 1 }, { -1, 0, 3 }, { -1, 1, 2 }, { 0, -1, 4 }, { 1, -1, 3 } } do
  c:put(DX + q[1], DY + q[2], DROP[q[3]], dtok)
end
c:put(DX - 1, DY, A.CREAM, dtok)

-- seeds last: matte hard shells, apical nub, AO between neighbours, one glint each
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  X.ao(sb, s.m, sm, 1, 0)
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.1, wrap = 0.25 })
  s.m:each(function(x, y) local k = K(x, y)
    if idx[k] and idx[k] >= 3 and idx[k] <= 4 and X.hash(x, y, 11 + i) > 0.84 then c:put(x, y, SEED[idx[k] - 1], tok) end
  end)
  -- nub at the apex (along major axis, toward upper right)
  local ca, sa = cos(s[5]), sin(s[5])
  local dir = (ca + (-sa) * 0) >= 0 and 1 or -1
  local nx, ny = floor(s[1] + dir * ca * (s[3] + 1.3) + .5), floor(s[2] + dir * sa * (s[3] + 1.3) + .5)
  if not allSeeds:has(nx, ny) then c:put(nx, ny, SEED[2], tok) end
  local gx, gy = A.specAt(s.m, s.n, 30)
  c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, i == 2 and A.CREAM or SEED[6], tok)
end
-- crack on the sprouting nut where the shoots emerge
for _, q in ipairs{ { 40, 47 }, { 41, 48 }, { 42, 48 }, { 43, 49 } } do c:put(q[1], q[2], SEED[1], { r = { name = "seed3" } }) end
c:put(41, 47, "#9ccc78", stok)

A.save2(c, NAME)
