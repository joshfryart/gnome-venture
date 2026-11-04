-- scarecrow (final, artist D14_3, Sonnet high). A slim field scarecrow on a post: wide straw hat with a woven brim and
-- red band, burlap-sack head (weave rows, button eye + stitched X eye, lit nose, stitched mouth), twisted rope at the
-- neck and belt, long blue tunic with diagonal weave and a patched pocket, cross-pole arms ending in raggedy straw
-- tufts, a fringed hem and the post running down into a little dirt mound.
-- quirk: a tiny yellow chick sits on the right sleeve, bold as brass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_aD14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scarecrow" }

local BLUE   = A.ramp("#4a7cc4")
local STRAW  = A.ramp("#eab84a")
local BURLAP = A.ramp("#d8b98c")
local WOOD   = A.ramp("#b4764a")
local RED    = A.ramp("#c8453f")
local YEL    = A.ramp("#f6cb3c")
local PATCH  = A.ramp("#d9893c")
local ROPE   = A.ramp("#c9a066")
local INK, CREAM = "#2b1c26", "#fff4d6"
local function tok(n) return { r = { name = n } } end

c:groundShadow(32, 54, 10, 1)

---------------------------------------------------------------- dirt mound + post
do
  local mound = c:ellipse(32, 53, 7, 2)
  local n = X.pillow(mound, 2)
  A.paint(c, mound, n, A.ramp("#8a5a3c"), { cuts = { .25, .45, .62, .78, .9 } })
  c:px(28, 52, "#c49060") c:px(36, 53, "#6a3f36") c:px(30, 53, "#6a3f36")
end
local post = c:rect(31, 22, 33, 53)
do
  local n = {}
  post:each(function(x, y) local t = (x - 32) / 1.7 n[K(x, y)] = { t, 0, sqrt(1 - min(.9, t * t)) } end)
  A.paint(c, post, n, WOOD, { adj = function(x, y, i)
    if A.hash(x, y, 5) > .8 and x == 32 then return i - 1 end
    if y % 7 == 3 and x == 31 then return i - 1 end
  end })
  -- cracked knot
  c:px(32, 48, WOOD[1]) c:px(32, 49, WOOD[2])
end

---------------------------------------------------------------- cross pole
local armL, armR = 10, 54
local bar = c:rect(armL, 28, armR, 30)
do
  local n = {}
  bar:each(function(x, y) local t = (y - 29) / 1.6 n[K(x, y)] = { 0, t, sqrt(1 - min(.9, t * t)) } end)
  A.paint(c, bar, n, WOOD, { adj = function(x, y, i)
    if (x * 7 + y) % 11 == 0 then return i - 1 end
  end })
end

---------------------------------------------------------------- tunic
local tunic = HP.mask()
for y = 25, 45 do
  local t = (y - 25) / 20
  local hw = 9.3 + 2.2 * t + (y < 27 and -1.6 or 0)
  for x = floor(32 - hw + .5), floor(32 + hw - .5) do tunic:set(x, y) end
end
-- ragged hem: nibble a few notches
for _, x in ipairs{ 24, 28, 31, 35, 38, 41 } do tunic:cut(c:rect(x, 45, x + (x % 3 == 0 and 1 or 0), 45)) end
local tN = X.pillow(tunic, 4, .9)
local tV, tI = A.paint(c, tunic, tN, BLUE, { amb = .06, wrap = .25, adj = function(x, y, i)
  -- diagonal weave
  if (x + y) % 4 == 0 then return i - 1 end
  if (x - y) % 7 == 0 and i > 2 then return i + 0 end
end })
-- fold lines (slim body: two vertical folds)
for y = 30, 44 do
  local k1, k2 = K(27 + floor((y - 30) * -.12 + .5), y), K(38 + floor((y - 30) * .14 + .5), y)
  if y % 5 ~= 0 then
    c:put(27 + floor((y - 30) * -.12 + .5), y, BLUE[2], tok("t"))
    c:put(38 + floor((y - 30) * .14 + .5), y, BLUE[1], tok("t"))
  end
end
-- sleeves (tubes along the bar)
local function sleeve(x0, x1)
  local m, n = A.tube({ { x0, 29 }, { x0 * .7 + x1 * .3, 29 }, { x0 * .3 + x1 * .7, 29 }, { x1, 29 } },
    function(t) return 3.6 - t * 1.0 end)
  A.paint(c, m, n, BLUE, { amb = .06, wrap = .25, adj = function(x, y, i)
    if (x + y) % 4 == 0 then return i - 1 end
  end })
  return m
