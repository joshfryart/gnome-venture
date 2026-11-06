-- ico-cat (final pass, Opus). Ginger tabby sitting upright, face to the viewer: round head with tall ears (pink
-- inner ear), cream muzzle and bib, slim front legs with cream sock paws, rear haunch, long tail curling up the
-- right side. Fur: per-pixel light (sphere head, pillow body), 6-tone ginger with cool-violet shade, tabby
-- M-mark, cheek and haunch stripes, banded tail, strand flecks; AO under the chin and where legs meet the body.
-- Face: 2x3 ink pills with glints, pink nose with a dark underside and glint, ink mouth.
-- quirk: a tiny pink tongue blep.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-cat")
local FUR = { "#5c2830", "#8e3c2e", "#c25d2c", "#e5853a", "#f6ad5a", "#ffd590" }
local CRM = { "#8c6a72", "#c29e92", "#e6c9b2", "#f7e4c8", "#fff4d6" }
local EAR = { "#c94f84", "#f5809f" }
local ftok, ctok = A.tok("fur"), A.tok("cream")

c:groundShadow(33, 56, 17, 1.5)

-- tail first (body paints over its root)
local tp = { { 38, 53 }, { 50, 56 }, { 55, 44 }, { 51, 33 } }
local tm, tn, TT = A.tube(tp, function(t) return 2.3 - t * 0.5 end)
local tidx = A.shade(c, tm, tn, FUR, { tok = ftok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 } })
tm:each(function(x, y) local t = TT[K(x, y)]
  if t > 0.25 and (t * 9) % 1 < 0.28 then A.step(c, tidx, FUR, x, y, -2, ftok) end
  if t > 0.9 then A.set(c, tidx, FUR, x, y, min(6, tidx[K(x, y)] + 1), ftok) end
end)

