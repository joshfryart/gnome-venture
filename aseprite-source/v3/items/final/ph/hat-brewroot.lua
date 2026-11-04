-- hat-brewroot (final, Opus single pass). Slim violet brewer's cone with a crooked tip that kinks right and ends
-- in a cork stopper, as if the hat were a bottle. Teal woven band with a glass flask badge (bright rim, pale core,
-- green brew), medium brim with a rounded lip.
-- Material: per-pixel cone light (6-tone violet felt, cool shade), felt nap speckle, two fold creases on the kink,
-- band weave, brim bevel + lit front lip, AO where crown meets brim and a cast shadow lower-right; cork grain + pale end.
-- quirk: three tiny brew bubbles drift up out of the cork.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_1.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("hat-brewroot")
local VIO  = { "#2a1940", "#3e2763", "#59398a", "#7651b0", "#9a75d2", "#c4a6ee" }
local TEAL = { "#14293c", "#1f4d5e", "#2a7378", "#3d9a95", "#6cc2b2", "#a9e6d2" }
local CORK = { "#3e2420", "#6a4030", "#956244", "#b98a5c", "#d8b080", "#f2d6a6" }

local CX, BY, RW, RY = 31, 46, 9, 2.2
-- crown (mask first, painted after the brim)
local pts = { { 31, 47 }, { 31, 34 }, { 28, 22 }, { 41, 17 } }
local cm, cn, CT, CS, samp = A.tube(pts, function(t)
  if t > 0.93 then return 2.0 end
  return 9.2 * (1 - t) ^ 0.8 + 1.9
end)
A.arcClip(cm, CX, BY, RW + 1, RY)

-- brim
local bias = {}
local tmpTop = HP.mask()
do
  for y = 40, 56 do for x = 8, 56 do
    local u, v = (x - 32) / 21.45, (y - 49) / 5.45
    if u*u + v*v <= 1 then tmpTop:set(x, y) end end end
  X.ao(bias, tmpTop, cm, 2, -1)
  A.cast(bias, tmpTop, cm, 3, 2, -1)
end
local btok = { r = { name = "brim" } }
local top, under, bidx = A.brim(c, 32, 49, 21, 5, 2, VIO, { bias = bias, tok = btok })

-- crown paint
local ctok = { r = { name = "crown" } }
local cbias = {}
cm:each(function(x, y) local k = K(x, y) if CT[k] > 0.9 then cbias[k] = -1 end end)
local cidx = A.shade(c, cm, cn, VIO, { bias = cbias, tok = ctok })
A.felt(c, cm, cidx, VIO, ctok, 3, 0.06)
A.creases(c, cm, cidx, CT, CS, A.tubeLen(samp), VIO, ctok, { { 0.58, -0.7, 0.8, 1.5 }, { 0.7, -0.5, 0.9, -1.0 } })
-- cool reflected light on the lower-right edge of the crown
local rim = X.rim(cn)
cm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and CT[k] > 0.15 and CT[k] < 0.75 then c:put(x, y, "#6a5fb8", ctok) end end)

-- band
local bm = A.bandMask(cm, CX, BY, RW + 1, RY, 7)
local ttok = { r = { name = "band" } }
local tidx = A.shade(c, bm, cn, TEAL, { tok = ttok })
bm:each(function(x, y)
  local a = A.arcY(x, CX, BY, RW + 1, RY)
  if y <= a - 6.3 then A.step(c, tidx, TEAL, x, y, -2, ttok)            -- top edge seam
  elseif (x + 2 * y) % 4 == 0 then A.step(c, tidx, TEAL, x, y, -1, ttok) -- weave
  elseif (x - 2 * y) % 4 == 1 and (tidx[K(x, y)] or 1) >= 3 then A.step(c, tidx, TEAL, x, y, 1, ttok) end
end)

-- flask badge on the band (glass: bright rim, pale core, brew)
A.map(c, {
  "...sSs...",
  "...gpg...",
  "..gRpBg..",
  ".gRBcBBg.",
  "gRBBBBBdg",
  "gBBBBBBdg",
  ".gdddddg.",
}, 27, 38, { s = CORK[3], S = CORK[5], g = "#35295f", R = "#d8f6ff", p = "#b6f0e0", B = "#7cc35a", c = "#e6ffb0", d = "#3f9150" })
c:put(29, 41, A.CREAM)

-- cork stopper on the tip (wood grain, pale end grain)
local ex, ey = 42, 17
local km = c:rrect(ex - 1, ey - 3, ex + 3, ey + 2, 1)
km:cut(cm)
local ktok = { r = { name = "cork" } }
km:each(function(x, y)
  local i = (x <= ex) and 4 or (x == ex + 3 and 2 or 3)
  if y == ey - 3 then i = 5 end
  if y == ey and x > ex - 1 and x < ex + 3 then i = i - 1 end  -- grain line
  c:put(x, y, CORK[i], ktok)
end)
c:put(ex, ey - 3, CORK[6]) c:put(ex + 1, ey - 3, CORK[6])
-- dark seam where cork plugs the tip
for y = ey - 2, ey + 2 do if cm:has(ex - 2, y) then c:put(ex - 2, y, VIO[1], ctok) end end

-- crown glint
c:put(26, 30, VIO[6], ctok) c:put(26, 31, VIO[6], ctok)

-- quirk: bubbles rising from the cork
for _, b in ipairs{ { 46, 11, 1 }, { 49, 8, 0 }, { 44, 7, 0 } } do
  local bx, by, r = b[1], b[2], b[3]
  if r == 1 then
    A.map(c, { ".b.", "bhb", ".b." }, bx - 1, by - 1, { b = "#5fc4c8", h = A.CREAM })
  else c:put(bx, by, "#7cd6c8") end
end
A.save(c, "hat-brewroot")
