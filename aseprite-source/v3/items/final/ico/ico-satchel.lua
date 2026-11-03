-- ico-satchel (final, Opus single pass). Slim leather satchel: tall arched shoulder strap (3-4 px, edge-creased),
-- boxy body with pillowed leather, front flap with rounded corners and a gold hem stitch, AO under the flap lip,
-- a narrow centre strap through a bevelled brass buckle (bright edge, dark hole, prong). Ground shadow (it stands).
-- quirk: a sprig of lavender poking out from under the flap on the right.
local NAME = "ico-satchel"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_2.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, floor, max, min, sqrt, sin, cos, pi = math.abs, math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEA = { "#3d2024", "#5c2f28", "#80432d", "#a35d35", "#c47c45", "#e3a263" }
local STR = { "#351c22", "#512a26", "#73402c", "#955733", "#b67240", "#d6955a" }
local BR = { "#5a3220", "#8f531f", "#c27d22", "#e5a92e", "#f8d258", "#fff0a8" }
local LAV = { "#3c2a6a", "#5c45a0", "#8a6fd0", "#b49af0" }
local STEM = { "#2e6a48", "#4f9a55", "#86c46a" }

c:groundShadow(32, 56, 19, 2)

-- shoulder strap (behind the body)
local sm, sn, ST, SS = A.tube({ { 20, 34 }, { 17, 2 }, { 47, 2 }, { 44, 34 } }, function(t) return 1.75 end)
local stok = A.tok("strap")
local sidx = A.shade(c, sm, sn, STR, { tok = stok })
sm:each(function(x, y) local k = K(x, y)
  -- crease line along the strap middle (leather edge fold)
  if abs(SS[k]) < 0.12 then A.step(c, sidx, STR, x, y, -1, stok) end
end)

-- body
local body = c:rrect(15, 25, 49, 54, 5)
local bn = A.bulge(X.pillow(body, 4), 26, 30, 22, 30, 0.55)
local btok = A.tok("body")
local flap = HP.mask()
for y = 22, 41 do for x = 15, 49 do
  local ok = true
  local r = 8
  if y > 41 - r then
    local dy = y - (41 - r)
    if x < 15 + r then local dx = (15 + r) - x ok = dx * dx + dy * dy <= r * r + 2 end
    if x > 49 - r then local dx = x - (49 - r) ok = dx * dx + dy * dy <= r * r + 2 end
  end
  if y == 22 and (x < 18 or x > 46) then ok = false end
  if y == 23 and (x < 16 or x > 48) then ok = false end
  if ok then flap:set(x, y) end
end end
local bb = {}
A.cast(bb, body, flap, 0, 2, -2)
A.cast(bb, body, flap, 0, 1, -1)
-- lower body: slight bulge from the seam
body:each(function(x, y) local k = K(x, y) bb[k] = (bb[k] or 0) - 1 + (y >= 52 and -1 or 0) end)
local bidx = A.shade(c, body, bn, LEA, { tok = btok, bias = bb })
-- side gussets: darker vertical fold lines near the edges
for y = 30, 52 do
  A.step(c, bidx, LEA, 17, y, -1, btok)
  A.step(c, bidx, LEA, 47, y, -1, btok)
end
-- bottom seam row
for x = 18, 46 do A.step(c, bidx, LEA, x, 51, -1, btok) end

-- quirk: lavender sprig behind the flap at the right, drawn before the flap so the flap covers its foot
local ltok = A.tok("lavender")
for i, p in ipairs{ { 44, 24 }, { 45, 23 }, { 45, 22 }, { 46, 21 }, { 46, 20 }, { 47, 19 }, { 47, 18 } } do
  c:put(p[1], p[2], STEM[i < 4 and 1 or 2], ltok) c:put(p[1] + 1, p[2], STEM[i < 4 and 2 or 3], ltok)
end
for i, b in ipairs{ { 48, 13, 4 }, { 47, 14, 3 }, { 49, 14, 3 }, { 48, 15, 3 }, { 47, 16, 2 }, { 49, 16, 3 }, { 48, 17, 2 }, { 46, 17, 2 }, { 49, 18, 2 }, { 48, 12, 4 } } do
  c:put(b[1], b[2], LAV[b[3]], ltok)