-- body: pear, haunch, legs
local body = A.ell(31, 44, 10, 11)
body:add(A.ell(31, 35, 7.5, 6))
body:clip(A.fn(0, 0, 63, 54, function() return true end))
local haunch = A.ell(37, 47.5, 6.5, 7)
haunch:clip(A.fn(0, 0, 63, 54, function() return true end))
local bidx = A.shade(c, body, X.pillow(body, 6), FUR, { tok = ftok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
local hn = X.sphere(36, 46, 7.5, haunch)
local hidx = A.shade(c, haunch, hn, FUR, { tok = ftok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
for k, v in pairs(hidx) do bidx[k] = v end
-- haunch crease: deep line where thigh meets belly (left edge of haunch)
haunch:each(function(x, y) if not haunch:has(x - 1, y) and y < 52 then A.step(c, bidx, FUR, x, y, -2, ftok) end end)
-- haunch stripes (curved arcs following the thigh)
haunch:each(function(x, y)
  local d = sqrt((x - 39)^2 + (y - 46)^2)
  if d > 2 and (d % 3.2) < 0.9 and x > 34 and y < 52 then A.step(c, bidx, FUR, x, y, -1, ftok) end
end)
-- side stripes on the back
body:each(function(x, y)
  if x <= 26 and y > 33 and y < 50 and (y + floor((26 - x) / 2)) % 5 == 0 then A.step(c, bidx, FUR, x, y, -1, ftok) end
end)
-- cream bib
local bib = A.ell(29.5, 37.5, 4.5, 6.5)
local bbidx = A.shade(c, bib, X.pillow(bib, 4), CRM, { tok = ctok, cuts = { 0.2, 0.42, 0.62, 0.86 } })
-- front legs with sock paws
local legs = {}
for i, lx in ipairs{ 24, 29 } do
  local m = A.fn(lx, 41, lx + 3, 54, function(x, y) return not (y == 54 and (x == lx or x == lx + 3)) end)
  local idx = A.shade(c, m, A.vcyl(m, lx, lx + 3), FUR, { tok = ftok, cuts = { 0.16, 0.34, 0.5, 0.66, 0.84 } })
  -- paw socks
  local paw = A.fn(lx, 51, lx + 3, 54, function(x, y) return m:has(x, y) end)
  local pidx = A.shade(c, paw, A.vcyl(paw, lx, lx + 3, -0.3), CRM, { tok = ctok, cuts = { 0.2, 0.42, 0.62, 0.86 } })
  c:put(lx + 1, 54, CRM[2], ctok) c:put(lx + 2, 54, CRM[1], ctok) -- toe split
  -- AO at the shoulder (top of leg tucks into bib/body)
  for x = lx, lx + 3 do A.step(c, idx, FUR, x, 41, -1, ftok) end
  -- inner separation line between the two legs / body
  for y = 42, 50 do A.step(c, idx, FUR, lx + 3, y, -1, ftok) end
  legs[i] = m
end
for y = 42, 54 do if not legs[1]:has(28, y) then c:put(28, y, FUR[1], ftok) end end

-- head
local head = A.ell(30, 22, 10.5, 8)
head:add(A.ell(30, 25.5, 11.5, 4.5))
local ears = HP.mask()
local earL = c:poly{ { 20, 19 }, { 21, 8 }, { 28, 15 } }
local earR = c:poly{ { 32, 15 }, { 39, 8 }, { 40, 19 } }
ears:add(earL):add(earR)
local eidx = A.shade(c, ears, A.plane(ears, { 0, -0.3, 1 }, 1.4), FUR, { tok = ftok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 } })
A.fn(21, 11, 26, 18, function(x, y) return earL:shrink(1):has(x, y) and y >= 12 end):each(function(x, y)
  c:put(x, y, (x + y) % 5 == 0 and EAR[1] or EAR[2], ftok) end)
A.fn(33, 11, 38, 18, function(x, y) return earR:shrink(1):has(x, y) and y >= 12 end):each(function(x, y)
  c:put(x, y, x >= 37 and EAR[1] or EAR[2], ftok) end)
local hidx2 = A.shade(c, head, X.sphere(29, 21, 11.5, head), FUR, { tok = ftok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 } })
-- AO under the chin onto bib/body
local chin = head:copy()
bib:each(function(x, y) if chin:has(x, y - 1) then A.step(c, bbidx, CRM, x, y, -2, ctok) elseif chin:has(x, y - 2) then A.step(c, bbidx, CRM, x, y, -1, ctok) end end)
body:each(function(x, y) if not bib:has(x, y) and chin:has(x, y - 1) then A.step(c, bidx, FUR, x, y, -1, ftok) end end)
-- tabby M-mark on the forehead and cheek stripes
for _, p in ipairs{ { 27, 15 }, { 27, 16 }, { 30, 14 }, { 30, 15 }, { 30, 16 }, { 33, 15 }, { 33, 16 }, { 28, 17 }, { 32, 17 } } do
  A.step(c, hidx2, FUR, p[1], p[2], -2, ftok) end
for _, p in ipairs{ { 19, 24 }, { 20, 24 }, { 21, 24 }, { 19, 26 }, { 20, 26 }, { 39, 24 }, { 40, 24 }, { 41, 24 }, { 40, 26 }, { 41, 26 } } do
  A.step(c, hidx2, FUR, p[1], p[2], -2, ftok) end
-- strand flecks
head:each(function(x, y) if X.hash(x, y, 3) < 0.07 then A.step(c, hidx2, FUR, x, y, 1, ftok) end end)
body:each(function(x, y) if X.hash(x, y, 9) < 0.06 then A.step(c, bidx, FUR, x, y, 1, ftok) end end)
-- muzzle
local muz = A.ell(30, 26, 4.5, 2.8)
A.shade(c, muz, X.pillow(muz, 2.5), CRM, { tok = ctok, cuts = { 0.18, 0.4, 0.6, 0.84 } })
-- eyes (2x3 ink pills with glint), a touch of green iris above
c:eyeSmall(25, 20) c:eyeSmall(34, 20)
-- nose: pink, dark underside, glint
A.map(c, { "pPp", ".d." }, 29, 23, { p = "#f5809f", P = "#ff9ab4", d = "#a83e6c" })
c:put(30, 23, "#ffd6e2")
-- mouth
A.map(c, { ".k.", "k.k" }, 29, 25, { k = "#2b1c26" })
c:put(28, 25, "#2b1c26") c:put(32, 25, "#2b1c26")
-- quirk: tongue blep
A.map(c, { "T", "t" }, 30, 26, { t = "#f0607f", T = "#ffaabd" })
-- cheek blush
c:cheek(21, 23) c:cheek(38, 23)
-- whisker dots
c:put(27, 26, CRM[2]) c:put(34, 26, CRM[2])
-- fur pop on the crown
c:put(25, 16, FUR[6]) c:put(26, 16, FUR[6])

A.save(c, "ico-cat")
