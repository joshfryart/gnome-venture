-- lemongrass-cordial (final, Opus single pass). A slim glass bottle of pale lemon-green cordial with a lemongrass
-- stalk steeping inside. Glass: cylinder light, bright left rim streak, pale core, cool reflected edge, thick base.
-- Liquid: 6-tone lime ramp, meniscus line, bubbles. Cork with pores, twine twist at the neck, kraft label.
-- quirk: a lemongrass blade is knotted round the neck like a ribbon, its tip flopping over the shoulder.
local NAME = "lemongrass-cordial"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLASS = { "#2c5560", "#4a8590", "#7cb8b6", "#aedcd0", "#d8f2e6", "#f4fff2" }
local LIQ   = { "#4c6420", "#77942a", "#a6c03a", "#cfdc58", "#ecef88", "#fbfbc4" }
local STALK = { "#6f8a3a", "#9cb65a", "#c6d98a", "#e4ecb4" }
local CORK  = { "#56361f", "#7c5232", "#a87849", "#c99a62", "#e2bd84", "#f4dcaa" }
local TW    = { "#6e4a26", "#a8783c", "#d8ad62", "#f2d48e" }
local LEAF  = { "#1d4a3a", "#2a6a44", "#3f8c4c", "#62ad55", "#92ca68", "#c4e38c" }
local PAPER = { "#a68a5c", "#cdb486", "#e9d9ac", "#fbf0cf" }

c:groundShadow(32, 56, 12, 1)

-- bottle profile along a vertical axis: lip, neck, shoulder, body, rounded heel
local Y0, Y1 = 12, 55
local function wfn(t)
  local y = Y0 + (Y1 - Y0) * t
  if y < 14 then return 3.6 end
  if y < 22 then return 2.7 end
  if y < 30 then local u = (y - 22) / 8 u = u * u * (3 - 2 * u) return 2.7 + 6.1 * u end
  if y > 53.5 then return 8.8 - (y - 53.5) * 1.1 end
  return 8.8
end
local bm, bn, BT, BS = X.cyl(32, Y0, 32, Y1, wfn)
-- shoulder faces up a little (catches light)
bm:each(function(x, y) local k = K(x, y)
  if y >= 22 and y < 30 then local q = bn[k] bn[k] = { A.norm(q[1], q[2] - 0.55, q[3]) } end
  if y >= 54 then local q = bn[k] bn[k] = { A.norm(q[1], q[2] + 0.5, q[3]) } end end)
local v = X.light(bn, { amb = 0.18, wrap = 0.35 })
local FILL = 31
local liq = HP.mask() local air = HP.mask()
bm:each(function(x, y) if y >= FILL and y <= 53 and abs(BS[K(x, y)]) < 0.86 then liq:set(x, y) else air:set(x, y) end end)
local gtok, ltok = { r = { name = "glass" } }, { r = { name = "liq" } }
-- glass shell: pale core, darker toward the silhouette (thicker glass seen edge-on)
local gidx = {}
air:each(function(x, y) local k = K(x, y)
  local s = BS[k]
  local i = floor(v[k] * 4) + 2
  if abs(s) > 0.8 then i = i - 2 end
  if y >= 54 then i = i - 1 end
  gidx[k] = max(1, min(6, i)) c:put(x, y, GLASS[gidx[k]], gtok) end)
-- liquid: lit core, deeper at the walls and toward the base
local lidx = {}
liq:each(function(x, y) local k = K(x, y)
  local s = BS[k]
  local i = floor(v[k] * 5.2) + 1
  if abs(s) > 0.66 then i = i - 1 end
  if y > 49 then i = i - 1 end
  lidx[k] = max(1, min(6, i)) c:put(x, y, LIQ[lidx[k]], ltok) end)
-- stalk steeping inside (seen through liquid, then glass above the fill line)
local sm = A.HP.line({ {28, 52}, {31, 40}, {34, 27}, {35, 22} }, 2)
sm:each(function(x, y) if bm:has(x, y) and abs(BS[K(x, y)]) < 0.7 then
  local inL = liq:has(x, y)
  local lft = not sm:has(x - 1, y)
  local col = inL and (lft and STALK[3] or STALK[1]) or (lft and STALK[4] or STALK[2])
  c:put(x, y, col, inL and ltok or gtok) end end)