end
local slL = sleeve(26, 15)
local slR = sleeve(38, 49)
-- cuff: dark band + frayed edge
for y = 26, 32 do
  if slL:has(15, y) or slL:has(16, y) then c:px(16, y, BLUE[1]) c:px(15, y, BLUE[2]) end
  if slR:has(49, y) or slR:has(48, y) then c:px(48, y, BLUE[1]) c:px(49, y, BLUE[2]) end
end
c:px(14, 28, BLUE[2]) c:px(14, 31, BLUE[1]) c:px(50, 27, BLUE[3]) c:px(50, 31, BLUE[2])
-- contact shadow on the tunic under each sleeve
for x = 23, 26 do c:px(x, 33, BLUE[1]) end
for x = 38, 41 do c:px(x, 33, BLUE[1]) end

---------------------------------------------------------------- straw: hem fringe and hand tufts
local function straw(x, y, dx, dy, len, w)
  for i = -w, w do
    local ex, ey = x + dx * len + i * (dy ~= 0 and 1.5 or 0) , y + dy * len + i * (dx ~= 0 and 1.5 or 0)
    ex, ey = floor(ex + .5), floor(ey + .5)
    local hexc = (i % 2 == 0) and STRAW[5] or STRAW[3]
    if (i + w) % 3 == 0 then hexc = STRAW[2] end
    A.line(c, { { x, y }, { ex, ey } }, hexc)
  end
end
straw(11, 29, -1, 0, 3, 2)
straw(53, 29, 1, 0, 3, 2)
-- fringe under the hem (short stalks)
for x = 23, 41, 2 do
  local l = 2 + floor(A.hash(x, 3, 9) * 3)
  A.line(c, { { x, 46 }, { x + (x < 32 and -1 or 1) * (l > 3 and 1 or 0), 46 + l } }, (x % 4 == 0) and STRAW[5] or STRAW[3])
end
-- the post emerges below the fringe (re-lay so the fringe overlaps it)
c:px(31, 47, WOOD[3]) c:px(33, 47, WOOD[2])

---------------------------------------------------------------- rope belt (twisted) + patch
for x = 22, 42 do
  local i = ((x + (x % 2)) % 4 < 2) and 4 or 2
  c:px(x, 38, ROPE[i + 1]) c:px(x, 39, ROPE[(i == 4) and 2 or 4])
end
c:px(31, 40, ROPE[3]) c:px(32, 40, ROPE[2]) c:px(32, 41, ROPE[1]) c:px(31, 41, ROPE[3])   -- knot tail
c:px(23, 38, ROPE[1]) c:px(41, 38, ROPE[1])
do
  local pm = c:rect(35, 31, 40, 36)
  local n = X.pillow(pm, 1.5)
  A.paint(c, pm, n, PATCH, { adj = function(x, y, i) if (x + y) % 3 == 0 then return i - 1 end end })
  -- gold stitch round the patch (the one stitched seam)
  c:stitch({ { 34, 30 }, { 41, 30 }, { 41, 37 }, { 34, 37 }, { 34, 30 } })
end
-- belt contact shadow
for x = 23, 41 do if tunic:has(x, 40) and not (x == 31 or x == 32) then c:px(x, 40, BLUE[1]) end end

---------------------------------------------------------------- head: burlap sack
local head = c:ellipse(32, 19, 6, 6.5)
local hN = X.sphere(31.6, 18.6, 6.2, head)
local hV, hI = A.paint(c, head, hN, BURLAP, { amb = .08, wrap = .22, adj = function(x, y, i)
  local r = 0
  if y % 2 == 0 then r = r - 1 end
  if (x + floor(y / 2)) % 3 == 0 and y % 2 == 1 then r = r + 1 end
  return i + r
end })
-- neck: twisted rope and the gathered sack bottom
for x = 28, 36 do
  local i = ((x + 1) % 3 == 0) and 2 or 4
  c:px(x, 25, ROPE[i]) c:px(x, 26, ROPE[(i == 4) and 3 or 5])
