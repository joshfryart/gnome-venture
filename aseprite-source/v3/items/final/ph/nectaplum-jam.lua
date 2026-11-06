-- nectaplum-jam (final, Opus single pass). A tall slim glass jar of deep plum-rose jam, shoulders stepping in to a
-- short neck, a mustard cloth cover gathered over the lid with a frilled skirt, tied by a twisted twine with a
-- dangling bow end; a cream paper label with a little nectaplum drawn on it; 2-tone ground shadow.
-- Material: per-pixel cylinder light on jam (6 tones) seen through glass (bright left rim, pale core headspace,
-- cool right rim, long specular streak), cloth weave diagonals + fold shade, twine twist, label paper curl shade,
-- AO under the frill and where the jar meets the ground.
-- quirk: a fat jam drip has escaped under the cloth and is crawling down the outside of the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "nectaplum-jam"
local c = A.new(NAME)
local JAM   = { "#260d2c", "#45133e", "#6c1c4e", "#962a5c", "#c2436c", "#e87a8c" }
local GLASS = { "#5f8fae", "#8fbfd0", "#c4e8e8", "#eefcf6" }
local CLOTH = { "#5a3418", "#8f561e", "#c4842a", "#e8b040", "#f8d470", "#fff0b0" }
local TW    = { "#6e4a2e", "#a87a4e", "#dcb684" }
local PAPER = { "#a8957a", "#d8c8a4", "#f2e6c4", "#fff4d6" }
local PL    = { "#3f1a58", "#86338a", "#c8548e", "#ffc58a" }
local LF    = { "#2e7646", "#6ab455" }
local SPEC  = "#fff4d6"

c:groundShadow(32, 55, 13, 2)
local X0, X1, Y0, Y1 = 21, 42, 25, 54
-- jar glass body + neck
local jar = c:rrect(X0, Y0, X1, Y1, 5)
local neck = c:rect(X0 + 3, 20, X1 - 3, Y0 + 2)
local jm, jn, JT, JS = X.cyl(31.5, 18, 31.5, 58, function() return 11 end, jar:copy():add(neck))
local all = jar:copy():add(neck)
-- jam fills below y=32; headspace above is clear glass
local jamM = HP.mask()
all:each(function(x, y) if y >= 32 then jamM:set(x, y) end end)
local bias = {}
X.ao(bias, jamM, c:rect(X0, Y1 + 1, X1, Y1 + 3), 1, -1)
local jtok = { r = { name = "jam" } }
local v = X.light(jn, { amb = 0.08, wrap = 0.25 })
local idx = X.tone(c, jamM, v, JAM, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = bias, tok = jtok })
-- fruit pieces suspended in the jam: small darker lumps with a lit edge
for _, p in ipairs{ { 26, 36 }, { 35, 47 }, { 29, 50 }, { 38, 32 }, { 24, 45 } } do
  local i = idx[K(p[1], p[2])] or 3
  c:put(p[1], p[2], JAM[max(1, i - 2)], jtok) c:put(p[1] + 1, p[2], JAM[max(1, i - 1)], jtok) c:put(p[1], p[2] - 1, JAM[min(6, i + 1)], jtok)
end
-- jam surface meniscus line
for x = X0 + 1, X1 - 1 do if all:has(x, 32) then c:put(x, 32, (x < 30) and JAM[6] or JAM[5], jtok) end end
-- headspace: clear glass pale core
local gtok = { r = { name = "glass" } }
all:each(function(x, y) if y < 32 then
  local s = JS[K(x, y)] or 0
  c:put(x, y, s < -0.6 and GLASS[4] or (s > 0.6 and GLASS[1] or (s > 0.1 and GLASS[2] or GLASS[3])), gtok) end end)
-- glass rims: bright left edge column, cool right edge, base thickness
all:edge():each(function(x, y) local s = JS[K(x, y)] or 0
  if y >= 32 then
    if s < 0 then c:put(x, y, (y < Y1 - 3) and GLASS[3] or GLASS[2], gtok) else c:put(x, y, GLASS[1], gtok) end
  end
end)
for x = X0 + 3, X1 - 3 do c:put(x, Y1 - 1, (x < 30) and GLASS[2] or GLASS[1], gtok) end   -- thick glass base
for x = X0 + 4, X1 - 4 do c:put(x, Y1 - 2, JAM[1], jtok) end                                -- AO above the base
-- specular streak down the left (broken in two) + second short streak right of centre
for y = 31, 44 do if y ~= 39 then c:put(X0 + 2, y, (y < 36) and SPEC or GLASS[3], gtok) end end
for y = 46, 49 do c:put(X0 + 2, y, GLASS[3], gtok) end
for y = 33, 37 do c:put(X1 - 4, y, JAM[6], jtok) end

