-- mulberry-jam (final, Opus single pass). A slim, tall glass jar of glossy deep-purple jam: cylinder-lit jam with a
-- pale air gap under the shoulder, glass rim highlights (bright left streak, thin right streak, thick pale base),
-- a lilac gingham cloth cap with diagonal weave, scalloped skirt and fold shadows, tied with twisted twine and a
-- bow, a parchment label with a tiny drawn mulberry, 2-tone ground shadow.
-- quirk: a fat drip of jam has escaped under the cloth and runs down the glass shoulder.
local NAME = "mulberry-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local JAM = { "#1f0c26", "#371238", "#561c4e", "#7a2a62", "#a2407a", "#c86c98" }
local GLASS = { "#5d6f8c", "#93a8c0", "#c6d8e4", "#eaf4f6" }
local CLOTH = { "#4a3470", "#6a4f9a", "#8e74c0", "#b6a0dc", "#d8c8f0", "#f2eafc" }
local TWINE = { "#6a3e24", "#9a6436", "#c8924e", "#e8c27a" }
local PAPER = { "#a88a62", "#d8c296", "#f0e2bc", "#fff4d6" }
local LEAF = { "#2e7648", "#6cb656" }

local X0, X1 = 21, 42          -- jar body
local YT, YB = 25, 55          -- body top (shoulder) / bottom
c:groundShadow(31.5, 56, 13, 2)

