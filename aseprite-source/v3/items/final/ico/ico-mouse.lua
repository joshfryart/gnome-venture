-- ico-mouse (final pass, Opus single pass). Bold icon: a slim field mouse in side view facing left, crouched,
-- egg-shaped body with a high back, pointed snout with an ink nose tip, big round ear with a concave pink inner,
-- long 3 px pink tail curling up behind. 6-tone fur, short fur strokes, pale belly, ambient where head meets body.
-- quirk: it clutches a cheese crumb almost as big as its head, holes and all.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_2.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, sqrt, abs = math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-mouse")
local FUR = { "#382e44", "#574c66", "#7d728e", "#a39ab2", "#c8c1d4", "#eae6f0" }
local PINK = { "#7d2c5e", "#b04878", "#e06a90", "#f5909f", "#ffbccc", "#ffe0e8" }
local BEL = { "#7a6c7c", "#a8988e", "#d2c4b2", "#e9decb", "#f7f0e2", "#fff8ea" }
local CHZ = { "#8f4a1f", "#c26f22", "#e8a12e", "#f9c642", "#ffe27a", "#fff3b8" }
local ftok, ptok, btok, ctok = { r = { name = "fur" } }, { r = { name = "pink" } }, { r = { name = "belly" } }, { r = { name = "chz" } }

c:groundShadow(33, 53, 19, 2)
-- tail (behind everything): pink tube curling up behind the back
local tm, tn = A.tube({ { 45, 48 }, { 57, 53 }, { 60, 40 }, { 51, 34 } }, function(t) return 1.55 - 0.55 * t end)
A.shade(c, tm, tn, PINK, { amb = 0.18, wrap = 0.35, tok = ptok })
-- back ear (darker, behind head)
local be = c:ellipse(31, 23, 4.5, 4.5)
A.shade(c, be, X.sphere(30.5, 22.5, 5, be), FUR, { amb = 0.05, tok = ftok, bias = setmetatable({}, { __index = function() return -1 end }) })
-- back foot
local bf = c:ellipse(41, 51, 4, 1.5)
A.shade(c, bf, X.pillow(bf, 1), PINK, { amb = 0.2, tok = ptok })
-- body: high-backed egg
local bm, bn = A.oval(35, 41, 12.5, 10, -0.22)
bm:cut(c:rect(0, 52, 63, 63))
local bb = {}
local bmP = X.pillow(bm, 4)
local bnn = A.blend(bn, bmP, 0.3)
-- head (made first as a mask so the body can take ambient from it)
local hm, hn = A.oval(20.5, 34.5, 8.5, 7.5, 0.3)
hm:add(c:poly{ { 15, 30 }, { 7, 38 }, { 9, 41 }, { 19, 42 } })
X.ao(bb, bm, hm, 2, -1)
local bidx = A.shade(c, bm, bnn, FUR, { amb = 0.08, wrap = 0.25, tok = ftok, bias = bb })
-- pale belly patch (front-bottom), same light, belly ramp
local belly = bm:copy():clip(c:ellipse(28, 48, 6.5, 4))
belly:each(function(x, y) local i = bidx[K(x, y)] if i then c:put(x, y, BEL[min(6, i + 1)], btok) end end)
-- fur strokes: short diagonal dashes one tone darker on the mid tones
bm:each(function(x, y)
  local k = K(x, y)
  if not belly:has(x, y) and bidx[k] and bidx[k] >= 3 and bidx[k] <= 5 and (x + 2 * y) % 7 == 0 and X.hash(x, y, 3) < 0.55 then
    A.step(c, bidx, FUR, x, y, -1, ftok) end
end)
-- haunch line: the back leg curve, deep tone
for _, p in ipairs{ { 44, 47 }, { 45, 46 }, { 46, 45 }, { 47, 44 }, { 43, 48 } } do if bm:has(p[1], p[2]) then c:put(p[1], p[2], FUR[2], ftok) end end
-- head
local hP = X.pillow(hm, 3)
local hS = X.sphere(19.5, 33.5, 10, hm)
local hnn = A.blend(hS, hP, 0.45)
local hidx = A.shade(c, hm, hnn, FUR, { amb = 0.1, wrap = 0.28, tok = ftok })
-- pale cheek/muzzle under the snout
hm:each(function(x, y) local i = hidx[K(x, y)]
  if y >= 38 and x <= 20 and i then c:put(x, y, BEL[min(6, i + 1)], btok) end end)
