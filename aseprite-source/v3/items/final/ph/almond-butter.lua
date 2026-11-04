-- almond-butter (final, Opus). A slim glass jar of almond butter with a red cloth cap tied on with twine.
-- Glass: vertical-cylinder light, pale cool core, bright rim on the shoulder, a long specular streak on the left and a
-- cool reflected edge on the right; the butter shows through as a 6-tone roasted tan with ground-almond grain flecks
-- and an AO row where it meets the glass. The cloth cap is pillow-lit, has a diagonal weave, folds gathered under the
-- twine and a gold stitched hem; the twine twists and ends in a little loose loop. A kraft label carries an almond.
-- quirk: one drip of almond butter has escaped under the cloth and is crawling down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "almond-butter"
local c = A.new(NAME)

local GLASS  = { "#3e5878", "#5d86a6", "#8ab6cb", "#b5dbdf", "#d8f0ea", "#f0fbf4" }
local BUTTER = { "#4a2a20", "#704228", "#986234", "#bd8646", "#d9a862", "#efca8a" }
local CLOTH  = { "#561c36", "#86283e", "#bb3b47", "#df5c4d", "#f68968", "#ffbb96" }
local TWINE  = { "#6e4424", "#a86e34", "#d9a24c", "#f2cf7c" }
local KRAFT  = { "#b8946a", "#dcc196", "#f1e2bc", "#fff2d2" }
local NUT    = { "#5a3326", "#8a5634", "#b47a48" }
local GOLD   = "#f5b82e"

c:groundShadow(32, 56, 14, 2)

-- jar silhouette: body + shoulder + short neck (cloth covers the neck)
local JX0, JX1 = 21, 43
local body = c:rrect(JX0, 26, JX1, 55, 4)
body:add(c:rrect(JX0 + 1, 23, JX1 - 1, 28, 3))
local function cylN(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    local ny = 0
    if y > 53 then ny = (y - 53) * 0.35 end
    if y < 27 then ny = -(27 - y) * 0.25 end
    n[K(x, y)] = { A.norm(t, ny, sqrt(1 - t * t)) }
  end)
  return n
end
local gtok, btok = { r = { name = "glass" } }, { r = { name = "butter" } }
local butter = c:rrect(JX0 + 2, 29, JX1 - 2, 53, 2)
local glass = body:copy():cut(butter)
local gn = cylN(body, JX0, JX1)
local gv = X.light(gn, { amb = 0.2, wrap = 0.35 })
X.tone(c, glass, gv, GLASS, { cuts = { 0.12, 0.25, 0.42, 0.62, 0.84 }, tok = gtok })
-- butter seen through glass: same cylinder light, AO where it meets the glass wall and the top meniscus
local bb = {}
X.ao(bb, butter, glass, 1, -1)
butter:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.93 then bb[k] = (bb[k] or 0) + 1 elseif h < 0.06 then bb[k] = (bb[k] or 0) - 1 end   -- ground-almond grain
  if (y - 29) % 7 == 3 and abs(x - 32 - 3 * sin(y)) > 2 then bb[k] = (bb[k] or 0) - 1 end      -- settled layers
end)
local bv = X.light(gn, { amb = 0.02, wrap = 0.15 })
local bidx = X.tone(c, butter, bv, BUTTER, { cuts = { 0.12, 0.28, 0.46, 0.66, 0.86 }, bias = bb, tok = btok })
-- butter top: wavy meniscus with a lit lip
for x = JX0 + 3, JX1 - 3 do
  local yy = 29 + ((x % 5 == 0 or x % 5 == 1) and 0 or 0)
  c:put(x, 29, BUTTER[x < 32 and 6 or 5], btok)
  if x % 6 == 2 then c:put(x, 28, BUTTER[5], btok) end
end
-- glass specular streak (left) + short second streak + cool reflected edge (right)
for y = 31, 50 do c:put(JX0 + 2, y, GLASS[6], gtok) if y > 33 and y < 46 then c:put(JX0 + 3, y, GLASS[5], gtok) end end
for y = 36, 40 do c:put(JX0 + 5, y, GLASS[5], gtok) end
for y = 30, 52 do c:put(JX1 - 1, y, GLASS[4], gtok) end
-- glass base: thick bottom, pale lens line
for x = JX0 + 3, JX1 - 3 do c:put(x, 54, GLASS[3], gtok) end
for x = JX0 + 4, JX0 + 9 do c:put(x, 54, GLASS[5], gtok) end
-- shoulder rim highlight
for x = JX0 + 3, JX0 + 8 do c:put(x, 26, GLASS[6], gtok) end