-- label: cream paper wrapped on the cylinder, little nectaplum drawn on it
local lab = c:rect(X0 + 3, 36, X1 - 2, 46)
local ltok = { r = { name = "label" } }
lab:each(function(x, y) local s = JS[K(x, y)] or 0
  local i = (s > 0.7) and 1 or ((s > 0.35) and 2 or ((s < -0.5) and 4 or 3))
  if y == 36 or y == 46 then i = max(1, i - 1) end
  c:put(x, y, PAPER[i], ltok) end)
-- wavy deckle edge rows (paper cut)
for x = X0 + 3, X1 - 2 do if x % 3 == 0 then c:put(x, 46, JAM[2], jtok) end end
local px, py = 30, 41
A.map(c, { "..g.", ".aab", "acdb", "abbb", ".bb." }, px - 2, py - 3,
  { g = LF[2], a = PL[3], b = PL[2], c = PL[4], d = PL[3] }, ltok)
c:put(px + 2, py - 3, LF[1], ltok)
-- tiny handwritten scribble under the plum (ink-brown ticks)
for _, x in ipairs{ 26, 27, 29, 33, 34, 36 } do c:put(x, 44, TW[1], ltok) end

-- cloth cover: dome over the lid, frilled skirt
local cloth = c:ellipse(31.5, 20, 10.5, 6)
cloth:cut(c:rect(0, 21, 63, 63))
cloth:add(c:poly{ { X0 - 2, 21 }, { X1 + 2, 21 }, { X1 + 3, 27 }, { X0 - 3, 27 } })
-- scalloped hem
cloth:each(function(x, y) if y == 27 and (x % 3 == 0) then cloth.s[K(x, y)] = nil end
  if y == 26 and (x % 6 == 0) then cloth.s[K(x, y)] = nil end end)
local cn = X.pillow(cloth, 3)
local cb = {}
cloth:each(function(x, y) local k = K(x, y)
  if y >= 22 and y <= 23 then cb[k] = -1 end                         -- tucked under the twine: AO
  if y >= 24 and (x % 4 == 1) then cb[k] = (cb[k] or 0) - 1 end       -- folds in the skirt
end)
local ctok = { r = { name = "cloth" } }
local cidx = X.tone(c, cloth, X.light(cn, { amb = 0.15, wrap = 0.3 }), CLOTH, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, bias = cb, tok = ctok })
-- weave: diagonal threads
cloth:each(function(x, y) local k = K(x, y)
  if (x + y) % 4 == 0 and y < 22 then c:put(x, y, CLOTH[max(1, cidx[k] - 1)], ctok) end
  if (x - y) % 4 == 0 and y < 21 and cidx[k] >= 4 then c:put(x, y, CLOTH[min(6, cidx[k] + 1)], ctok) end end)
-- AO on the glass just under the frill
for x = X0, X1 do if all:has(x, 28) and not cloth:has(x, 28) then c:put(x, 28, GLASS[1], gtok) end end
-- twine: 2 rows with twist (alternating diagonal strands)
local ttok = { r = { name = "twine" } }
for x = X0 - 1, X1 + 1 do
  local p = (x % 3)
  c:put(x, 22, p == 0 and TW[3] or (p == 1 and TW[2] or TW[1]), ttok)
  c:put(x, 23, p == 2 and TW[2] or (p == 0 and TW[1] or TW[2]), ttok)
end
-- bow loop + dangling end on the right
A.map(c, { "bab..", "a.ab.", "bab..", ".b...", "..b..", "..a..", "...b.", "...c." }, X1 + 1, 20,
  { a = TW[3], b = TW[2], c = TW[1] }, ttok)
-- top knot puff highlight + one sparkle-free specular on the dome
c:put(27, 16, CLOTH[6], ctok) c:put(28, 16, CLOTH[6], ctok)

-- quirk: jam drip from under the frill crawling down the glass (right of the label)
local djt = { r = { name = "drip" } }
A.map(c, { "ab", "ab", "ab", ".b", "ab", "bc", "bc", ".c" }, 38, 27, { a = JAM[5], b = JAM[4], c = JAM[3] }, djt)
c:put(38, 34, JAM[6], djt)
A.save(c, NAME)