-- front ear: fur disc + concave pink inner (lit lower-right like a cup)
local fe = c:ellipse(25.5, 25, 6, 6)
local feidx = A.shade(c, fe, X.sphere(24.5, 24, 6.5, fe), FUR, { amb = 0.1, wrap = 0.3, tok = ftok })
-- ambient where the ear meets the head
hm:each(function(x, y) if fe:has(x, y - 1) and not fe:has(x, y) then c:put(x, y, FUR[2], ftok) end end)
local ie = c:ellipse(25.5, 25.5, 3.6, 3.6)
local inS = X.sphere(25.5, 25.5, 4, ie)
for k, v in pairs(inS) do inS[k] = { -v[1], -v[2], v[3] } end
A.shade(c, ie, inS, PINK, { amb = 0.2, wrap = 0.35, tok = ptok })
c:put(23, 23, FUR[3], ftok) -- ear rim lip shadow
-- front foot + paws
local ff = c:ellipse(24, 51, 3.5, 1.5)
A.shade(c, ff, X.pillow(ff, 1), PINK, { amb = 0.2, tok = ptok })
-- quirk: cheese crumb held to the mouth
local cz = c:poly{ { 8, 44 }, { 17, 41 }, { 18, 49 }, { 9, 50 } }
local czn = {}
cz:each(function(x, y) local top = y <= 44 + (x - 8) * -0.33 + 1.2
  czn[K(x, y)] = top and { -0.2, -0.85, 0.5 } or { -0.55, 0.1, 0.83 } end)
for k, v in pairs(czn) do czn[k] = { A.norm(v[1], v[2], v[3]) } end
local cidx = A.shade(c, cz, czn, CHZ, { amb = 0.15, wrap = 0.3, tok = ctok })
-- rind edge on the right face, holes with a lit lower lip
cz:each(function(x, y) if not cz:has(x + 1, y) then c:put(x, y, CHZ[2], ctok) end end)
for _, h in ipairs{ { 11, 46 }, { 14, 48 } } do
  c:put(h[1], h[2], CHZ[2], ctok) c:put(h[1] + 1, h[2], CHZ[2], ctok) c:put(h[1], h[2] + 1, CHZ[5], ctok)
end
c:put(15, 45, CHZ[3], ctok)
c:put(10, 44, CHZ[6], ctok) c:put(11, 44, CHZ[6], ctok)
-- paws gripping the crumb
for _, p in ipairs{ { 17, 45 }, { 17, 48 } } do
  local pm = c:ellipse(p[1] + 0.5, p[2] + 0.5, 1.5, 1.2)
  A.shade(c, pm, X.sphere(p[1], p[2], 2, pm), PINK, { amb = 0.25, wrap = 0.4, tok = ptok })
end
-- face: eye pill, nose tip, whisker pads, cheek
c:eyeSmall(17, 31)
c:put(7, 37, A.INK, ftok) c:put(8, 37, A.INK, ftok) c:put(7, 38, A.INK, ftok) c:put(8, 38, A.INK, ftok)
c:put(7, 37, A.CREAM, ftok)
c:put(12, 37, FUR[2], ftok) c:put(13, 38, FUR[2], ftok) c:put(11, 39, FUR[3], ftok)
c:put(19, 37, "#f5809f", ptok) c:put(20, 37, "#f5809f", ptok)
-- one fur sheen glint on the back
c:put(31, 32, FUR[6], ftok) c:put(32, 32, FUR[6], ftok)
A.save(c, "ico-mouse", "ico")