end
c:put(47, 15, LAV[3], ltok) c:put(48, 14, LAV[4], ltok) c:put(48, 16, LAV[2], ltok) c:put(47, 18, LAV[1], ltok)
-- a leaf off the stem
c:put(43, 20, STEM[2], ltok) c:put(44, 20, STEM[3], ltok) c:put(42, 19, STEM[2], ltok)

-- flap
local fn = A.bulge(X.pillow(flap, 3), 24, 22, 22, 26, 0.6)
local ftok = A.tok("flap")
local fb = {}
local fidx = A.shade(c, flap, fn, LEA, { tok = ftok, bias = fb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- flap lip: bright edge row along the bottom curve, then the stitch inset
flap:edge():each(function(x, y) if y >= 36 and not flap:has(x, y + 1) then A.step(c, fidx, LEA, x, y, 1, ftok) end end)
-- fold where the flap bends over the top
for x = 18, 46 do A.step(c, fidx, LEA, x, 25, -1, ftok) end
for x = 19, 45 do A.step(c, fidx, LEA, x, 24, 1, ftok) end
c:stitch{ { 18, 28 }, { 18, 34 }, { 20, 36 }, { 24, 38 }, { 40, 38 }, { 44, 36 }, { 46, 34 }, { 46, 28 } }
-- leather scuffs (grain): a few pale and dark nicks
for _, p in ipairs{ { 20, 31, 1 }, { 21, 31, 1 }, { 39, 29, -1 }, { 24, 46, 1 }, { 41, 49, -1 }, { 42, 49, -1 }, { 19, 44, 1 } } do
  if flap:has(p[1], p[2]) then A.step(c, fidx, LEA, p[1], p[2], p[3], ftok) else A.step(c, bidx, LEA, p[1], p[2], p[3], btok) end
end

-- centre strap: from inside the flap down onto the body
local cs = c:rect(29, 33, 34, 50)
local cb = {}
cs:each(function(x, y) if y >= 42 and y <= 43 then cb[K(x, y)] = -1 end end)
local cn = X.pillow(cs, 2)
local ctok = A.tok("cstrap")
local cidx = A.shade(c, cs, cn, STR, { tok = ctok, bias = cb })
-- strap end: rounded tip
c.pix[50 * 64 + 29], c.own[50 * 64 + 29] = nil, nil
c.pix[50 * 64 + 34], c.own[50 * 64 + 34] = nil, nil
A.step(c, bidx, LEA, 29, 50, 0, btok) A.step(c, bidx, LEA, 34, 50, 0, btok)
-- contact shadow right of the strap on the body
for y = 43, 50 do A.step(c, bidx, LEA, 35, y, -2, btok) end
for x = 30, 35 do A.step(c, bidx, LEA, x, 51, -2, btok) end
-- strap holes
c:put(31, 47, STR[1], ctok) c:put(32, 47, STR[1], ctok)

-- brass buckle: square ring with bevel, dark eye, prong
local bk = c:rrect(27, 36, 36, 43, 1)
local hole = c:rect(29, 38, 34, 41)
bk:cut(hole)
local kn = X.pillow(bk, 1.6)
local ktok = A.tok("buckle")
local kidx = A.shade(c, bk, kn, BR, { tok = ktok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 } })
-- hole shows the strap in deep shadow
hole:each(function(x, y) c:put(x, y, y == 38 and STR[1] or STR[2], ctok) end)
-- prong crossing the hole
for x = 29, 33 do c:put(x, 40, x == 29 and BR[2] or BR[4], ktok) end
c:put(33, 39, BR[5], ktok)
-- specular on the top-left bevel
c:put(28, 37, BR[6], ktok) c:put(29, 37, BR[6], ktok)
A.step(c, kidx, BR, 35, 42, -1, ktok)
-- cream sparkle on the buckle corner
c:put(27, 36, A.CREAM, ktok)

A.save(c, NAME)
