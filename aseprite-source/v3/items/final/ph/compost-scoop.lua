-- compost-scoop (Opus single pass). A slim galvanised hand scoop on the diagonal: oval steel bowl (upper-left)
-- heaped with crumbly compost, riveted tang, bevelled ferrule, slim oak handle with grain and a hang hole
-- threaded with a twisted twine loop.
-- Material: per-pixel convex light on the steel shell, bright lip + shadowed inner wall, specular glint; compost as a
-- textured dome with eggshell / peel / leaf bits and a cast shadow under the rim; handle as a lit cylinder.
-- quirk: an earthworm has arched up out of the compost and over the rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local pi, floor, max, min, abs = math.pi, math.floor, math.max, math.min, math.abs
local c = A.new2("compost-scoop")
local S = A.STEEL

-- handle (painted first; bowl tang overlaps it)
local hm, hn, HT, HS = A.tube({ { 38, 38 }, { 43, 43 }, { 49, 49 }, { 54, 54 } }, function(t) return 1.75 end)
local hb = {}
local hidx = X.tone(c, hm, X.light(hn, { amb = 0.08, wrap = 0.25 }), A.WOOD, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, bias = hb })
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  -- grain: two long lines along the handle
  if (abs(s - 0.25) < 0.17 and t > 0.12 and t < 0.7) or (abs(s + 0.3) < 0.15 and t > 0.4 and t < 0.8) then
    c:px(x, y, A.WOOD[max(1, hidx[k] - 1)]) end
  if s < -0.45 and s > -0.8 and t > 0.2 and t < 0.42 then c:px(x, y, A.WOOD[6]) end
end)
-- hang hole
c:px(51, 51, A.SOIL[1]) c:px(52, 51, A.SOIL[2]) c:px(51, 52, A.WOOD[2])
-- twine loop through the hole (twist: alternating light / dark)
local TW = { "#f2d38c", "#c9964f", "#7e5530" }
local loop = { {53,52},{54,53},{55,54},{56,55},{57,56},{57,57},{56,58},{55,58},{54,57},{53,56} }
for i, p in ipairs(loop) do if not hm:has(p[1], p[2]) or i > 3 then c:px(p[1], p[2], i % 2 == 0 and TW[1] or TW[2]) end end
c:px(55, 59, TW[3]) c:px(56, 59, TW[3])

-- ferrule: bevelled steel collar with a groove
local fm, fn, FT, FS = A.tube({ { 34.5, 34.5 }, { 35.8, 35.8 }, { 37.2, 37.2 }, { 38.6, 38.6 } }, function(t) return 2.3 end)
local fidx = X.tone(c, fm, X.light(fn, { amb = 0.1, wrap = 0.2 }), S, { cuts = { 0.22, 0.38, 0.55, 0.7, 0.85 } })
fm:each(function(x, y) local k = K(x, y) if abs(FT[k] - 0.5) < 0.16 then c:px(x, y, S[max(1, fidx[k] - 2)]) end end)
A.aoRow(c, fm, hm, A.WOOD[1])
-- tang
local tm, tn = A.tube({ { 29, 29 }, { 31, 31 }, { 33, 33 }, { 35, 35 } }, function(t) return 1.3 end)
X.tone(c, tm, X.light(tn, { amb = 0.1 }), S, { cuts = { 0.22, 0.38, 0.55, 0.7, 0.85 } })

-- bowl shell
local ang = pi / 4
local om, on = A.oval(23, 23, 14, 9.5, ang, 0.9)
local oidx = X.tone(c, om, X.light(on, { amb = 0.1, wrap = 0.3 }), S, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- rivet where the tang meets the bowl
c:px(31, 31, S[1]) c:px(30, 30, S[5]) c:px(31, 30, S[3])
-- compost inside
local im, inn = A.oval(22, 22, 11.2, 7, ang, 0.7)
local ring = om:copy():cut(im)
local bias = {}
im:each(function(x, y)
  local h = X.hash(x, y, 7) local k = K(x, y)
  if h < 0.14 then bias[k] = 1 elseif h > 0.86 then bias[k] = -1 end
end)
A.cast(bias, im, ring, 1, 1, -1)
A.cast(bias, im, ring, 2, 2, -1)
X.tone(c, im, X.light(inn, { amb = 0.1, wrap = 0.3 }), A.SOIL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias })
-- inner wall / lip: shadowed on the upper-left, lit lip on the lower-right
im:grow(1):cut(im):each(function(x, y) if om:has(x, y) then
  if x + y < 44 then c:px(x, y, S[2]) else c:px(x, y, S[5]) end end end)
-- specular streak on the outer shell, upper-left
for _, p in ipairs{ {13,19},{14,17},{15,16},{17,14} } do if om:has(p[1], p[2]) then c:px(p[1], p[2], S[6]) end end
c:px(16, 15, A.CREAM)
-- compost bits
A.bit(c, 17, 21, "egg") A.bit(c, 24, 25, "peel") A.bit(c, 19, 26, "leaf") A.bit(c, 22, 17, "twig")
A.bit(c, 26, 22, "crumb") A.bit(c, 21, 23, "crumb") A.bit(c, 15, 24, "crumb")

-- quirk: earthworm arched out of the compost and over the rim
local WL, WB, WD = "#ffb3c4", "#f07f98", "#b84a72"
local path = { {25,20},{26,19},{27,18},{28,17},{29,16},{30,15},{31,15},{32,16},{33,17},{33,18} }
for i, p in ipairs(path) do
  c:px(p[1], p[2], i == 6 and "#e05f78" or WB)
  c:px(p[1], p[2] - 1, (i == 6 or i == 7) and "#e05f78" or WL)
  if i >= 7 then c:px(p[1] + 1, p[2], WD) end
end
c:px(33, 19, WB) c:px(34, 19, WD) c:px(33, 20, WD)
c:px(26, 21, A.SOIL[1]) c:px(27, 20, A.SOIL[1])   -- burrow shadow
A.save2(c, "compost-scoop")
