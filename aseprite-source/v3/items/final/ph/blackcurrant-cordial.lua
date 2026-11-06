-- blackcurrant-cordial (aR20_4, Opus single pass). Tall slim glass bottle of deep ruby-violet cordial: narrow neck,
-- glass lip collar, porous cork with pale end grain, sloped shoulders, liquid lit through the glass (pale left core,
-- meniscus line, caustic glow at the lower right, thick glass base), long vertical specular streak and a thin bright
-- rim. A paper tag hangs from twisted twine round the neck, printed with a currant sprig. 2-tone ground shadow.
-- quirk: a sticky drip of cordial has run from under the cork down the neck.
local NAME = "blackcurrant-cordial"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, sin, pi, max, min = math.floor, math.abs, math.sqrt, math.sin, math.pi, math.max, math.min
local c = R.new2(NAME)
local CORD = { "#22091f", "#3c0f36", "#5a1650", "#7a2168", "#a0347e", "#d0649e" }
local GLS = { "#3f5677", "#5d7896", "#86a6bc", "#b0cdd6", "#d6ecec", "#f2fbf6" }
local CORK = { "#5a3a2a", "#7e5636", "#a47848", "#c49a62", "#ddb880", "#f0d4a0" }
local TWINE = { "#7a5434", "#b08a56", "#dcc08a" }
local PAPER = { "#b89c7c", "#e2cfa6", "#f6ead0", "#fff4d6" }
local INKP, LEAFP = "#3a2450", "#4a8a4c"

c:groundShadow(31.5, 55, 12, 1.5)

-- row spans
local spans = {}
for y = 14, 22 do spans[y] = { 29, 34 } end
for y = 23, 29 do local hw = 3 + 6 * sin(pi / 2 * (y - 22) / 7.5) ^ 1.3
  spans[y] = { floor(31.5 - hw + 0.5), floor(31.5 + hw - 0.5) } end
for y = 30, 51 do spans[y] = { 23, 40 } end
spans[52] = { 24, 39 } spans[53] = { 25, 38 }
local LIQ = 25
local body, liq, glass = HP.mask(), HP.mask(), HP.mask()
local n = {}
for y, s in pairs(spans) do for x = s[1], s[2] do
  body:set(x, y)
  local t = max(-.96, min(.96, ((x + .5 - s[1]) / (s[2] + 1 - s[1])) * 2 - 1))
  local ny = (y >= 23 and y <= 29) and -0.5 or -0.1
  n[K(x, y)] = { R.norm(t, ny, sqrt(1 - t * t)) }
  if y >= LIQ and y <= 51 then liq:set(x, y) else glass:set(x, y) end
end end
local btok = { r = { name = "bottle" } }
local v = X.light(n, { amb = 0.1, wrap = 0.35 })
-- liquid: lit through, so the left-of-centre core is the palest; edges dark
local lv = {}
liq:each(function(x, y) local k = K(x, y) local nn = n[k]
  lv[k] = max(0, min(1, v[k] * 0.7 + 0.25 * nn[3] - 0.2)) end)
local lidx = X.tone(c, liq, lv, CORD, { cuts = { 0.2, 0.36, 0.5, 0.64, 0.8 }, tok = btok })
X.tone(c, glass, v, GLS, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = btok })
-- meniscus and caustic
for x = spans[LIQ][1] + 1, spans[LIQ][2] - 1 do c:put(x, LIQ, CORD[5], btok) end
for _, q in ipairs{ { 36, 48, 5 }, { 37, 48, 4 }, { 35, 49, 4 }, { 36, 49, 5 }, { 37, 49, 5 }, { 36, 50, 4 }, { 38, 47, 4 } } do c:put(q[1], q[2], CORD[q[3]], btok) end
-- thick glass base
for y = 52, 53 do for x = spans[y][1], spans[y][2] do c:put(x, y, (x < 30) and GLS[3] or GLS[2], btok) end end
for x = 25, 38 do c:put(x, 51, CORD[1], btok) end
-- glass rim: thin bright left edge, cool right edge
for y, s in pairs(spans) do
  c:put(s[1], y, (y >= LIQ and y <= 51) and CORD[4] or GLS[5], btok)
  c:put(s[2], y, (y >= LIQ and y <= 51) and "#3e2f62" or GLS[2], btok)