-- stalk rings (nodes)
for _, p in ipairs{ {30, 45}, {32, 36} } do c:put(p[1], p[2], STALK[1], ltok) c:put(p[1] + 1, p[2], STALK[1], ltok) end
-- meniscus: bright line, darker row just under
for x = 24, 40 do if liq:has(x, FILL) then c:put(x, FILL, (x < 30) and LIQ[6] or LIQ[5], ltok) end
  if liq:has(x, FILL + 1) and not sm:has(x, FILL + 1) then c:put(x, FILL + 1, LIQ[max(1, (lidx[K(x, FILL + 1)] or 3) - 1)], ltok) end end
-- bubbles (glossy)
for _, p in ipairs{ {35, 47}, {37, 42}, {34, 38}, {36, 34} } do c:put(p[1], p[2], LIQ[6], ltok) c:put(p[1] + 1, p[2] + 1, LIQ[3], ltok) end
-- glass specular streak (left), short reflected cool streak (right), thick base glass
bm:each(function(x, y) local k = K(x, y) local s = BS[k]
  if s > -0.66 and s < -0.46 and y > 15 and y < 52 and (y < 39 or y > 48) then c:put(x, y, (y > 24 and y < 36) and A.CREAM or GLASS[6], gtok)
  elseif s > 0.62 and s < 0.8 and y > 33 and y < 50 then c:put(x, y, "#9ad4cc", gtok) end end)
for x = 25, 39 do c:put(x, 53, x < 31 and GLASS[4] or GLASS[3], gtok) end
for x = 27, 37 do c:put(x, 54, GLASS[2], gtok) end
-- lip ring bevel
for x = 29, 35 do c:put(x, 12, x < 32 and GLASS[6] or GLASS[4], gtok) c:put(x, 14, GLASS[2], gtok) end

-- kraft label with a tiny lemongrass mark
local lab = c:rect(26, 40, 37, 48)
local ptok = { r = { name = "paper" } }
lab:each(function(x, y) local i = 3
  if x >= 36 or y >= 48 then i = 2 end
  if x == 26 or y == 40 then i = 4 end
  if x == 37 then i = 1 end
  c:put(x, y, PAPER[i], ptok) end)
c:put(26, 48, PAPER[2], ptok)
A.map(c, {
  "....g...",
  "..g.g.g.",
  "..g.g.g.",
  "...gg.g.",
  "....gg..",
  "....s...",
}, 28, 41, { g = LEAF[3], s = TW[2] }, ptok)
for x = 28, 35 do if x % 2 == 0 then c:put(x, 47, PAPER[1], ptok) end end

-- cork with pores and a domed top
local cork = c:rrect(29, 7, 35, 11, 1)
local cn = X.pillow(cork, 2.5)
local ctok = { r = { name = "cork" } }
local cidx = A.shade(c, cork, cn, CORK, { amb = 0.15, wrap = 0.3, tok = ctok })
cork:each(function(x, y) local h = X.hash(x, y, 7)
  if h < 0.18 then c:put(x, y, CORK[max(1, (cidx[K(x, y)] or 3) - 2)], ctok) elseif h > 0.92 then c:put(x, y, CORK[min(6, (cidx[K(x, y)] or 3) + 1)], ctok) end end)
for x = 30, 34 do c:put(x, 11, CORK[1], ctok) end           -- AO where cork meets glass

-- twine wrap at the neck (twist)
local ttok = { r = { name = "twine" } }
for y = 17, 19 do for x = 28, 36 do if bm:has(x, y) or x == 28 or x == 36 then
  local i = ((x + y) % 3 == 0) and 1 or ((x < 31) and 4 or 3)
  if x >= 35 then i = max(1, i - 1) end
  c:put(x, y, TW[i], ttok) end end end
for x = 29, 35 do c:put(x, 20, GLASS[1], gtok) end          -- shadow under the wrap

-- quirk: lemongrass blade knotted at the neck, tip flopping out over the shoulder
local ktok = { r = { name = "knot" } }
local kn = c:ellipse(37.5, 18, 1.6, 1.6)
A.shade(c, kn, X.sphere(37, 17.5, 2, kn), LEAF, { tok = ktok })
A.grass(c, 38, 19, 45, 18, 46, 30, 1.7, LEAF, { tok = ktok, cut = kn })
A.grass(c, 37, 16, 41, 11, 45, 10, 1.3, LEAF, { tok = ktok, cut = kn })
A.save(c, NAME)
