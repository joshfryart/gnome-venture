-- crop-tree (final, Opus single pass). A slim long-necked pear hanging from a short twig cut from the tree,
-- two glossy leaves on the twig.
-- Material: per-pixel pillow/sphere light (6-tone green-gold, cool-violet shade), warm blush ramp on the sunny
-- shoulder, russet lenticel freckles, one cream specular, cool reflected light lower-right, AO under the stalk.
-- Twig: bark grain lines, a paler end-grain disc on the cut end with a dark pith dot, a bud at the tip,
-- contact shadow where the stalk meets it. Leaves: midrib + veins.
-- quirk: a single dewdrop is sliding down the pear's belly, leaving a little wet trail.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs
local c = A.new("crop-tree")
local PEAR  = { "#3e4a26", "#66762c", "#93a335", "#bcc63f", "#dcde5c", "#f4f09a" }
local BLUSH = { "#4e3e26", "#7e6630", "#b0843a", "#d4a046", "#ecc060", "#f9e096" }
local LEAF  = { "#1b3c38", "#235743", "#2f7548", "#45944c", "#6ab455", "#9dd06c" }
local BARK  = { "#2f2026", "#4c3230", "#6e4a3a", "#93684a", "#b48a5e" }
local ENDG  = { "#b98e5c", "#dcb47c", "#f0d29a" }
local STEM  = { "#3a2622", "#5e3d2c", "#86603e", "#b08752" }
local SPEC, BOUNCE = "#fff4d6", "#7a8aa8"
local WATER = { "#3a86b0", "#8fd6e0", "#d9f6f2", "#fff4d6" }

-- twig: slight arc left->right, cut end on the left, bud on the right
local TOK = { r = { name = "bark" } }
local tw, tn, TT, TS = A.stem(c, { {14, 15}, {24, 11}, {38, 10}, {50, 13} }, function(t) return 2.2 - 0.9 * t end, BARK, { tok = TOK, cuts = { 0.22, 0.42, 0.62, 0.82 } })
-- bark grain: broken lines along the twig
tw:each(function(x, y) local k = K(x, y)
  local s, t = TS[k], TT[k]
  if abs(s) > 0.15 and abs(s) < 0.7 and ((t * 46 + s * 3) % 7) < 3.2 and X.hash(x, y, 5) > 0.25 then
    local cur = c:get(x, y)
    for i, h in ipairs(BARK) do if h == cur then c:put(x, y, BARK[max(1, i - 1)], TOK) break end end
  end
end)
-- end grain disc on the cut end
local eg = c:ellipse(13.5, 15.2, 1.2, 2)
c:fillMask(eg, ENDG[2])
c:put(13, 14, ENDG[3]) c:put(13, 13, ENDG[3]) c:put(14, 16, ENDG[1]) c:put(14, 15, ENDG[1]) c:put(13, 15, BARK[2])
-- bud on the tip
local bud = c:ellipse(51.5, 13, 1.4, 1.4)
c:fillMask(bud, BARK[4]) c:put(51, 12, BARK[5]) c:put(52, 14, BARK[2]) c:put(53, 13, BARK[2])

-- leaves hanging off the twig
A.leaf(c, 40, 12, 48, 14, 52, 24, 3.8, LEAF, { vs = 3 })
A.leaf(c, 21, 11, 16, 6, 11, 7, 3.0, LEAF, { vs = 3 })

-- stalk from twig to pear
local sm = A.stem(c, { {30, 12}, {30, 15}, {31, 18}, {31.5, 21} }, function(t) return 1.0 + 0.2 * t end, STEM)
c:put(31, 12, BARK[1], TOK) c:put(29, 13, BARK[1], TOK)          -- contact shadow on the twig

-- pear body: neck + waist + bulb, closed to smooth the waist
local m = c:ellipse(31, 28, 4.6, 7.5):add(c:ellipse(31.5, 37, 7.5, 7)):add(c:ellipse(32.5, 44.5, 9.5, 8.5))
m = m:grow(2):shrink(2)
local n = A.body(m, 31, 38, 15, 5, 0.5)
local bias = {}
X.ao(bias, m, c:rect(30, 19, 33, 20), 2, -1)
local tok = { r = { name = "pear" } }
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local idx = X.tone(c, m, v, PEAR, { cuts = { 0.18, 0.34, 0.52, 0.7, 0.86 }, bias = bias, tok = tok })
-- blush on the sunny side: smooth region upper-left of the bulb
m:each(function(x, y) local k = K(x, y)
  local d = ((x - 27) / 5)^2 + ((y - 39) / 6.5)^2 + (X.hash(x, y, 9) - 0.5) * 0.2
  if d < 1 and idx[k] >= 4 then c:put(x, y, BLUSH[idx[k]], tok) end
end)
-- russet freckles: small dark dots, more on the shade side
m:copy():shrink(2):each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 31)
  if h > 0.94 and (x + y) % 2 == 0 then
    local ramp = (c:get(x, y) == BLUSH[idx[k]]) and BLUSH or PEAR
    c:put(x, y, ramp[max(1, idx[k] - 2)], tok)
  end
end)
-- reflected light lower-right
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y > 42 and x > 33 then c:put(x, y, BOUNCE, tok) end end)
-- calyx: tiny dark star at the bottom
for _, p in ipairs{ {32, 53}, {33, 53}, {32, 52} } do if m:has(p[1], p[2]) then c:put(p[1], p[2], PEAR[1], tok) end end
-- specular
c:put(25, 40, SPEC, tok) c:put(25, 41, SPEC, tok) c:put(26, 39, BLUSH[6], tok) c:put(28, 25, PEAR[6], tok) c:put(28, 26, PEAR[6], tok)
-- stalk sinks into the neck
c:put(31, 20, PEAR[1], tok) c:put(32, 20, PEAR[2], tok)

-- quirk: dewdrop + wet trail on the belly (glass: bright rim, pale core, dark lower edge)
for _, p in ipairs{ {37, 36}, {37, 37}, {38, 38}, {38, 39} } do
  local k = K(p[1], p[2]) c:put(p[1], p[2], PEAR[min(6, (idx[k] or 3) + 1)], tok) end
A.map(c, {
  ".ab.",
  "acbb",
  "bccb",
  "dbbd",
  ".dd.",
}, 37, 40, { a = WATER[4], b = WATER[2], c = WATER[3], d = WATER[1] })
A.save(c, "crop-tree")