end
-- specular streak (2 px wide body, 1 px neck) and a small right glint
for y = 31, 47 do if y ~= 40 and y ~= 41 then c:put(25, y, y < 40 and "#ffe8f0" or "#f2b2c8", btok) end end
for y = 32, 38 do c:put(26, y, "#f2b2c8", btok) end
for y = 15, 21 do c:put(30, y, GLS[6], btok) end
for y = 26, 28 do c:put(spans[y][1] + 2, y, "#f2b2c8", btok) end
for y = 34, 37 do c:put(38, y, CORD[5], btok) end

-- lip collar
local lip = c:rect(28, 12, 35, 13)
local ltok = { r = { name = "lip" } }
for x = 28, 35 do
  local t = (x - 28) / 7
  c:put(x, 12, t < 0.35 and GLS[6] or (t < 0.75 and GLS[5] or GLS[3]), ltok)
  c:put(x, 13, t < 0.3 and GLS[4] or (t < 0.75 and GLS[3] or GLS[1]), ltok)
end
-- cork: porous, paler end grain on top, AO where it enters the lip
local ctok = { r = { name = "cork" } }
local cm = c:rect(29, 7, 34, 11) cm:set(30, 6) cm:set(31, 6) cm:set(32, 6) cm:set(33, 6)
local cn = R.vn(cm, 29, 34)
local cidx = X.tone(c, cm, X.light(cn, { amb = 0.1, wrap = 0.3 }), CORK, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ctok })
cm:each(function(x, y) local k = K(x, y)
  if y == 6 then c:put(x, y, x < 32 and CORK[6] or CORK[5], ctok)
  elseif y == 11 then c:put(x, y, CORK[1], ctok)
  elseif X.hash(x, y, 8) > 0.72 then c:put(x, y, CORK[max(1, cidx[k] - 2)], ctok) end
end)
c:put(30, 7, CORK[5], ctok) c:put(33, 7, CORK[4], ctok)

-- quirk: drip from under the cork, down over the lip and the neck
local dtok = { r = { name = "drip" } }
for _, q in ipairs{ { 33, 12, 3 }, { 33, 13, 3 }, { 33, 14, 4 }, { 33, 15, 3 }, { 33, 16, 3 }, { 33, 17, 4 }, { 32, 17, 2 }, { 33, 18, 2 } } do
  c:put(q[1], q[2], CORD[q[3]], dtok) end
c:put(33, 14, CORD[6], dtok)

-- twine round the neck (twist) + tag
local ttok = { r = { name = "twine" } }
for x = 28, 35 do c:put(x, 19, (x % 2 == 0) and TWINE[3] or TWINE[2], ttok) c:put(x, 20, (x % 2 == 0) and TWINE[1] or TWINE[2], ttok) end
c:put(36, 20, TWINE[2], ttok) c:put(37, 21, TWINE[3], ttok) c:put(37, 22, TWINE[2], ttok) c:put(36, 21, TWINE[1], ttok)
-- shadow of the twine on the neck
for x = 29, 34 do if c:get(x, 21) then c:put(x, 21, GLS[1], btok) end end
local tag = c:poly{ { 37, 23 }, { 43, 22 }, { 45, 30 }, { 39, 31 } }
local tgtok = { r = { name = "tag" } }
-- cast shadow of the tag onto the bottle
tag:shift(-1, 1):each(function(x, y) if body:has(x, y) and not tag:has(x, y) then
  c:put(x, y, liq:has(x, y) and CORD[1] or GLS[1], btok) end end)
local tn = X.pillow(tag, 1.5)
X.tone(c, tag, X.light(tn, { amb = 0.2, wrap = 0.3 }), PAPER, { cuts = { 0.3, 0.55, 0.8 }, tok = tgtok })
c:put(39, 24, TWINE[1], tgtok) c:put(38, 23, TWINE[2], tgtok)
-- printed currant sprig on the tag
for _, q in ipairs{ { 40, 27, INKP }, { 42, 26, INKP }, { 41, 28, INKP }, { 43, 28, INKP }, { 41, 25, LEAFP }, { 42, 25, LEAFP } } do
  c:put(q[1], q[2], q[3], tgtok) end
c:put(42, 29, PAPER[1], tgtok)

R.save2(c, NAME)