-- glass jar silhouette: rounded shoulder + neck + base
local jar = c:rrect(X0, YT, X1, YB, 4)
jar:add(c:rect(X0 + 3, YT - 3, X1 - 3, YT + 1))
-- jam fill region (inside the glass walls)
local jam = c:rrect(X0 + 1, YT + 5, X1 - 1, YB - 2, 3)
local air = c:rect(X0 + 1, YT + 1, X1 - 1, YT + 4):clip(jar:shrink(1))
local function cylN(m, x0, x1)
  local n = {}
  m:each(function(x, y) local t = max(-.96, min(.96, ((x - x0) / (x1 - x0)) * 2 - 1)) n[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
  return n
end
-- glass wall + base first
local gtok = { r = { name = "glass" } }
local gn = cylN(jar, X0, X1)
X.tone(c, jar, X.light(gn, { amb = 0.2, wrap = 0.3 }), GLASS, { cuts = { 0.3, 0.55, 0.8 }, tok = gtok })
-- air gap: pale cool glass showing the cloth shadow
air:each(function(x, y) c:put(x, y, (y == YT + 1) and GLASS[1] or (x < X0 + 6 and GLASS[3] or GLASS[2]), gtok) end)
-- jam body: cylinder light, darker toward the bottom
local jtok = { r = { name = "jam" } }
local jbias = {}
jam:each(function(x, y) if y > YB - 6 then jbias[K(x, y)] = -1 end if y == YT + 5 then jbias[K(x, y)] = 1 end end)
local jidx = X.tone(c, jam, X.light(cylN(jam, X0 + 1, X1 - 1), { amb = 0.05, wrap = 0.2 }), JAM, { cuts = { 0.12, 0.26, 0.44, 0.62, 0.82 }, bias = jbias, tok = jtok })
-- jam texture: seeds / fruit bits (tiny darker and lighter specks)
jam:each(function(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.94 and y > YT + 6 then c:put(x, y, JAM[max(1, (jidx[K(x, y)] or 3) - 2)], jtok)
  elseif h < 0.035 and y > YT + 6 then c:put(x, y, JAM[min(6, (jidx[K(x, y)] or 3) + 1)], jtok) end
end)
-- meniscus line at the jam top
for x = X0 + 2, X1 - 2 do c:put(x, YT + 5, x < X0 + 9 and JAM[6] or JAM[5], jtok) end
-- thick glass base
for x = X0 + 2, X1 - 2 do c:put(x, YB - 1, x < X0 + 8 and GLASS[4] or GLASS[3], gtok) c:put(x, YB, GLASS[2], gtok) end
c:put(X0 + 1, YB - 1, GLASS[3], gtok) c:put(X1 - 1, YB - 1, GLASS[2], gtok)
-- glass highlights: bright left streak, thin right streak, rim glint
for y = YT + 3, YB - 5 do c:put(X0 + 2, y, GLASS[4], gtok) if y > YT + 6 and y < YB - 12 then c:put(X0 + 3, y, GLASS[3], gtok) end end
for y = YT + 8, YB - 9 do c:put(X1 - 2, y, GLASS[2], gtok) end
for y = YT + 12, YT + 17 do c:put(X1 - 3, y, GLASS[3], gtok) end
-- wall edges in cool glass tone (jar outline reads as glass, not jam)
jar:edge():each(function(x, y) if y > YT + 1 and y < YB - 1 then c:put(x, y, x < 30 and GLASS[3] or GLASS[1], gtok) end end)
c:put(X0 + 2, YT + 2, A.CREAM, gtok)

-- label: parchment band with a tiny mulberry
local ptok = { r = { name = "label" } }
local lab = c:rect(X0 + 5, YT + 11, X1 - 4, YT + 21)
lab:each(function(x, y)
  local i = 3
  if x == X0 + 5 then i = 4 elseif x >= X1 - 5 then i = 2 end
  if y == YT + 21 then i = 1 elseif y == YT + 11 then i = 4 end
  c:put(x, y, PAPER[i], ptok)
end)
-- curled corner (lower right)
c:put(X1 - 4, YT + 21, PAPER[2], ptok) c:put(X1 - 4, YT + 20, PAPER[4], ptok)
-- mini mulberry: 2x4 drupe block with a leaf
for _, q in ipairs{ { 30, 0, 5 }, { 31, 0, 4 }, { 29, 1, 4 }, { 30, 1, 3 }, { 31, 1, 4 }, { 29, 2, 3 }, { 30, 2, 4 }, { 31, 2, 2 }, { 30, 3, 3 }, { 31, 3, 2 }, { 30, 4, 2 } } do
  c:put(q[1], YT + 14 + q[2], JAM[q[3]], ptok) end
c:put(32, YT + 13, LEAF[2], ptok) c:put(33, YT + 13, LEAF[2], ptok) c:put(33, YT + 14, LEAF[1], ptok) c:put(31, YT + 13, LEAF[1], ptok)
-- hand-written squiggle (date) on the label
for _, x in ipairs{ 25, 26, 28, 35, 36, 38 } do c:put(x, YT + 19, PAPER[1], ptok) end

-- cloth cap: dome over the lid + scalloped skirt below the twine
local ctok = { r = { name = "cloth" } }
local cap = c:ellipse(31.5, YT - 5, 11, 5)
cap:add(c:rect(X0 + 1, YT - 5, X1 - 1, YT + 1))
-- skirt: scallops hang to YT+3 alternately
for x = X0, X1 do local f = (x - X0) % 5 if f >= 1 and f <= 3 then cap:set(x, YT + 2) if f == 2 then cap:set(x, YT + 3) end end end
cap:add(c:rect(X0, YT - 1, X1, YT + 1))
local cn = X.pillow(cap, 3)
local cbias = {}
cap:each(function(x, y) if y >= YT - 1 then cbias[K(x, y)] = -1 end end)
local cidx = X.tone(c, cap, X.light(cn, { amb = 0.12, wrap = 0.3 }), CLOTH, { cuts = A.CUTS, bias = cbias, tok = ctok })
-- gingham: check rows/cols one tone darker + diagonal weave ticks
cap:each(function(x, y) local k = K(x, y) local i = cidx[k] or 3
  local cx, cy = (x - X0) % 4 < 2, (y - YT) % 4 < 2
  if cx and cy then i = i - 2 elseif cx or cy then i = i - 1 end
  if (x + y) % 4 == 0 and not (cx or cy) then i = i + 1 end
  c:put(x, y, CLOTH[max(1, min(6, i))], ctok)
end)
-- fold shadows radiating from the top knot
for _, f in ipairs{ { 26, YT - 7, 24, YT - 1 }, { 37, YT - 7, 39, YT - 1 }, { 31, YT - 8, 31, YT - 3 } } do
  A.line(c, { { f[1], f[2] }, { f[3], f[4] } }, CLOTH[2], ctok, cap) end
-- gold stitch hem on the skirt
c:stitch{ { X0 + 1, YT + 1 }, { X1 - 1, YT + 1 } }

-- twine around the neck: twisted cord (alternating light/dark diagonals) + bow on the right
local ttok = { r = { name = "twine" } }
for x = X0, X1 do
  local ph = x % 3
  c:put(x, YT - 2, ph == 0 and TWINE[4] or (ph == 1 and TWINE[3] or TWINE[2]), ttok)
  c:put(x, YT - 1, ph == 0 and TWINE[2] or (ph == 1 and TWINE[1] or TWINE[3]), ttok)
end
-- bow loops + tails hanging over the shoulder
local bow = { { X1 - 1, YT - 4, 3 }, { X1, YT - 5, 4 }, { X1 + 1, YT - 4, 3 }, { X1 + 1, YT - 3, 2 }, { X1, YT - 3, 1 },
  { X1 + 2, YT - 3, 3 }, { X1 + 3, YT - 2, 2 }, { X1 + 2, YT - 2, 1 },
  { X1, YT, 2 }, { X1 + 1, YT + 1, 3 }, { X1 + 1, YT + 2, 2 }, { X1 + 2, YT + 3, 3 }, { X1 + 2, YT + 4, 1 },
  { X1 - 1, YT, 3 }, { X1 - 1, YT + 1, 2 } }
for _, q in ipairs(bow) do c:put(q[1], q[2], TWINE[q[3]], ttok) end
-- knot
c:put(X1, YT - 2, TWINE[1], ttok) c:put(X1, YT - 1, TWINE[2], ttok)

-- quirk: jam drip escaping under the cloth, running down the left shoulder over the glass
local dtok = { r = { name = "drip" } }
local drip = { { 24, YT + 2, 4 }, { 25, YT + 2, 3 }, { 24, YT + 3, 4 }, { 25, YT + 3, 3 }, { 24, YT + 4, 4 }, { 25, YT + 4, 2 },
  { 24, YT + 5, 3 }, { 25, YT + 5, 2 }, { 24, YT + 6, 3 }, { 25, YT + 6, 2 }, { 24, YT + 7, 3 }, { 25, YT + 7, 2 },
  { 24, YT + 8, 2 }, { 25, YT + 8, 1 }, { 24, YT + 9, 2 } }
for _, q in ipairs(drip) do c:put(q[1], q[2], JAM[q[3] + 2], dtok) end
c:put(24, YT + 3, JAM[6], dtok) c:put(24, YT + 8, JAM[5], dtok) c:put(24, YT + 9, JAM[4], dtok) c:put(25, YT + 9, JAM[3], dtok)
c:put(24, YT + 10, JAM[3], dtok) c:put(25, YT + 10, JAM[2], dtok) c:put(24, YT + 11, JAM[2], dtok)
c:put(24, YT + 4, A.CREAM, dtok)

A.save2(c, NAME)