end
c:px(27, 25, ROPE[1]) c:px(37, 25, ROPE[1]) c:px(27, 26, ROPE[1]) c:px(37, 26, ROPE[1])
c:px(29, 24, BURLAP[2]) c:px(35, 24, BURLAP[2]) c:px(32, 24, BURLAP[1])
-- sack seam ( a thread running down the right cheek )
for y = 17, 23 do c:px(37 - floor(abs(y - 20) / 3), y, BURLAP[2]) end
-- face. nose: lit tip, dark underside, shadow beside
c:px(31, 20, BURLAP[6]) c:px(32, 20, BURLAP[5]) c:px(31, 21, BURLAP[4]) c:px(32, 21, BURLAP[3])
c:px(31, 22, BURLAP[1]) c:px(32, 22, BURLAP[1]) c:px(33, 21, BURLAP[2])
-- left eye: round button (dark brown, glint, two thread holes)
c:fillMask(c:rect(28, 17, 30, 19), "#4a2a2a")
c:px(28, 17, CREAM) c:px(29, 18, "#8a4a3a") c:px(30, 19, INK)
c:px(29, 17, "#2b1c26") c:px(28, 18, "#2b1c26")
c:px(29, 18, "#8a5a46")
-- right eye: stitched X in ink
for _, p in ipairs{ { 34, 17 }, { 36, 17 }, { 35, 18 }, { 34, 19 }, { 36, 19 } } do c:px(p[1], p[2], INK) end
-- mouth: zig-zag stitched with little crossings
for _, p in ipairs{ { 28, 22 }, { 29, 23 }, { 30, 23 }, { 31, 23 }, { 32, 23 }, { 33, 23 }, { 34, 23 }, { 35, 23 }, { 36, 22 } } do c:px(p[1], p[2], INK) end
for _, x in ipairs{ 30, 33, 35 } do c:px(x, 24, INK) end
-- rosy patch of sun on the cheek
c:px(27, 21, "#e69a7a") c:px(28, 21, "#e69a7a")

---------------------------------------------------------------- hat
do
  local brim = c:ellipse(32, 14, 15, 2.6)
  local bN = X.pillow(brim, 2.5, .9)
  A.paint(c, brim, bN, STRAW, { amb = .1, wrap = .3, adj = function(x, y, i)
    local r = sqrt(((x - 32) / 15) ^ 2 + ((y - 14) / 2.6) ^ 2)
    if floor(r * 6) % 2 == 0 and r > .3 then return i - 1 end
    if (x * 5 + y) % 13 == 0 then return i + 1 end
  end })
  -- ragged ends
  c:px(16, 14, STRAW[2]) c:px(15, 15, STRAW[3]) c:px(48, 14, STRAW[2]) c:px(49, 13, STRAW[3])
  -- shadow from the brim on the face
  for x = 27, 37 do if head:has(x, 16) then c:px(x, 16, BURLAP[2]) end end
  -- crown
  local crown = c:rrect(25, 5, 39, 13, 4)
  local cN = X.pillow(crown, 3.6, 1.0)
  A.paint(c, crown, cN, STRAW, { amb = .08, wrap = .28, adj = function(x, y, i)
    if (x * 2 + floor(y / 2)) % 5 == 0 then return i - 1 end
    if y == 5 then return i + 0 end
  end })
  -- band
  local band = c:rect(25, 10, 39, 11)
  A.paint(c, band, (function() local n = {} band:each(function(x, y) local s = (y - 10.5) / 1.4 n[K(x, y)] = { -.35 + (x - 32) / 40, s, sqrt(max(.1, 1 - s * s)) } end) return n end)(), RED, { amb = .1, wrap = .25 })
  c:px(37, 10, RED[6]) c:px(38, 11, RED[2])
  -- ambient where crown meets brim
  for x = 26, 38 do c:px(x, 12, STRAW[2]) end
  for x = 27, 37 do c:px(x, 13, (x % 2 == 0) and STRAW[1] or STRAW[2]) end
  -- crown top dent
  c:px(31, 5, STRAW[3]) c:px(32, 5, STRAW[2]) c:px(33, 5, STRAW[3])
  -- specular glint on the crown
  c:px(28, 7, "#fff1b8") c:px(29, 7, "#fff1b8") c:px(28, 8, STRAW[6])
  -- a few loose straws stick out of the crown top
  A.line(c, { { 35, 5 }, { 36, 4 } }, STRAW[4]) A.line(c, { { 36, 5 }, { 38, 4 } }, STRAW[5])
end

---------------------------------------------------------------- the chick on the right sleeve (quirk)
do
  local body = c:ellipse(47.5, 24.5, 3.4, 3.0)
  local n = X.sphere(46.9, 23.8, 3.5, body)
  A.paint(c, body, n, YEL, { amb = .08, wrap = .25 })
  -- tiny wing
  c:px(46, 25, YEL[3]) c:px(47, 26, YEL[3]) c:px(45, 25, YEL[2]) c:px(48, 26, YEL[2])
  -- eye + beak
  c:px(49, 23, INK) c:px(48, 22, YEL[6])
  c:px(51, 24, "#e8742c") c:px(52, 24, "#c85a24") c:px(51, 25, "#c85a24")
  -- tuft on head
  c:px(46, 20, YEL[5]) c:px(47, 20, YEL[4])
  -- feet gripping the sleeve
  c:px(46, 28, "#e8742c") c:px(48, 28, "#e8742c")
  c:px(46, 27, YEL[1]) c:px(47, 27, YEL[1])
end

A.fin(c, "scarecrow")
