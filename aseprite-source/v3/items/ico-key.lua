-- ico-key (pass 3B, final). Slim upright gold key: heart-ring bow (uniform 4 px band, heart-shaped hole),
-- 4 px shaft with a collar + thin ring, rounded tip, slim 3-tooth bit (long / short / long).
-- Realism (hpx.lua): rounded-bevel normals from the distance field, light quantised to 6 gold tones (so the ring
-- reads as a torus: lit outer upper-left, lit inner lower-right), specular streaks on the bow and down the shaft,
-- warm reflected light on lower-right edges, AO under the collar rings and where the string crosses the ring.
-- History: ico-key.p1 (pass 1), ico-key.p2 (previous final).
-- quirk: a little red luggage tag on a twisted cream string, metal grommet, twill weave, gold hem stitch.
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ico-key" }

local GOLD = { "#73361c", "#a2521f", "#d0802a", "#eeab3a", "#ffd15e", "#fff0b4" }
local GSPEC, GRIM = "#fffbea", "#f5964c"
local RED  = { "#5a1a30", "#8a2538", "#b8343f", "#de4d3e", "#f27158", "#ff9a7a" }
local STR  = { "#bfa88c", "#e8d8b8", "#fbf0d2" }
local STEELR = { "#5b5d78", "#9a9cb0", "#dcdee8" }
local cx, Y = 38, -1                                   -- key centre column; global vertical nudge

local function metal(m, R, tok, cuts)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.05, wrap = 0.15 })
  X.tone(c, m, v, GOLD, { cuts = cuts or { 0.2, 0.4, 0.58, 0.74, 0.88 }, tok = tok })
  local rim = X.rim(n)
  m:edge():each(function(x, y) if rim[K(x, y)] > 0.6 then c:put(x, y, GRIM, tok) end end)
  return n
end

-- string: twisted (two tones alternating along it), from the tag grommet up to the bow
local str = c:line({ {17, 38 + Y}, {18, 35 + Y}, {21, 31 + Y}, {25, 28 + Y}, {28, 26 + Y} }, 1)
local stok = { r = { name = "string" } }
str:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and STR[3] or STR[1], stok) end)

-- tag: clipped top corners; twill weave (diagonal), soft pillow light, grommet, hem stitch
local tag = c:poly{ {11,40+Y},{14,37+Y},{20,37+Y},{23,40+Y},{23,53+Y},{11,53+Y} }
local tv = X.light(X.pillow(tag, 1.5), { amb = 0.3, wrap = 0.3 })
local tb = {}
local ttok = { r = { name = "tag" } }
X.tone(c, tag, tv, RED, { cuts = { 0.25, 0.45, 0.62, 0.8, 0.95 }, bias = tb, tok = ttok })
-- twill: diagonal threads a touch darker than whatever tone they sit on (new hard colours, not a full step)
local function darker(hex, f)
  local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  return string.format("#%02x%02x%02x", math.floor(r * f), math.floor(g * f), math.floor(b * f))
end
tag:each(function(x, y) if (x + y) % 3 == 0 and not tag:edge():has(x, y) then c:put(x, y, darker(c:get(x, y), 0.88), ttok) end end)
-- grommet: steel ring, dark hole
for _, p in ipairs{ {16,39},{17,39},{18,39},{19,39},{16,40},{16,41},{19,40},{19,41},{16,42},{17,42},{18,42},{19,42} } do
  local lit = p[2] == 39 or p[1] == 16
  c:put(p[1], p[2] + Y, lit and STEELR[3] or STEELR[1], ttok) end
c:put(16, 39 + Y, STEELR[2], ttok) c:put(19, 42 + Y, STEELR[1], ttok)
c:fillMask(c:rect(17, 40 + Y, 18, 41 + Y), "#3f2430")
c:put(17, 39 + Y, STR[3], ttok)                         -- string through the grommet
c:stitch({ {13, 50 + Y}, {21, 50 + Y} })

-- key shaft + rounded tip + bit
local ktok = { r = { name = "gold" } }
local shaft = c:rect(cx - 2, 30 + Y, cx + 1, 57 + Y):cut(c:rect(cx - 2, 57 + Y, cx - 2, 57 + Y))
local bit = c:rect(cx + 2, 49 + Y, cx + 7, 57 + Y)
bit:cut(c:rect(cx + 4, 51 + Y, cx + 7, 52 + Y)):cut(c:rect(cx + 6, 54 + Y, cx + 7, 55 + Y))
shaft:add(bit)
metal(shaft, 1.5, ktok)
for y = 40, 47 do if y ~= 44 then c:put(cx - 1, y + Y, GOLD[6], ktok) end end        -- streak (broken once)
c:put(cx - 1, 41 + Y, GSPEC, ktok)
-- collar + thin ring, with AO on the shaft under each
local ctok = { r = { name = "collar" } }
metal(c:rrect(cx - 4, 32 + Y, cx + 3, 34 + Y, 1), 1.2, ctok)
metal(c:rect(cx - 3, 37 + Y, cx + 2, 37 + Y), 1, ctok, { 0.1, 0.3, 0.45, 0.6, 0.8 })
for x = cx - 2, cx + 1 do c:put(x, 35 + Y, GOLD[1], ktok) c:put(x, 38 + Y, GOLD[2], ktok) end

-- bow: heart ring
local heart = c:ellipse(cx - 6.5, 15 + Y, 7, 7):add(c:ellipse(cx + 6.5, 15 + Y, 7, 7))
heart:add(c:poly{ {cx - 13.5, 17 + Y}, {cx + 14.5, 17 + Y}, {cx + 0.5, 32 + Y} })
-- clean 1 px nubs on the silhouette (pixel with neither vertical or neither horizontal neighbour)
local nub = HP.mask()
heart:each(function(x, y)
  if (not heart:has(x, y - 1) and not heart:has(x, y + 1)) or (not heart:has(x - 1, y) and not heart:has(x + 1, y)) then nub:set(x, y) end end)
heart:cut(nub)
local bow = heart:copy():cut(heart:shrink(4))
local btok = { r = { name = "bow" } }
metal(bow, 2, btok, { 0.18, 0.38, 0.56, 0.72, 0.86 })
-- specular streak hugging the upper-left lobe + the one sparkle
for _, p in ipairs{ {cx-12,13},{cx-12,12},{cx-11,11},{cx-10,10},{cx-9,10} } do c:put(p[1], p[2] + Y, GOLD[6], btok) end
c:put(cx - 12, 14 + Y, GSPEC, btok)
-- string loops over the ring at the lower-left of the bow: knot + contact shadow on the gold beside it
for _, p in ipairs{ {28,26},{29,25},{29,26},{30,25} } do c:put(p[1], p[2] + Y, STR[2], stok) end
c:put(30, 26 + Y, STR[1], stok)
for _, p in ipairs{ {31,25},{31,26},{30,27} } do if bow:has(p[1], p[2] + Y) then c:put(p[1], p[2] + Y, GOLD[2], btok) end end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "ico-key.aseprite", png = out .. "ico-key.png" }
