-- nav-garden (final pass, Opus). A short stretch of slim picket fence (four pointed pickets on two rails, air
-- between them) with a crumbly soil mound in front and a fresh two-leaf seedling. Wood: per-pixel bevelled
-- planks, vertical grain lines, paler end grain on the cut tips, rail shadow cast onto the pickets, two nail
-- heads per picket. Soil: lumpy pillow with crumbs. Seedling: lit stem, veined leaves with midribs.
-- quirk: a tiny snail is climbing the last picket.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local c = A.new("nav-garden")
local WOOD = { "#4a2a2a", "#6e3f30", "#965a3a", "#b97a4a", "#d9a068", "#f0c690" }
local RAIL = { "#3e2428", "#5e3630", "#864c33", "#a86c44", "#c88e5c", "#e2b07a" }
local SOIL = { "#2e1c22", "#4a2c2c", "#6a3e32", "#8a5638", "#a87048", "#c48c5c" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local tk = function(n) return { r = { name = n } } end

-- rails (behind)
local rails = c:rect(8, 22, 56, 24):add(c:rect(8, 37, 56, 39))
local ridx = A.shade(c, rails, A.slab(rails, 1.4, 0, 0, 1), RAIL, { tok = tk("rail"), amb = 0.1 })
rails:each(function(x, y) if (x * 7 + y) % 9 == 0 then A.step(c, ridx, RAIL, x, y, -1, tk("rail")) end end)

-- pickets
local pick = HP.mask()
local xs = { 11, 22, 33, 44 }
local tops = { 12, 9, 11, 13 }
for i, x in ipairs(xs) do
  local w = 6
  local m = c:poly{ { x, tops[i] + 3 }, { x + 2, tops[i] }, { x + 3, tops[i] }, { x + w - 1, tops[i] + 3 }, { x + w - 1, 49 }, { x, 49 } }
  local bias = {}
  -- rail shadow cast onto picket below each rail? rails are behind: dark where picket meets rails edges
  local idx = A.shade(c, m, A.slab(m, 1.8, 0, 0, 1), WOOD, { tok = tk("pick" .. i), amb = 0.08 })
  -- grain: vertical wavy lines
  m:each(function(x2, y)
    local g = (x2 - x + floor(math.sin(y * 0.35 + i) * 0.9 + 0.5))
    if (g == 2 or g == 4) and X.hash(x2, y, i) > 0.35 and y > tops[i] + 4 then A.step(c, idx, WOOD, x2, y, -1, tk("pick" .. i)) end
  end)
  -- end grain on the cut tip: paler pixels
  for _, p in ipairs{ { x + 1, tops[i] + 2 }, { x + 2, tops[i] + 1 }, { x + 2, tops[i] + 2 } } do if m:has(p[1], p[2]) then c:put(p[1], p[2], WOOD[6], tk("pick" .. i)) end end
  -- nail heads on the rails
  for _, ry in ipairs{ 23, 38 } do c:put(x + 2, ry, "#444663", tk("pick" .. i)) c:put(x + 1, ry - 1, "#aaa9b8", tk("pick" .. i)) end
  -- base ambient
  for xx = x, x + w - 1 do A.step(c, idx, WOOD, xx, 48, -1, tk("pick" .. i)) A.step(c, idx, WOOD, xx, 49, -2, tk("pick" .. i)) end
  pick:add(m)
end
-- rail ambient: darken rail pixels touching pickets (contact shadow to the right of each picket)
rails:each(function(x, y) if not pick:has(x, y) and (pick:has(x - 1, y) or pick:has(x - 2, y)) then A.step(c, ridx, RAIL, x, y, -2, tk("rail")) end end)

-- soil mound
local soil = c:ellipse(32, 50, 17, 5):add(c:ellipse(30, 47, 9, 3))
local sbias = {}
soil:each(function(x, y) if X.hash(x, y, 9) > 0.86 then sbias[K(x, y)] = -1 elseif X.hash(x, y, 4) > 0.9 then sbias[K(x, y)] = 1 end end)
local sidx = A.shade(c, soil, A.body(soil, 31, 49, 15, 3, 0.4), SOIL, { tok = tk("soil"), amb = 0.1, bias = sbias })
-- crumbs beside the mound
c:put(13, 52, SOIL[3], tk("soil")) c:put(51, 51, SOIL[4], tk("soil"))

-- seedling
local stem = A.stem(c, { { 31, 46 }, { 31, 41 }, { 32, 36 }, { 31, 32 } }, function(t) return 1.0 end, LEAF, { tok = tk("stem") })
A.leaf(c, 31, 33, 25, 26, 19, 29, 3.2, LEAF, { tok = tk("leafL"), vs = 2.8 })
A.leaf(c, 32, 32, 37, 24, 44, 25, 3.4, LEAF, { tok = tk("leafR"), vs = 2.8 })
c:put(31, 46, SOIL[1], tk("soil")) c:put(32, 46, SOIL[2], tk("soil"))

-- quirk: snail on picket 4
local SN = { K = "#2b1c26", a = "#ffe38a", b = "#f5b82e", c = "#d98322", d = "#8f4a1f", s = "#c9b2f0", t = "#8a6fd0", u = "#5a459e" }
A.map(c, {
  "..K...",
  ".abb..",
  "abccdK",
  "bcddcs",
  "bcdcds",
  ".dddst",
  "..sstu",
}, 44, 28, SN, tk("snail"))

A.save(c, "nav-garden")