-- label: kraft paper band with a drawn almond
local ktok = { r = { name = "label" } }
local lab = c:rect(JX0 + 4, 36, JX1 - 4, 46)
local ln = cylN(lab, JX0, JX1)
X.tone(c, lab, X.light(ln, { amb = 0.3, wrap = 0.4 }), KRAFT, { cuts = { 0.3, 0.55, 0.78 }, tok = ktok })
for x = JX0 + 4, JX1 - 4 do c:put(x, 36, KRAFT[4], ktok) c:put(x, 46, KRAFT[1], ktok) end
for y = 37, 45 do c:put(JX0 + 4, y, KRAFT[3], ktok) end
for x = JX0 + 6, JX1 - 6 do c:put(x, 38, CLOTH[3], ktok) c:put(x, 44, CLOTH[3], ktok) end
-- torn notch on the label's lower-left corner
c:put(JX0 + 4, 46, BUTTER[2], btok) c:put(JX0 + 5, 46, BUTTER[3], btok)
-- almond drawing
local aux, auy = A.norm(0.8, -0.6, 0)
local am, amn = A.almond(32, 41, aux, auy, 5.4, 2.9, 0.8)
A.shade(c, am, amn, { NUT[1], NUT[1], NUT[2], NUT[2], NUT[3], NUT[3] }, { amb = 0.1, tok = ktok })
c:put(29, 42, KRAFT[4], ktok) c:put(30, 41, NUT[3], ktok)

-- cloth cap: dome over the lid + flared skirt with a zig-zag pinked hem
local cap = c:ellipse(32, 16.5, 10.5, 5.5):add(c:rect(22, 17, 42, 22))
local skirt = c:poly{ { 21, 20 }, { 43, 20 }, { 47, 27 }, { 17, 27 } }
for x = 17, 47 do if (x % 3) == 0 then skirt:cut(c:rect(x, 27, x, 27)) end end
cap:add(skirt)
cap:cut(c:rect(0, 20, 63, 21))     -- twine band goes here
local ctok = { r = { name = "cloth" } }
local cn = X.pillow(cap, 4)
local cb = {}
X.ao(cb, cap, c:rect(18, 20, 46, 21), 1, -1)
cap:each(function(x, y) local k = K(x, y)
  local g = (((x - 20) // 3) % 2 == 0 and 1 or 0) + (((y - 10) // 3) % 2 == 0 and 1 or 0)
  cb[k] = (cb[k] or 0) + (1 - g)                                    -- gingham checks
  if g == 1 and (x + y) % 2 == 0 then cb[k] = cb[k] - 1 end          -- weave on the half-tone bands
  if y > 21 and ((x - 32) % 5 == 0) then cb[k] = (cb[k] or 0) - 1 end   -- gathered folds in the skirt
end)
local cidx = A.shade(c, cap, cn, CLOTH, { amb = 0.1, wrap = 0.3, bias = cb, tok = ctok })
-- gold stitched hem (2 on, 1 off) just above the pinked edge
local st = 0
for x = 19, 45 do st = st + 1 if st % 3 ~= 0 and cap:has(x, 25) then c:put(x, 25, GOLD, ctok) end end
-- cloth pop
c:put(25, 14, CLOTH[6], ctok) c:put(26, 14, CLOTH[6], ctok)

-- twine: twisted band round the neck, loose loop + tail on the right
local ttok = { r = { name = "twine" } }
for x = 20, 44 do
  for y = 20, 21 do
    local ph = (x + (y - 20) * 2) % 4
    c:put(x, y, ph == 0 and TWINE[1] or (ph == 1 and TWINE[2] or (y == 20 and TWINE[4] or TWINE[3])), ttok)
  end
end
-- knot + loop + tail
local loop = { { 45, 20 }, { 46, 19 }, { 47, 18 }, { 48, 18 }, { 49, 19 }, { 49, 20 }, { 48, 21 }, { 47, 21 }, { 46, 21 } }
for i, p in ipairs(loop) do c:put(p[1], p[2], i % 2 == 0 and TWINE[2] or TWINE[3], ttok) end
for i, p in ipairs{ { 45, 22 }, { 46, 23 }, { 46, 24 }, { 47, 25 }, { 47, 26 } } do c:put(p[1], p[2], i % 2 == 0 and TWINE[2] or TWINE[3], ttok) end
c:put(45, 21, TWINE[1], ttok) c:put(44, 20, TWINE[4], ttok)

-- quirk: drip of almond butter crawling down the glass from under the hem
local dtok = { r = { name = "drip" } }
local drip = { { 37, 28, 5 }, { 38, 28, 4 }, { 37, 29, 5 }, { 38, 29, 3 }, { 37, 30, 4 }, { 38, 30, 3 }, { 37, 31, 4 }, { 38, 31, 2 },
  { 37, 32, 4 }, { 38, 32, 2 }, { 37, 33, 4 }, { 38, 33, 2 }, { 37, 34, 4 }, { 38, 34, 2 }, { 37, 35, 3 }, { 38, 35, 2 }, { 37, 36, 4 }, { 38, 36, 3 }, { 37, 37, 4 }, { 38, 37, 2 },
  { 36, 38, 5 }, { 37, 38, 4 }, { 38, 38, 3 }, { 39, 38, 2 }, { 36, 39, 4 }, { 37, 39, 3 }, { 38, 39, 2 }, { 39, 39, 1 }, { 37, 40, 2 }, { 38, 40, 1 }, { 37, 41, 'KR' }, { 38, 41, 'KR' } }
for _, p in ipairs(drip) do if p[3] == 'KR' then c:put(p[1], p[2], KRAFT[1], ktok) else c:put(p[1], p[2], BUTTER[p[3]], dtok) end end
c:put(36, 38, BUTTER[6], dtok)

A.save(c, NAME)
