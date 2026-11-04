-- ico-music (final pass, Opus single pass). Bold icon: a pair of beamed eighth notes in glossy violet lacquer.
-- Tilted oval note heads (sphere + bevel), slim 3 px stems and one thick slanted beam, all bevelled (pillow normals,
-- bright left edge, dark lower-right), a specular streak down each stem, ambient where stems meet beam and heads.
-- quirk: the left note has a little brass wind-up key sticking out of its back, like a clockwork toy.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_2.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, sqrt, abs = math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-music")
local LAC = { "#21183c", "#35295f", "#523f94", "#7a5fc6", "#a88de8", "#d8cbfb" }
local KEY = { "#6e3a1c", "#a8621e", "#d9932a", "#f5c24a", "#ffe58a", "#fff4c8" }
local ltok, ktok = { r = { name = "lac" } }, { r = { name = "key" } }

-- quirk first (behind the head): brass key, shaft + bow with a slot
local shaft = c:rect(8, 45, 14, 47)
local sn = {}
shaft:each(function(x, y) local s = (y - 46) / 1.6 sn[K(x, y)] = { 0, s, sqrt(1 - s * s) } end)
A.shade(c, shaft, sn, KEY, { amb = 0.15, wrap = 0.3, tok = ktok })
local bow = c:rrect(3, 40, 8, 52, 2)
local bidx = A.shade(c, bow, A.blend(X.pillow(bow, 2), X.sphere(5.5, 46, 6, bow), 0.4), KEY, { amb = 0.12, wrap = 0.3, tok = ktok })
for y = 43, 49 do if y ~= 46 then c:put(5, y, KEY[1], ktok) c:put(6, y, KEY[2], ktok) end end  -- two slots
c:put(4, 41, KEY[6], ktok)
-- stems + beam: one bevelled lacquer piece
local L = c:rect(24, 14, 26, 46)
local R = c:rect(47, 10, 49, 42)
local beam = c:poly{ { 24, 13 }, { 49, 8 }, { 49, 14 }, { 24, 19 } }
local frame = L:copy():add(R):add(beam)
local fn = X.pillow(frame, 2)
local fb = {}
-- ambient: stem just under the beam
frame:each(function(x, y) local k = K(x, y)
  if not beam:has(x, y) and (beam:has(x, y - 1) or beam:has(x, y - 2)) then fb[k] = -1 end end)
local heads = {}
local h1m, h1n = A.oval(19.5, 47.5, 7, 4.8, -0.42)
local h2m, h2n = A.oval(42.5, 43.5, 7, 4.8, -0.42)
local hm = h1m:copy():add(h2m)
X.ao(fb, frame, hm, 2, -1)
local fidx = A.shade(c, frame, fn, LAC, { amb = 0.08, wrap = 0.22, tok = ltok, bias = fb })
-- specular streaks down the lit side of each stem, and along the beam's top bevel
for y = 22, 40 do if y % 9 ~= 0 then c:put(24, y, LAC[6], ltok) end end
for y = 18, 36 do if y % 9 ~= 0 then c:put(47, y, LAC[6], ltok) end end
for x = 27, 44 do local y = 13 - (x - 24) * 5 / 25 + 1 local yy = math.floor(y + 0.5)
  if frame:has(x, yy) and x % 7 ~= 0 then c:put(x, yy, LAC[5], ltok) end end
-- heads: tilted ovals, sphere light blended with a bevel
for _, h in ipairs{ { h1m, h1n }, { h2m, h2n } } do
  local m, n = h[1], h[2]
  local nn = A.blend(n, X.pillow(m, 3), 0.35)
  local hb = {}
  m:each(function(x, y) if not m:has(x, y + 2) then hb[K(x, y)] = -1 end end)
  A.shade(c, m, nn, LAC, { amb = 0.04, wrap = 0.18, tok = ltok, bias = hb })
end
-- head glints: 2x1 cream + bright under it
c:put(15, 45, A.CREAM, ltok) c:put(16, 45, A.CREAM, ltok) c:put(16, 44, LAC[6], ltok)
c:put(38, 41, A.CREAM, ltok) c:put(39, 41, A.CREAM, ltok) c:put(39, 40, LAC[6], ltok)
-- cool reflected light along the lower-right of each head
for _, h in ipairs{ h1m, h2m } do
  h:each(function(x, y) if not h:has(x, y + 1) and not h:has(x + 1, y + 1) and not h:has(x + 1, y) == false then end end)
end
for _, p in ipairs{ { 21, 51 }, { 22, 51 }, { 23, 50 }, { 44, 47 }, { 45, 47 }, { 46, 46 } } do
  if hm:has(p[1], p[2]) then c:put(p[1], p[2], "#4a5aa8", ltok) end end
A.save(c, "ico-music", "ico")
