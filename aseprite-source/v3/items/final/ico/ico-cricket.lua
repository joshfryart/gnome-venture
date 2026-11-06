-- ico-cricket (final, Opus). A field cricket in side view facing right: round head with a big amber eye, a saddle
-- shaped pronotum, a long slim body under folded wings, two cerci trailing behind, a powerful club-shaped jumping
-- leg folded along the side with a thin spined shin, two slim walking legs, and long antennae swept back.
-- Material: pillow/dome normals snapped to 6-tone chestnut (body) and umber (wing) ramps, wing veins (long ribs plus
-- the diagonal "harp" veins) with a lit vein edge, bevelled pronotum rim, herringbone chevrons on the femur, abdomen
-- segment rings below the wing, AO under the wing edge and where legs join, glossy specular on head and femur.
-- quirk: a single dewdrop is hanging off the tip of one antenna.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-cricket")
local BODY = { "#3a1a1c", "#5e2a24", "#86402a", "#ad5e34", "#d08244", "#f0b066" }
local WING = { "#241620", "#36222a", "#4c302e", "#664234", "#85583c", "#a8744a" }
local VEIN = "#f0bc64"
local LEGR = { "#4a2a20", "#7a4a2c", "#a8703c", "#d09a56", "#f0c482" }
local ANT  = { "#5a3a28", "#9a6a3e" }
local DEW  = { "#3a86b0", "#7ccfd8", "#c8f4ec", "#fff4d6" }
local EYEG = "#f2b632"
local tB, tW, tL, tA, tD = A.tok("body"), A.tok("wing"), A.tok("leg"), A.tok("ant"), A.tok("dew")
local cuts6 = { 0.18, 0.34, 0.5, 0.66, 0.84 }

-- antennae (thin, drawn first so the head covers their roots)
local function strand(p, cols, tok)
  local last
  for i = 0, 80 do
    local t = i / 80
    local x, y = A.bez(p, t)
    local xi, yi = floor(x + 0.5), floor(y + 0.5)
    local key = xi * 100 + yi
    if key ~= last then c:put(xi, yi, t < 0.5 and cols[1] or cols[2], tok) last = key end
  end
end
strand({ { 49, 26 }, { 45, 14 }, { 34, 9 }, { 22, 11 } }, { ANT[1], ANT[2] }, tA)
strand({ { 51, 26 }, { 52, 15 }, { 46, 8 }, { 38, 6 } }, { ANT[1], ANT[2] }, tA)
-- cerci
strand({ { 14, 32 }, { 11, 31 }, { 8, 29 }, { 6, 28 } }, { BODY[3], BODY[2] }, tB)
strand({ { 14, 34 }, { 11, 35 }, { 8, 36 }, { 6, 37 } }, { BODY[3], BODY[2] }, tB)

-- walking legs (near side): front and mid
local function leg(p, w0, w1, w2)
  local m1, n1 = A.seg(p[1][1], p[1][2], p[2][1], p[2][2], w0, w1)
  local m2, n2 = A.seg(p[2][1], p[2][2], p[3][1], p[3][2], w1, w2)
  local m3, n3 = A.seg(p[3][1], p[3][2], p[4][1], p[4][2], 0.8, 0.7)
  return m1:add(m2):add(m3), A.merge(A.merge(n1, n2), n3), { floor(p[2][1] + 0.5), floor(p[2][2] + 0.5) }
end
local fm, fn, fk = leg({ { 44, 35 }, { 46, 41 }, { 49, 45 }, { 52, 45 } }, 1.5, 1.3, 1.1)
local mm, mn, mk = leg({ { 37, 36 }, { 34, 42 }, { 31, 46 }, { 28, 46 } }, 1.5, 1.3, 1.1)

-- body parts
local abd = A.ell(25, 34, 11.5, 3.4)
local wing = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  -- folded wings: long lozenge, flat bottom edge, rounded rear tip
  local dx, dy = (x - 26) / 13, (y - 28.6) / 4.3
  if dx * dx + dy * dy * (dx < 0 and 1 or 1.15) <= 1 and y <= 32 then wing:set(x, y) end
end end
local pro = HP.mask()
for y = 24, 36 do for x = 36, 45 do
  local dx, dy = (x - 40.5) / 5.2, (y - 30) / 6.2
  if dx ^ 4 + dy ^ 2 <= 1 then pro:set(x, y) end
end end
local head = A.ell(47.5, 30, 4.8, 5.4)

-- abdomen
local an = X.pillow(abd, 2.4)
local ab = {}
X.ao(ab, abd, wing, 2, -1)
local aidx = A.shade(c, abd, an, BODY, { tok = tB, bias = ab, cuts = cuts6 })
-- segment rings
abd:each(function(x, y) if (x % 3 == 0) and y > 33 and x < 36 then A.step(c, aidx, BODY, x, y, -1, tB) end end)
-- wings
local wn = X.pillow(wing, 2.0)
local wb = {}
local widx = A.shade(c, wing, wn, WING, { tok = tW, bias = wb, amb = 0.0, wrap = 0.1, tilt = { 26, 28, 13, 0.15 }, cuts = cuts6 })
-- long rib along the wing (lit) + harp veins (diagonal) + lit upper edge
wing:each(function(x, y)
  local k = K(x, y)
  if y == 27 and x > 16 and x < 37 then c:put(x, y, VEIN, tW)
  elseif y > 27 and y < 32 and (x + y) % 4 == 0 and x > 18 and x < 36 then c:put(x, y, WING[6], tW)
  elseif y < 27 and (x - y) % 6 == 0 and x > 14 and x < 34 then A.step(c, widx, WING, x, y, 1, tW) end
end)
wing:edge():each(function(x, y) if not wing:has(x, y - 1) and x < 34 then c:put(x, y, WING[6], tW) end end)
-- pronotum (saddle) with a bevelled rim
local pn = X.pillow(pro, 2.2)
local pb = {}
X.ao(pb, pro, head, 1, -1)
local pidx = A.shade(c, pro, pn, BODY, { tok = tB, bias = pb, cuts = cuts6 })
pro:each(function(x, y) if not pro:has(x, y + 1) or not pro:has(x, y + 2) then A.step(c, pidx, BODY, x, y, -1, tB) end end)
-- shadow line where the pronotum overlaps the wing
wing:each(function(x, y) if pro:has(x + 1, y) and not pro:has(x, y) then A.step(c, widx, WING, x, y, -2, tW) end end)
-- head
local hn = X.sphere(47.5, 30, 5.2, head)
local hidx = A.shade(c, head, hn, BODY, { tok = tB, cuts = { 0.22, 0.4, 0.58, 0.76, 0.92 }, amb = 0.05 })
-- eye (amber ring, 2x3 ink pill, glint)
do
  local ex, ey = 47, 26
  local rows = { ".gg.", "gcKg", "gKKg", "gKKg", ".gg." }
  for j, row in ipairs(rows) do for i = 1, 4 do local ch = row:sub(i, i)
    local col = ch == "g" and EYEG or ch == "K" and A.INK or ch == "c" and A.CREAM or nil
    if col then c:put(ex + i - 1, ey + j - 1, col, tB) end end end
end
-- mouth: mandible + a clear little mouth line
c:put(49, 33, A.INK, tB) c:put(50, 33, A.INK, tB) c:put(51, 32, A.INK, tB)
c:put(52, 35, LEGR[3], tB) c:put(51, 35, LEGR[2], tB) c:put(52, 36, LEGR[2], tB)
-- head specular
c:put(45, 27, BODY[6], tB) c:put(45, 28, A.CREAM, tB)

-- near walking legs
for _, L in ipairs{ { fm, fn, fk }, { mm, mn, mk } } do
  local lb = {}
  X.ao(lb, L[1], A.union{ abd, pro, head }, 1, -1)
  lb[K(L[3][1], L[3][2])] = (lb[K(L[3][1], L[3][2])] or 0) - 1
  A.shade(c, L[1], L[2], LEGR, { tok = tL, bias = lb, cuts = { 0.2, 0.4, 0.6, 0.8 } })
end

-- hind leg: club-shaped femur folded along the side, thin spined tibia, tarsus
local FA, FB = { 31, 37 }, { 12, 23 }
local femM, femN, femT, femS = A.seg(FA[1], FA[2], FB[1], FB[2], 2.4, 1.2)
local tibM, tibN = A.seg(FB[1], FB[2], 17, 46, 1.25, 1.0)
local tarM, tarN = A.seg(17, 46, 23, 47, 0.9, 0.8)
local tb = {}
X.ao(tb, tibM, femM, 1, -1)
A.shade(c, tibM:copy():add(tarM), A.merge(A.merge({}, tibN), tarN), LEGR, { tok = tL, bias = tb, cuts = { 0.2, 0.4, 0.6, 0.8 } })
-- tibia spines on the back edge
for _, p in ipairs{ { 12, 29 }, { 13, 34 }, { 14, 39 } } do c:put(p[1], p[2], LEGR[1], tL) end
local fb = {}
local FEM = { BODY[3], BODY[4], BODY[5], BODY[6], LEGR[4], LEGR[5] }
local fidx = A.shade(c, femM, femN, FEM, { tok = tL, bias = fb, cuts = cuts6 })
-- herringbone chevrons on the femur
femM:each(function(x, y) local k = K(x, y) local t, s = femT[k], femS[k]
  if t and t > 0.12 and t < 0.85 then
    local v = (t * 21.5 + abs(s) * 1.6) % 3
    if v < 0.7 then c:put(x, y, (fidx[k] or 3) >= 4 and BODY[4] or BODY[2], tL) end
  end end)
-- femur gloss
c:put(24, 30, LEGR[5], tL) c:put(23, 30, LEGR[5], tL) c:put(23, 29, A.CREAM, tL)
-- knee: dark joint
c:put(12, 23, LEGR[1], tL) c:put(13, 24, LEGR[1], tL)

-- quirk: a dewdrop hanging off the tip of the upper antenna
do
  local dx, dy = 37, 8
  local dm = A.ell(dx, dy, 1.6, 1.8)
  local dn = X.sphere(dx, dy, 1.8, dm)
  A.shade(c, dm, dn, DEW, { tok = tD, amb = 0.2, wrap = 0.4, cuts = { 0.3, 0.6, 0.85 } })
  c:put(dx - 1, dy - 1, A.CREAM, tD)
  c:put(dx + 1, dy + 1, DEW[1], tD)
end

A.save(c, "ico-cricket")
